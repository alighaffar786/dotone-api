require 'encryptor'

module DotOne::Utils::Encryptor

  # Encrypt the given data and return the encrypted
  # string. Use this with decrypt method to
  # translate back and forth the data
  def self.encrypt(data)
    return if data.blank?

    # TODO: Make this encryption secured
    # especially for password data.
    # Checkout documentation here:
    # https://github.com/attr-encrypted/encryptor
    encrypted = Encryptor.encrypt(
      data,
      key: Digest::SHA256.hexdigest(ENV.fetch('ENCRYPTOR_KEY')),
      algorithm: 'rc4-40',
      insecure_mode: true,
    )
    unpacked = encrypted.unpack('H*')
    unpacked.first
  end

  # Decrypt the given encrypted data and return
  # in plain text the decrypted data
  def self.decrypt(data)
    return if data.blank?

    packed = [data].pack('H*')

    Encryptor.decrypt(
      packed,
      key: Digest::SHA256.hexdigest(ENV.fetch('ENCRYPTOR_KEY')),
      algorithm: 'rc4-40',
      insecure_mode: true,
    )
  end

  def self.hexdigest(str, algo = 'SHA2')
    "Digest::#{algo}".constantize.hexdigest(str)
  end
end
