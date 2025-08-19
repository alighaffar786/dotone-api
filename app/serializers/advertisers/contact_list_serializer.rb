class Advertisers::ContactListSerializer < ApplicationSerializer
  attributes :id, :email, :first_name, :last_name, :title, :phone, :email_optin, :status, :messenger_id,
    :owner_id, :owner_type, :messenger_service
end
