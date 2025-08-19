class Api::Client::Teams::AffiliateTagsController < Api::Client::AffiliateTagsController
  load_resource

  def create
    authorize! action, @affiliate_tag

    if @affiliate_tag.save
      respond_with @affiliate_tag
    else
      respond_with @affiliate_tag, status: :unprocessable_entity
    end
  end

  def update
    authorize! action, @affiliate_tag

    if @affiliate_tag.update(affiliate_tag_params)
      respond_with @affiliate_tag
    else
      respond_with @affiliate_tag.errors, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! action, @affiliate_tag

    if @affiliate_tag.destroy
      head :ok
    else
      respond_with @affiliate_tag.errors, status: :unprocessable_entity
    end
  end

  private

  def action
    ConstantProcessor.to_method_name("#{action_name}_#{@affiliate_tag.tag_type.gsub(/tag/i, '')}")
  end

  def affiliate_tag_params
    params.require(:affiliate_tag).permit(:name, :tag_type)
  end
end
