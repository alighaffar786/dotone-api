module ControllerHelper
  def login_user
    before(:each) do
      @time_zone = FactoryBot.create(:time_zone, :"+00:00")
      @wl_company = FactoryBot.create(:wl_company)
      @user = FactoryBot.create(:network, :active)

      old_controller = @controller
      @controller = Api::V2::Advertisers::SessionsController.new
      post :create, params: { email: @user.contact_email, password: @user.password }
      @controller = old_controller

      token = JSON(response.body).token
      @request.headers['Authorization'] = token
    end
  end
end
