class Cache::ResetMaxUpdatedAtJob < EntityManagementJob
  def perform(hour = nil)
    return unless DotOne::Setup.db_on?

    klasses = [
      AffiliateOffer,
      Affiliate,
    ]

    klasses.each do |klass|
      klass.select(:id, :updated_at).where('updated_at > ?', (hour || 1).hour.ago).find_each do |record|
        cached = klass.cached_find(record.id)
        next if cached.blank? || cached.updated_at == record.updated_at

        record.flush_cache
        klass.cached_find(record.id)
      end
    end
  end
end
