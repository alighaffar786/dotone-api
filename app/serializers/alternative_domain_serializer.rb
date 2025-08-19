class AlternativeDomainSerializer < ApplicationSerializer
  attributes :id, :host, :host_type, :visible, :adult_only?, :temporary?, :permanent?
end
