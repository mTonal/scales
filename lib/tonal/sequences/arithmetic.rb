class Tonal::Sequence::Arithmetic < Tonal::Sequence
  def initialize(lower: 1, upper: 12, factor: 1, nexus: 1, identity: :otonal)
    raise ArgumentError, "lower bound must be less than or equal to upper bound" if lower > upper
    raise ArgumentError, "factor must be greater than zero" if factor <= 0

    steps = ((upper - lower) / factor.to_f).floor.to_i
    func = identity == :utonal ? ->(n){ [nexus, lower + factor * n] } : ->(n){ [lower + factor * n, nexus] }
    @sequence = (0..steps).map do |i|
      Tonal::Ratio.new(*func.(i))
    end
  end
end
