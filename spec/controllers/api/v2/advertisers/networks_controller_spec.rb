require 'rails_helper'

RSpec.describe Api::V2::Advertisers::NetworksController, type: :controller do
  describe '#show' do
    login_user

    context 'when user logged in' do
      login_user

      it "returns user's profile data" do
        get :show, params: { id: @user.id }

        expect(response).to be_successful
        expect(JSON(response.body).data.id).to eq(@user.id)
      end
    end

    context 'when user does not exist' do
      it 'returns record not found' do
        get :show, params: { id: @user.id + 1 }

        expect(JSON(response.body).message).to eq('Record not found.')
      end
    end
  end

  describe '#update' do
    login_user

    let(:valid_profile_attributes) { FactoryBot.attributes_for :network, name: Faker::Company.name }

    context 'when user does not exist' do
      it 'returns record not found' do
        put :update, params: { id: @user.id + 1, network: valid_profile_attributes }

        expect(JSON(response.body).message).to eq('Record not found.')
      end
    end

    context 'when user is logged in' do
      context 'with valid attributes' do
        it 'returns updated profile' do
          put :update, params: { id: @user.id, network: valid_profile_attributes }

          @user.reload
          expect(response).to have_http_status(:ok)
          expect(@user.name).to eq(valid_profile_attributes[:name])
        end
      end
    end
  end
end
