# app/services/discogs_service.rb
require 'ostruct'

class DiscogsService
  def initialize
    # Use personal access token for authentication
    if ENV['DISCOGS_TOKEN'].present?
      @client = Discogs::Wrapper.new("VinylTracker", user_token: ENV['DISCOGS_TOKEN'])
    else
      # Use app identity for authenticated requests
      @client = Discogs::Wrapper.new("VinylTracker", 
        app_key: ENV['DISCOGS_API_KEY'],
        app_secret: ENV['DISCOGS_API_SECRET'])
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

  def search_artist_releases(artist_name)
    begin
      Rails.logger.info "Searching for artist: #{artist_name}"
      Rails.logger.info "API Key: #{ENV['DISCOGS_TOKEN']&.first(6)}... (truncated)"
      
      # First find the artist
      artist_results = @client.search(artist_name, type: :artist, per_page: 1)
      Rails.logger.info "Artist search completed, found #{artist_results&.results&.count || 0} results"
      
      if artist_results && artist_results.results && artist_results.results.any?
        artist = artist_results.results.first
        artist_id = artist.id
        
        # Then get their releases
        releases = @client.get_artist_releases(artist_id, per_page: 50)
        release_list = releases.respond_to?(:releases) ? releases.releases : []
        Rails.logger.info "Found #{release_list.count} releases for artist ID #{artist_id}"
        
        # Return structured data
        OpenStruct.new(
          artist: artist,
          releases: release_list,
          pagination: releases.respond_to?(:pagination) ? releases.pagination : nil
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
      Rails.logger.error("Backtrace: #{e.backtrace.first(5).join("\n")}")
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

  def genre_for_artist(artist_id)
    releases = get_artist_releases(artist_id, page: 1, per_page: 1)
    first_release = releases.releases.first
    return nil unless first_release

    rel = get_release(first_release.id)
    return nil unless rel

    Array(rel.genres).first || Array(rel.styles).first
  rescue => e
    Rails.logger.error("genre_for_artist error: #{e.message}")
    nil
  end

  def country_for_artist(artist_id)
    releases = get_artist_releases(artist_id, page: 1, per_page: 1)
    first_release = releases.releases.first
    return nil unless first_release

    rel = get_release(first_release.id)
    return rel.country if rel && rel.respond_to?(:country)

    nil
  rescue => e
    Rails.logger.error("country_for_artist error: #{e.message}")
    nil
  end

end
