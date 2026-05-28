class Tonal::Scale::Arithmetic < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Arithmetic.new(lower: @args[:lower], upper: @args[:upper], factor: @args[:factor], nexus: @args[:nexus], identity: @args[:identity])
  end

  def name
    "Arithmetic Sequence, lower: #{@args[:lower]}, upper: #{@args[:upper]}, factor: #{@args[:factor]}, nexus: #{@args[:nexus]}, identity: #{@args[:identity]}"
  end

  def description
    "Arithmetic Sequence: lower: #{@args[:lower]}, upper: #{@args[:upper]}, factor: #{@args[:factor]}, nexus: #{@args[:nexus]}, identity: #{@args[:identity]}"
  end
end