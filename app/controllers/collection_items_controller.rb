class CollectionItemsController < ApplicationController
  def index
    @collection_items = CollectionItem.all
  end

  def create
    @collection_item = CollectionItem.create(
      title: params[:album],
      artist: params[:artist]
    )
    redirect_to collection_items_path, notice: "Album added to your collection!"
  end

  def destroy
    CollectionItem.find(params[:id]).destroy
    redirect_to collection_items_path, notice: "Album removed from your collection."
  end
end

