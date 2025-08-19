class Base::AffiliateStatSerializer < ApplicationSerializer
  forexable_attributes(*AffiliateStat.forexable_attributes)
  local_time_attributes(*AffiliateStat.local_time_attributes)
  maskable_address_attributes(*AffiliateStat.maskable_address_attributes)

  conditional_attributes :captured_count, :published_count, :converted_count, if: :include_counts?

  def transaction_id
    object.original_id
  end

  def id
    transaction_id
  end

  def copy_stat_id
    object.id
  end

  def country
    countries ? countries[object.ip_country.to_s.downcase] : object.country
  end

  def captured_count
    conversion_counts[object.id].try(:[], :captured_at).to_i
  end

  def published_count
    conversion_counts[object.id].try(:[], :published_at).to_i
  end

  def converted_count
    conversion_counts[object.id].try(:[], :converted_at).to_i
  end

  def approvals
    return [] unless approvals_from_orders

    approvals_from_orders[object.id].to_a
  end

  def include_counts?
    instance_options[:conversion_counts].present?
  end

  def step_label
    if conversion_steps
      conversion_steps[object.offer_id].try(:[], object.step_name)&.t_label || object.step_label
    else
      object.step_label
    end
  end

  def single_point?
    object.offer&.single?
  end

  def multi_point?
    object.offer&.multi?
  end

  def order_real_total
    object.copy_order&.real_total || object.real_total
  end

  def order_total
    affiliate? ? object.forex_order_total_for_affiliate : object.forex_order_total
  end

  private

  def countries
    instance_options[:countries]
  end

  def conversion_steps
    instance_options[:conversion_steps]
  end

  def conversion_counts
    instance_options[:conversion_counts] || {}
  end

  def approvals_from_orders
    instance_options[:approvals_from_orders]
  end
end
