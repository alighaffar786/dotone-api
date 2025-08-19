# Helper to manage all the available
# options during conversion process and calculation
class DotOne::Utils::ConversionOptions
  # Indicate if payment for this conversion is already
  # received. If so, we waill bypass the Published step
  attr_accessor :is_payment_received, :skip_set_to_published, :skip_approved_transaction, :no_modification_on_final_status, :user_role

  def initialize(params = {})
    combine(params.with_indifferent_access)
  end

  def as_json
    super.with_indifferent_access
  end

  def combine(params = {})
    @user_role = params[:user_role] || :network
    @is_payment_received = BooleanHelper.truthy?(params[:is_payment_received])
    @skip_approved_transaction = user_role == :owner ? BooleanHelper.truthy?(params[:skip_approved_transaction]) : true
    @skip_set_to_published = BooleanHelper.truthy?(params[:skip_set_to_published])
    @no_modification_on_final_status = !(user_role == :owner && @is_payment_received)
  end
end
