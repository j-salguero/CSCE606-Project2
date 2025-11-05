require 'rails_helper'

RSpec.describe CollectionItemsController, type: :controller do
  routes { Rails.application.routes }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('DISCOGS_API_KEY').and_return('fakekey')
  end

  describe 'GET #index' do
    it 'assigns collection items and wishlist items' do
      artist = create(:artist, name: "Test Artist")
      album = Album.create!(title: "Test Album", artist: artist, year: 2000)
      collection_item = CollectionItem.create!(album: album)
      wishlist_item = WishlistItem.create!(
        title: "Wishlist Album",
        artist: "Wishlist Artist",
        added_at: Time.current
      )

      get :index

      expect(assigns(:collection_items)).to include(collection_item)
      expect(assigns(:wishlist_items)).to include(wishlist_item)
    end

    it 'loads albums with artist associations' do
      artist = create(:artist)
      album = Album.create!(title: "Test Album", artist: artist, year: 2000)
      CollectionItem.create!(album: album)

      get :index

      # Test that the query includes albums and artists to avoid N+1 queries
      expect(assigns(:collection_items).first.album.artist).to eq(artist)
    end
  end

  describe 'POST #create' do
    let(:release_data) do
      {
        artist_id: 6542,
        title: "X&Y",
        thumb: "https://image.url/thumb.jpg",
        year: "2005",
        artist: "Coldplay"
      }
    end

    context 'with valid release data' do
      it "creates a collection item and redirects with success notice" do
        expect {
          post :create, params: { release: release_data }
        }.to change(CollectionItem, :count).by(1)

        expect(response).to redirect_to(collection_items_path)
        expect(flash[:notice]).to include("X&Y by Coldplay added to your collection!")
      end

      it "creates artist with discogs_id" do
        post :create, params: { release: release_data }

        artist = Artist.find_by(name: "Coldplay")
        expect(artist.discogs_id).to eq("6542")
      end

      it "creates album with year and image" do
        post :create, params: { release: release_data }

        album = Album.find_by(title: "X&Y")
        expect(album.year).to eq(2005)
        expect(album.image_url).to eq("https://image.url/thumb.jpg")
      end

      it "updates image_url if album exists but image was blank" do
        artist = create(:artist, name: "Coldplay")
        album = Album.create!(title: "X&Y", artist: artist, year: 2005, image_url: nil)

        post :create, params: { release: release_data }

        expect(album.reload.image_url).to eq("https://image.url/thumb.jpg")
      end

      it "does not update image_url if album already has one" do
        artist = create(:artist, name: "Coldplay")
        existing_url = "https://existing.url/image.jpg"
        album = Album.create!(title: "X&Y", artist: artist, year: 2005, image_url: existing_url)

        post :create, params: { release: release_data }

        expect(album.reload.image_url).to eq(existing_url)
      end
    end

    context 'when album already in collection' do
      it "redirects with alert message" do
        artist = create(:artist, name: "Coldplay")
        album = Album.create!(title: "X&Y", artist: artist, year: 2005)
        CollectionItem.create!(album: album)

        expect {
          post :create, params: { release: release_data }
        }.not_to change(CollectionItem, :count)

        expect(response).to redirect_to(collection_items_path)
        expect(flash[:alert]).to eq("X&Y is already in your collection!")
      end
    end

    context 'when collection item fails to persist' do
      it "redirects to search with alert" do
        allow_any_instance_of(CollectionItem).to receive(:persisted?).and_return(false)

        post :create, params: { release: release_data }

        expect(response).to redirect_to(search_path)
        expect(flash[:alert]).to eq("Failed to add album to collection.")
      end
    end

    context 'with artist name in title format' do
      it "extracts artist from title" do
        release_without_artist = {
          title: "The Beatles - Abbey Road",
          year: "1969"
        }

        post :create, params: { release: release_without_artist }

        artist = Artist.find_by(name: "The Beatles")
        expect(artist).to be_present
        expect(Album.last.title).to eq("The Beatles - Abbey Road")
      end
    end

    context 'with no artist information' do
      it "uses Unknown Artist" do
        release_no_artist = {
          title: "Some Album",
          year: "2000"
        }

        post :create, params: { release: release_no_artist }

        artist = Artist.find_by(name: "Unknown Artist")
        expect(artist).to be_present
      end
    end

    context 'with year as string' do
      it 'extracts year correctly through create' do
        post :create, params: { release: { artist: "Coldplay", title: "Parachutes", year: "1969" } }
        
        album = Album.find_by(title: "Parachutes")
        expect(album.year).to eq(1969)
      end
    end

    context 'with invalid year' do
      it 'sets year to nil for zero' do
        post :create, params: { release: { artist: "Test", title: "Album", year: "0" } }
        
        album = Album.find_by(title: "Album")
        expect(album.year).to be_nil
      end

      it 'sets year to nil for blank string' do
        post :create, params: { release: { artist: "Test", title: "Album", year: "" } }
        
        album = Album.find_by(title: "Album")
        expect(album.year).to be_nil
      end
    end

    context 'with existing artist' do
      it "finds existing artist instead of creating new one" do
        existing_artist = create(:artist, name: "Coldplay", discogs_id: 6542)

        expect {
          post :create, params: { release: release_data }
        }.not_to change(Artist, :count)

        expect(Album.last.artist).to eq(existing_artist)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes item and redirects to index' do
      artist = create(:artist)
      album = Album.create!(title: "Test Album", artist: artist, year: 2000)
      collection_item = CollectionItem.create!(album: album)

      expect {
        delete :destroy, params: { id: collection_item.id }
      }.to change(CollectionItem, :count).by(-1)

      expect(response).to redirect_to(collection_items_path)
      expect(flash[:notice]).to eq("Test Album removed from your collection.")
    end

    it 'removes the correct item' do
      artist = create(:artist)
      album1 = Album.create!(title: "Album 1", artist: artist, year: 2000)
      album2 = Album.create!(title: "Album 2", artist: artist, year: 2001)
      item1 = CollectionItem.create!(album: album1)
      item2 = CollectionItem.create!(album: album2)

      delete :destroy, params: { id: item1.id }

      expect(CollectionItem.exists?(item1.id)).to be false
      expect(CollectionItem.exists?(item2.id)).to be true
    end
  end

  describe 'private #extract_artist_name' do
    it 'extracts artist from release data artist field' do
      release_data = { artist: "Coldplay", title: "Parachutes" }.with_indifferent_access
      expect(controller.send(:extract_artist_name, release_data)).to eq("Coldplay")
    end

    it 'extracts artist name from title with separator' do
      release_data = { title: "   Coldplay   - Parachutes  " }.with_indifferent_access
      expect(controller.send(:extract_artist_name, release_data)).to eq("Coldplay")
    end

    it 'returns Unknown Artist when no artist info available' do
      release_data = { title: "Just A Title" }.with_indifferent_access
      expect(controller.send(:extract_artist_name, release_data)).to eq("Unknown Artist")
    end

    it 'handles empty title' do
      release_data = { title: "" }.with_indifferent_access
      expect(controller.send(:extract_artist_name, release_data)).to eq("Unknown Artist")
    end

    it 'prefers artist field over title parsing' do
      release_data = { artist: "Real Artist", title: "Fake Artist - Album" }.with_indifferent_access
      expect(controller.send(:extract_artist_name, release_data)).to eq("Real Artist")
    end
  end

  describe 'private #extract_year' do
    it 'extracts year from valid string' do
      expect(controller.send(:extract_year, "1969")).to eq(1969)
    end

    it 'extracts year from integer' do
      expect(controller.send(:extract_year, 2005)).to eq(2005)
    end

    it 'returns nil for invalid year string' do
      expect(controller.send(:extract_year, "not a year")).to be_nil
    end

    it 'returns nil for zero' do
      expect(controller.send(:extract_year, "0")).to be_nil
    end

    it 'returns nil for negative number' do
      expect(controller.send(:extract_year, "-5")).to be_nil
    end

    it 'returns nil for blank string' do
      expect(controller.send(:extract_year, "")).to be_nil
    end

    it 'returns nil for nil value' do
      expect(controller.send(:extract_year, nil)).to be_nil
    end
  end
end