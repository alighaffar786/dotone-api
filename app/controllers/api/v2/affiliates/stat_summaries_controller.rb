class Api::V2::Affiliates::StatSummariesController < Api::V2::Affiliates::BaseController
  include Api::StatSummaryHelper

  before_action :validate_stat_start_date

  def stat_summary_klass
    DotOne::Reports::Affiliates::StatSummary
  end

  def index
    authorize! :read, Stat
    @stats, @total = query_stat_summary
    @stats = array_paginate(@stats)
    respond_with_pagination @stats, **instance_options, meta: { total: @total }
  end

  private

  def instance_options
    super.merge(each_serializer: V2::Affiliates::StatSummarySerializer)
  end

  def dimensions
    DotOne::Reports::Affiliates::StatSummary.dimensions.map do |dimension|
      dimension.to_s.pluralize
    end
  end

  def report_params
    params
      .permit(*dimensions, :start_date, :end_date, :time_zone, :period, :date_type)
      .tap do |param|
        dimensions.each do |key|
          param[key.singularize] = param.delete(key).to_s.split(',')
        end
        param[:start_date] ||= Date.today
        param[:end_date] ||= Date.today
      end
      .merge(super)
  end
end
