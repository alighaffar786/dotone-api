module Relations::HasCrmInfos
  extend ActiveSupport::Concern

  included do
    has_many :crm_infos, as: :crm_target, inverse_of: :crm_target, dependent: :destroy
  end
end
