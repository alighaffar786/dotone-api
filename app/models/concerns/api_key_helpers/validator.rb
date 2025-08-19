module ApiKeyHelpers::Validator
  class ApiKeyValidator < ActiveModel::Validator
    def validate(record)
      should_not_exceed_max_allowed(record)
    end

    private

    def should_not_exceed_max_allowed(record)
      return unless record.current_count >= ApiKey::MAX_ALLOWED

      record.errors.add :current_count, DotOne::I18n.st('Max N allowed', n: ApiKey::MAX_ALLOWED)
    end
  end
end
