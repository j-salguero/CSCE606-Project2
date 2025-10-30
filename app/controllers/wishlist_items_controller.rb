class WishlistItemsController < ApplicationController
  def index
    @wishlist_items = WishlistItem.all
  end

  def create
    @wishlist_item = WishlistItem.create(
      title: params[:album],
      artist: params[:artist]
    )
    redirect_to wishlist_items_path, notice: "Album added to your wishlist!"
  end

  def destroy
    WishlistItem.find(params[:id]).destroy
    redirect_to wishlist_items_path, notice: "Album removed from your wishlist."
  end
end

