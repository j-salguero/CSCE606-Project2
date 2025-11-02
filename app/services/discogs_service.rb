# app/services/discogs_service.rb
require 'ostruct'

class DiscogsService
  def initialize
    # Use personal access token for authentication
    if ENV['DISCOGS_TOKEN'].present?
      @client = Discogs::Wrapper.new("VinylTracker", user_token: ENV['DISCOGS_TOKEN'])
    else
      # Fallback to app key/secret (may have limited access)
      @client = Discogs::Wrapper.new("VinylTracker") do |c|
        c.app_key = ENV['DISCOGS_API_KEY']
        c.app_secret = ENV['DISCOGS_API_SECRET']
      end
    end
  end

  def search_artist(artist_name)
    begin
      # Search for artists
      results = @client.search(artist_name, type: :artist)
      Rails.logger.info "Discogs search returned #{results.results.count} results"
      results
    rescue Discogs::AuthenticationError => e
      Rails.logger.error("Discogs API authentication error: #{e.message}")
      Rails.logger.error("API Key present: #{ENV['DISCOGS_API_KEY'].present?}")
      Rails.logger.error("API Secret present: #{ENV['DISCOGS_API_SECRET'].present?}")
      OpenStruct.new(results: [])
    rescue StandardError => e
      Rails.logger.error("Discogs API error: #{e.message}")
      OpenStruct.new(results: [])
    end
  end

  def search_releases(query)
    begin
      # Search for releases (albums, singles, etc.)
      results = @client.search(query, type: :release, per_page: 20)
      Rails.logger.info "Discogs release search returned #{results.results.count} results"
      results
    rescue Discogs::AuthenticationError => e
      Rails.logger.error("Discogs API authentication error: #{e.message}")
      OpenStruct.new(results: [])
    rescue StandardError => e
      Rails.logger.error("Discogs API error: #{e.message}")
      OpenStruct.new(results: [])
    end
  end

    def find_artist_id_by_name(name)
    res = search_artist(name)
    res&.results&.first&.id
    rescue StandardError => e
      Rails.logger.error("find_artist_id_by_name failed: #{e.class}: #{e.message}")
      nil
  end

  def search_artist_releases(artist_name)
    begin
      Rails.logger.info "Searching for artist: #{artist_name}"
      Rails.logger.info "API Key: #{ENV['DISCOGS_API_KEY'][0..5]}... (truncated)"
      
      # First find the artist
      artist_results = @client.search(artist_name, type: :artist, per_page: 1)
      Rails.logger.info "Artist search completed, found #{artist_results.results.count} results"
      
      if artist_results.results.any?
        artist = artist_results.results.first
        artist_id = artist.id
        
        # Then get their releases
        releases = @client.get_artist_releases(artist_id, per_page: 50)
        Rails.logger.info "Found #{releases.releases.count} releases for artist ID #{artist_id}"
        
        # Return structured data
        OpenStruct.new(
          artist: artist,
          releases: releases.releases,
          pagination: releases.pagination
        )
      else
        OpenStruct.new(artist: nil, releases: [], pagination: nil)
      end
    rescue Discogs::AuthenticationError => e
      Rails.logger.error("Discogs API authentication error: #{e.message}")
      OpenStruct.new(artist: nil, releases: [], pagination: nil)
    rescue StandardError => e
      Rails.logger.error("Discogs API error: #{e.message}")
      Rails.logger.error("Error class: #{e.class}")
      OpenStruct.new(artist: nil, releases: [], pagination: nil)
    end
  end

  def get_artist(artist_id)
    @client.get_artist(artist_id)
  rescue StandardError => e
    Rails.logger.error("Error fetching artist: #{e.message}")
    nil
  end

  def get_release(release_id)
    @client.get_release(release_id)
  rescue StandardError => e
    Rails.logger.error("Error fetching release: #{e.message}")
    nil
  end
end

  def get_artist_releases(artist_id, page: 1, per_page: 50)
    @client.get_artist_releases(artist_id, page:page, per_page: per_page)
  rescue StandardError => e
    Rails.logger.error("Error fetching releases for artist #{artist_id}: #{e.message}")
    OpenStruct.new(releases: [], pagination: OpenStruct.new(items: 0, pages: 0))
  end

  def releases_count_for_artist(artist_id:)
    first_page = get_artist_releases(artist_id, page: 1, per_page: 1)
    first_page&.pagination&.items.to_i
  end
