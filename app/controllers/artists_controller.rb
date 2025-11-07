class ArtistsController < ApplicationController
  before_action :set_artist, only: %i[ show edit update destroy ]

  def index
    #@artists = Artist.all
    @q = params[:q].to_s.strip
    @artists = 
      if @q.present?
        Artist.where("name ILIKE ?", "%#{@q}%").order(:name)
      else
        Artist.order(:name)
      end
  end

  def show
    @artist = Artist.find(params[:id])
    discogs = DiscogsService.new
    discogs_id = @artist.try(:discogs_id) || discogs.find_artist_id_by_name(@artist.name)

    @discogs_releases_count = 
      if discogs_id.present?
        Rails.cache.fetch(["discogs_releases_count", discogs_id], expires_in: 30.minutes) do
          discogs.releases_count_for_artist(artist_id: discogs_id)
      end
      else
        0 #artist not in discogs
      end

      @discogs_genre = 
        if discogs_id.present?
          Rails.cache.fetch(["discogs_genre", discogs_id], expires_in: 30.minutes) do
            discogs.genre_for_artist(discogs_id)
        end
        else
          nil # discogs doesn't have a specific genre
        end

      @discogs_country = 
        if discogs_id.present?
          Rails.cache.fetch(["discogs_country", discogs_id], expires_in: 30.minutes) do
            discogs.country_for_artist(discogs_id)
        end
        else
          nil #discogs doesn't have a specific country
        end
  end

  # new artist
  def new
    @artist = Artist.new
  end

  # edit artist
  def edit
  end

  # create artist
  def create
    @artist = Artist.new(artist_params)

    respond_to do |format|
      if @artist.save
        format.html { redirect_to @artist, notice: "Artist was successfully created." }
        format.json { render :show, status: :created, location: @artist }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @artist.errors, status: :unprocessable_entity }
      end
    end
  end

  # update artist
  def update
    respond_to do |format|
      if @artist.update(artist_params)
        format.html { redirect_to @artist, notice: "Artist was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @artist }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @artist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE artists
  def destroy
    @artist.destroy!

    respond_to do |format|
      format.html { redirect_to artists_path, notice: "Artist was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # Want to be able to lookup artist info on Discogs
  def lookup
    name = params[:name].to_s.strip
    
    respond_to do |format|
    if name.blank?
      format.html { redirect_to artists_path, alert: "No artist name provided." }
      format.json { render json: { error: "Artist name is required" }, status: :unprocessable_entity }
    else
      begin
        @artist = Artist.find_or_create_by!(name: name)

        format.html { redirect_to @artist, notice: "Showing #{name}." }
        format.html { render :show, status: :ok, location: @artist }
 
      rescue ActiveRecord::RecordInvalid => e
        format.html { redirect_to artists_path, alert: e.record.errors.full_messages.to_sentence }
        format.json { render json: { errors: e.record.errors }, status: :unprocessable_entity }
      rescue => e
        Rails.logger.error("artists#lookup error: #{e.class}: #{e.message}")
        format.html { redirect_to artists_path, alert: "Could not look up that artist." }
        format.json { render json: { error: "lookup_failed" }, status: :internal_server_error }
      end
    end
  end
end

    def set_artist
      @artist = Artist.find(params[:id])
    end

    def artist_params
      params.require(:artist).permit( :name, :genre, :country, :discogs_id, :discogs_uri )
    end
end