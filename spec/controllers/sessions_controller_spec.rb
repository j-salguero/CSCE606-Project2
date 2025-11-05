require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
    let(:user) { User.create!(name: "Bob", email: "bob@email.com", password: "password") }
    
    describe 'when creating a new session' do
        it 'log in user and redirect to collection_items page' do
            post :create, params: { email: user.email, password: "password" }
            expect(session[:user_id]).to eq(user.id)
            expect(response).to redirect_to(collection_items_path)
            expect(flash[:notice]).to eq("Welcome back to VinylVerse, #{user.name}!")
        end

        it 'invalid credentials does not log in' do
            post :create, params: { email: user.email, password: "wrongpassword" }
            expect(session[:user_id]).to be_nil
            expect(response).to render_template(:new)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(flash.now[:alert]).to eq("Invalid email or password")
        end
    end

    describe 'when logging out of session' do
        it 'should log out user and redirects to login page' do
            delete :destroy
            expect(session[:user_id]).to be_nil
            expect(response).to redirect_to(login_path)
            expect(flash[:notice]).to eq("You have been logged out.")
        end
    end
end