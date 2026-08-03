class Tonal::Sequence::Genus < Tonal::Sequence
  def initialize(factors: {3 => 1, 5 => 1})
    ranges = factors.map{|_prime, exponent| (0..exponent).to_a}
    @sequence = ranges[0].product(*ranges[1..]).map do |powers|
      factors.keys.zip(powers).map{|prime, power| prime**power}.inject(:*)
    end.map{|product| Tonal::Ratio.new(product)}
  end
end
