class Api::Client::Teams::NewslettersController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @newsletters = paginate(query_index)
    respond_with_pagination @newsletters
  end

  def create
    if @newsletter.save
      respond_with @newsletter
    else
      respond_with @newsletter, status: :unprocessable_entity
    end
  end

  def update
    if @newsletter.update(newsletter_params)
      respond_with @newsletter
    else
      respond_with @newsletter, status: :unprocessable_entity
    end
  end

  def destroy
    if @newsletter.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def deliver
    if @newsletter.deliver
      respond_with @newsletter
    else
      respond_with @newsletter, status: :unprocessable_entity
    end
  end

  def recipients
    @recipient_list = paginate(@newsletter.recipient_list)
    respond_with_pagination @recipient_list, each_serializer: Teams::Newsletter::RecipientSerializer
  end

  def preview
    recipient = DotOne::Setup.send("test_#{@newsletter.recipient_type}")
    mailer = NewsletterMailer.email_message(@newsletter, recipient)

    if mailer.html_part.present? && mailer.text_part.present?
      respond_with({
        id: @newsletter.id,
        html: mailer.html_part.body.raw_source,
        text: mailer.text_part.body.raw_source
      })
    else
      head 422
    end
  end

  private

  def query_index
    NewsletterCollection.new(current_ability, params)
      .collect
      .preload(:email_template, offer: :name_translations)
  end

  def newsletter_params
    params
      .require(:newsletter)
      .permit(
        :sender_id, :sender, :role, :offer_id, :recipient, recipient_ids: [],
        email_template_attributes: [:id, :subject, :content, :footer],
      )
  end
end
