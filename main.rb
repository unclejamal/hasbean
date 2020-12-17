$stdout.sync = true
$LOAD_PATH << 'lib'

require 'update_feed'
require 'hasbean-coffees'
require 'scrape'
require 'sinatra'
require 'redis'

class Config
  def self.app_mode
    ENV["APP_MODE"]
  end

  def self.is_test_mode?
    ENV["APP_MODE"]
  end

  def self.limit
    value = Config.is_test_mode? ? 3 : 999 # 999 = effectively no limit
    puts "PAWEL using limit of #{value} coffees"
    value
  end

  def self.redis_prefix
    value = Config.is_test_mode? ? "hasbeantest" : "hasbean"
    puts "PAWEL using redis prefix of #{value}"
    value
  end

  def self.redis_url
    ENV['RURL']
  end
end

redis = Redis.new(url: Config.redis_url)
snapshot_repository = HasBeanSnapshotRepository.new(redis, Config.redis_prefix)

Thread.new do
  puts "PAWEL Refresh Start"
  previous_snapshot = snapshot_repository.most_recent_snapshot
  fresh_scrape = HasBeanCoffeeCollectionPage.new(Config.limit).scrape
  fresh_scrape = fresh_scrape.sort_by {|c| -c.score_as_float}
  snapshot_repository.take_snapshot(fresh_scrape, Time.now)
  current_snapshot = snapshot_repository.most_recent_snapshot

  fresh_comparison = CompareSnapshots.new.compare(previous_snapshot, current_snapshot)
  previous_update_feed = snapshot_repository.get_update_feed
  merged_update_feed = MergeComparisons.new.merge(previous_update_feed, fresh_comparison)
  snapshot_repository.store_update_feed(merged_update_feed)
  puts "PAWEL Refresh End"
end

get '/' do
  snapshot = snapshot_repository.most_recent_snapshot
  @table = snapshot.coffees
  @last_updated = snapshot.last_updated
  @update_feed = snapshot_repository.get_update_feed
  erb :index
end
