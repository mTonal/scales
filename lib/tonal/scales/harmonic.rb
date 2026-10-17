class Tonal::Scale::Harmonic < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Harmonic.new(indices: @args[:indices], nexus: @args[:nexus])
  end

  def default_name
    "Harmonic sequence, #{@args[:indices]}, nexus: #{@args[:nexus]}"
  end

  def default_description
    "Harmonic sequence, indices: #{@args[:indices]}, nexus: #{@args[:nexus]}"
  end
end
