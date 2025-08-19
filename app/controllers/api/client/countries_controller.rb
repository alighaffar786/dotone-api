class Api::Client::CountriesController < Api::Client::BaseController
  load_and_authorize_resource

  def index
    respond_with query_index
  end

  def create
    if @country.save
      respond_with @country
    else
      respond_with @country, status: :unprocessable_entity
    end
  end

  def update
    if @country.update(country_params)
      respond_with @country
    else
      respond_with @country, status: :unprocessable_entity
    end
  end

  def destroy
    if @country.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def query_index
    CountryCollection.new(current_ability, params).collect.order(name: :asc)
  end

  def country_params
    params.require(:country).permit(:code, :continent, :iso_3_country_code, :name)
  end
end
