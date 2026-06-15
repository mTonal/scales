class Tonal::Scale::Diamond < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Diamond.new(set: assigned_set)
  end

  def name
    "Tonality diamond, #{assigned_set}"
  end

  def description
    "Tonality diamond: all ratios p/q for p, q in #{assigned_set}, reduced to the octave"
  end

  private

  def assigned_set
    @set ||= @args[:set].empty? ? [1, 3, 5, 7] : @args[:set]
  end
end
