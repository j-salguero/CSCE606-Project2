class AlbumsController < ApplicationController
  def index
    @albums = Albums.includes(:artist).order(:title)
  end

  def collection
    scope = CollectionItem.includes(album: :artist)
    scope = scope.where(user_id: current_user.id) if defined?(current_user) && current_user
    @items = scope.order(created_at: :desc)
  end
end
