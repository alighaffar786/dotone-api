class DotOne::AffiliateStats::SiblingAttacher
  def self.attach(source_id, target_id)
    return if source_id.blank? || target_id.blank?
    return unless source_transaction = AffiliateStat.find_by_id(source_id)
    return unless target_transaction = AffiliateStat.find_by_id(target_id)
    return if [target_transaction.s1, target_transaction.s2, target_transaction.s3, target_transaction.s4].any?

    updates = {}

    if source_transaction.s1.present? &&
        source_transaction.s2.present? &&
        source_transaction.s3.present? &&
        source_transaction.s4.present?
      updates[:s1] = source_transaction.s1
      updates[:s2] = source_transaction.s3
      updates[:s3] = source_transaction.s4
      updates[:s4] = source_transaction.id
    elsif source_transaction.s1.present? &&
        source_transaction.s2.present? &&
        source_transaction.s3.present?
      updates[:s1] = source_transaction.s1
      updates[:s2] = source_transaction.s2
      updates[:s3] = source_transaction.s3
      updates[:s4] = source_transaction.id
    elsif source_transaction.s1.present? &&
        source_transaction.s2.present?
      updates[:s1] = source_transaction.s1
      updates[:s2] = source_transaction.s2
      updates[:s3] = source_transaction.id
    elsif source_transaction.s1.present?
      updates[:s1] = source_transaction.s1
      updates[:s2] = source_transaction.id
    else
      updates[:s1] = source_transaction.id
    end

    AffiliateStat.where(id: target_transaction.id).update_all(updates)
  end
end
