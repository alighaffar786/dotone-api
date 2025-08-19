class CountryCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_continents if params[:continents].present?
  end

  def filter_by_continents
    filter { @relation.where(continent: params[:continents]) }
  end

  def filter_by_search
    filter do
      @relation.like(params[:search])
    end
  end
end
