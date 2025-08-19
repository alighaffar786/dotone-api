class Teams::PlatformSerializer < ApplicationSerializer
  translatable_attributes(*WlCompany.dynamic_translatable_attributes)

  attributes :id, :address, :affiliate_contact_email, :affiliate_terms, :general_contact_email, :name, :setup

  has_many :affiliate_terms_translations
end
