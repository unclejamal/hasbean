$stdout.sync = true
$LOAD_PATH << 'lib'

require 'config'
require 'refresh_data'
require 'update_feed'
require 'repository'
require 'scrape'
require 'sinatra'
require 'redis'

repo = HasBeanRepository.new(Config.redis_url, Config.redis_prefix)

Thread.new do
  RefreshData.new(repo).refresh
end

get '/' do
  snapshot = repo.most_recent_snapshot
  @table = snapshot.coffees
  @last_updated = snapshot.last_updated
  @update_feed = repo.get_update_feed
  erb :index
end
