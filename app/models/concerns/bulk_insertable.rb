# Taken from the following gem:
# https://github.com/jamis/bulk_insert

module BulkInsertable
  extend ActiveSupport::Concern

  module ClassMethods
    def bulk_insert(*columns, values: nil, set_size: 500, ignore: false, update_duplicates: false)
      columns = default_bulk_columns if columns.empty?
      worker = DotOne::Utils::BulkInserter.new(connection, table_name, columns, set_size, ignore,
        update_duplicates)

      if values.present?
        transaction do
          worker.add_all(values)
          worker.save!
        end
        nil
      elsif block_given?
        transaction do
          yield worker
          worker.save!
        end
        nil
      else
        worker
      end
    end

    # helper method for preparing the columns before a call to :bulk_insert
    def default_bulk_columns
      column_names - ['id']
    end
  end
end
