class Api::Client::CategoryGroupsController < Api::Client::BaseController
  load_and_authorize_resource

  def index
    @category_groups = query_index
    respond_with @category_groups, categories: truthy?(params[:categories])
  end

  def update
    if @category_group.update(category_group_params)
      respond_with @category_group
    else
      respond_with @category_group, status: :unprocessable_entity
    end
  end

  private

  def query_index
    collection = CategoryGroupCollection.new(current_ability, params).collect.order(name: :asc)
    collection = collection.preload(:categories) if truthy?(params[:categories])
    collection
  end

  def category_group_params
    params.require(:category_group).permit(:click_pixels)
  end
end
