# frozen_string_literal: true

module DotOne::Reports::Dashboard
  class Exposure < Base
    def generate
      super do
        {
          active_offers: offers_exposure,
          active_landing_pages: offer_variants_exposure,
          active_banners: image_creatives_exposure,
          active_promo_and_deals: text_creatives_exposure,
          active_affiliates: affiliate_offers_exposure,
        }
      end
    end

    def offers_exposure
      generate_exposure(active_offers, date_column: :published_date_local)
    end

    def offer_variants_exposure
      generate_exposure(active_offer_variants)
    end

    def image_creatives_exposure
      generate_exposure(active_image_creatives)
    end

    def text_creatives_exposure
      generate_exposure(active_text_creatives)
    end

    def affiliate_offers_exposure
      generate_exposure(active_affiliate_offers)
    end

    private

    def generate_exposure(items, date_column: :created_at)
      return {} unless items.any?

      date = items.first&.send(date_column)

      {
        total: items.count,
        last_updated: to_time_ago(date, to_date: true),
        last_updated_at: date&.to_s(:db),
      }
    end

    def active_offers
      offers
        .joins(:default_offer_variant)
        .active
        .recently_published
    end

    def active_offer_variants
      OfferVariant.active
        .where(offer_id: offers.select(:id))
        .recently_updated
    end

    def active_image_creatives
      ImageCreative.joins(:offer_variants)
        .where(offer_variants: { offer_id: active_offers.select(:id) })
        .active
        .publicly
        .publishable
        .order_by_recent
        .distinct
    end

    def active_text_creatives
      TextCreative.joins(:offer_variants)
        .where(offer_variants: { offer_id: offers.select(:id) })
        .active
        .publishable
        .order_by_recent
        .distinct
    end

    def active_affiliate_offers
      AffiliateOffer.active
        .where(offer_id: offers.select(:id))
        .recently_applied
    end
  end
end
