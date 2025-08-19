class Api::Client::Teams::ConversionStepsController < Api::Client::Teams::BaseController
  load_and_authorize_resource except: :search

  def index
    @conversion_steps = paginate(query_index)
    respond_with_pagination @conversion_steps, meta: { t_columns: ConversionStep.flexible_translatable_attribute_types }
  end

  def create
    if @conversion_step.save
      respond_with @conversion_step
    else
      respond_with @conversion_step, status: :unprocessable_entity
    end
  end

  def search
    authorize! :read, ConversionStep
    @conversion_steps = query_search
    respond_with @conversion_steps, each_serializer: Teams::ConversionStep::SearchSerializer, full_scope: full_scope?
  end

  def update
    if @conversion_step.update(conversion_step_params)
      respond_with @conversion_step
    else
      respond_with @conversion_step, status: :unprocessable_entity
    end
  end

  private

  def query_index
    ConversionStepCollection.new(@conversion_steps, params)
      .collect
      .preload(
        :true_currency,:available_pay_schedules, :available_pay_schedule, :label_translations,
        offer: [:default_conversion_step, :name_translations]
      )
  end

  def query_search
    collection = ConversionStepCollection.new(current_ability, params).collect
    collection = collection.preload(:label_translations, :true_currency)
    collection = collection.preload(:offer, :step_prices) if full_scope?
    collection
  end

  def conversion_step_params
    params[:conversion_step][:pay_schedules_attributes].to_a.each do |pay_schedules_params|
      assign_local_time_params([:starts_at, :ends_at], pay_schedules_params)
    end

    params.require(:conversion_step).permit(
      :offer_id, :name, :label, :true_currency_id, :true_conv_type, :affiliate_conv_type, :true_share, :affiliate_share,
      :days_to_return, :days_to_expire, :conversion_mode, :session_option, :on_past_due, :true_pay, :affiliate_pay,
      translations_attributes: [:id, :locale, :field, :content],
      pay_schedules_attributes: pay_schedules_attributes
    )
  end

  def pay_schedules_attributes
    [
      :id, :true_share, :affiliate_share, :true_pay, :affiliate_pay,
      starts_at_local: [], ends_at_local: []
    ]
  end
end
