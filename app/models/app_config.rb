class AppConfig < DatabaseRecords::PrimaryRecord
  include AppRoleable

  validates :role, presence: true

  after_save :set_active, if: :active?

  private

  def set_active
    self.class.with_roles(role).where.not(id: id).update_all(active: false)
  end
end
