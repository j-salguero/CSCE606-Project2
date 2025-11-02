class WishlistItemsController < ApplicationController
  def index
    @wishlist_items = WishlistItem.all
    @wishlist_item = WishlistItem.new
  end

  def create
    @wishlist_item = WishlistItem.new(wishlist_item_params)
    if @wishlist_item.save
      redirect_to wishlist_items_path, notice: "✅ Added to your wishlist!"
    else
      redirect_to wishlist_items_path, alert: "⚠️ Could not add item."
    end
  end

  def destroy
    @wishlist_item = WishlistItem.find(params[:id])
    @wishlist_item.destroy
    redirect_to wishlist_items_path, notice: "🗑️ Removed from your wishlist."
  end

  private

  def wishlist_item_params
    params.require(:wishlist_item).permit(:title, :artist)
  end
end
