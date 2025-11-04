class WishlistItemsController < ApplicationController
  def index
    @wishlist_items = WishlistItem.all
  end

  def create
    release_data = params[:release] || {}
    artist_name = extract_artist_name(release_data)
    
    # Check for duplicates
    existing = WishlistItem.find_by(title: release_data[:title], artist: artist_name)
    
    if existing
      redirect_to wishlist_items_path, alert: "#{release_data[:title]} is already in your wishlist!"
      return
    end
    
    @wishlist_item = WishlistItem.create(
      title: release_data[:title],
      artist: artist_name,
      image_url: release_data[:thumb]  # Add this line
    )
    
    if @wishlist_item.persisted?
      redirect_to wishlist_items_path, notice: "#{@wishlist_item.title} added to your wishlist!"
    else
      redirect_to search_path, alert: "Failed to add album to wishlist."
    end
  end

  def destroy
    @wishlist_item = WishlistItem.find(params[:id])
    title = @wishlist_item.title
    @wishlist_item.destroy
    redirect_to wishlist_items_path, notice: "#{title} removed from your wishlist."
  end

  private

  def extract_artist_name(release_data)
    if release_data[:artist].present?
      release_data[:artist]
    else
      title = release_data[:title].to_s
      if title.include?(' - ')
        title.split(' - ').first.strip
      else
        "Unknown Artist"
      end
    end
  end
end