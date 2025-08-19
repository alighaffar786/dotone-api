class Teams::BlogPageSerializer < ApplicationSerializer
  attributes :id, :name, :created_at, :description, :blog_id
end
