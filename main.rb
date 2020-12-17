$stdout.sync = true
$LOAD_PATH << 'lib'

require 'config'
require 'refresh_data'
require 'update_feed'
require 'hasbean-coffees'
require 'scrape'
require 'sinatra'
require 'redis'

redis = Redis.new(url: Config.redis_url)
repo = HasBeanSnapshotRepository.new(redis, Config.redis_prefix)

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
