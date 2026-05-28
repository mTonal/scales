class Tonal::Sequence::EdoStep < Tonal::Sequence
  def initialize(start: 1, stop: 53)
    @sequence = start.upto(stop).map{|modulo| (2 ** (1.0/modulo))}
  end
end
