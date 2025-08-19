# frozen_string_literal: true

class Advertisers::ClientApiSerializer < Base::ClientApiSerializer
  attributes :id, :name, :owner_id, :owner_type, :status, :host, :username, :password

  has_one :owner
end
