require 'rails_helper'

RSpec.describe Api::V2::Advertisers::ImageCreativesController, type: :controller do
  login_user

  describe '#index' do
    let(:offer) { FactoryBot.create(:offer, network: @user) }

    context 'List all banners' do
      let!(:image_creative) { FactoryBot.create(:image_creative) }
      context 'when records not found' do
        it 'returns empty array' do
          get :index

          expect(response).to have_http_status(:ok)
          expect(JSON(response.body).data).to be_empty
        end
      end

      context 'when records found' do
        let!(:image_creative2) { FactoryBot.create(:image_creative, offer_variant: offer.offer_variants.first) }
        let!(:image_creative3) do
          FactoryBot.create(:image_creative, :rejected, offer_variant: offer.offer_variants.first)
        end

        it 'will returns all records' do
          get :index

          resp = JSON(response.body).data

          expect(response).to have_http_status(:ok)
          expect(resp.pluck('status')).to include(ImageCreative.status_rejected)
          expect(resp.count).to eq(2)
        end
      end
    end

    describe 'filters' do
      let!(:image_creative) { FactoryBot.create(:image_creative, offer_variant: offer.offer_variants.first) }
      let!(:image_creative_2) { FactoryBot.create(:image_creative, offer_variant: offer.offer_variants.first) }

      context 'when pagination params exists' do
        it 'returns paginated records' do
          get :index, params: { page: 1, per_page: 10 }

          resp = JSON(response.body)
          expect(response).to have_http_status(:ok)
          expect(resp.keys).to include('meta')
          expect(resp.data.count).to eq(2)
        end
      end

      context 'when offer_id present' do
        context 'when image_creatives exists of that offer' do
          it 'returns records' do
            get :index, params: { offer_id: offer.id.to_s }

            expect(response).to have_http_status(:ok)
            expect(JSON(response.body).data.count).to eq(2)
          end
        end

        context 'when multiple offer_ids passed' do
          let(:offer_2) { FactoryBot.create(:offer, network: @user) }
          let!(:image_creative_3) do
            FactoryBot.create(:image_creative, offer_variant: offer_2.offer_variants.first)
          end

          context 'when banners found for all offer_ids' do
            it 'returns banner records' do
              get :index, params: { offer_id: @user.offers.ids.join(',') }

              resp = JSON(response.body).data

              expect(response).to have_http_status(:ok)
              expect(resp.pluck('offer').pluck('id').uniq).to eq(@user.offers.ids)
              expect(resp.count).to eq(3)
            end
          end

          context 'when banners found for some offer_ids' do
            it 'returns found banner records' do
              get :index, params: { offer_ids: [offer.id.to_s, '100'] }

              resp = JSON(response.body).data
              expect(response).to have_http_status(:ok)
              expect(resp.pluck('offer').pluck('id').uniq).to eq([offer.id])
              expect(resp.count).to eq(2)
            end
          end
        end

        context 'when image_creatives does not exists' do
          it 'returns empty response' do
            get :index, params: { offer_ids: [100] }

            expect(response).to have_http_status(:ok)
            expect(JSON(response.body).data.count).to be_zero
          end
        end
      end

      context 'when status present' do
        context 'when image_creatives exists that status' do
          it 'returns records' do
            get :index, params: { status: ImageCreative.status_pending }

            expect(response).to have_http_status(:ok)
            expect(JSON(response.body).data.count).to eq(2)
          end
        end

        context 'when multiple statuses passed' do
          context 'when banners found for all statuses' do
            let!(:image_creative3) do
              FactoryBot.create(:image_creative, :rejected, offer_variant: offer.offer_variants.first)
            end

            it 'returns all found banner records' do
              get :index, params: { status: [ImageCreative.status_pending, ImageCreative.status_rejected].join(',') }

              expect(response).to have_http_status(:ok)
              expect(JSON(response.body).data.count).to eq(3)
            end
          end

          context 'when banners found for some statuses' do
            it 'returns all found banner records' do
              get :index, params: { status: [ImageCreative.status_pending, ImageCreative.status_rejected].join(',') }

              expect(response).to have_http_status(:ok)
              expect(JSON(response.body).data.count).to eq(2)
            end
          end
        end

        context 'when image_creatives does not exists of that status' do
          it 'returns empty response' do
            get :index, params: { statuses: [ImageCreative.status_active] }

            expect(response).to have_http_status(:ok)
            expect(JSON(response.body).data.count).to be_zero
          end
        end
      end
    end
  end

  describe '#update' do
    let(:offer) { FactoryBot.create(:offer, network: @user) }
    let(:offer_variant) { offer.offer_variants.first }
    let(:image_creative) { FactoryBot.create(:image_creative, :active, offer_variant: offer_variant) }

    context 'when record found' do
      let(:params) do
        {
          id: image_creative.id,
          image_creative: {
            locale: %w[zh-TW en-US].sample,
            active_date_start: DateTime.now
          }
        }
      end

      it 'will update successfully' do
        put :update, params: params

        resp = JSON(response.body).data

        expect(response).to have_http_status(:ok)
        expect(resp.is_infinity_time).to be_falsey
        expect(resp.status).to eq(ImageCreative.status_active)
        expect(resp.locale).to eq(params[:image_creative][:locale])
      end
    end

    context 'when record not found' do
      it 'will returns not found exception' do
        put :update, params: { id: 1000 }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#create' do
    let(:offer) { FactoryBot.create(:offer, network: @user) }
    let(:params) do
      {
        image_creative: {
          offer_variant_id: offer.offer_variants.ids.first,
          locale: %w[zh-TW en-US].sample,
          status: ImageCreative.status_pending,
          is_infinity_true: true,
          cdn_url: Faker::Internet.url
        }
      }
    end

    context 'Create new banner' do
      context 'when banner is successfully created' do
        it 'returns created banner' do
          post :create, params: params

          resp = JSON(response.body).data

          expect(response).to have_http_status(:ok)
          expect(resp['status']).to include(ImageCreative.status_pending)
          expect(resp['offer_variant_id']).to eq(params[:image_creative][:offer_variant_id])
        end
      end

      context 'when images are not included in the params' do
        it 'will throw missing parameter exception' do
          post :create, params: { image_creative: params[:image_creative].except(:cdn_url) }

          expect(JSON(response.body).message).to include("CDN URL can't be blank")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when logged in user didn't have specific offer variant" do
        let(:new_params) do
          params[:image_creative][:offer_variant_id] = 1000
          params
        end

        it 'will throw record not found exception' do
          post :create, params: new_params

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
