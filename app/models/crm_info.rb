class CrmInfo < DatabaseRecords::PrimaryRecord
  include ConstantProcessor

  CONTACT_MEDIAS = ['phone', 'email', 'messenger', 'face_to_face', 'other_media' ].freeze

  belongs_to :affiliate_log, inverse_of: :crm_infos, touch: true
  belongs_to :crm_target, polymorphic: true, inverse_of: :crm_infos, touch: true

  validates :contact_media, inclusion: { in: CONTACT_MEDIAS }

  define_constant_methods CONTACT_MEDIAS, :contact_media
end
