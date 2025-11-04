require 'rails_helper'

RSpec.describe ArtistsController, type: :controller do

  before do
    Artist.create(name: "Coldplay")
    Artist.create(name: "Taylor Swift")
    Artist.create(name: "Michael Jackson")
  end

  describe 'get artist list' do
    it "order based on query" do
        get :index
        expect(assigns(:artists).map(&:name)).to eq(["Coldplay", "Taylor Swift", "Michael Jackson"].sort)
        expect(assigns(:q)).to eq("")
    end

    it 'order without query' do
      get :index, params: { q: "taylor" }
      expect(assigns(:artists).map(&:name)).to eq(["Taylor Swift"])
      expect(assigns(:q)).to eq("taylor")
    end
  end

  

end