class Api::Client::Advertisers::RegistrationsController < Api::Client::Advertisers::BaseController
  def register
    authorize! :signup, Network
    @network = Network.new(registration_params)

    if captcha_verified? && @network.save
      send_notification
      handle_any_conversion
      respond_with @network
    else
      respond_with @network, status: :unprocessable_entity
    end
  end

  private

  def send_notification
    AdvertiserMailer.status_pending(@network).deliver_later
  end

  def registration_params
    params.require(:registration).permit(
      :contact_name, :name, :contact_email, :contact_phone, :country_id, :locale,
      :client_notes, :channel_id, :company_url, brands: [], category_group_ids: []
    )
  end

  def captcha_verified?
    verify_recaptcha(
      model: @network,
      action: 'advertiser/register',
      minimum_score: ENV.fetch('RECAPTCHA_MINIMUM_SCORE', 0.5).to_f,
      response: params[:g_recaptcha_response],
    )
  end

  ##
  # Helper to record conversion. If conversion
  # approval is manual, then this method will
  # set the conversion to pending
  def handle_any_conversion
    return unless params[:campaign_target] == 'advertiser'
    return unless stat_id = params[:subid] || params[:vtm_stat_id]
    return unless affiliate_stat = AffiliateStat.find_by_id(stat_id)

    affiliate_stat.process_conversion!(
      adv_uniq_id: ['adv', @network.id].join('-'),
      real_time: true,
    )
  end
end
