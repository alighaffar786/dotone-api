# frozen_string_literal: true

class DotOne::Reports::ImageCreativeDownloadStat
  attr_accessor :image_creative_ids, :date_range

  def initialize(params = {})
    @image_creative_ids = params[:image_creative_ids]
    @start_at = Date.parse(params[:start_at]) rescue 29.days.ago.utc.to_date
    @end_at = Date.parse(params[:end_at]) rescue Time.now.utc.to_date
    @date_range = @start_at..@end_at
  end

  def query_stats
    ImageCreativeStat
      .select('image_creative_id, date, SUM(ui_download_count) AS total_downloads')
      .where(image_creative_id: image_creative_ids)
      .where(date: date_range)
      .group(:date, :image_creative_id)
  end

  def generate(view_count_only: false)
    detail_view_stats = {}

    query_stats
      .group_by(&:image_creative_id)
      .each_pair do |image_creative_id, stats|
        detail_view_stats[image_creative_id] = stats
          .group_by(&:date)
          .map { |date, stats| [date, stats.sum(&:total_downloads)] }
          .to_h
      end

    result = format_detail_view_stats(detail_view_stats)

    return result unless view_count_only

    result.transform_values { |x| x.values }
  end

  def format_detail_view_stats(detail_view_stats)
    initial = date_range.to_a.map { |date| [date, 0] }.to_h

    detail_view_stats.map do |image_creative_id, detail_view_stat|
      [image_creative_id, initial.merge(detail_view_stat)]
    end
      .to_h
  end
end
