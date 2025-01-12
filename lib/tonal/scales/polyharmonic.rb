class Tonal::Scale::Polyharmonic < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Polyharmonic.new(indices: @args[:indices], fundamentals: @args[:fundamentals])
  end

  def name
    "Polyharmonic sequence, #{@args[:indices]}, #{@args[:fundamentals]}"
  end

  def description
    "Polyharmonic sequence, indices: #{@args[:indices]}, fundamentals: #{@args[:fundamentals]}"
  end
end