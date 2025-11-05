# app/models/user.rb
class User < ApplicationRecord
    has_secure_password
    
    has_many :collection_items
    has_many :wishlist_items
    
    validates :email, presence: true, uniqueness: true
    validates :name, presence: true
end