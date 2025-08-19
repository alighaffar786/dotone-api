class Api::Client::Teams::PostbacksController < Api::Client::Teams::BaseController
  load_resource only: [:repost, :reflect_time]

  def index
    if params[:affiliate_stat_id].present?
      affiliate_stat = AffiliateStat.clicks.find_by_id(params[:affiliate_stat_id])
      authorize! :read, affiliate_stat

      if affiliate_stat.present?
        respond_with_postbacks
      else
        head :not_found
      end
    elsif params[:order_id].present?
      authorize! :read, Postback
      order = Order.find_by(id: params[:order_id])

      if order.present?
        params.merge!(
          affiliate_stat_id: order.affiliate_stat_id,
          start_date: order.recorded_at.beginning_of_day - 1.month,
          end_date: order.recorded_at.end_of_day + 1.day,
        )

        @postbacks = query_index.incoming
        @postbacks = @postbacks.query_by_order_number(order.order_number) unless order.auto_number?

        @postbacks = @postbacks.select do |postback|
          postback.order_number == order.order_number || postback.order_number.blank? && order.auto_number? && postback.order&.order_number == order.order_number
        end

        @postbacks = array_paginate(@postbacks)
        respond_with_pagination @postbacks
      else
        head :not_found
      end
    elsif truthy?(params[:missing_order])
      authorize! :read, Postback

      @postbacks = query_index.incoming

      affiliate_stat_ids = @postbacks.map(&:affiliate_stat_id).uniq.select { |id| AffiliateStat.valid_id?(id) }
      order_numbers = @postbacks.map(&:order_number).compact_blank
      orders = Order.where(order_number: order_numbers).to_h { |order| [order.order_number, order.affiliate_stat_id] }
      affiliate_stat_ids -= orders.values
      single_order_ids = AffiliateStat.clicks.conversions.where(id: affiliate_stat_ids).pluck(:id)

      @postbacks = @postbacks.reject do |postback|
        orders[postback.order_number] == postback.affiliate_stat_id || single_order_ids.include?(postback.affiliate_stat_id)
      end
      @postbacks = array_paginate(@postbacks)

      respond_with_pagination @postbacks
    else
      authorize! :read, Postback
      respond_with_postbacks(true)
    end
  end

  def repost
    authorize! :update, @postback
    Postbacks::BulkRepostJob.perform_later(@postback.id)
    head :ok
  end

  def reflect_time
    authorize! :update, @postback
    @postback.reflect_time!
    respond_with @postback
  end

  def bulk_repost
    authorize! :update, Postback
    @postbacks = query_bulk
    Postbacks::BulkRepostJob.perform_later(@postbacks.pluck(:id))
    head :ok
  end

  def bulk_reflect_time
    authorize! :update, Postback
    @postbacks = query_bulk
    Postbacks::BulkReflectTimeJob.perform_later(@postbacks.pluck(:id))
    head :ok
  end

  private

  def respond_with_postbacks(full = false)
    @postbacks = paginate(query_index)
    respond_with_pagination @postbacks, **(full ? instance_options : {})
  end

  def query_index
    PostbackCollection.new(current_ability, params, **current_options).collect.preload(:conversion_stat)
  end

  def query_bulk
    Postback.accessible_by(current_ability).where(id: params[:ids])
  end

  def instance_options
    incoming_postbacks = @postbacks.select { |postback| postback.incoming? }
    order_postbacks = incoming_postbacks.select { |postback| postback.order_number.present? }
    auto_order_postbacks = incoming_postbacks.reject { |postback| postback.order_number.present? }

    affiliate_stat_ids = incoming_postbacks.map(&:affiliate_stat_id).select { |id| AffiliateStat.valid_id?(id) }
    new_stats = AffiliateStat.clicks.where(subid_1: affiliate_stat_ids).select(:id, :subid_1).index_by(&:subid_1)
    affiliate_stat_ids |= new_stats.values.map(&:id)

    order_numbers = order_postbacks.map(&:order_number)
    auto_order_numbers = auto_order_postbacks.map do |postback|
      postback.order_number = postback.order&.order_number
      postback.order_number
    end
    .compact_blank
    order_numbers |= auto_order_numbers

    orders = Order
      .select(:id, :affiliate_stat_id, :order_number)
      .where(affiliate_stat_id: affiliate_stat_ids, order_number: order_numbers)
      .group_by(&:affiliate_stat_id)

    { orders: orders, new_stats: new_stats }
  end
end
