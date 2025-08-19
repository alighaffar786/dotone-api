module AffiliatePaymentInfoHelpers::Validator
  class MustHaveProperAttachment < ActiveModel::Validator
    def validate(record)
      must_have_proper_attachments(record)
    end

    private

    def must_have_proper_attachments(record)
      return true if record.waiting_on_affiliate? || !record.status_changed?

      affiliate = record.affiliate

      if record.local_tax_filing?
        if affiliate.individual? && (affiliate.front_of_id_url.blank? || affiliate.back_of_id_url.blank? || affiliate.bank_booklet_url.blank?)
          record.errors.add(:base, :attachment_not_complete)
          return false
        end

        if affiliate.company? && affiliate.bank_booklet_url.blank?
          record.errors.add(:base, :attachment_not_complete)
          false
        end
      else
        if affiliate.individual? && (affiliate.valid_id_url.blank? || affiliate.tax_form_url.blank?)
          record.errors.add(:base, :attachment_not_complete)
          return false
        end

        if affiliate.company? && affiliate.tax_form_url.blank?
          record.errors.add(:base, :attachment_not_complete)
          false
        end
      end
    end
  end

  class MustHaveProperStatusChange < ActiveModel::Validator
    def validate(record)
      must_have_proper_status_change(record)
    end

    private

    def must_have_proper_status_change(record)
      if record.status_changed? && AffiliatePaymentInfo.final_statuses.include?(record.status_was)
        record.errors.add(:status, :final_status)
        false
      end
    end
  end
end
