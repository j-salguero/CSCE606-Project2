class ArtistsController < ApplicationController
  before_action :set_artist, only: %i[ show edit update destroy ]

  # GET /artists or /artists.json
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

  # GET /artists/1 or /artists/1.json
  def show
    @artist = Artist.find(params[:id]
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
  end

  # GET /artists/new
  def new
    @artist = Artist.new
  end

  # GET /artists/1/edit
  def edit
  end

  # POST /artists or /artists.json
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

  # PATCH/PUT /artists/1 or /artists/1.json
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

  # DELETE /artists/1 or /artists/1.json
  def destroy
    @artist.destroy!

    respond_to do |format|
      format.html { redirect_to artists_path, notice: "Artist was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_artist
      @artist = Artist.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def artist_params
      params.expect(artist: [ :name, :genre, :country ])
    end
end
