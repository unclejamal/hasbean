Snapshot = Struct.new(:coffees, :last_updated, keyword_init: true)

class HasBeanRepository
  def initialize(url, prefix)
    @redis = Redis.new(url: url)
    @prefix = prefix
  end

  def take_snapshot(coffees, timestamp)
    @redis.set("#{@prefix}_last_snapshot_coffees", coffees.map {|c| c.to_h}.to_json)
    @redis.set("#{@prefix}_last_snapshot_timestamp", timestamp)
  end

  def most_recent_snapshot
    text_coffees = @redis.get("#{@prefix}_last_snapshot_coffees")
    text_timestamp = @redis.get("#{@prefix}_last_snapshot_timestamp")
    coffees = JSON.parse(text_coffees).map {|h| Coffee.new(h)}
    timestamp = Time.parse(text_timestamp)

    return Snapshot.new(coffees: coffees, last_updated: timestamp)
  end

  def store_update_feed(update_feed)
    @redis.set("#{@prefix}_update_feed", update_feed.map {|c| c.to_h}.to_json)
  end

  def get_update_feed
    text_uf = @redis.get("#{@prefix}_update_feed") || "[]"
    puts "PAWEL retrieved update feed: #{text_uf}"
    JSON.parse(text_uf).map {|h| Comparison.new(h)}
  end
end
