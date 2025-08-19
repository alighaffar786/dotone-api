namespace :contact_list do
  task migrate_messenger: :environment do
    AffHash.where(entity_type: 'ContactList').find_each do |aff_hash|
      contact_list = ContactList.find_by(id: aff_hash.entity_id)
      messenger_service = aff_hash.flag['messenger_service']
      messenger_id = aff_hash.flag['messenger_id']

      next if contact_list.blank? || messenger_service.blank? || messenger_id.blank?

      contact_list.update_columns(
        messenger_service: messenger_service,
        messenger_id: messenger_id,
        updated_at: Time.now,
      )
    end

    # AffHash.where(entity_type: 'ContactList').delete_all
  end
end
