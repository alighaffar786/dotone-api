class AlternativeDomains::CheckValidationJob < MaintenanceJob
  def perform
    AlternativeDomain.check_validations
  end
end
