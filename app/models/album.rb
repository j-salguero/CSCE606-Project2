class Album < ApplicationRecord
  belongs_to :artist, optional: true
end
