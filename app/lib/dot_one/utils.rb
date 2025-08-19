module DotOne::Utils
  def self.to_date(str)
    return if str.blank?

    ['%Y-%m-%d', '%m/%d/%Y'].each do |format|
      return Date.strptime(str.to_s, format)
    rescue ArgumentError
      next
    end

    begin
      return Date.parse(str.to_s)
    rescue
    end

    raise DotOne::Errors::InvalidDataError.new(str, 'data.invalid_date_format', str)
  end

  def self.to_datetime(str)
    return if str.blank?

    ['%Y-%m-%d %H:%M:%S', '%m/%d/%Y %H:%M:%S'].each do |format|
      return DateTime.strptime(str.to_s, format)
    rescue ArgumentError
      next
    end

    begin
      return DateTime.parse(str.to_s)
    rescue
    end

    raise DotOne::Errors::InvalidDataError.new(str, 'data.invalid_date_format', str)
  end

  def self.to_number_range(*args, round: 2)
    args
      .flatten
      .map(&:to_f)
      .reject { |v| v == 0 }
      .map { |v| v.round(round) }
      .uniq
  end

  def self.to_base_cache_key_array(entities, *args)
    entity_cache_key = [entities].flatten
      .flat_map do |entity|
        date = begin
          if entity.respond_to?(:updated_at)
            entity.updated_at
          elsif entity.respond_to?(:cached_max_updated_at)
            entity.cached_max_updated_at
          else
            entity.maximum(:updated_at)&.to_s(:number)
          end
        rescue
        end

        name = begin
          entity.table_name rescue entity.class.base_class.to_s
        rescue
          entity.to_s
        end

        [name, date].compact_blank
      end
      .compact_blank

    # Standardize postfix for further processing.
    # Sometimes postfix is supplied as string
    postfix = [*args].flatten.reject(&:blank?)

    [*entity_cache_key, *postfix].flatten
  end

  def self.to_global_cache_key(entities, *args)
    key_string = ['global', *to_base_cache_key_array(entities, *args)].flatten.compact_blank.join('/')
    Rails.logger.info "[Global Cache Key] #{key_string}" unless DotOne::Setup.tracking_server?
    DotOne::Utils::Encryptor.hexdigest(key_string)
  end

  def self.to_cache_key(entities, *args)
    key_string = [
      *to_base_cache_key_array(entities, *args),
      DotOne::Current.user&.roles,
      DotOne::Current.user&.id,
      DotOne::Current.locale,
      DotOne::Current.time_zone.gmt_string,
      DotOne::Current.currency.code,
    ].flatten.compact_blank.join('/')

    Rails.logger.info "[Cache Key] #{key_string}" unless DotOne::Setup.tracking_server?

    DotOne::Utils::Encryptor.hexdigest(key_string)
  end

  # generate unique token for unique data
  # this is a one-way mechanism. Use this
  # to generate unique data other than plain integer
  # as ID.
  def self.generate_token(seed = 999_999_999)
    require 'digest/md5'
    Digest::MD5.hexdigest(rand(seed).to_s + Time.now.to_i.to_s)
  end

  def self.str_match?(str1, str2)
    str1.to_s.strip.casecmp(str2.to_s.strip) == 0
  end

  def self.return_meaningful_amount(*values)
    values.flatten.each do |value|
      return value.to_f if value.to_f != 0.0
    end

    return 0.0
  end

  def self.to_percentage(value, total)
    return 0.0 if total.to_f == 0.0

    (value.to_f / total.to_f) * 100
  end

  def self.percentage_to_total(percentage, value)
    return 0.0 if percentage.to_f == 0.0

    value.to_f * (100 / percentage.to_f)
  end

  def self.percentage_to_amount(percentage, total)
    (total.to_f * percentage.to_f) / 100
  end

  def self.to_utf8(str)
    str.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      .chars.select { |c| c.bytesize < 4 }.join
  end

  def self.cleanup_emoji(str)
    str.to_s.gsub(EMOJI_RULES, '')
  end

  def self.now_locked?
    current = TimeZone.platform.now
    current_max = current.change(day: 15).beginning_of_day

    current > current_max
  end

  def self.earliest_conversion_date
    if now_locked?
      TimeZone.platform.now.beginning_of_month
    else
      (TimeZone.platform.now - 1.month).beginning_of_month
    end
  end

  def self.date_convertable?(converted_at = nil)
    return false if converted_at.blank?

    TimeZone.platform.convert(converted_at) > earliest_conversion_date
  end
end
