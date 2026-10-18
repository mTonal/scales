# Harmonic content of a scale: the primes its ratios are built from, and how complex they are.
#
# Prime-based values (max primes, prime divisions, prime vectors) are nil for ratios with a prime factor above limit
# (default Tonal::Ratio::PRIME_LIMIT), such as EDO steps, which are irrational and held as the binary fraction of a Float.
#
# @example
#   Tonal::Scale.harmonic.primes.heights
#
class Tonal::Scale::Primes < Tonal::Scale::Service
  MEASURES = %i{benedetti wilson tenney log_weil weil}

  def_delegators :@scale, :ratios

  # @return [Array] of max primes of the ratios
  # @example
  #   Tonal::Scale.new(1/1r, 3/2r, 5/4r, 7/4r).primes.max_primes
  #   => [nil, 3, 5, 7]
  #
  # @param limit [Integer] the largest prime to factor by
  #
  def max_primes(limit: Tonal::Ratio::PRIME_LIMIT)
    ratios.map{|ratio| ratio.max_prime(limit:)}
  end

  # @return [Array<Numeric>] complexity heights of each ratio in the scale measured by the given method
  #
  # @example
  #   Tonal::Scale.harmonic.primes.heights
  #   => [1, 72, 20, 88, 6, 104, 28, 120]
  #
  # @param method [Symbol] complexity measure to apply; one of :benedetti, :wilson, :tenney, :log_weil, :weil
  #
  def heights(method: :benedetti)
    return "Unknown measure #{method}. Use #{MEASURES}" unless MEASURES.include?(method)
    method = "#{method}_height".to_sym
    ratios.map(&method)
  end
  alias :measures :heights

  # @return [Array] of prime divisions of the ratios
  # @example
  #   Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r).primes.prime_divisions
  #   => [[[], []], [[[5, 1]], [[2, 2]]], [[[3, 1]], [[2, 1]]], [[[7, 1]], [[2, 2]]]]
  #
  # @param limit [Integer] the largest prime to factor by
  #
  def prime_divisions(limit: Tonal::Ratio::PRIME_LIMIT)
    ratios.map{|ratio| ratio.prime_divisions(limit:)}
  end

  # @return [Array] of prime vectors of the notes of the scale
  #
  # @example
  #   Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r).primes.prime_vectors
  #   => [nil, Vector[-2, 0, 1], Vector[-1, 1], Vector[-2, 0, 0, 1]]
  #
  # @param limit [Integer] the largest prime to factor by
  #
  def prime_vectors(limit: Tonal::Ratio::PRIME_LIMIT)
    ratios.map{|ratio| ratio.prime_vector(limit:)}
  end
end
