class Tonal::Scale::Harmonic < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Harmonic.new(indices: @args[:indices], nexus: @args[:nexus])
  end

  def name
    "Harmonic sequence, #{@args[:indices]}, nexus: #{@args[:nexus]}"
  end

  def description
    "Harmonic sequence, indices: #{@args[:indices]}, nexus: #{@args[:nexus]}"
  end
end
