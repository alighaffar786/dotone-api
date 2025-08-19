class Client::PagesController < Client::BaseController
  before_action :set_page, except: :index

  private

  def set_page
    @page = :main
  end
end
