# Any class that include this module
# will be able to define a translateable
# method based on its existing method or
# attribute.

module DynamicTranslatable
  extend ActiveSupport::Concern
  include Translatable

  included do
    cattr_accessor :dynamic_translatable_attribute_types
    cattr_reader :dynamic_translatable_attributes

    before_save :set_translation_stats

    ##
    # Filter any translations where blank is greater
    # than zero. This also include entity whose
    # translation stat is null - that is no translation
    # is done
    scope :translation_not_done, -> (*args) {
      locales = args.flatten

      if locales.present?
        sql = []

        sql << <<-SQL.squish
          (
            #{table_name}.translation_stat_cache IS NULL
          )
        SQL

        extract_json_sql = []

        locales.each do |locale|
          extract_json_sql << <<-SQL.squish
            CAST(
              IFNULL(
                JSON_UNQUOTE(
                  JSON_EXTRACT(
                    #{table_name}.translation_stat_cache,
                    '$."#{locale}".present'
                  )
                ), 0
              ) AS UNSIGNED
            ) < CAST(
              IFNULL(
                JSON_UNQUOTE(
                  JSON_EXTRACT(
                    #{table_name}.translation_stat_cache,
                    '$."#{locale}".required'
                  )
                ), 0
              ) AS UNSIGNED
            )
          SQL
        end

        sql << "(#{extract_json_sql.join(' AND ')})"

        where(sql.join(' OR '))
      end
    }

    scope :translation_done, -> (locales) {
      if locales.present?
        sql = []

        sql << <<-SQL.squish
          (
            #{table_name}.translation_stat_cache IS NULL
          )
        SQL

        extract_json_sql = []

        locales.each do |locale|
          extract_json_sql << <<-SQL.squish
            CAST(
              IFNULL(
                JSON_UNQUOTE(
                  JSON_EXTRACT(
                    #{table_name}.translation_stat_cache,
                    '$."#{locale}".present'
                  )
                ), 0
              ) AS UNSIGNED
            ) >= CAST(
              IFNULL(
                JSON_UNQUOTE(
                  JSON_EXTRACT(
                    #{table_name}.translation_stat_cache,
                    '$."#{locale}".required'
                  )
                ), 0
              ) AS UNSIGNED
            )
          SQL
        end

        sql << "(#{extract_json_sql.join(' AND ')})"

        where(sql.join(' OR '))
      end
    }

    scope :select_translations, -> (*fields, locale) {
      select_sqls = fields.map do |field|
        <<-SQL.squish
          COALESCE(agg_translations_#{field}.content, #{table_name}.#{field}) as translated_#{field}
        SQL
      end

      join_sqls = fields.map do |field|
        <<-SQL.squish
          LEFT OUTER JOIN (
            SELECT owner_id, content FROM translations
            WHERE translations.locale = '#{locale}' AND owner_type = '#{table_name.classify}' AND translations.field = '#{field}'
          ) agg_translations_#{field} ON agg_translations_#{field}.owner_id = #{table.name}.id
        SQL
      end

      select(select_sqls.join(', ')).joins(join_sqls.join)
    }
  end

  module ClassMethods
    ##
    # Any attribute declated on this parameter
    # will have its translation pulled from translation
    # db table
    def set_dynamic_translatable_attributes(values)
      self.dynamic_translatable_attribute_types = values
      class_variable_set(:@@dynamic_translatable_attributes, dynamic_translatable_attributes.to_a | values.keys)

      dynamic_translatable_attributes.each do |attribute|
        has_many "#{attribute}_translations".to_sym, -> { where(field: attribute) }, as: :owner, class_name: 'Translation', autosave: true
        alias_attribute "original_#{attribute}", attribute

        # Getter method with current locale
        define_method "t_#{attribute}".to_sym do |locale = nil|
          return send("translated_#{attribute}") if respond_to?("translated_#{attribute}")
          locale ||= Language.current_locale

          original_value = send(attribute) rescue nil
          translations = send("#{attribute}_translations").index_by(&:locale)
          translations[locale.to_s]&.content.presence || original_value
        end

        # Setter method with current locale
        define_method "t_#{attribute}=".to_sym do |*args|
          content, locale = args.flatten
          locale ||= Language.current_locale
          translation = translations.find_or_initialize_by(locale: locale.to_s, field: attribute)
          translation.update(content: content)
        end

        LOCALES.each do |locale|
          define_method "t_#{attribute}_#{locale.underscore}" do
            send("t_#{attribute}", locale)
          end
        end
      end
    end
  end

  ##
  # Returns number of translatable attributes
  # translated for each locale.
  # Example of return value:
  # {
  #   "en-US": {
  #     "present": 10,
  #     "required": 30
  #   },
  #   "zh-TW": {
  #     "present": 5,
  #     "required": 35
  #   },
  #   ...
  # }

  def generate_translation_stats
    stats = LOCALES.each_with_object({}) do |locale, result|
      result[locale] = {
        present: 0,
        required: 0,
      }
    end

    translations.each do |translation|
      stats[translation.locale][:present] += 1 if translation.content.present?
    end

    # Only calculate blank when the original value
    # is present. Otherwise, the attribute is not required
    self.class.dynamic_translatable_attributes.each do |attribute|
      next if Translation.sanitize(send(attribute)).blank?

      stats.keys.each do |locale|
        stats[locale][:required] += 1
      end
    end

    stats.with_indifferent_access
  end

  def translation_stats
    @translation_stats ||= if respond_to?(:translation_stat_cache)
      if translation_stat_cache.is_a?(Hash)
        translation_stat_cache
      else
        JSON.parse(translation_stat_cache.presence || '{}')
      end
    else
      generate_translation_stats
    end
    .slice(*LOCALES)
    .with_indifferent_access
  end

  def set_translation_stats
    return unless respond_to?(:translation_stat_cache)

    self.translation_stat_cache = generate_translation_stats
  end
end
