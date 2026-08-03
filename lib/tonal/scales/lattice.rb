class Tonal::Scale::Lattice < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Lattice.new(primes: @args[:primes], max_weight: @args[:max_weight])
  end

  def name
    "Lattice, #{@args[:primes]}, max_weight: #{@args[:max_weight]}"
  end

  def description
    "Euler-Fokker/Wilson lattice: #{@args[:primes]} as independent bidirectional axes, up to #{@args[:max_weight]} simultaneously active"
  end

  # @return [Array<Tonal::Scale::Chord>] the four-note "unit square" tetrads of the lattice -
  #   for every pair of primes, each 2x2 block of neighboring points on their shared sub-grid
  #
  # @example
  #   Tonal::Scale.lattice.chords.count => 40
  #
  def chords
    @args[:primes].combination(2).flat_map do |prime_a, prime_b|
      [-1, 0].product([-1, 0]).map do |exp_a, exp_b|
        ratios = [[exp_a, exp_b], [exp_a + 1, exp_b], [exp_a, exp_b + 1], [exp_a + 1, exp_b + 1]].map do |a, b|
          raw = Rational(prime_a)**a * Rational(prime_b)**b
          Tonal::ReducedRatio.new(raw.numerator, raw.denominator)
        end.sort

        Tonal::Scale::Chord.new(
          ratios: ratios,
          steps: ratios.map{|ratio| find_index(ratio)},
          name: "Square, #{prime_a}.#{prime_b}",
          description: "Unit-square tetrad on the #{prime_a}/#{prime_b} axes of #{name}"
        )
      end
    end
  end
end
