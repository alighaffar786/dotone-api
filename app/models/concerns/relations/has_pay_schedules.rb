module Relations::HasPaySchedules
  extend ActiveSupport::Concern

  included do
    has_many :pay_schedules, as: :owner, inverse_of: :owner, dependent: :destroy
    
    has_one :active_pay_schedule, -> { active }, as: :owner, inverse_of: :owner, class_name: 'PaySchedule'
    has_one :available_pay_schedule, -> { available }, as: :owner, inverse_of: :owner, class_name: 'PaySchedule'

    accepts_nested_attributes_for :pay_schedules, reject_if: -> (attrs) {
      missing_dates?(attrs) || all_payouts_zero?(attrs)
    }
  end

  module ClassMethods
    def missing_dates?(attrs)
      attrs['starts_at_local'].blank? || attrs['ends_at_local'].blank?
    end

    def all_payouts_zero?(attrs)
      ['affiliate_pay', 'true_pay', 'true_share', 'affiliate_share'].all? { |key| attrs[key].to_f.zero? }
    end
  end
end
