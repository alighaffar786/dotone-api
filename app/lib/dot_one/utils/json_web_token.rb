module DotOne::Utils
  class JsonWebToken
    class << self
      def encode(payload, expiration = 1.day.from_now)
        payload[:expiration] = expiration.to_i
        JWT.encode(payload, ENV.fetch('JWT_SECRET_KEY', nil))
      end

      def decode(token)
        payload = JWT.decode(token, ENV.fetch('JWT_SECRET_KEY', nil), true, algorithm: 'HS256')[0]
        return payload unless Rails.env.production?

        payload && payload['expiration'] > Time.now.to_i ? payload : nil
      end
    end
  end
end
