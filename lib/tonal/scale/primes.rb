# Harmonic content of a scale: the primes its ratios are built from, and how complex they are.
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
  #   => [2, 5, 3, 7]
  #
  def max_primes
    ratios.map(&:max_prime)
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
  def prime_divisions
    ratios.map(&:prime_divisions)
  end

  # @return [Array] of prime vectors of the notes of the scale
  #
  # @example
  #   Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r).primes.prime_vectors
  #   => [[0, 0], [-2, 0, 1], [-1, 1], [-2, 0, 0, 1]]
  #
  def prime_vectors
    ratios.map(&:prime_vector)
  end
end
