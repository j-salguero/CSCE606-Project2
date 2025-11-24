# spec/services/discogs_service_spec.rb
require 'rails_helper'

RSpec.describe DiscogsService, type: :service do
  let(:mock_client) { instance_double("Discogs::Wrapper") }
  let(:service) { described_class.new }

  before do
    allow(Discogs::Wrapper).to receive(:new).and_return(mock_client)
  end

  describe "#initialize" do
    it "authenticates with DISCOGS_TOKEN if present" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("DISCOGS_TOKEN").and_return("fake_token")
      expect(Discogs::Wrapper).to receive(:new).with("VinylTracker", user_token: "fake_token")
      described_class.new
    end

    it "authenticates with API key/secret if DISCOGS_TOKEN is missing" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("DISCOGS_TOKEN").and_return(nil)
      expect(Discogs::Wrapper).to receive(:new).with("VinylTracker")
      described_class.new
    end
  end

  describe "#search_artist" do
    it "returns results when successful" do
      results = OpenStruct.new(results: [OpenStruct.new(id: 1)])
      allow(mock_client).to receive(:search).and_return(results)
      expect(service.search_artist("Kanye").results.count).to eq(1)
    end

    it "returns empty results when authentication error occurs" do
      allow(mock_client).to receive(:search).and_raise(Discogs::AuthenticationError.new("Invalid token"))
      result = service.search_artist("Adele")
      expect(result.results).to eq([])
    end

    it "returns empty results when a standard error occurs" do
      allow(mock_client).to receive(:search).and_raise(StandardError.new("Network error"))
      result = service.search_artist("Drake")
      expect(result.results).to eq([])
    end
  end

  describe "#search_releases" do
    it "returns results when successful" do
      results = OpenStruct.new(results: [OpenStruct.new(id: 42)])
      allow(mock_client).to receive(:search).and_return(results)
      expect(service.search_releases("The Beatles").results.first.id).to eq(42)
    end

    it "returns empty results when authentication error occurs" do
      allow(mock_client).to receive(:search).and_raise(Discogs::AuthenticationError.new("Invalid token"))
      result = service.search_releases("Radiohead")
      expect(result.results).to eq([])
    end

    it "returns empty results when a standard error occurs" do
      allow(mock_client).to receive(:search).and_raise(StandardError.new("Bad request"))
      result = service.search_releases("Coldplay")
      expect(result.results).to eq([])
    end
  end

  describe "#find_artist_id_by_name" do
    it "returns artist id when found" do
      artist = OpenStruct.new(id: 123)
      results = OpenStruct.new(results: [artist])
      allow(mock_client).to receive(:search).and_return(results)
      
      expect(service.find_artist_id_by_name("Radiohead")).to eq(123)
    end

    it "returns nil when no results found" do
      results = OpenStruct.new(results: [])
      allow(mock_client).to receive(:search).and_return(results)
      
      expect(service.find_artist_id_by_name("Unknown Artist")).to be_nil
    end

    it "returns nil when search_artist returns nil" do
      allow(service).to receive(:search_artist).and_return(nil)
      
      expect(service.find_artist_id_by_name("Test")).to be_nil
    end

    it "returns nil when error occurs" do
      allow(service).to receive(:search_artist).and_raise(StandardError.new("Error"))
      
      expect(service.find_artist_id_by_name("Test")).to be_nil
    end
  end

  describe "#search_artist_releases" do
    it "returns structured data when artist and releases are found" do
      artist = OpenStruct.new(id: 5, name: "Daft Punk")
      artist_results = OpenStruct.new(results: [artist])
      releases = OpenStruct.new(releases: [OpenStruct.new(title: "Discovery")], pagination: OpenStruct.new(page: 1))

      allow(mock_client).to receive(:search).and_return(artist_results)
      allow(mock_client).to receive(:get_artist_releases).and_return(releases)

      result = service.search_artist_releases("Daft Punk")
      expect(result.artist.name).to eq("Daft Punk")
      expect(result.releases.first.title).to eq("Discovery")
    end

    it "returns empty struct when no artist found" do
      allow(mock_client).to receive(:search).and_return(OpenStruct.new(results: []))
      result = service.search_artist_releases("Unknown Artist")
      expect(result.artist).to be_nil
      expect(result.releases).to eq([])
    end

    it "returns empty struct on authentication error" do
      allow(mock_client).to receive(:search).and_raise(Discogs::AuthenticationError.new("Auth error"))
      result = service.search_artist_releases("Test")
      expect(result.releases).to eq([])
    end

    it "returns empty struct on standard error" do
      allow(mock_client).to receive(:search).and_raise(StandardError.new("Timeout"))
      result = service.search_artist_releases("Test")
      expect(result.releases).to eq([])
    end
  end

  describe "#get_artist" do
    it "returns artist when successful" do
      artist = OpenStruct.new(name: "Prince")
      allow(mock_client).to receive(:get_artist).and_return(artist)
      expect(service.get_artist(1).name).to eq("Prince")
    end

    it "returns nil when error occurs" do
      allow(mock_client).to receive(:get_artist).and_raise(StandardError.new("Error"))
      expect(service.get_artist(1)).to be_nil
    end
  end

  describe "#get_release" do
    it "returns release when successful" do
      release = OpenStruct.new(title: "Thriller")
      allow(mock_client).to receive(:get_release).and_return(release)
      expect(service.get_release(1).title).to eq("Thriller")
    end

    it "returns nil when error occurs" do
      allow(mock_client).to receive(:get_release).and_raise(StandardError.new("Error"))
      expect(service.get_release(1)).to be_nil
    end
  end

  describe "#get_artist_releases" do
    it "returns releases when successful" do
      releases = OpenStruct.new(
        releases: [OpenStruct.new(id: 1, title: "Album 1")],
        pagination: OpenStruct.new(items: 10, pages: 2)
      )
      allow(mock_client).to receive(:get_artist_releases).and_return(releases)
      
      result = service.get_artist_releases(123)
      expect(result.releases.count).to eq(1)
      expect(result.pagination.items).to eq(10)
    end

    it "accepts page and per_page parameters" do
      releases = OpenStruct.new(releases: [], pagination: OpenStruct.new(items: 0, pages: 0))
      expect(mock_client).to receive(:get_artist_releases).with(123, page: 2, per_page: 25).and_return(releases)
      
      service.get_artist_releases(123, page: 2, per_page: 25)
    end

    it "returns empty struct when error occurs" do
      allow(mock_client).to receive(:get_artist_releases).and_raise(StandardError.new("Error"))
      
      result = service.get_artist_releases(123)
      expect(result.releases).to eq([])
      expect(result.pagination.items).to eq(0)
    end
  end

  describe "#releases_count_for_artist" do
    it "returns count from pagination" do
      releases = OpenStruct.new(
        releases: [],
        pagination: OpenStruct.new(items: 42, pages: 1)
      )
      allow(mock_client).to receive(:get_artist_releases).and_return(releases)
      
      expect(service.releases_count_for_artist(artist_id: 123)).to eq(42)
    end

    it "returns 0 when pagination is nil" do
      releases = OpenStruct.new(releases: [], pagination: nil)
      allow(mock_client).to receive(:get_artist_releases).and_return(releases)
      
      expect(service.releases_count_for_artist(artist_id: 123)).to eq(0)
    end

    it "returns 0 when get_artist_releases returns nil" do
      allow(service).to receive(:get_artist_releases).and_return(nil)
      
      expect(service.releases_count_for_artist(artist_id: 123)).to eq(0)
    end
  end

  describe "#genre_for_artist" do
    let(:releases_response) do
      OpenStruct.new(
        releases: [OpenStruct.new(id: 456)],
        pagination: OpenStruct.new(items: 1)
      )
    end

    it "returns genre from first release" do
      release = OpenStruct.new(genres: ["Rock", "Alternative"], styles: [])
      allow(mock_client).to receive(:get_artist_releases).and_return(releases_response)
      allow(mock_client).to receive(:get_release).and_return(release)
      
      expect(service.genre_for_artist(123)).to eq("Rock")
    end

    it "returns style when genres are empty" do
      release = OpenStruct.new(genres: [], styles: ["Indie Rock"])
      allow(mock_client).to receive(:get_artist_releases).and_return(releases_response)
      allow(mock_client).to receive(:get_release).and_return(release)
      
      expect(service.genre_for_artist(123)).to eq("Indie Rock")
    end

    it "returns nil when no releases found" do
      empty_releases = OpenStruct.new(releases: [], pagination: OpenStruct.new(items: 0))
      allow(mock_client).to receive(:get_artist_releases).and_return(empty_releases)
      
      expect(service.genre_for_artist(123)).to be_nil
    end

    it "returns nil when release has no genres or styles" do
      release = OpenStruct.new(genres: [], styles: [])
      allow(mock_client).to receive(:get_artist_releases).and_return(releases_response)
      allow(mock_client).to receive(:get_release).and_return(release)
      
      expect(service.genre_for_artist(123)).to be_nil
    end

    it "returns nil when get_release returns nil" do
      allow(mock_client).to receive(:get_artist_releases).and_return(releases_response)
      allow(mock_client).to receive(:get_release).and_return(nil)
      
      expect(service.genre_for_artist(123)).to be_nil
    end

    it "returns nil when error occurs" do
      allow(mock_client).to receive(:get_artist_releases).and_raise(StandardError.new("Error"))
      
      expect(service.genre_for_artist(123)).to be_nil
    end
  end

  describe "#country_for_artist" do
    let(:releases_response) do
      OpenStruct.new(
        releases: [OpenStruct.new(id: 789)],
        pagination: OpenStruct.new(items: 1)
      )
    end

    it "returns country from first release" do
      release = OpenStruct.new(country: "UK")
      allow(mock_client).to receive(:get_artist_releases).and_return(releases_response)
      allow(mock_client).to receive(:get_release).and_return(release)
      
      expect(service.country_for_artist(123)).to eq("UK")
    end

    it "returns nil when no releases found" do
      empty_releases = OpenStruct.new(releases: [], pagination: OpenStruct.new(items: 0))
      allow(mock_client).to receive(:get_artist_releases).and_return(empty_releases)
      
      expect(service.country_for_artist(123)).to be_nil
    end

    it "returns nil when release doesn't respond to country" do
      release = OpenStruct.new(title: "Album")
      allow(release).to receive(:respond_to?).with(:country).and_return(false)
      allow(mock_client).to receive(:get_artist_releases).and_return(releases_response)
      allow(mock_client).to receive(:get_release).and_return(release)
      
      expect(service.country_for_artist(123)).to be_nil
    end

    it "returns nil when get_release returns nil" do
      allow(mock_client).to receive(:get_artist_releases).and_return(releases_response)
      allow(mock_client).to receive(:get_release).and_return(nil)
      
      expect(service.country_for_artist(123)).to be_nil
    end

    it "returns nil when error occurs" do
      allow(mock_client).to receive(:get_artist_releases).and_raise(StandardError.new("Error"))
      
      expect(service.country_for_artist(123)).to be_nil
    end
  end
end