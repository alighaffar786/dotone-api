require 'csv'

module DotOne::ApiClient::ProductApi
  module XmlFeedHelper
    def download
      uri = URI(remote_xml_url)

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        response = http.head(uri)
        response = http.get(uri) if response.is_a?(Net::HTTPMethodNotAllowed)

        # Follow redirects if necessary
        while response.is_a?(Net::HTTPRedirection)
          location = response['location']
          uri = URI(location)
          response = http.head(uri)
        end
      end

      Net::HTTP.get_response(uri) do |response|
        File.open(local_xml_file, 'wb') do |file|
          response.read_body do |chunk|
            file.write(chunk)
          end
        end
      end

      local_xml_file
    end

    private

    def read_entries
      file = File.open(local_xml_file)
      index = 0
      Nokogiri::XML::Reader(file).each do |node|
        next unless node.name == entry_name && node.outer_xml != "<#{entry_name}/>"

        element = Nokogiri::XML(node.outer_xml)
        entry = {}
        headers.each do |header|
          # get tag if has namespace i.e <g:id>, <g:title>
          path = "//*[local-name()=\"#{header}\"]"
          entry[header] = element.at(path)&.text
        end

        yield entry, index
        index += 1
      end
    end

    def headers
      raise NotImplementedError
    end

    def entry_name
      raise NotImplementedError
    end

    def remote_xml_url
      host
    end
  end
end
