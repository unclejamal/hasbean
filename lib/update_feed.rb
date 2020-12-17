Comparison = Struct.new(:added, :removed, :timestamp, keyword_init: true) do
  def changed?
    !added.empty? || !removed.empty?
  end
end

class CompareSnapshots
  def compare(before, after)
    Comparison.new(
      added: after.coffees - before.coffees,
      removed: before.coffees - after.coffees,
      timestamp: after.last_updated
    )
  end
end

class MergeComparisons
  def merge(old_ones, fresh)
    ([fresh] + old_ones).filter {|c| c.changed?}.first(5)
  end
end
