# frozen_string_literal: true

class OmniAuth::Strategies::GoogleOauth2
  # Documentation
  # https://developers.google.com/people/api/rest/v1/people/get
  PEOPLE_API_URL = 'https://people.googleapis.com/v1/people/me?personFields=genders,birthdays'

  def profile
    @profile ||= access_token.get(PEOPLE_API_URL).parsed
  end

  def gender
    @gender ||= begin
      if (gender = profile.genders&.find { |g| g.metadata.primary } || profile.genders&.first)
        case gender.value
        when 'male'
          Affiliate.gender_man
        when 'female'
          Affiliate.gender_woman
        when 'unspecified'
          Affiliate.gender_prefer_not_to_say
        when Affiliate.genders.include?(gender.formatted_value)
          gender.formatted_value
        end
      end
    end
  end

  def birthday
    @birthday ||= begin
      if (birthday = profile.birthdays&.find { |g| g.date.year && g.date.month && g.date.day })
        Date.parse("#{birthday.date.day}/#{birthday.date.month}/#{birthday.date.year}")
      end
    end
  end

  def raw_info
    @raw_info ||= begin
      info = access_token.get(USER_INFO_URL).parsed
      info.merge(
        gender: gender,
        birthday: birthday,
        picture: info.picture&.gsub('s96-c', 's300-c'),
      )
    end
  end
end
