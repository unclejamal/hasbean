require 'refresh_data'
require 'repository'
require 'redis'
require 'json'
require 'scrape'

describe RefreshData do
  refresh_data = RefreshData.new(nil)

  yesterday = Time.parse("2020-12-19")
  today = Time.parse("2020-12-20")

  it "no coffees before and no coffees after" do
    response = refresh_data.functional_refresh(RefreshDataRequest.new(
      most_recent_snapshot: Snapshot.new(coffees: [], last_updated: yesterday),
      most_recent_update_feed: [],
      fresh_scrape: [],
      fresh_scrape_timestamp: today
    ))
    expect(response).to eq(RefreshDataResponse.new(
      snapshot_to_store: Snapshot.new(
        coffees: [],
        last_updated: today
      ),
      update_feed_to_store: []
    ))
  end

  it "no coffees before and one after" do
    added_coffee = Coffee.new(link: "link1", name: "name1")
    response = refresh_data.functional_refresh(RefreshDataRequest.new(
      most_recent_snapshot: Snapshot.new(coffees: [], last_updated: yesterday),
      most_recent_update_feed: [],
      fresh_scrape: [added_coffee],
      fresh_scrape_timestamp: today
    ))
    expect(response).to eq(RefreshDataResponse.new(
      snapshot_to_store: Snapshot.new(
        coffees: [added_coffee],
        last_updated: today
      ),
      update_feed_to_store: [Comparison.new(
        added: [added_coffee],
        removed: [],
        timestamp: today
      )]
    ))
  end
end
