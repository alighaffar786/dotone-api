class Api::Client::Teams::Reports::AffiliatesController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def inactive
    authorize! :read_inactive, Affiliate
    @affiliates = paginate(query_inactive)
    respond_with_pagination @affiliates, each_serializer: Teams::Affiliate::InactiveSerializer
  end

  def download_inactive
    @download = build_download(query_inactive, Affiliate.download_inactive_columns)
    @download.name = if params[:report_type] == 'inactive_capture'
      'Affiliates without Captured'
    else
      'Affiliates not Logged In'
    end

    authorize! :create, @download
    authorize! :download, Affiliate

    if @download.save
      start_download_job(@download)
      respond_with @download
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  def performance
    authorize! :read_performance, Affiliate
    @stats = paginate(query_performance)
    respond_with_pagination @stats, each_serializer: Teams::Stat::AffiliatePerformanceSerializer
  end

  def download_performance
    @download = Download.new(
      file_type: Stat.download_file_type,
      name: 'Affiliate Performance',
      notes: Stat.generate_download_notes(params),
      headers: Stat.generate_download_performance_headers,
      exec_sql: query_performance.to_sql,
      owner: current_user,
      downloaded_by: current_user&.name_with_role,
      download_format: current_download_format,
    )

    authorize! :create, @download
    authorize! :download, Affiliate

    if @download.save
      start_download_job(@download)
      respond_with @download
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  private

  def query_inactive
    report = DotOne::Reports::AffiliateUsers::ClaimableAffiliateBalance.new(current_ability)

    @affiliates = if params[:report_type] == 'inactive_capture'
      report.query_inactive_capture_affiliates
    else
      report.query_inactive_affiliates
    end

    AffiliateCollection.new(@affiliates, params).collect
  end

  def query_performance
    Stat
      .select(
        :affiliate_id,
        "#{Stat.clicks_sql} as clicks",
        "#{Stat.captured_sql} as captured",
      )
      .between(*date_range, :captured_at, current_time_zone)
      .or(Stat.between(*date_range, :recorded_at, current_time_zone))
      .with_networks(params[:network_ids])
      .with_offers(params[:offer_ids])
      .with_affiliates(params[:affiliate_ids])
      .where('affiliate_id IS NOT NULL AND affiliate_id > 0')
      .group(:affiliate_id)
      .preload(affiliate: :site_infos)
  end

  def date_range
    @date_range ||= [params[:start_date], params[:end_date]].map { |d| d || Date.today }
  end
end
