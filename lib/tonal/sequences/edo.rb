class Tonal::Sequence::Edo < Tonal::Sequence
  def initialize(modulo:)
    @sequence = (0..modulo-1).map{|step| ratio = (2**(step/modulo.to_f))}
  end
end
