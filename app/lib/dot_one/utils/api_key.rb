# TODO:: deprecate
class DotOne::Utils::ApiKey
  attr_accessor :affiliate_offer_id, :encrypted_string, :network_id

  def initialize(*args)
    if args[0].is_a?(Hash)
      @affiliate_offer_id = args[0][:affiliate_offer_id]
      @network_id = args[0][:network_id]
    else
      @encrypted_string = args[0]
      self.decrypt
    end
  end

  def to_s
    params = { ao: affiliate_offer_id, nt: network_id }.compact_blank
    URI.encode_www_form(params)
  end

  def decrypt
    decrypted = DotOne::Utils::Encryptor.decrypt(encrypted_string)
    hash = URI.decode_www_form(decrypted).to_h
    self.affiliate_offer_id = hash['ao']
    self.network_id = hash['nt']

    hash
  rescue ArgumentError
  end

  def encrypt
    self.encrypted_string = DotOne::Utils::Encryptor.encrypt(self.to_s)
  end
end
