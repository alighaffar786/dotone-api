class ElasticsearchIndexerJob < ApplicationJob
  queue_as :elasticsearch

  # skip retry when operation is delete and document is not found
  discard_on Elasticsearch::Transport::Transport::Errors::NotFound
  discard_on ActiveRecord::RecordNotFound

  def perform(operation, klass, id)
    klass = klass.constantize
    entity =
      if operation.to_s == 'delete'
        klass.new(id: id)
      else
        klass.find(id)
      end

    case operation.to_s
    when 'index'
      entity.__elasticsearch__.index_document
    when 'update'
      entity.__elasticsearch__.update_document
    when 'delete'
      entity.__elasticsearch__.delete_document
    else raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end
end
