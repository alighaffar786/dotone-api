class ApiKeyCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_api_keys
    filter_by_owners if params[:owner_type].present? && params[:owner_ids].present?
    filter_by_statuses if params[:statuses].present?
  end

  def filter_by_api_keys
    filter { @relation.api_keys }
  end

  def filter_by_owners
    filter do
      if affiliate_user?
        @relation.owned_by(params[:owner_type], params[:owner_ids])
      else
        @relation
      end
    end
  end

  def filter_by_statuses
    filter { @relation.with_statuses(params[:statuses]) }
  end
end
