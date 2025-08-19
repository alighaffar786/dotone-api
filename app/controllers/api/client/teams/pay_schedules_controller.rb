class Api::Client::Teams::PaySchedulesController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @pay_schedules = paginate(query_index)
    respond_with_pagination @pay_schedules
  end

  def update
    if @pay_schedule.update(pay_schedule_params)
      respond_with @pay_schedule
    else
      respond_with @pay_schedule, status: :unprocessable_entity
    end
  end

  private

  def query_index
    collection = PayScheduleCollection.new(@pay_schedules, params).collect
    collection.preload(owner: :true_currency)
  end

  def pay_schedule_params
    params.require(:pay_schedule).permit(:expired)
  end
end
