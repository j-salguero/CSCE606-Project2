require 'ostruct'
class HomeController < ApplicationController
  def index
    @collection_items = CollectionItem.all

    if @collection_items.empty?
      @collection_items = [
        OpenStruct.new(title: "Thriller", artist: "Michael Jackson" , year:1982),
        OpenStruct.new(title: "Back to Black", artist: "Amy Winehouse", year:2006),
        OpenStruct.new(title: "Random Access Memories", artist: "Daft Punk", year:2013)
      ]
    end
  end
end
