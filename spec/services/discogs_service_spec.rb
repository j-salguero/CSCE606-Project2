require 'rails_helper'

RSpec.describe DiscogsService, type: :service do
    let(:discogs_service) { instance_double("DiscogsService") }
    let(:wrapper_double) { instance_double("Discogs::Wrapper") }
    let(:service) { DiscogsService.new }

    before do
        ENV['DISCOGS_TOKEN'] = nil
        ENV['DISCOGS_API_KEY'] = nil
        ENV['DISCOGS_API_SECRET'] = nil

        allow(Discogs::Wrapper).to receive(:new).and_return(wrapper_double)
    end

    describe 'when initializing service' do
        it 'authenticate using token' do
            ENV['DISCOGS_TOKEN'] = 'abc-token'
            expect(Discogs::Wrapper).to receive(:new).with("VinylTracker", user_token: 'abc-token').and_return(discogs_service)
            service = DiscogsService.new
            expect(service.instance_variable_get(:@client)).to eq(discogs_service)
        end

        it 'authenticate using API key' do
            ENV['DISCOGS_API_KEY'] = 'keyxyz'
            ENV['DISCOGS_API_SECRET'] = 'secret123'
            expect(Discogs::Wrapper).to receive(:new).with("VinylTracker", app_key: 'keyxyz', app_secret: 'secret123').and_return(discogs_service)
            service = DiscogsService.new
            expect(service.instance_variable_get(:@client)).to eq(discogs_service)
        end
    end

    describe 'when searching by artist name' do
        it 'return result of artists' do
            results = OpenStruct.new(results: ['artist1', 'artist2'])
            allow(wrapper_double).to receive(:search).with('Coldplay', type: :artist).and_return(results)

            response = service.search_artist('Coldplay')
            expect(response.results).to eq(['artist1', 'artist2'])
        end

        it 'return empty result with authentication error' do
            allow(wrapper_double).to receive(:search).and_raise(Discogs::AuthenticationError.new('401 Unauthorized'))
            response = service.search_artist('Coldplay')
            expect(response.results).to eq([])
        end

        it 'return empty result with standard error' do
            allow(wrapper_double).to receive(:search).and_raise(StandardError.new('Something went wrong'))
            response = service.search_artist('Coldplay')
            expect(response.results).to eq([])
        end
    end

    describe 'when searching by album releases' do

        it 'return list of releases' do
            results = OpenStruct.new(results: ['release1', 'release2'])
            allow(wrapper_double).to receive(:search).with('X&Y', type: :release, per_page: 20).and_return(results)

            response = service.search_releases('X&Y')
            expect(response.results).to eq(['release1', 'release2'])
        end

        it 'return empty releases with authentication error' do
            allow(wrapper_double).to receive(:search).and_raise(Discogs::AuthenticationError.new('401 Unauthorized'))
            response = service.search_releases('X&Y')
            expect(response.results).to eq([])
        end

        it 'return empty releases with standard error' do
            allow(wrapper_double).to receive(:search).and_raise(StandardError.new('Something went wrong'))
            response = service.search_releases('X&Y')
            expect(response.results).to eq([])
        end
    end

    describe 'when searching artist releases' do

        it 'return data on artist and album releases' do
            artist_data = OpenStruct.new(id: 123, name: 'Coldplay')
            artist_results = OpenStruct.new(results: [artist_data])
            releases_data = OpenStruct.new(releases: ['album1', 'album2'], pagination: nil)

            allow(wrapper_double).to receive(:search).with('Coldplay', type: :artist, per_page: 1).and_return(artist_results)
            allow(wrapper_double).to receive(:get_artist_releases).with(123, per_page: 50).and_return(releases_data)

            response = service.search_artist_releases('Coldplay')
            expect(response.artist).to eq(artist_data)
            expect(response.releases).to eq(['album1', 'album2'])
        end

        it 'return nil on data' do
            artist_results = OpenStruct.new(results: [])
            allow(wrapper_double).to receive(:search).and_return(artist_results)

            response = service.search_artist_releases('Unknown Artist')
            expect(response.artist).to be_nil
            expect(response.releases).to eq([])
        end

        it 'return empty releases with authentication error' do
            allow(wrapper_double).to receive(:search).and_raise(Discogs::AuthenticationError.new('401 Unauthorized'))
            response = service.search_artist_releases('Coldplay')
            expect(response.releases).to eq([])
        end

        it 'return empty releases with standard error' do
            allow(wrapper_double).to receive(:search).and_raise(StandardError.new('Something went wrong'))
            response = service.search_artist_releases('Coldplay')
            expect(response.releases).to eq([])
        end
    end

    describe 'when fetching artist' do
        it 'by id' do
            artist_data = double('artist')
            allow(wrapper_double).to receive(:get_artist).with(123).and_return(artist_data)
            expect(service.get_artist(123)).to eq(artist_data)
        end

        it 'return nil with standard error' do
            allow(wrapper_double).to receive(:get_artist).and_raise(StandardError)
            expect(service.get_artist(123)).to be_nil
        end
    end

    describe 'when fetching release album' do
        it 'by release id' do
            release_data = double('release')
            allow(wrapper_double).to receive(:get_release).with(123).and_return(release_data)
            expect(service.get_release(123)).to eq(release_data)
        end

        it 'return nil with standard' do
            allow(wrapper_double).to receive(:get_release).and_raise(StandardError)
            expect(service.get_release(123)).to be_nil
        end

    end
end