module DotOne::Track
  class TokenProcessor
    def self.cleanup_params_token(params)
      converted_params = {}

      params.each_pair do |key, value|
        scanned_parameters = value.to_s.scan(TOKEN_REGEX).flatten

        scanned_parameters = scanned_parameters.map do |p|
          p.gsub(/_decoded$/i, '')
        end

        if scanned_parameters.present?
          scanned_parameters.each do |parameter|
            converted_params[parameter] = ''
          end
        else
          converted_params[key] = value
        end
      end

      converted_params
    end
  end
end
