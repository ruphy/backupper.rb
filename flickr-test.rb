require 'rubygems'
require 'flickr'

flickr = Flickr.new("flickr-token.cfg", "6b68b90702411082818b8ca39919434a", "db8e5e4d8a08aa00")
# puts flickr.auth.class
unless flickr.auth.token
  flickr.auth.getFrob
  url = flickr.auth.login_link
  puts "You must visit #{url} to authorize this application.  Press enter"+
    " when you have done so. This is the only time you will have to do this."
  gets
  flickr.auth.getToken
  flickr.auth.cache_token
end

response = flickr.call_method "flickr.collections.getInfo", {"collection_id" => "5587578-72157612185298087"}



