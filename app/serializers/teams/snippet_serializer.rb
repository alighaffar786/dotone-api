class Teams::SnippetSerializer < ApplicationSerializer
  attributes :id, :snippet_key, :snippet_hash, :owner_id, :owner_type
end
