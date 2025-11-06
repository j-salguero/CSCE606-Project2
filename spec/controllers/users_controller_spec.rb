require 'rails_helper'

RSpec.describe UsersController, type: :controller do

    describe 'GET #new' do
        it 'gets a new user' do
            get :new
            expect(assigns(:user)).to be_a_new(User)
            expect(response).to render_template(:new)
        end
    end

    describe 'when creating a new user' do
        let(:valid_params) do
        {
            user: {
            name: "Bob",
            email: "bob@email.com",
            password: "password",
            password_confirmation: "password"
            }
        }
        end

        let(:invalid_params) do
        {
            user: {
            name: "",
            email: "invalid",
            password: "123",
            password_confirmation: "456"
            }
        }
        end

        it 'create valid user and redirect to collection_items page' do
            expect {
                post :create, params: valid_params
            }.to change(User, :count).by(1)

            user = User.last
            expect(session[:user_id]).to eq(user.id)
            expect(response).to redirect_to(collection_items_path)
            expect(flash[:notice]).to eq("Welcome to VinylVerse, #{user.name}!")
        end

        it 'create invalid user' do
            expect {
                post :create, params: invalid_params
            }.not_to change(User, :count)

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response).to render_template(:new)
            expect(flash.now[:alert]).to include("can't be blank").or include("doesn't match")
        end
    end

end