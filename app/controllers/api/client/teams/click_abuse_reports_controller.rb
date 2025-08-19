class Api::Client::Teams::ClickAbuseReportsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @click_abuse_reports = paginate(query_index)
    respond_with_pagination @click_abuse_reports
  end

  def block
    if params[:column].present?
      @click_abuse_report.send("block_by_#{params[:column]}")
      head :ok
    else
      head :bad_request
    end
  end

  def summary
    @summary = ClickAbuseReport::AGGREGATE_COLUMNS.index_with do |column|
      records = ClickAbuseReport.top_aggregations(column)
      if column == :token
        records = map_tokens(records)
        records = map_captured(records)
      end

      records
    end

    respond_with @summary
  end

  private

  def query_index
    ClickAbuseReportCollection.new(current_ability, params).collect
  end

  def map_tokens(records)
    records = records.map do |record|
      parsed = DotOne::Track::Token.new(record[:value])
      offer_id = OfferVariant.cached_find(parsed.offer_variant_id).offer_id

      record.merge(
        affiliate_id: parsed.affiliate_id,
        offer_variant_id: parsed.offer_variant_id,
        affiliate_offer_id: parsed.affiliate_offer_id,
        offer_id: offer_id,
      )
    end
  end

  def map_captured(records)
    affiliate_ids, offer_ids = records.reduce([[], []]) do |collection, record|
      [
        collection[0].concat([record[:affiliate_id]]),
        collection[1].concat([record[:offer_id]]),
      ]
    end

    date_range = current_time_zone.local_range(:last_6_months)
    captured = AffiliateStatCapturedAt
      .accessible_by(current_ability)
      .with_offers(offer_ids.uniq.compact_blank)
      .with_affiliates(affiliate_ids.uniq.compact_blank)
      .between(*date_range, :captured_at, current_time_zone)
      .group(:affiliate_id, :offer_id)
      .count

    records.map do |records|
      records.merge(
        captured: captured[[records[:affiliate_id], records[:offer_id]]] || 0
      )
    end
  end
end
