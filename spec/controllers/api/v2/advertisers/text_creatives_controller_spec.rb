require 'rails_helper'

RSpec.describe Api::V2::Advertisers::TextCreativesController, type: :controller do
  login_user

  describe '#index' do
    let!(:text_creative) do
      FactoryBot.create(:text_creative)
    end

    context "when native ads don't exist" do
      it 'returns empty response' do
        get :index

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).data).to be_empty
      end
    end

    context 'when native ads exist' do
      context 'when logged in user have native ads' do
        let(:offer) { FactoryBot.create(:offer, network: @user) }
        let!(:text_creative_1) { FactoryBot.create(:text_creative, offer_variant: offer.offer_variants.first) }

        it "returns logged in user's native ads" do
          get :index

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body).data.first.id).to eq(text_creative_1.id)
        end
      end
    end

    describe '#filters' do
      describe 'pagination' do
        context 'when logged in user does not have any native ads' do
          it 'returns empty response' do
            get :index, params: { per_page: 2, page: 1 }

            resp = JSON.parse(response.body)
            expect(response).to have_http_status(:ok)
            expect(resp.keys).to include('meta')
            expect(resp.data).to be_empty
          end
        end

        context 'when logged in user has native ads' do
          let(:offer) { FactoryBot.create(:offer, network: @user) }
          let!(:text_creative_1) { FactoryBot.create(:text_creative, offer_variant: offer.offer_variants.first) }

          it "returns logged in user's native ads" do
            get :index, params: { per_page: 2, page: 1 }

            resp = JSON.parse(response.body)
            expect(response).to have_http_status(:ok)
            expect(resp.keys).to include('meta')
            expect(resp.data.first.id).to eq(text_creative_1.id)
          end
        end
      end

      describe 'status' do
        context 'when logged in user does not have any native ads' do
          it 'returns empty response' do
            get :index, params: { statuses: [VibrantConstant::Status::PENDING] }

            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body).data).to be_empty
          end
        end

        context 'when logged in user have native ads' do
          let(:offer) { FactoryBot.create(:offer, network: @user) }
          let!(:text_creative_1) { FactoryBot.create(:text_creative, offer_variant: offer.offer_variants.first) }

          context 'when native ads has status' do
            it 'returns native ads' do
              get :index, params: { statuses: [VibrantConstant::Status::PENDING] }

              resp = JSON.parse(response.body).data
              expect(response).to have_http_status(:ok)
              expect(resp.pluck('status')).to include(VibrantConstant::Status::PENDING)
              expect(resp.first.id).to eq(text_creative_1.id)
            end
          end

          context "when native ads don't have requested status" do
            it 'returns empty response' do
              get :index, params: { statuses: [VibrantConstant::Status::ACTIVE] }

              expect(response).to have_http_status(:ok)
              expect(JSON.parse(response.body).data).to be_empty
            end
          end
        end
      end

      describe 'offer_id' do
        context 'when logged in user does not have any native ads' do
          it 'returns empty response' do
            get :index, params: { offer_ids: [Offer.maximum(:id) + 1] }

            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body).data).to be_empty
          end
        end

        context 'when native ads includes requested offer ids' do
          let(:offer) { FactoryBot.create(:offer, network: @user) }
          let!(:native_ad_1) { FactoryBot.create(:text_creative, offer_variant: offer.offer_variants.first) }

          it 'returns native ads' do
            get :index, params: { offer_ids: [offer.id] }

            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body).data.first['offer']['id']).to eq(offer.id)
          end
        end

        context "when native ads doesn't include requested offer ids" do
          it 'returns native ads' do
            get :index, params: { offer_ids: [100] }

            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body).data).to be_empty
          end
        end
      end
    end
  end

  # TODO: Create tests for #update and #create

  # describe '#update' do
  #   context "when text creatives don't exist" do
  #     it 'returns record not found exception' do
  #       patch :update, params: { id: 100 }

  #       expect(response).to have_http_status(:not_found)
  #       expect(JSON.parse(response.body)['message']).to eq('Record not found.')
  #     end
  #   end

  #   context 'when text creatives found' do
  #     let(:offer) { FactoryBot.create(:offer, network: @user) }
  #     let(:native_ad_1) { FactoryBot.create(:text_creative, offer_variant: offer.offer_variants.first) }
  #     let(:payload) do
  #       {
  #         id: native_ad_1.id,
  #         locale: 'zh-TW',
  #         title: native_ad_1.title + ' updated',
  #         status_reason: ''
  #       }
  #     end

  #     it 'returns updated native ads' do
  #       patch :update, params: payload

  #       resp = JSON.parse(response.body).data
  #       expect(response).to have_http_status(:ok)
  #       expect(resp['title']).to eq(native_ad_1.title + ' updated')
  #       expect(resp['locale']).to eq('zh-TW')
  #       expect(resp['status']).to eq(VibrantConstant::Status::PENDING)
  #     end
  #   end
  # end

  # describe '#create' do
  #   context 'when required params are missing' do
  #     it 'returns exception' do
  #       post :create

  #       expect(response).to have_http_status(:unprocessable_entity)
  #       expect(JSON.parse(response.body)['message']).to include('param is missing or the value is empty')
  #     end
  #   end

  #   context 'when required fields are present' do
  #     let(:offer) { FactoryBot.create(:offer, network: @user) }

  #     let(:payload) do
  #       {
  #         text_creative: {
  #           active_date_start: DateTime.now,
  #           active_date_end: DateTime.now + 2.days,
  #           creative_name: Faker::Lorem.word,
  #           title: Faker::Lorem.word,
  #           content_1: Faker::Lorem.word,
  #           custom_landing_page: Faker::Internet.url,
  #           button_text: 'Click me',
  #           offer_variant_id: offer.offer_variants.first.id,
  #           deal_scope: 'Entire Store'
  #         }
  #       }
  #     end

  #     context 'when category id present' do
  #       let(:category) { FactoryBot.create(:category) }
  #       let(:payload_1) do
  #         { text_creative: payload[:text_creative].merge(category_ids: [category.id]) }
  #       end

  #       it 'returns created native ad' do
  #         post :create, params: payload_1

  #         resp = JSON.parse(response.body).data
  #         expect(response).to have_http_status(:created)
  #         expect(resp['categories']).to include(category.as_json)
  #         expect(resp['status']).to eq(VibrantConstant::Status::PENDING)
  #       end
  #     end

  #     context 'when requested category does not exist' do
  #       let(:payload_1) do
  #         payload[:text_creative].merge(category_id: [Category.maximum(:id) + 1])
  #       end

  #       it 'returns exception' do
  #         post :create, params: payload_1

  #         expect(response).to have_http_status(:not_found)
  #         expect(JSON.parse(response.body)['message']).to eq('Record not found.')
  #       end
  #     end
  #   end
  # end
end
