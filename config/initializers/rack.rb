require 'cgi'
# Erwin at 2016-02-07:
# monkey patching to resolve invalid %-encoding
# source: http://stackoverflow.com/questions/16269897/rails-argumenterror-invalid-encoding
module Rack
  module Utils
    if defined?(::Encoding)
      def unescape(s, encoding = Encoding::UTF_8)
        URI.decode_www_form_component(s, encoding)
      rescue ArgumentError
        URI.decode_www_form_component(CGI.escape(s), encoding)
      end
    else
      def unescape(s, encoding = nil)
        URI.decode_www_form_component(s, encoding)
      rescue ArgumentError
        URI.decode_www_form_component(CGI.escape(s), encoding)
      end
    end
    module_function :unescape
  end
end
