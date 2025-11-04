require 'rails_helper'

RSpec.describe CollectionItemsController, type: :controller do

  before do
    @release_data = {
    artist_id: 6542,
    title: "X&Y",
    thumb: "https://image.url/thumb.jpg",
    year: "2005",
    artist: "Coldplay"
  }.with_indifferent_access

    taylor = Artist.create(name: "Taylor Swift")
    mj = Artist.create!(name: "Michael Jackson")
    coldplay = Artist.create(discogs_id: 6542, name: "Coldplay", genre: "pop")

    album = Album.create(title: "X&Y", year:2005, artist_id: coldplay.id)

    allow(controller).to receive(:extract_artist_name).and_return("Coldplay")
    allow(controller).to receive(:extract_year).and_return(2005)

  end

  describe 'create collection_item' do
    # it "order based on query" do
    #     get :index
    #     expect(assigns(:artists).map(&:name)).to eq(["Coldplay", "Taylor Swift", "Michael Jackson"].sort)
    #     expect(assigns(:q)).to eq("")
    # end
    it "creates artist, album, and collection item, then redirects with success notice" do
        artist = Artist.find_by(name: 'Coldplay')
        album = Album.find_by(title: "X&Y")
        expect {
          post :create, params: { release: @release_data }
        }.to change(Artist, :count).by(0)
         .and change(Album, :count).by(0)
         .and change(CollectionItem, :count).by(1)

        artist = Artist.last
        album = Album.last
        collection_item = CollectionItem.last

        expect(artist.name).to eq("Coldplay")


        expect(response).to redirect_to(collection_items_path)
        # expect(flash[:notice]).to eq("X&Y by Coldplay added to your collection!")
      end

      # Not covering private method
      it 'extracts year' do
        post :create, params: { release: { artist: "Coldplay", title: "Parachutes", year: "1969" } }
        expect(Artist.last.name).to eq("Coldplay")
      end
  end

  describe 'destroy collection_item' do
    it 'redirects to the collection_items page and flashes a notice' do
      coldplay = Artist.create(discogs_id: 6542, name: "Coldplay", genre: "pop")
      album = Album.create(title: "X&Y", year:2005, artist_id: coldplay.id)
      collection_item = CollectionItem.create!(album: album)

      # expect(CollectionItem.exists?(collection_item.id)).to be true
      delete :destroy, params: { id: collection_item.id }

      expect(response).to redirect_to(collection_items_path)
    end
  end

  # describe 'extract artist name' do
  #   it '' do
  #     release_data = { title: "   Coldplay   - Parachutes  " }.with_indifferent_access
  #     expect(controller.send(:extract_artist_name, release_data)).to eq("Coldplay")
  #   end
  # end
  

end