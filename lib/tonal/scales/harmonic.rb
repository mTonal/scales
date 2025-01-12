class Tonal::Scale::Harmonic < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Harmonic.new(indices: @args[:indices])
  end

  def name
    "Harmonic sequence, #{@args[:indices]}"
  end

  def description
    "Harmonic sequence, indices: #{@args[:indices]}"
  end
end
