class Api::Client::Teams::EmailTemplatesController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @email_templates = paginate(query_index)
    respond_with_pagination @email_templates, meta: { t_columns: EmailTemplate.dynamic_translatable_attribute_types }
  end

  def types
    respond_with EmailTemplate.email_types
  end

  def update
    if @email_template.update(email_template_params)
      respond_with @email_template
    else
      respond_with @email_template, status: :unprocessable_entity
    end
  end

  private

  def query_index
    EmailTemplateCollection.new(current_ability, params)
      .collect
      .where(email_type: EmailTemplate.email_types)
      .order(email_type: :asc)
      .preload_translations(:subject, :content, :footer)
  end

  def email_template_params
    params.require(:email_template).permit(
      :subject, :content, :footer, :recipient, :sender, :status, translations_attributes: [:id, :locale, :field, :content]
    )
  end
end
