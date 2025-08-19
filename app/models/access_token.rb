class AccessToken < ApiKey
  belongs_to :partner_app, inverse_of: :access_tokens

  validates :partner_app_id, presence: true

  def partner_app_name
    partner_app&.name
  end
end
