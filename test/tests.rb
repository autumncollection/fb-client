require 'fb_client'
require 'test/unit'
require 'tokens'

class FbClientTest < Test::Unit::TestCase
  def test_initialize
    FbClient.fetch(
      '144301939056471/feed?fields=likes.summary(1){id,profile_type},comments.summary(1).fields(comment_count,message,id,from,created_time),created_time,from,id,message,story,link,name,properties,type&limit=250&since=2015-08-31&until=1442394198',
      :new_api
    )
  end
end
