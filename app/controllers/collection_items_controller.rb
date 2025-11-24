class CollectionItemsController < ApplicationController
  def index
    @collection_items = CollectionItem.includes(album: :artist).all
    @wishlist_items = WishlistItem.all
  end

  def create
    release_data = params[:release] || {}
    
    # Extract artist name from release data
    artist_name = extract_artist_name(release_data)
    
    # Find or create the artist
    artist = Artist.find_or_create_by(name: artist_name) do |a|
      a.discogs_id = release_data[:artist_id]
    end
    
    # Find or create the album
    album = Album.find_or_create_by(
      title: release_data[:title],
      artist: artist
    ) do |a|
      a.year = extract_year(release_data[:year])
      a.image_url = release_data[:thumb]
    end
    
    # Update image if it wasn't set before
    if album.image_url.blank? && release_data[:thumb].present?
      album.update(image_url: release_data[:thumb])
    end
    
    # Check if already in collection
    existing_item = CollectionItem.find_by(album: album)
    
    if existing_item
      redirect_to collection_items_path, alert: "#{album.title} is already in your collection!"
    else
      @collection_item = CollectionItem.create(album: album)
      
      if @collection_item.persisted?
        redirect_to collection_items_path, notice: "#{album.title} by #{artist.name} added to your collection!"
      else
        redirect_to search_path, alert: "Failed to add album to collection."
      end
    end
  end

  def destroy
    @collection_item = CollectionItem.find(params[:id])
    album_title = @collection_item.album.title
    @collection_item.destroy
    redirect_to collection_items_path, notice: "#{album_title} removed from your collection."
  end

  def extract_artist_name(release_data)
    # Discogs sometimes returns artist as a string or within the title
    if release_data[:artist].present?
      release_data[:artist]
    else
      # Parse from title if format is "Artist - Album"
      title = release_data[:title].to_s
      if title.include?(' - ')
        title.split(' - ').first.strip
      else
        "Unknown Artist"
      end
    end
  end

  def extract_year(year_value)
    # Year might be a string like "1969" or nil
    year_value.to_i if year_value.present? && year_value.to_i > 0
  end
end