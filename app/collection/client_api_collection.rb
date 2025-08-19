# frozen_string_literal: true

class ClientApiCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_owned_by if params[:owner_type].present? && params[:owner_id].present?
    filter_by_statuses if params[:statuses].present?
    filter_by_api_types if params[:api_types].present? || params[:api_type].present?
  end

  def filter_by_owned_by
    filter { @relation.owned_by(params[:owner_type], params[:owner_id]) }
  end

  def filter_by_statuses
    filter { @relation.with_statuses(params[:statuses]) }
  end

  def filter_by_api_types
    filter { @relation.with_api_types(params[:api_types].presence || params[:api_type].presence) }
  end
end
