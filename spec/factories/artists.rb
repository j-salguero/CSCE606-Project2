# spec/factories/artists.rb
FactoryBot.define do
    factory :artist do
      sequence(:name) { |n| "Artist #{n}" }
      genre { "Rock" }
      country { "USA" }
      discogs_id { nil }
      discogs_uri { nil }
    end
  end
  