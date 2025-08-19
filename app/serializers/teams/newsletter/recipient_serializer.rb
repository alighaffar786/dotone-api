class Teams::Newsletter::RecipientSerializer < ApplicationSerializer
  class ContactListSerializer < ApplicationSerializer
    attributes :id, :full_name, :email
  end

  attributes :id, :email, :full_name

  has_many :contact_lists, serializer: ContactListSerializer
end
