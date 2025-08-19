module Snippetable
  extend ActiveSupport::Concern

  included do
    has_many :snippets, as: :owner, inverse_of: :owner, dependent: :destroy
  end

  # Obtain the hash content under certain snippet name and snippet key
  def snippet_content(snippet_name, hash_key)
    snippet_set = snippet(snippet_name)
    snippet_set.present? ? snippet_set.snippet_hash[hash_key] : nil
  end

  # Method to obtain the snippet hash from snippet name
  def snippet(snippet_name)
    snippets.find_by(snippet_key: snippet_name)
  end
end
