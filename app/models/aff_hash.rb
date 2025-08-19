class AffHash < DatabaseRecords::PrimaryRecord
  belongs_to :entity, polymorphic: true, inverse_of: :aff_hash, touch: true

  serialize :flag
  serialize :system_flag


  # array_hash is of this form:
  # [
  #   { 'key' => 'key-content-1', 'value' => 'value-content-1' },
  #   { 'key' => 'key-content-2', 'value' => 'value-content-2' },
  #   { 'key' => 'key-content-3', 'value' => 'value-content-3' },
  #   ....
  # ]
  def self.hash_array_to_hash(array_hash)
    hash = {}
    return hash if array_hash.blank?

    array_hash
      .map(&:stringify_keys)
      .reject { |x| x['key'].to_s.blank? || x['value'].to_s.blank? }
      .each do |ah|
        hash[ah['key'].to_s.strip] = ah['value']
      end

    hash
  end

  def set(att, key, value)
    hash = send(att)
    hash = {} if hash.blank?
    send("#{att}=", hash.merge({ key.to_s => value }))
    save! if entity.persisted?
  end

  def get(att, key)
    hash = send(att)
    return unless hash.is_a?(Hash)

    val = hash[key.to_s]
    handle_json_split(val)
  end

  private

  def handle_json_split(value)
    to_return = value
    json = JSON.parse(value) rescue nil

    if json.present? && json.respond_to?(:keys) && json.keys.include?('split')
      to_return = DotOne::Utils::Converter.hash_splitter_to_value(json['split'])
    end

    to_return
  end
end
