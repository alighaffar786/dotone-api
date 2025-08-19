class DotOne::Constraints::PublicConstraint
  def self.matches?(request)
    Rails.env.development? || request.host == ENV['HOST']
  end
end
