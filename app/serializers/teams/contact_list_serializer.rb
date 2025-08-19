class Teams::ContactListSerializer < ApplicationSerializer
  attributes :id, :full_name, :email, :status, :first_name, :last_name, :title, :phone, :email_optin, :messenger_id,
    :owner_id, :owner_type, :messenger_service, :owner_id, :owner_type
end
