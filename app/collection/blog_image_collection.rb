class BlogImageCollection < BaseCollection
  private

  def filter_by_search
    filter do
      @relation.like(params[:search])
    end
  end
end
