Snapshot = Struct.new(:coffees, :last_updated, keyword_init: true)

class HasBeanSnapshotRepository
  def initialize(repo)
    @repo = repo
  end

  def take_snapshot(coffees, timestamp)
    @repo.set("hasbean_last_snapshot_coffees", coffees.map {|c| c.to_h}.to_json)
    @repo.set("hasbean_last_snapshot_timestamp", timestamp)
  end

  def most_recent_snapshot
    text_coffees = @repo.get("hasbean_last_snapshot_coffees")
    text_timestamp = @repo.get("hasbean_last_snapshot_timestamp")
    coffees = JSON.parse(text_coffees).map {|h| Coffee.new(h)}
    timestamp = Time.parse(text_timestamp)

    return Snapshot.new(coffees: coffees, last_updated: timestamp)
  end
end
