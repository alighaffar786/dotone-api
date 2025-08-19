class Public::BaseController < ApplicationController
  include Api::Public::ResponseHandler
  before_action :require_params

  def require_params; end
end
