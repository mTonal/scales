class Tonal::Scale::Edo < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Edo.new(modulo: @args[:modulo])
  end

  def name
    "#{@args[:modulo]} EDO"
  end

  def description
    "#{@args[:modulo]}-tone equal division of the octave scale"
  end
end
