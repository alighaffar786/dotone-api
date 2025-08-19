namespace :wl do
  namespace :text_creative do
    task migrate_aff_hash: :environment do
      AffHash.where(entity_type: 'TextCreative').find_each do |aff_hash|
        text_creative = TextCreative.find_by(id: aff_hash.entity_id)

        next if text_creative.blank?

        text_creative.update_columns(
          offer_name: aff_hash.flag['offer_name'].presence,
          discount_price: aff_hash.flag['discount_price'].presence,
          original_price: aff_hash.flag['original_price'].presence,
          updated_at: Time.now,
        )
      end
    end
  end
end
