module HasUniqueToken
  extend ActiveSupport::Concern

  included do
    before_create :generate_unique_token
  end

  def refresh_unique_token
    self.class.where(id: id).update_all(
      unique_token: DotOne::Utils.generate_token,
      updated_at: Time.now,
    )
    reload
  end

  def generate_unique_token
    self.unique_token = DotOne::Utils.generate_token
  end
end
