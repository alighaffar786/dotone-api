module AffiliateHelpers::Validator
  class MustBeOldEnough < ActiveModel::Validator
    def validate(record)
      return unless record.birthday.present? && !record.old_enough?

      record.errors.add :birthday, record.errors.generate_message(:birthday, :not_old_enough)
    end
  end

  class CanAssignRecruiterWhenNoConversion < ActiveModel::Validator
    def validate(record)
      can_assign_recruiter_when_no_conversion(record)
    end

    def can_assign_recruiter_when_no_conversion(record)
      return true if DotOne::Current.user&.roles != 'Affiliate Manager'

      return unless record.conversion_count.to_i > 0

      record.errors.add :recruiter_id, record.errors.generate_message(:recruiter_id, :affiliate_has_conversion)
    end
  end

  class CanAssignRecruiterWhenBlank < ActiveModel::Validator
    def validate(record)
      can_assign_recruiter_when_blank(record)
    end

    def can_assign_recruiter_when_blank(record)
      return true if DotOne::Current.user&.roles != 'Affiliate Manager'

      return unless record.recruiter_id.present? && record.recruiter_id_was.present?

      record.errors.add :recruiter_id, record.errors.generate_message(:recruiter_id, :recruiter_is_present)
    end
  end

  class CannotBeBlacklistedEmailDomain < ActiveModel::Validator
    def validate(record)
      cannot_be_blacklisted_email_domain(record)
    end

    def cannot_be_blacklisted_email_domain(record)
      return if (record.email =~ /.*mail\.ru$/i).nil?

      record.errors.add :email, record.errors.generate_message(:email, :blacklisted_email_domain)
    end
  end
end
