require 'update_feed'
require 'hasbean-coffees'
require 'scrape'

describe CompareSnapshots do
  it "detects no changes" do
      before = Snapshot.new(coffees: [], last_updated: "fri")
      after = Snapshot.new(coffees: [], last_updated: "sat")
      expect(subject.compare(before, after)).to eq(Comparison.new(added: [], removed: [], timestamp: "sat"))
  end

  it "detects added coffee" do
      c = Coffee.new()
      before = Snapshot.new(coffees: [], last_updated: "fri")
      after = Snapshot.new(coffees: [c], last_updated: "sat")
      expect(subject.compare(before, after)).to eq(Comparison.new(added: [c], removed: [], timestamp: "sat"))
  end

  it "detects removed coffee" do
      c = Coffee.new()
      before = Snapshot.new(coffees: [c], last_updated: "fri")
      after = Snapshot.new(coffees: [], last_updated: "sat")
      expect(subject.compare(before, after)).to eq(Comparison.new(added: [], removed: [c], timestamp: "sat"))
  end

  it "detects added coffee that's different to existing coffee" do
      a = Coffee.new(link: "a")
      e = Coffee.new(link: "e")
      before = Snapshot.new(coffees: [e], last_updated: "fri")
      after = Snapshot.new(coffees: [e, a], last_updated: "sat")
      expect(subject.compare(before, after)).to eq(Comparison.new(added: [a], removed: [], timestamp: "sat"))
  end

  it "detects both added and removed coffee at the same time" do
      a = Coffee.new(link: "a")
      e1 = Coffee.new(link: "e1")
      e2 = Coffee.new(link: "e2")
      before = Snapshot.new(coffees: [e1, e2], last_updated: "fri")
      after = Snapshot.new(coffees: [e1, a], last_updated: "sat")
      expect(subject.compare(before, after)).to eq(Comparison.new(added: [a], removed: [e2], timestamp: "sat"))
  end
end

describe Comparison do
  it "detects a change" do
    comparison = Comparison.new(added: [], removed: [])
    expect(comparison.changed?).to eq(false)
  end

  it "detects added" do
    comparison = Comparison.new(added: ["c"], removed: [])
    expect(comparison.changed?).to eq(true)
  end

  it "detects removed" do
    comparison = Comparison.new(added: [], removed: ["r"])
    expect(comparison.changed?).to eq(true)
  end
end



describe MergeComparisons do
  c1 = Comparison.new(added:"c1")
  c2 = Comparison.new(added:"c2")
  c3 = Comparison.new(added:"c3")
  c4 = Comparison.new(added:"c4")
  c5 = Comparison.new(added:"c5")
  c6 = Comparison.new(added:"c6")

  it "merges one" do
      expect(subject.merge([], c1)).to eq([c1])
  end

  it "merges multiple" do
      expect(subject.merge([c4,c3,c2,c1], c5)).to eq([c5,c4,c3,c2,c1])
  end

  it "removes oldest" do
      expect(subject.merge([c5,c4,c3,c2,c1], c6)).to eq([c6,c5,c4,c3,c2])
  end
end
