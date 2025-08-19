class AffiliateUserCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_statuses if params[:statuses].present?
    filter_by_roles if params[:roles].present?
    filter_others if affiliate_user? && params[:other]
  end

  def filter_by_statuses
    filter { @relation.with_statuses(params[:statuses]) }
  end

  def filter_by_roles
    filter { @relation.with_roles(params[:roles]) }
  end

  def filter_others
    filter { @relation.where.not(id: user&.id)}
  end
end
