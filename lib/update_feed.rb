Comparison = Struct.new(:added, :removed, :timestamp, keyword_init: true) do
  def changed?
    !added.empty? || !removed.empty?
  end
end

class CompareSnapshots
  def compare(before, after)
    puts "PAWEL CompareSnapshots before #{before}"
    puts "PAWEL CompareSnapshots after #{after}"
    val = Comparison.new(
      added: after.coffees - before.coffees,
      removed: before.coffees - after.coffees,
      timestamp: after.last_updated
    )
    puts "PAWEL CompareSnapshots val #{val}"
    val
  end
end

class MergeComparisons
  def merge(old_ones, fresh)
    puts "PAWEL MergeComparisons old_ones #{old_ones}"
    puts "PAWEL MergeComparisons fresh #{fresh}"
    val = ([fresh] + old_ones).filter {|c| c.changed?}.first(5)
    puts "PAWEL MergeComparisons #{val}"
    val
  end
end
