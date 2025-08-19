module DotOne::ApiClient::ProductApi
  class GoogleCategoryMap
    class << self
      def generate(options = {})
        result = {}

        categories = open_url(options[:locale]).split("\n")
        categories.shift

        categories.each do |category|
          category_id = category.split(/\s*-\s*/).first
          category = category.gsub(/#{category_id}\s*-\s*/, '')
          sub_categories = category.split(/\s*>\s*/)

          result[category_id] = {
            category_1: sub_categories.shift,
            category_2: sub_categories.shift,
            category_3: sub_categories.present? ? sub_categories.last : nil,
          }
        end

        result.with_indifferent_access
      end

      private

      def open_url(locale)
        response = begin
          URI.open("https://www.google.com/basepages/producttype/taxonomy-with-ids.#{format_locale(locale)}.txt")
        rescue StandardError
          URI.open('https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt')
        end

        response.read.force_encoding('UTF-8')
      end

      def format_locale(locale)
        arr = locale.split('-')
        [arr[0].downcase, arr[1].upcase].join('-')
      rescue StandardError
        'en-US'
      end
    end
  end
end
