class Teams::EmailTemplateSerializer < ApplicationSerializer
  translatable_attributes(*EmailTemplate.dynamic_translatable_attributes)

  attributes :id, :owner_type, :content, :email_type, :footer, :content, :recipient, :sender, :status, :subject

  has_many :subject_translations
  has_many :content_translations
  has_many :footer_translations
end
