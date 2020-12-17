class RefreshData

  def initialize(repo)
    @repo = repo
  end

  def refresh
    puts "PAWEL RefreshData Start"
    previous_snapshot = @repo.most_recent_snapshot
    fresh_scrape = HasBeanCoffeeCollectionPage.new(Config.limit).scrape
    fresh_scrape = fresh_scrape.sort_by {|c| -c.score_as_float}
    @repo.take_snapshot(fresh_scrape, Time.now)
    current_snapshot = @repo.most_recent_snapshot

    fresh_comparison = CompareSnapshots.new.compare(previous_snapshot, current_snapshot)
    previous_update_feed = @repo.get_update_feed
    merged_update_feed = MergeComparisons.new.merge(previous_update_feed, fresh_comparison)
    @repo.store_update_feed(merged_update_feed)
    puts "PAWEL RefreshData End"
  end
end
