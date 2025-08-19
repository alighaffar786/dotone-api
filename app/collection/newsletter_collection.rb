class NewsletterCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_statuses if params[:statuses].present?
    filter_by_roles if params[:roles].present?
  end

  def filter_by_statuses
    filter { @relation.with_statuses(params[:statuses]) }
  end

  def filter_by_roles
    filter { @relation.with_roles(params[:roles]) }
  end

  def filter_by_search
    filter do
      @relation
        .joins(:email_template)
        .where('offer_list LIKE :q OR email_templates.subject LIKE :q OR email_templates.content LIKE :q', q: "%#{params[:search]}%")
    end
  end

  def default_sorted
    sort { @relation.order(created_at: :desc) }
  end
end
