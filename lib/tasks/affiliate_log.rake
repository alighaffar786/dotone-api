namespace :wl do
  namespace :affiliate_logs do
    task convert_offer_notes: :environment do
      offers = NetworkOffer.where("private_notes is NOT NULL AND TRIM(private_notes) != ''")
      offer_attrs = offers.pluck(:id, :private_notes)

      log_attrs = offer_attrs.map do |attrs|
        {
          owner_id: attrs.id,
          notes: attrs.private_notes,
          owner_type: 'Offer',
          agent_id: DotOne::Setup.wl_company.user.id,
          agent_type: 'User',
        }
      end

      AffiliateLog.bulk_insert values: log_attrs
      offers.update_all(updated_at: DateTime.now)
    end
  end
end
