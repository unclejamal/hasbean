require 'compare_snapshots'
require 'hasbean-coffees'
require 'scrape'

no_changes = Comparison.new(added: [], removed: [])

describe CompareSnapshots do
  it "detects no changes" do
      expect(subject.compare([], [])).to eq(no_changes)
  end

  it "detects added coffee" do
      c = Coffee.new()
      expect(subject.compare([], [c])).to eq(Comparison.new(added: [c], removed: []))
  end

  it "detects removed coffee" do
      c = Coffee.new()
      expect(subject.compare([c], [])).to eq(Comparison.new(added: [], removed: [c]))
  end

  it "detects added coffee that's different to existing coffee" do
      a = Coffee.new(link: "a")
      e = Coffee.new(link: "e")
      expect(subject.compare([e], [e, a])).to eq(Comparison.new(added: [a], removed: []))
  end

  it "detects added coffee that's different to existing coffee" do
      a = Coffee.new(link: "a")
      e = Coffee.new(link: "e")
      expect(subject.compare([e], [e, a])).to eq(Comparison.new(added: [a], removed: []))
  end

  it "detects both added and removed coffee at the same time" do
      a = Coffee.new(link: "a")
      e1 = Coffee.new(link: "e1")
      e2 = Coffee.new(link: "e2")
      expect(subject.compare([e1, e2], [e1, a])).to eq(Comparison.new(added: [a], removed: [e2]))
  end
end
