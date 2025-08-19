# frozen_string_literal: true

class AlternativeDomains::DeployJob < EntityManagementJob
  def perform(id)
    alternative_domain = AlternativeDomain.find(id)
    catch_exception { alternative_domain.deploy }
  end
end
