class Artist < ApplicationRecord
  has_many :collection_items
  has_many :albums
  validates :name, presence: true
end
