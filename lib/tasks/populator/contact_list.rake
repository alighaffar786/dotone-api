require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy affiliates'
    task :contact_lists, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Contact Lists'

        # Full cleanup
        puts '  Destroy old data'
        [
          ContactList,
        ].each do |klass|
          klass.delete_all
        end

        AffHash.where(entity_type: 'ContactList').delete_all

        puts '   Generate contact list for advertisers'

        network_ids = Network.pluck(:id)
        email_index = 0

        ContactList.statuses.each do |status|
          ContactList.populate network_ids.length * 3 do |contact_list|
            contact_list.owner_id = network_ids.rotate!.first
            contact_list.owner_type = 'Network'
            contact_list.email = "contactlist#{email_index += 1}@converly.com"
            contact_list.first_name = Faker::Name.first_name
            contact_list.last_name = Faker::Name.last_name
            contact_list.title = ['Marketing Manager', 'VP Sales', 'Customer Relation', 'Engineer', 'Co-Founder',
              'Biz Dev'].sample
            contact_list.phone = Faker::PhoneNumber.phone_number
            contact_list.email_optin = [0, 1].sample
            contact_list.status = status
          end
        end

        contact_lists = ContactList.all
        contact_list_ids = contact_lists.map(&:id)

        AffHash.populate contact_lists.length do |aff_hash|
          hash_to_store = {}
          hash_to_store['messenger_service'] = ['Line', 'QQ', 'Skype', 'WeChat', 'Telegram', 'Whatsapp'].sample
          hash_to_store['messenger_id'] = Faker::Internet.user_name

          aff_hash.entity_id = contact_list_ids.rotate!.first
          aff_hash.entity_type = 'ContactList'
          aff_hash.flag = hash_to_store
        end
      end
    end
  end
end
