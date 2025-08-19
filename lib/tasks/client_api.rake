namespace :wl do
  namespace :client_api do
    namespace :product_api do
      task convert_owner_to_offer: :environment do
        ClientApi.product_api.where(owner_type: 'Network').each do |client_api|
          offer = NetworkOffer.find(client_api.related_offer_ids)

          copy_client_api = client_api.dup
          copy_client_api.owner = offer
          copy_client_api.related_offer_ids = nil

          begin
            copy_client_api.save!
            client_api.update_column(:status, ClientApi.status_paused)
          rescue
            puts "offer #{offer.id}"
            puts copy_client_api.errors.full_messages.inspect
          end
        end
      end
    end
  end
end
