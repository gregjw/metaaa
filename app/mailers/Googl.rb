require "rubygems"
require "httparty"
require "json"

class Googl
  include HTTParty
  base_uri "https://www.googleapis.com"
  headers  "Content-Type" => "application/json"
  default_options.update(verify: false)
  
  def self.shorten(url)
    post("/urlshortener/v1/url", :body => {:longUrl => url}.to_json)["id"]
  end
end
