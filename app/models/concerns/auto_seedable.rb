module AutoSeedable
  extend ActiveSupport::Concern

  module ClassMethods
    def auto_seed(seed)
      class_eval do
        class << self
          attr_accessor :auto_seed
        end

        @auto_seed = seed
      end
    end
  end
end
