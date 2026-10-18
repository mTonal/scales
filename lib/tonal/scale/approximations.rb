# How a scale fits equal divisions and simpler ratios: EDO step mappings, best-fitting EDOs, and small-number approximations.
#
# @example
#   Tonal::Scale.harmonic.approximations.best_fitting_edo
#
class Tonal::Scale::Approximations < Tonal::Scale::Service
  ACCEPTED_APPROX_METHODS = %i{continued_fraction tree_path superparticular neighborhood}

  def_delegators :@scale, :count, :ratios, :first, :find, :to_r

  # @return [Array] of alternate approximations of ratios of the scale
  # @example
  #   Tonal::Scale.new(2**(0.0/12), (2**(1.0/12))).approximations.approximate
  #   => [[0, (1/1): [(1/1)]], [1, (4771397596969315/4503599627370496): [(17/16), (18/17), (89/84), (196/185), (1461/1379), (1657/1564), (3118/2943), (7893/7450), (18904/17843)]]]
  #
  # @param by [Symbol] the approximation algorithm. Accepted types are :continued_fraction, :tree_path, :superparticular, :neighborhood
  # @param sort_by [Symbol] the measures to sort the list of approximating ratios. Accepted measures are :benedetti, :wilson, :tenney, :log_weil, :weil
  # @param **kwargs keyword arguments used in the context of the algorithm
  #
  def approximate(by: :continued_fraction, sort_by: :benedetti, **kwargs)
    raise(ArgumentError, "Unknown approximation type: #{by}. Use #{ACCEPTED_APPROX_METHODS}") unless ACCEPTED_APPROX_METHODS.include?(by)
    raise(ArgumentError, "Unknown measure type: #{sort_by}. Use #{Tonal::Scale::Primes::MEASURES}") unless Tonal::Scale::Primes::MEASURES.include?(sort_by)

    sort_by = "#{sort_by}_height".to_sym
    cents_tolerance = kwargs[:cents_tolerance] || Tonal::Cents::TOLERANCE
    max_prime = kwargs[:max_prime] || Tonal::Ratio::Approximation::DEFAULT_MAX_PRIME
    min_prime = kwargs[:min_prime] || Tonal::Ratio::Approximation::DEFAULT_MIN_PRIME

    case by
    when :continued_fraction
      depth = kwargs[:depth] || Tonal::Ratio::Approximation::DEFAULT_DEPTH
      conv_limit = kwargs[:conv_limit] || Tonal::Ratio::Approximation::CONVERGENT_LIMIT
      ratios.each_with_index.map{|r, i| [i, r.approximate.send("by_#{by}".to_sym, cents_tolerance:, depth:, max_prime:, min_prime:,conv_limit:).sort_by(&sort_by.to_sym)]}
    when :tree_path
      depth = kwargs[:depth] || Tonal::Ratio::Approximation::DEFAULT_TREE_PATH_DEPTH
      ratios.each_with_index.map{|r, i| [i, r.approximate.send("by_#{by}".to_sym, cents_tolerance:, depth:, max_prime:).sort_by(&sort_by.to_sym)]}
    when :superparticular
      depth = kwargs[:depth] || Tonal::Ratio::Approximation::DEFAULT_SUPERPART_DEPTH
      superpart = kwargs[:superpart] || :upper
      ratios.each_with_index.map{|r, i| [i, r.approximate.send("by_#{by}".to_sym, cents_tolerance:, depth:, max_prime:, superpart:).sort_by(&sort_by.to_sym)]}
    when :neighborhood
      depth = kwargs[:depth] || Tonal::Ratio::Approximation::DEFAULT_NEIGHBORHOOD_DEPTH
      max_boundary = kwargs[:max_boundary] || Tonal::Ratio::Approximation::DEFAULT_MAX_GRID_BOUNDARY
      max_scale = kwargs[:max_scale] || Tonal::Ratio::Approximation::DEFAULT_MAX_GRID_SCALE
      ratios.each_with_index.map{|r, i| [i, r.approximate.send("by_#{by}".to_sym, cents_tolerance:, depth:, max_prime:, max_boundary:, max_scale:).sort_by(&sort_by.to_sym)]}
    end
  end

  # @return [Array<Tonal::ReducedRatio>] the lowest-complexity approximation of each ratio in the scale
  #
  # @example
  #   Tonal::Scale.edo(12).approximations.nearest_small_ratios
  #   => [1/1, 16/15, 9/8, 6/5, 5/4, 4/3, 7/5, 3/2, 8/5, 5/3, 7/4, 15/8]
  #
  # @param sort_by [Symbol] complexity measure used to rank approximations; one of :benedetti, :wilson, :tenney, :log_weil, :weil
  #
  def nearest_small_ratios(sort_by: :benedetti)
    sort_by = :benedetti unless Tonal::Scale::Primes::MEASURES.include?(sort_by)
    sort_by = "#{sort_by}_height".to_sym
    ratios.map{|r| r.approximate.by_continued_fraction.sort_by(&sort_by).ratios.first}
  end

  # @return [Rational] the ratio of scale best expressing the given ratio
  # @example
  #   Tonal::Scale.edo(12).approximations.ratio_best_expressing(3/2r)
  #     => 421735949569275/281474976710656
  #
  # @param ratio being compared to notes of scale
  # @param epsilon nearness, in cents, to notes of scale being compared
  #
  def ratio_best_expressing(ratio, epsilon: 1.cents)
    ratio = ratio.kind_of?(Tonal::ReducedRatio) ? ratio : ratio.kind_of?(Numeric) ? Tonal::ReducedRatio.new(ratio) : raise(ArgumentError, "Ratio must be Tonal::ReducedRatio or Numeric")
    interval_in_cents = (first * ratio).to_cents

    result_ratio = nil
    while result_ratio.nil? do
      result_ratio = find{|r| (r.to_cents - interval_in_cents).abs <= epsilon}
      epsilon += 1
    end
    result_ratio
  end

  # @return [Tonal::Step] the step of scale best expressing the given ratio
  # @example
  #   Tonal::Scale.edo(12).approximations.step_best_expressing(3/2r)
  #     => 7\12
  #
  # @param ratio being compared to notes of scale
  # @param epsilon nearness, in cents, to notes of scale being compared
  #
  def step_best_expressing(ratio, epsilon: 1.cents)
    ratio_best_expressing(ratio, epsilon: epsilon).step(count)
  end

  # @return [Array] tuple with the EDO scale and average error best fitting the scale
  #
  # @param min_edo
  # @param max_edo
  #
  def best_fitting_edo(min_edo: 5, max_edo: 72)
    to_r.best_fitting_edo(min_edo:, max_edo:)
  end

  # @return [Array] of [Tonal::Step] mapping for the given modulo
  # @example
  #   Tonal::Scale.cps(1,3,5,7).approximations.steps
  #   => [1\6, 2\6, 2\6, 4\6, 5\6, 5\6]
  # @param modulo [Integer] the modulo
  #
  def steps(modulo=count)
    ratios.map{|ratio| ratio.step(modulo)}
  end

  # @return [Array] of steps in modulo 1200
  # @example
  #   Tonal::Scale.cps(1,3,5,7).approximations.steps_in_cents
  #   => [155\1200, 386\1200, 471\1200, 702\1200, 969\1200, 1088\1200]
  #
  def steps_in_cents
    steps(Tonal::Cents::CENT_SCALE)
  end

  # @return [Array] of [ratio, step, nearest-hundredth cents, nearest-hundredth-cent difference] tuples for each ratio of the scale
  #
  # @example
  #   Tonal::Scale.harmonic.approximations.maps_on
  #   => [[1/1, 0\8, 0.0, 0.0], [9/8, 1\8, 200.0, 3.91], ...]
  #
  # @param modulo [Integer] modulo used to compute step numbers, defaults to scale count
  #
  def maps_on(modulo=count)
    ratios.map{|r| [r, r.step(modulo), r.to_cents.nearest_hundredth.value, r.to_cents.nearest_hundredth_difference.value]}
  end

  # @return [Array<Tonal::Step>] the step positions of the Levy-negative of each ratio in the scale
  #
  # @example
  #   Tonal::Scale.harmonic.approximations.negatives
  #   => [5\8, 3\8, 2\8, 1\8, 0\8, 7\8, 6\8, 5\8]
  #
  def negatives
    ratios.map(&:negative).map{|r| r.step(count)}
  end

  # @return [Tonal::Scale::Approximations::Differences] containing the differences of scale notes to the chosen unit
  # @example
  #   Tonal::Scale.edo(7).approximations.differences
  #
  # @param unit [Symbol] :hundredth_cent (default) or :scale_step
  #
  def differences(unit: :hundredth_cent)
    Differences.new(scale, unit:)
  end

  class Differences
    attr_reader :scale, :unit
    extend Forwardable
    def_delegators :@scale, :equave, :count, :ratios

    def initialize(scale, unit: :hundredth_cent)
      @unit = unit
      @scale = scale
      generate_differences
    end

    def ratio_cents
      @differences.map(&:ratio_cents)
    end

    def unit_cents
      @differences.map(&:unit_cents)
    end

    def differences
      @differences.map(&:difference)
    end

    def inspect
      Terminal::Table.new(headings: ['step', 'ratio', 'ratio cents', 'unit cents', 'difference'], rows: @differences).render
    end
    alias :to_s :inspect

    private
    def generate_differences
      @differences ||= cents_difference(unit: @unit)
    end

    # @return [Array<Difference>] of notes to the chosen unit measurement
    # @example
    #   Tonal::Scale.edo(7).approximations.differences(unit: :hundredth_cent).unit_cents
    #   => [0.0, 200.0, 300.0, 500.0, 700.0, 900.0, 1000.0]
    #
    def cents_difference(unit: :hundredth_cent)
      case unit
      when :scale_step
        ratios.each_with_index.map do |ratio, i|
          unit_cents = (equave ** (i.to_f/count)).to_cents
          ratio_cents = ratio.to_cents
          Difference.new(step: i, ratio: ratio, ratio_cents:, unit_cents:, difference: ratio_cents - unit_cents)
        end
      when :hundredth_cent
        ratios.each_with_index.map do |ratio, i|
          ratio_cents = ratio.to_cents
          Difference.new(step: i, ratio: ratio, ratio_cents:, unit_cents: ratio_cents.nearest_hundredth, difference: ratio_cents.nearest_hundredth_difference)
        end
      end
    end

    Difference = Struct.new(:step, :ratio, :ratio_cents, :unit_cents, :difference, keyword_init: true) do
      def inspect
        [step, ratio, ratio_cents, unit_cents, difference]
      end
      alias :to_s :inspect
    end
  end
end
