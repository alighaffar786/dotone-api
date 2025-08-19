module Authenticatable
  extend ActiveSupport::Concern

  included do
    attr_accessor :password, :password_confirmation, :tfa_verified

    validates :password, presence: true, on: :create, unless: :skip_password_validation?
    validates :password, length: { minimum: 6, allow_blank: true }
    validates :password, confirmation: true

    before_save :set_crypted_password
  end

  def self.encrypt_password(value)
    DotOne::Utils::Encryptor.encrypt(value)
  end

  module ClassMethods
    def authenticatable(extra_params = nil)
      define_singleton_method(:authenticate) do |params|
        user = find_by_credentials(params, extra_params)
        block_given? ? yield(user) : user
      end
    end

    def find_by_credentials(params, extra_params = nil)
      login_info = params[:login_info].to_s.strip
      crypted_password = Authenticatable.encrypt_password(params[:password])

      where_params = { email: login_info, crypted_password: crypted_password }
      where_params_by_username = { username: login_info, crypted_password: crypted_password }

      if extra_params
        where_params.merge!(extra_params)
        where_params_by_username.merge!(extra_params)
      end

      user = find_by(where_params)
      user ||= find_by(where_params_by_username) if column_names.include?('username')
      user&.validate_tfa(params[:tfa_code])
      user
    end
  end

  def has_password?
    crypted_password.present?
  end

  def password_match?(value)
    Authenticatable.encrypt_password(value) == crypted_password
  end

  def auth_token_expiration
    6.hours.from_now
  end

  def auth_token
    token_params = { email: email, user_type: self.class.name, id: id }
    DotOne::Utils::JsonWebToken.encode(token_params, auth_token_expiration)
  end

  def set_crypted_password
    self.crypted_password = Authenticatable.encrypt_password(password) if password.present?
  end

  def skip_password_validation?
    false
  end

  def validate_tfa(value)
    return unless tfa_enabled?

    if value.present? && tfa_code == value
      self.tfa_verified = true
      update_column(:tfa_code, nil)
    elsif value.blank?
      update_column(:tfa_code, format('%06d', rand(0..999_999)))
      UserMailer.tfa(self).deliver_later
    else
      self.tfa_verified = false
    end
  end
end
