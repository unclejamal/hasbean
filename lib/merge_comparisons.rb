class MergeComparisons
  def merge(old_ones, fresh)
    puts "PAWEL MergeComparisons old_ones #{old_ones}"
    puts "PAWEL MergeComparisons fresh #{fresh}"
    val = ([fresh] + old_ones).filter {|c| c.changed?}.first(5)
    puts "PAWEL MergeComparisons #{val}"
    val
  end
end
