class AffiliateLogCollection < BaseCollection
  def ensure_filters
    super
    filter_by_date if params[:start_date].present? && params[:end_date].present?
    filter_by_agent_type if params[:agent_types].present?
    filter_by_agent_ids if params[:agent_ids].present?
    filter_by_contact_medias if params[:contact_medias].present?
    filter_by_contact_stages if params[:contact_stages].present?
    filter_by_owner_types if params[:owner_types].present?
  end

  def filter_by_date
    filter do
      @relation.between(params[:start_date], params[:end_date], :created_at, time_zone, any: true)
    end
  end

  def filter_by_agent_type
    filter { @relation.with_agent_types(params[:agent_types]) }
  end

  def filter_by_agent_ids
    filter { @relation.where(agent_id: params[:agent_ids]) }
  end

  def filter_by_contact_medias
    filter { @relation.with_contact_media(params[:contact_medias]) }
  end

  def filter_by_contact_stages
    filter { @relation.with_contact_stages(params[:contact_stages]) }
  end

  def filter_by_owner_types
    filter { @relation.where(owner_type: params[:owner_types]) }
  end
end
