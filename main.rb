$stdout.sync = true

require_relative './lib/scrape.rb'
require_relative './lib/hasbean-coffees.rb'
require 'sinatra'
require 'redis'

limit = 999 # effectively no limit
if (ENV["APP_MODE"] == "TEST")
  limit = 3
end
puts "PAWEL using limit of #{limit} coffees"

rurl=ENV['RURL']
redis = Redis.new(url: rurl)
snapshot_repository = HasBeanSnapshotRepository.new(redis)

Thread.new do
  loop do
    puts "PAWEL Refresh Start"
    fresh_scrape = HasBeanCoffeeCollectionPage.new(limit).scrape
    fresh_scrape = fresh_scrape.sort_by {|c| -c.score_as_float}
    snapshot_repository.take_snapshot(fresh_scrape, Time.now)
    puts "PAWEL Refresh End"
    sleep 60*60 # sleep 1 hour
  end
end

get '/' do
  snapshot = snapshot_repository.most_recent_snapshot
  @table = snapshot.coffees
  @last_updated = snapshot.last_updated
  erb :index
end
