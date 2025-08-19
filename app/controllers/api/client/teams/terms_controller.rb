class Api::Client::Teams::TermsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @terms = paginate(query_index)
    respond_with_pagination @terms, meta: { t_columns: Term.dynamic_translatable_attribute_types  }
  end

  def create
    if @term.save
      respond_with @term
    else
      respond_with @term, status: :unprocessable_entity
    end
  end

  def update
    if @term.update(term_params)
      respond_with @term
    else
      respond_with @term, status: :unprocessable_entity
    end
  end

  def destroy
    if @term.destroy
      respond_with @term
    else
      respond_with @term, status: :unprocessable_entity
    end
  end

  def search
    authorize! :read, Term
    @terms = query_index
    respond_with @terms
  end

  private

  def query_index
    TermCollection.new(current_ability, params)
      .collect
      .preload_translations(:text)
      .order(text: :asc)
  end

  def term_params
    params.require(:term).permit(:text, translations_attributes: [:id, :locale, :field, :content])
  end
end
