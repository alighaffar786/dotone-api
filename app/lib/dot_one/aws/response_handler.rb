module DotOne::Aws::ResponseHandler
  def handle_response
    yield
  rescue Aws::Waiters::Errors::FailureStateError, ArgumentError => e
    raise DotOne::Errors::AwsError.new({ code: e.class.name }, e.message)
  rescue Aws::Errors::ServiceError => e
    raise DotOne::Errors::AwsError.new({ code: e.code }, e.message)
  rescue Aws::Waiters::Errors::WaiterFailed
  end
end
