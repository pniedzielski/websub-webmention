require 'sinatra'
require 'simple-rss'
require 'webmention'

post '/callback' do
  # Request body is an RSS or Atom feed.  Parse it into entries, find
  # their permalinks, and then send webmention to each link in the
  # h-entry at that permalink.
  feed = SimpleRSS.parse request.body
  feed.entries.each do |entry|
    client = Webmention::Client.new entry.link
    client.send_mentions
  end
  ""
end
