require 'rails_helper'

RSpec.describe SearchController, type: :controller do
    let(:discogs_service) { instance_double("DiscogsService") }

    before do
        allow(DiscogsService).to receive(:new).and_return(discogs_service)
    end

    describe 'Search for query' do
        it 'when query is artist name' do
            artist_name = "Coldplay"
            fake_results = [{ title: "X&Y" }, { title: "Fix You" }]
            allow(discogs_service).to receive(:search_artist_releases).with(artist_name).and_return(fake_results)

            get :index, params: { artist_name: artist_name }

            expect(assigns(:search_data)).to eq(fake_results)

        end

        it 'when query is album name' do
            album_name = "X&Y"
            fake_album_results = [{ artist: "Coldplay", title: "X&Y" }]
            allow(discogs_service).to receive(:search_releases).with(album_name).and_return(fake_album_results)

            get :index, params: { album_name: album_name }

            expect(assigns(:album_results)).to eq(fake_album_results)
        end
    end
end