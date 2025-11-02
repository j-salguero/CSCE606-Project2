class AlbumsController < ApplicationController
  def index

    @albums = [
      { id: 1, title: "Thriller", artist: "Michael Jackson", image_url: "https://upload.wikimedia.org/wikipedia/en/5/55/Michael_Jackson_-_Thriller.png" },
      { id: 2, title: "Back to Black", artist: "Amy Winehouse", image_url: "https://upload.wikimedia.org/wikipedia/en/7/75/Amy_Winehouse_-_Back_to_Black_%28album%29.png" },
      { id: 3, title: "Rumours", artist: "Fleetwood Mac", image_url: "https://upload.wikimedia.org/wikipedia/en/f/fb/FMacRumours.PNG" },
      { id: 4, title: "Purple Rain", artist: "Prince", image_url: "https://upload.wikimedia.org/wikipedia/en/9/9c/Princepurplerain.jpg" }
    ]

    @albums = Albums.includes(:artist).order(:title)
  end

  def collection
    scope = CollectionItem.includes(album: :artist)
    scope = scope.where(user_id: current_user.id) if defined?(current_user) && current_user
    @items = scope.order(created_at: :desc)

  end
end

