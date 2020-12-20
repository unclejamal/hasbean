require 'repository'
require 'update_feed'
require 'redis'
require 'json'
require 'scrape'

describe HasBeanRepository do
  url = ENV['RURL']
  prefix = "hasbeanspec"
  repo = HasBeanRepository.new(url, prefix)

  today = Time.parse("2020-12-20")

  it "stores empty update_feed" do
    update_feed = []

    repo.store_update_feed(update_feed)

    expect(repo.get_update_feed).to eq(update_feed)
  end

  it "stores update feed with added coffee" do
    update_feed = [Comparison.new(
      added: [Coffee.new(link: "link1", name: "name1")],
      removed: [],
      timestamp: today
    )]

    repo.store_update_feed(update_feed)

    expect(repo.get_update_feed).to eq(update_feed)
  end
end
