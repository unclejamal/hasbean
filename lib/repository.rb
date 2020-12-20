Snapshot = Struct.new(:coffees, :last_updated, keyword_init: true)

class HasBeanRepository
  def initialize(url, prefix)
    @redis = Redis.new(url: url)
    @prefix = prefix
  end

  def take_snapshot(snapshot)
    @redis.set("#{@prefix}_last_snapshot_coffees", snapshot.coffees.map {|c| c.to_h}.to_json)
    @redis.set("#{@prefix}_last_snapshot_timestamp", snapshot.last_updated)
  end

  def most_recent_snapshot
    text_coffees = @redis.get("#{@prefix}_last_snapshot_coffees") || "[]"
    text_timestamp = @redis.get("#{@prefix}_last_snapshot_timestamp")
    coffees = JSON.parse(text_coffees).map {|h| Coffee.new(h)}
    timestamp = !!text_timestamp ? Time.parse(text_timestamp) : nil

    return Snapshot.new(coffees: coffees, last_updated: timestamp)
  end

  def store_update_feed(update_feed)
    puts "PAWEL storing update feed: #{update_feed}"

    json_to_store = update_feed.map {|comp| {
      added: comp.added.map {|c| c.to_h},
      removed: comp.removed.map {|c| c.to_h},
      timestamp: comp.timestamp
    }}.to_json
    puts "PAWEL storing update feed as json: #{json_to_store}"
    @redis.set("#{@prefix}_update_feed", json_to_store)
  end

  def get_update_feed
    text_uf = @redis.get("#{@prefix}_update_feed") || "[]"
    puts "PAWEL retrieved update feed as json: #{text_uf}"
    JSON.parse(text_uf).map {|json| Comparison.new(
      added: json["added"].map {|i| Coffee.new(i)},
      removed: json["removed"].map {|i| Coffee.new(i)},
      timestamp: text_to_time(json["timestamp"]),
    )}
  end

  def text_to_time(text)
    !!text ? Time.parse(text) : nil
  end
end
