# frozen_string_literal: true

class AlternativeDomains::DestroyJob < EntityManagementJob
  def perform(id)
    alternative_domain = AlternativeDomain.find(id)
    catch_exception { alternative_domain.destroy }
  end
end
