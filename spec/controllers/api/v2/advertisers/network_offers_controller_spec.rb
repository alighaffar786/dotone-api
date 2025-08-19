require 'rails_helper'

RSpec.describe Api::V2::Advertisers::NetworkOffersController, type: :controller do
  let!(:wl) { create(:wl_company) }

  describe '#index' do
    let(:offers) { create_list(:offer, 5, network: @user) }

    context 'when user requests for network offers' do
      context 'when user is not authenticated' do
        it 'returns unauthorized error response' do
          offers
          get :index

          expect(response).to have_http_status(:unauthorized)
          expect(JSON.parse(response.body)).to eq({ 'message'=>'You are not authorized' })
        end
      end

      context 'when user is authenticated' do
        include_context 'with Stats'

        context 'when user has no network offers' do
          before do
            offers
          end

          login_user

          it 'returns no network offers' do
            get :index

            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body).data.pluck('id')).to eq([])
            expect(JSON.parse(response.body).data.count).to eq(0)
          end
        end

        context 'when user has network offers' do
          login_user

          it 'returns network offers' do
            offers
            get :index

            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body).data.pluck('id')).to eq(offers.pluck(:id))
            expect(JSON.parse(response.body).data.count).to eq(offers.count)
          end
        end
      end
    end
  end
end
