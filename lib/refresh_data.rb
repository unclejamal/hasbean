require 'time'
require 'update_feed'

RefreshDataRequest = Struct.new(:most_recent_snapshot, :most_recent_update_feed, :fresh_scrape, :fresh_scrape_timestamp, keyword_init: true)
RefreshDataResponse = Struct.new(:snapshot_to_store, :update_feed_to_store, keyword_init: true)

class RefreshData

  def initialize(repo)
    @repo = repo
  end

  def refresh
    puts "PAWEL RefreshData Start"

    rs = functional_refresh(RefreshDataRequest.new(
      most_recent_snapshot: @repo.most_recent_snapshot,
      most_recent_update_feed: @repo.get_update_feed,
      fresh_scrape: HasBeanCoffeeCollectionPage.new(Config.limit).scrape,
      fresh_scrape_timestamp: Time.now
    ))

    @repo.take_snapshot(rs.snapshot_to_store)
    @repo.store_update_feed(rs.update_feed_to_store)
    puts "PAWEL RefreshData End"
  end

  def functional_refresh(rq)
    fresh_scrape = rq.fresh_scrape.sort_by {|c| -c.score_as_float}
    fresh_snapshot = Snapshot.new(
      coffees: fresh_scrape,
      last_updated: rq.fresh_scrape_timestamp
    )

    RefreshDataResponse.new(
      snapshot_to_store: fresh_snapshot,
      update_feed_to_store: create_new_update_feed(
        rq.most_recent_snapshot,
        rq.most_recent_update_feed,
        fresh_snapshot
      )
    )
  end

  def create_new_update_feed(previous_snapshot, previous_update_feed, fresh_snapshot)
    fresh_comparison = CompareSnapshots.new.compare(previous_snapshot, fresh_snapshot)
    MergeComparisons.new.merge(previous_update_feed, fresh_comparison)
  end
end
