class Api::Client::Teams::TracesController < Api::Client::Teams::BaseController
  before_action :set_target, only: :index

  def index
    authorize! :read, @target
    respond_with_pagination @target.traces(params[:verb], current_page, current_per_page, trace_params).preload(:agent_user)
  end

  def types
    authorize! :read, target_class

    attributes =
      if target_class.respond_to?(:trace_has_many_includes_attributes)
        target_class.trace_has_many_includes_attributes.map do |attr|
          { key: attr.to_s.singularize, value: attr }
        end
      else
        []
      end

    respond_with attributes
  end

  private

  def target_class
    params[:target_type].classify.constantize
  end

  def set_target
    @target = target_class.find(params[:target_id])

    if @target.respond_to?(:type)
      type = @target.type.constantize
      @target = @target.becomes(type)
    end

    @target
  rescue StandardError
    raise ActionController::ParameterMissing, 'target_type or target_id'
  end

  def trace_params
    params.permit(excluded_target_types: []).tap do |param|
      param[:exclude_has_many] = param.delete(:excluded_target_types)
    end
  end
end
