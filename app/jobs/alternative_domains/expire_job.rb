# frozen_string_literal: true

class AlternativeDomains::ExpireJob < MaintenanceJob
  def perform
    alternative_domains = AlternativeDomain.tracking.success.expired
    alternative_domains.each do |domain|
      catch_exception { domain.destroy }
    end
  end
end
