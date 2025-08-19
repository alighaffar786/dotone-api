class EmailTemplateCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_email_types if params[:email_types].present?
    filter_by_owner_types if params[:owner_types].present?
  end

  def filter_by_email_types
    filter { @relation.where(email_type: params[:email_types]) }
  end

  def filter_by_owner_types
    filter { @relation.where(owner_type: params[:owner_types] == 'System' ? nil : params[:owner_types]) }
  end
  
  def filter_by_search
    filter do
      @relation.like(params[:search])
    end
  end
end
