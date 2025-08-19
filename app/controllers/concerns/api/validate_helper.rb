module Api::ValidateHelper
  def validate_stat_start_date
    return unless params[:start_date].present?

    min_allowed_date = current_time_zone.from_utc(Stat.date_limit.to_s).to_date
    params[:start_date] = params[:start_date] && params[:start_date].to_date < min_allowed_date ? min_allowed_date.to_s : params[:start_date]
  end
end
