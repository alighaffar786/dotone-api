class Teams::NewsletterSerializer < ApplicationSerializer
  attributes :id, :role, :recipient, :status, :created_at, :updated_at, :start_sending_at,
    :end_sending_at, :email_template, :error_reason, :recipient_ids, :sender_id, :offer_id

  has_one :sender, serializer: Teams::Newsletter::SenderSerializer
  has_one :offer, serializer: Teams::NetworkOffer::MiniSerializer
end
