# Discogs step glue – actual HTTP is stubbed in features/support/discogs_stubs.rb

Given('Discogs returns {int} artist result for {string} \(id {int}\)') do |_n, _q, _id|
  # no-op; WebMock stubs handle it
end

Given('Discogs returns 0 results for {string}') do |_q|
  # no-op; WebMock stubs handle it
end

Given('Discogs responds with rate limit for {string}') do |_q|
  stub_request(:get, %r{\Ahttps://api\.discogs\.com/database/search})
    .to_return(
      status: 429,
      headers: { "Content-Type" => "application/json",
                 "X-Discogs-Ratelimit-Remaining" => "0" },
      body: { message: "Rate limit exceeded" }.to_json
    )
end
