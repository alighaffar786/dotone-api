class SkinMap < DatabaseRecords::SecondaryRecord
  has_many :blogs, inverse_of: :skin_map, dependent: :nullify

  validates :hostname, presence: true, uniqueness: true

  after_commit :flush_cache

  default_scope { where(wl_company_id: DotOne::Setup.wl_id) }

  scope :with_hostname, -> (hostname) {
    host = hostname.gsub(/^(local\.|www\.|staging\.)/, '')
    where(hostname: host)
  }

  def public_folder
    segments = [
      "#{Rails.root}/public/skins",
      wl_company_id,
      folder
    ].join('/')
  end
end
