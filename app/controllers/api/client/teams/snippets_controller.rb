class Api::Client::Teams::SnippetsController < Api::Client::Teams::BaseController
  load_and_authorize_resource except: :search

  def index
    respond_with query_index
  end

  def create
    if @snippet.save
      respond_with @snippet
    else
      respond_with @snippet, status: :unprocessable_entity
    end
  end

  def update
    if @snippet.update(snippet_params)
      respond_with @snippet
    else
      respond_with @snippet, status: :unprocessable_entity
    end
  end

  def destroy
    if @snippet.destroy
      head :ok
    else
      respond_with @snippet, status: :unprocessable_entity
    end
  end

  def search_keys
    authorize! :read, Snippet
    respond_with Snippet.lookup_hash_keys(params[:search])
  end

  private

  def query_index
    @snippets.owned_by(params[:owner_type], params[:owner_id])
  end

  def snippet_params
    params
      .require(:snippet)
      .permit(:snippet_key, :owner_type, :owner_id, snippet_hash: {})
  end
end
