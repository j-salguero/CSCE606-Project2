require "addressable/uri"

Before do
  stub_request(:get, %r{\Ahttps://api\.discogs\.com/database/search})
    .to_return do |req|
      q = Addressable::URI.parse(req.uri.to_s).query_values || {}
      artist_q = (q["q"] || "").to_s.strip

      case artist_q
      when /the\s*beatles/i
        {
          status: 200, headers: { "Content-Type" => "application/json" },
          body: {
            pagination: { items: 1, page: 1, pages: 1, per_page: 50 },
            results: [{ "id" => 82730, "title" => "The Beatles", "type" => "artist" }]
          }.to_json
        }
      when "Nonexistent Person", "Nope", ""
        {
          status: 200, headers: { "Content-Type" => "application/json" },
          body: { pagination: { items: 0, page: 1, pages: 1, per_page: 50 }, results: [] }.to_json
        }
      else
        {
          status: 200, headers: { "Content-Type" => "application/json" },
          body: { pagination: { items: 0, page: 1, pages: 1, per_page: 50 }, results: [] }.to_json
        }
      end
    end

  stub_request(:get, %r{\Ahttps://api\.discogs\.com/artists/82730/releases})
    .to_return(
      status: 200, headers: { "Content-Type" => "application/json" },
      body: {
        pagination: { items: 2, page: 1, pages: 1, per_page: 50 },
        releases: [{ "id" => 1, "title" => "Abbey Road" }, { "id" => 2, "title" => "Let It Be" }]
      }.to_json
    )

  stub_request(:get, %r{\Ahttps://api\.discogs\.com/releases/\d+})
    .to_return(
      status: 200, headers: { "Content-Type" => "application/json" },
      body: { id: 1, title: "Abbey Road", genres: ["Rock"], styles: ["Pop Rock"] }.to_json
    )
end
