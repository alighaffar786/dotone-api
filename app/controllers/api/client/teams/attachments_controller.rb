class Api::Client::Teams::AttachmentsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    respond_with @attachments.owned_by(params[:owner_type], params[:owner_id])
  end

  def create
    @attachment.uploader = current_user

    if @attachment.save
      respond_with @attachment
    else
      respond_with @attachment, status: :unprocessable_entity
    end
  end

  def update
    if @attachment.update(attachment_params)
      respond_with @attachment
    else
      respond_with @attachment, status: :unprocessable_entity
    end
  end

  def destroy
    if @attachment.destroy
      head :ok
    else
      respond_with @attachment, status: :unprocessable_entity
    end
  end

  private

  def attachment_params
    params.require(:attachment).permit(:name, :link, :owner_type, :owner_id)
  end
end
