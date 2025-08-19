require 'rails_helper'

RSpec.describe Api::V2::Advertisers::SessionsController, type: :controller do
  let!(:wl) { create(:wl_company) }

  describe '#create' do
    context 'when user requests for login' do
      context 'when no credentials supplied' do
        it 'returns unauthorized error response' do
          post :create, params: {}

          expect(response).to have_http_status(:unauthorized)
          expect(JSON.parse(response.body)).to eq({ 'message' => 'Invalid Login' })
        end
      end

      context 'when wrong credentials supplied' do
        it 'returns unauthorized error response' do
          post :create, params: { email: 'abc@test.com', password: '123456789' }

          expect(response).to have_http_status(:unauthorized)
          expect(JSON.parse(response.body)).to eq({ 'message' => 'Invalid Login' })
        end
      end

      context 'when correct credentials supplied' do
        let(:network) { create(:network, :active) }
        let(:params) do
          {
            email: network.contact_email,
            password: network.password
          }
        end
        let(:token) { DotOne::Utils::JsonWebToken.encode(network_id: network.id, email: network.contact_email) }

        before do
          allow(DotOne::Utils::JsonWebToken).to receive(:encode)
            .with(network_id: network.id, email: network.contact_email).and_return(token)
        end

        it 'returns success response' do
          post :create, params: params

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq({ 'token' => token })
        end
      end
    end
  end
end
