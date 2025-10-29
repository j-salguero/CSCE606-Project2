# app/controllers/search_controller.rb
class SearchController < ApplicationController
  def index
    service = DiscogsService.new
    
    if params[:artist_name].present?
      @search_data = service.search_artist_releases(params[:artist_name])
      @search_type = 'artist'
    elsif params[:album_name].present?
      @album_results = service.search_releases(params[:album_name])
      @search_type = 'album'
    end
  end
end