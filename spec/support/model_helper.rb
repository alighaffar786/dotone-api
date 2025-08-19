module ModelHelper
  def init_setup
    before(:each) do
      @wl_company = FactoryBot.create(:wl_company)
      @current_affiliate = FactoryBot.create(:affiliate)
    end
  end
end
