Comparison = Struct.new(:added, :removed)

class CompareSnapshots
  def compare(before, after)
    Comparison.new(
      added: after - before,
      removed: before - after
    )
  end
end
