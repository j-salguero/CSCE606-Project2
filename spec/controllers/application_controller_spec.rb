# spec/controllers/application_controller_spec.rb
require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    before_action :require_login, only: :restricted

    def index
      render plain: "OK"
    end

    def restricted
      render plain: "Restricted content"
    end
  end

  let(:user) { instance_double(User, id: 1) }

  describe "#current_user" do
    it "returns the user if session[:user_id] is present" do
      session[:user_id] = 1
      allow(User).to receive(:find_by).with(id: 1).and_return(user)
      expect(controller.send(:current_user)).to eq(user)
    end

    it "returns nil if session[:user_id] is not present" do
      session[:user_id] = nil
      expect(controller.send(:current_user)).to be_nil
    end
  end

  describe "#logged_in?" do
    it "returns true when user is present" do
      allow(controller).to receive(:current_user).and_return(user)
      expect(controller.send(:logged_in?)).to be true
    end

    it "returns false when user is nil" do
      allow(controller).to receive(:current_user).and_return(nil)
      expect(controller.send(:logged_in?)).to be false
    end
  end

  describe "#require_login" do
    before { routes.draw { get "restricted" => "anonymous#restricted" } }

    it "redirects and sets flash alert if not logged in" do
      allow(controller).to receive(:logged_in?).and_return(false)
      get :restricted
      expect(flash[:alert]).to eq("You must be logged in to access this page")
      expect(response).to redirect_to(login_path)
    end

    it "renders normally when logged in" do
      allow(controller).to receive(:logged_in?).and_return(true)
      get :restricted
      expect(response.body).to eq("Restricted content")
    end
  end
end
