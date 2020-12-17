require 'merge_comparisons'

c1 = "c1"
c2 = "c2"
c3 = "c3"
c4 = "c4"
c5 = "c5"
c6 = "c6"

describe MergeComparisons do
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
