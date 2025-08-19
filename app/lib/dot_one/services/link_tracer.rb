class DotOne::Services::LinkTracer
  attr_accessor :link
  attr_reader :data

  def initialize(link)
    @link = URI(link) rescue nil
  end

  def trace
    @data = []

    loop do
      break if link.blank? || link.host.blank?

      response = get_response
      @data << serialize_response(response)
      @link = URI(response['location']) if response['location']

      break unless response.is_a?(Net::HTTPRedirection)
    end

    @data
  end

  def serialize_response(response)
    {
      link: link.to_s,
      status: response.code,
      body: response.body.force_encoding('UTF-8'),
      host: link.host,
      path: link.path,
      query: link.query ? URI.decode_www_form(link.query) : nil,
    }
  end

  def get_response
    link.scheme = 'https' if link.scheme.blank?
    Net::HTTP.get_response(link)
  end
end
