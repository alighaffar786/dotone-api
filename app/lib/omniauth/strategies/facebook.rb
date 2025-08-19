# frozen_string_literal: true

class OmniAuth::Strategies::Facebook
  def format_gender(value)
    if value && Affiliate.genders.include?(value.capitalize)
      value.capitalize
    elsif value == 'male'
      Affiliate.gender_man
    elsif value == 'female'
      Affiliate.gender_woman
    end
  end

  def format_birthday(value)
    Date.strptime(value, '%m/%d/%Y') if value.present?
  end

  def raw_info
    @raw_info ||= (access_token.get('me', info_options).parsed || {}).tap do |raw|
      raw[:gender] = format_gender(raw.gender)
      raw[:birthday] = format_birthday(raw.birthday)
    end
  end
end
