class Bank
  class << self
    def data
      @data ||= BANKS[:TW]
    end

    def all
      @all ||= data.map { |item| item.slice(:id, :name) }
    end

    def branch_map
      @branch_map ||= data.map do |item|
        branches = item[:branches].map do |branch|
          key = to_branch_key(id: branch[:id], name: branch[:name])
          branch.merge(key: key).with_indifferent_access
        end

        [item[:id], branches]
      end
      .to_h
    end

    def get_branches(bank_id:)
      branch_map[bank_id].to_a
    end

    def find(id:)
      all.find { |bank| bank[:id] == id }
    end

    def find_branch(key:, bank_id:)
      branches = get_branches(bank_id: bank_id)
      branches.find { |branch| branch[:key] == key }
    end

    def to_branch_key(id:, name:)
      [id, name].compact.join('_').presence
    end
  end
end
