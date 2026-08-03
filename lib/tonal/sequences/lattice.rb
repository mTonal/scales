class Tonal::Sequence::Lattice < Tonal::Sequence
  def initialize(primes: [3, 5, 7, 11, 13], max_weight: 2)
    @sequence = [-1, 0, 1].repeated_permutation(primes.count).to_a
      .select{|exponents| exponents.count{|exponent| exponent != 0} <= max_weight}
      .map{|exponents| primes.zip(exponents).map{|prime, exponent| Rational(prime)**exponent}.inject(:*)}
      .map{|product| Tonal::Ratio.new(product)}
  end
end
