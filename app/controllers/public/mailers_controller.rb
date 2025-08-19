class Public::MailersController < Public::BaseController
  def contact
    SkinMailer.contact_us(contact_params).deliver_later

    head :ok
  end

  private

  def contact_params
    params
      .permit(:name, :email, :phone, :message, :domain)
      .merge(
        submitted_at: Time.now,
        to: DotOne::Setup.contact_emails,
        from: BaseMailer::SUPPORT_EMAIL,
      )
  end

  def require_params
    [:name, :email, :phone, :message, :domain].each do |key|
      params.require(key)
    end
  end
end
