class Tonal::Scale::Analysis
  ACCEPTED_MEASURES = %i{benedetti wilson tenney log_weil weil}

  extend Forwardable
  def_delegators :@scale, :to_cents, :count, :length, :ratios, :[], :steps, :to_cents, :equave, :indices
  def_delegators :@approximations, :approximate, :step_best_expressing, :ratio_best_expressing, :best_fitting_edo #, :by_best_expressions_of
  def_delegators :@descriptions, :max_primes, :heights, :prime_divisions, :prime_vectors, :steps, :steps_in_cents
  def_delegators :@efficiencies, :efficiencies, :efficiency_with
  def_delegators :@intervals, :intervals, :occurrences, :unique_intervals_by_step_distances

  PRECISION = 2

  attr_accessor :scale

  # @return [Tonal::Scale::Analysis]
  # @example
  #   Tonal::Scale::Analysis.new(Tonal::Scale.harmonic)
  #   => [(1/1), (9/8), (5/4), (11/8), (3/2), (13/8), (7/4), (15/8)]
  # @param scale [Tonal::Scale] a scale instance to analyze
  #
  def initialize(scale=nil)
    @scale = scale
    @approximations = Approximations.new(scale)
    @descriptions = Descriptions.new(scale)
    @efficiencies = Efficiencies.new(scale)
    @intervals = Intervals.new(scale)
  end

  def inspect
    scale
  end

  # @return [Array] list of all modes of self
  # @example
  #   TODO provide one
  #   TODO Consider putting in a Descriptions class
  #
  def modes
    [].tap do |scales|
      (0..scale.count-1).each do |step|
        scales << scale.mode(step)
      end
    end
  end

  # @return [Boolean] if scale is a constant structure
  # @example
  #   Tonal::Scale::Analysis.new(Tonal::Scale.harmonic).constant_structure?
  #   => false
  #
  def constant_structure?
    unique_intervals_by_steps_flattened = unique_intervals_by_step_distances.flatten.map(&:to_r)
    unique_intervals_by_steps_flattened.count == unique_intervals_by_steps_flattened.uniq.count
  end

  # @return [Tonal::Scale::Analysis::Differences] containing the differences of scale notes to selected measure
  # @example
  #   Tonal::Scale.edo(7).differences
  #
  # @param unit
  #
  def differences(unit: :hundredth_cent)
    Differences.new(scale, unit:)
  end

  # BEGIN Moved from Tonal::Scale.
  # Some of these methods are initially returning scales, but they shouldn't be. They should only be reporting data, which can be used to generate scales.
  ################
  #
  # TODO: Move to an Analyzer class
  #

  # TODO: Document
  def nearest_ratio_to(ratio)

  end

  # END Moved from Tonal::Scale

  # TODO WIP: Analyzing generating MOS
  def self.partitionings(mod)
    1.upto(mod).map{|i| "#{i}: #{Step.new(mod, (2**(i.to_f/mod)))}, #{mod} / #{i} = #{mod / i}, #{mod} % #{i} = #{mod % i}"}
  end

  # ######################################################
  # Measurements
  # ######################################################

  def determinant_by_step(step)
    Matrix[*unique_interval_prime_vectors_by_step(step)].determinant
  end

  # @return [Array] of all intervals found in scale that span ratio
  # @params [Rational] being searched
  # @example
  #   Tonal::Scale::Analysis.new(Tonal::Scale.from_scalarchive("wilson7")).find_all(15/14r)
  #   => [15/14 (10/9 / 28/27), 15/14 (5/4 / 7/6), 15/14 (5/3 / 14/9), 15/14 (15/8 / 7/4)]
  #
  def find_all(ratio)
    all_intervals_by_steps.flatten.find_all{|i| i.interval == ratio}
  end

  # @return [Boolean] if scale is an MOS
  # @example
  #   TODO
  # DEBUG
  #
  def mos?
    intervals.sequential_unique.count.in? [1, 2]
  end

  # @return [Array] of cent differences between self and the nearest approximations expressed by modulo
  # @example
  # @param mod the unit of measurement
  def cent_diff_mod(mod)
    ratios.map{|r| r.cent_diff_mod(mod)}
  end

  # @return [Array] Cent differences between consecutive ratios of scale
  # @example
  #   Tonal::Scale::Analysis.new(Tonal::Scale.harmonic).cent_diff
  #   => [203.91000173077484,
  #       182.40371213406,
  #       165.0042284999219,
  #       150.6370585006307,
  #       138.57266090392318,
  #       128.2982446998143,
  #       119.4428082610973]
  #
  def cent_diff
    cents.cons_diff
  end

  class Approximations
    ACCEPTED_APPROX_METHODS = %i{continued_fraction tree_path superparticular neighborhood}

    extend Forwardable
    def_delegators :@scale, :to_cents, :count, :length, :ratios, :[], :first, :steps, :to_cents, :equave, :indices, :to_r

    attr_reader :scale

    def initialize(scale)
      @scale = scale
    end

    # @return [Array] of alternate approximations of ratios of the scale
    # @example
    #   Tonal::Scale::Analysis::Approximations.new(Tonal::Scale.new(2**(0.0/12), (2**(1.0/12)))).approximate
    #   => [[0, (1/1): [(1/1)]], [1, (4771397596969315/4503599627370496): [(17/16), (18/17), (89/84), (196/185), (1461/1379), (1657/1564), (3118/2943), (7893/7450), (18904/17843)]]]
    #
    # @param by [Symbol] the approximation algorithm. Accepted types are :continued_fraction, :tree_path, :superparticular, :neighborhood
    # @param sort_by [Symbol] the measures to sort the list of approximating ratios. Accepted measures are :benedetti, :wilson, :tenney, :log_weil, :weil
    # @param **kwargs keyword arguments used in the context of the algorithm
    #
    def approximate(by: :continued_fraction, sort_by: :benedetti, **kwargs)
      raise(ArgumentError, "Unknown approximation type: #{by}. Use #{ACCEPTED_APPROX_METHODS}") unless ACCEPTED_APPROX_METHODS.include?(by)
      raise(ArgumentError, "Unknown measure type: #{sort_by}. Use #{ACCEPTED_MEASURES}") unless ACCEPTED_MEASURES.include?(sort_by)

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

    # @return [Rational] the ratio of scale best expressing the given ratio
    # @example
    #   Tonal::Scale::Analysis::Approximations.new(Tonal::Scale.edo(12)).ratio_best_expressing(3/2r)
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
        result_ratio = scale.find{|r| (r.to_cents - interval_in_cents).abs <= epsilon}
        epsilon += 1
      end
      result_ratio
    end

    # @return [Tonal::Step] the step of scale best expressing the given ratio
    # @example
    #   Tonal::Scale::Analysis::Approximations.new(Tonal::Scale.edo(12)).step_best_expressing(3/2r)
    #     => 7\12
    #
    # @param ratio being compared to notes of scale
    # @param epsilon nearness, in cents, to notes of scale being compared
    #
    def step_best_expressing(ratio, epsilon: 1.cents)
      ratio_best_expressing(ratio, epsilon: epsilon).step(count)
    end

    # @return [Array] tuple with the EDO scale and average error best fitting self
    # @example
    #
    # @param min_edo
    # @param max_edo
    #
    def best_fitting_edo(min_edo: 5, max_edo: 72)
      to_r.best_fitting_edo(min_edo:, max_edo:)
    end

  end

  class Descriptions
    extend Forwardable
    def_delegators :@scale, :to_cents, :count, :length, :ratios, :[], :first, :steps, :to_cents, :equave, :indices

    attr_reader :scale

    def initialize(scale)
      @scale = scale
    end

    # @return [Array] of max primes of the ratios
    # @example
    #   Tonal::Scale::Analysis.new(Tonal::Scale.new(1/1r, 3/2r, 5/4r, 7/4r)).max_primes
    #   => [2, 5, 3, 7]
    #
    def max_primes
      ratios.map(&:max_prime)
    end

    # @return [Array<Numeric>] complexity heights of each ratio in the scale measured by the given method
    #
    # @example
    #   Tonal::Scale::Analysis.new(Tonal::Scale.harmonic).heights
    #   => [1, 72, 20, 88, 6, 104, 28, 120]
    #
    # @param method [Symbol] complexity measure to apply; one of :benedetti, :wilson, :tenney, :log_weil, :weil
    #
    def heights(method: :benedetti)
      return "Unknown measure #{method}. Use #{ACCEPTED_MEASURES}" unless ACCEPTED_MEASURES.include?(method)
      method = "#{method}_height".to_sym
      ratios.map(&method)
    end
    alias :measures :heights

    # @return [Array] of prime divisions of the ratios
    # @example
    #   Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r).prime_divisions
    #   => [[[[2, 1]], [[2, 1]]], [[[5, 1]], [[2, 2]]], [[[3, 1]], [[2, 1]]], [[[7, 1]], [[2, 2]]]]
    #
    def prime_divisions
      ratios.map(&:prime_divisions)
    end

    # @return [Array] of prime vectors of the notes of the scale
    #
    # @example
    #   Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r).prime_vectors
    #   => [[0, 0], [-2, 0, 1], [-1, 1], [-2, 0, 0, 1]]
    #
    def prime_vectors
      ratios.map(&:prime_vector)
    end

    # @return [Array] of [Tonal::Step] mapping for the given modulo
    # @example
    #   Tonal::Scale.cps(1,3,5,7).steps
    #   => [1\6, 2\6, 2\6, 4\6, 5\6, 5\6]
    # @param mod [Integer] the modulo
    #
    def steps(modulo=count)
      ratios.map{|ratio| ratio.step(modulo)}
    end

    # @return [Array] of steps in modulo 1200
    # @example
    #   Tonal::Scale.cps(1,3,5,7).steps_in_cents
    #   => [155\1200, 386\1200, 471\1200, 702\1200, 969\1200, 1088\1200]
    #
    def steps_in_cents
      steps(Tonal::Cents::CENT_SCALE)
    end
  end

  class Differences
    attr_reader :scale, :unit
    extend Forwardable
    def_delegators :@scale, :to_cents, :indices, :equave, :count, :ratios

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

    # @return [Tonal::Scale::Analysis::Differences] of notes to the chosen unit measurement
    # @example
    #   Tonal::Scale.edo(7).cents_difference(unit: :scale_step)
    #   =>
    #
    # @example
    #   Tonal::Scale.edo(7).cents_difference(unit: :hundredth_cent)
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

  class Efficiencies
    extend Forwardable
    def_delegators :@scale, :count

    PRECISION = 2

    attr_reader :scale

    def initialize(scale)
      @scale = scale
    end

    # @return [Array<Float>] the EDO step efficiency of each ratio in the scale
    #
    # @example
    #   Tonal::Scale::Analysis::Efficiencies.new(Tonal::Scale.harmonic).efficiencies
    #   => [0.0, -3.91, 13.69, -48.68, 1.96, -40.53, -31.17, -11.73]
    #
    # @param modulo [Integer] the EDO modulo used to compute step efficiency, defaults to scale count
    #
    def efficiencies(modulo=count)
      scale.ratios.map{|r| r.efficiency(modulo, is_step_efficiency: true)}
    end

    # @return [Float] difference in cents between the provided ratio and the scale's best step approximation to it
    # @example
    #   Tonal::Scale.edo(12).efficiency_with(81/64r) => -7.82
    #
    def efficiency_with(ratio)
      ratio = ratio.kind_of?(Tonal::ReducedRatio) ? ratio : ratio.kind_of?(Numeric) ? Tonal::ReducedRatio.new(ratio) : raise(ArgumentError, "Ratio must be Tonal::ReducedRatio or Numeric")
      ratio.efficiency(count)
    end
  end

  class Intervals
    attr_reader :scale

    def initialize(scale)
      raise ArgumentError, "Scale required" unless scale.kind_of?(Tonal::Scale)

      @scale = scale
      @inventory = nil
    end

    # @return [Hash] mapping each interval ratio to all Tonal::Interval instances of that ratio found in the scale
    #
    # @example
    #   Tonal::Scale::Analysis::Intervals.new(Tonal::Scale.harmonic).occurrences
    #   => {(1/1) => [...], (9/8) => [...], ...}
    #
    # TODO See how output could be better designed
    #
    def occurrences
      Hash.new{|h,k| h[k] = []}.tap do |hsh|
        scale.to_a.each do |n|
          scale.to_a.each do |m|
            i = Tonal::Interval.new(n, m)
            hsh[i.interval.to_r] << i
          end
        end
      end.sort.to_h
    end

    # @return [Array] averages between consecutive ratios of scale
    def averages_between_steps
      [].tap do |ratios|
        scale.each_cons(2) do |r1, r2|
          ratios << ((r1.to_r + r2.to_r) / 2).to_ratio
        end
      end
    end

    # @return [Tonal::Interval] interval between given steps of scale
    # @example
    #   scale = Tonal::Scale.harmonic
    #   Tonal::Scale::Analysis.new(scale).interval_between_steps(3, 4)
    #   => 12/11 (3/2 / 11/8)
    #
    # @example
    #   Tonal::Scale.harmonic.interval_between_steps(3, 4)
    #   => 12/11 (3/2 / 11/8)
    #
    # @param lower_step [Integer] scale step of the divisor
    # @param upper_step [Integer] scale step of the dividend
    #
    def interval_between_steps(lower_step, upper_step)
      Tonal::Interval.new(scale[lower_step], scale[upper_step])
    end

    # @return [Array] of all intervals for step of scale
    # @example
    #   scale = Tonal::Scale.harmonic
    #   Tonal::Scale::Analysis.new(scale).all_intervals_by_step(2)
    #   => [8/5 (1/1 / 5/4), 18/11 (9/8 / 11/8), 5/3 (5/4 / 3/2), 22/13 (11/8 / 13/8), 12/7 (3/2 / 7/4), 26/15 (13/8 / 15/8), 7/4 (7/4 / 1/1), 5/3 (15/8 / 9/8)]
    #
    # @example
    #    Tonal::Scale.harmonic.all_intervals_by_step(2)
    #    => [8/5 (1/1 / 5/4), 18/11 (9/8 / 11/8), 5/3 (5/4 / 3/2), 22/13 (11/8 / 13/8), 12/7 (3/2 / 7/4), 26/15 (13/8 / 15/8), 7/4 (7/4 / 1/1), 5/3 (15/8 / 9/8)]
    #
    # @param step between note pairs
    #
    # TODO
    # Review what this is doing
    # 1. In method name and API, differentiate between step on which interval measurement is being based and interval being measured
    # 2. Allow method to accept the step and the interval
    # 3. Consolidate methods into this method
    def all_intervals_by_step(step)
      [].tap do |accumulator|
        0.upto(count-1) do |i|
          accumulator << interval_between_steps(i, i+step)
        end
      end
    end
    # intervals_at_step
    # intervals_by_step
    # step_distant_intervals
    # intervals_step_apart
    # intervals

    # @return [Array] array of all intervals for all steps of scale
    # @example
    #   Tonal::Scale::Analysis.new(Tonal::Scale.harmonic).all_intervals_by_steps
    #     => [[1/1 (1/1 / 1/1), 1/1 (9/8 / 9/8), 1/1 (5/4 / 5/4), 1/1 (11/8 / 11/8), 1/1 (3/2 / 3/2), 1/1 (13/8 / 13/8), 1/1 (7/4 / 7/4), 1/1 (15/8 / 15/8)],
    #         [16/9 (1/1 / 9/8), 9/5 (9/8 / 5/4), 20/11 (5/4 / 11/8), 11/6 (11/8 / 3/2), 24/13 (3/2 / 13/8), 13/7 (13/8 / 7/4), 28/15 (7/4 / 15/8), 15/8 (15/8 / 1/1)],
    #        ...
    #
    def all_intervals_by_steps
      [].tap do |accumulator|
        0.upto(count-1) do |i|
          accumulator << all_intervals_by_step(i)
        end
      end
    end

    # @return [Array] array of unique intervals with a given step distance
    # @example
    #   scale = Tonal::Scale.from_scalarchive("wilson7")
    #   Tonal::Scale::Analysis.new(scale).unique_intervals_by_step(1)
    #   => [(81/80) ((9/8) / (10/9)), (25/24) ((10/9) / (16/15)), (36/35) ((16/15) / (28/27)), (28/27) ((28/27) / (1/1))]
    # @param step between note pairs
    #
    def unique_intervals_by_step(step)
      all_intervals_by_step(step).uniq{|i| i.to_r}.sort{|i| i.to_r}
    end

    # @return [Array<Array<Integer>>] prime vectors of the unique intervals at the given step distance, zero-padded to equal length
    #
    # @example
    #   Tonal::Scale::Analysis::Intervals.new(Tonal::Scale.harmonic).unique_interval_prime_vectors_by_step(1)
    #   => [[-4, 0, 1], [-3, 1], ...]
    #
    # @param step [Integer] the step distance between note pairs
    #
    def unique_interval_prime_vectors_by_step(step)
      pvs = unique_intervals_by_step(step).map(&:interval).map(&:prime_vector).map(&:to_a)
      max_count = pvs.map(&:length).max
      pvs.map{|e| e.rpad!(max_count, 0)}
    end

    # @return [Array] array of intervals for all steps of scale
    # @example
    #   Tonal::Scale::Analysis.new(Tonal::Scale.harmonic).unique_intervals_by_step_distances
    #   => [[1/1 (1/1 / 1/1)],
    #       [11/10 (11/8 / 5/4), 16/15 (1/1 / 15/8), 15/14 (15/8 / 7/4), 14/13 (7/4 / 13/8), 9/8 (9/8 / 1/1), 13/12 (13/8 / 3/2), 12/11 (3/2 / 11/8), 10/9 (5/4 / 9/8)],
    #       [8/7 (1/1 / 7/4), 15/13 (15/8 / 13/8), 7/6 (7/4 / 3/2), 13/11 (13/8 / 11/8), 6/5 (3/2 / 5/4), 11/9 (11/8 / 9/8), 5/4 (5/4 / 1/1)],
    #      ...
    #
    def unique_intervals_by_step_distances
      [].tap do |accumulator|
        0.upto(count-1) do |i|
          accumulator << unique_intervals_by_step(i)
        end
      end
    end

    # @return [Hash] containing ratio varieties between pairs of ratios at each step of scale
    # @example
    #
    def variations_of_unique_intervals
      Hash.new{|h, k| h[k] = []}.tap do |hsh|
        unique_intervals_by_step_distances.each do |row|
          next if row.one?
          row.combination(2).map do |comb|
            variation = (comb[1] > comb[0]) ? comb[1].to_r / comb[0].to_r : comb[0].to_r / comb[1].to_r
            hsh[variation] << comb
          end
        end
      end
    end

    # @return [Array] of [interval_ratio, span_string] pairs summarizing each interval combination in the scale
    #
    # @example
    #   Tonal::Scale::Analysis::Intervals.new(Tonal::Scale.harmonic).combinations_description
    #   => [[9/8, "9/8 (9/8 / 1/1)"], ...]
    #
    def combinations_description
      combinations.map{|k,v| [k, v.map(&:span).join(', ')]}
    end

    # Intervals charts
    # Done
    #   2D Table - Table of ratios between pitches
    #   Occurences - List of occurrences of ratios
    # WIP
    #   Inventory - Inventory of all ratios - Includes: interval, prime vector, difference
    #     To add: occurrences
    # TO DO
    #   Structure - List of ratios ordered by their subtending count
    #


    # Renders a 2D table of intervals between all scale note pairs (not yet active)
    #
    #def table
    #  rows = []
    #  rows << ([nil] + scale.to_r)
    #  scale.each do |n|
    #    rows << ([n.to_r] + [].tap{|combis| scale.each{|m| combis << (n / m).to_r}})
    #  end
    #  Terminal::Table.new(rows: rows)
    #end

    # Renders a sorted inventory of all interval ratios in the scale with prime vectors and cent differences (not yet active)
    #
    # Generalize - presently hard-coded for 7-limit
    #
    #def inventory
    #  unless @inventory
    #    set = SortedSet.new.tap do |set|
    #      scale.to_a.combination(2).to_a.each do |first, second|
    #        set << Interval.new(first, second).interval
    #        set << Interval.new(second, first).interval
    #      end
    #    end
    #    max = set.map(&:max_prime).max
    #    max_pad = Prime.upto(max).count + 1
    #    @inventory ||= [].tap do |rows|
    #      set.each do |interval|
    #        rows << ([interval.to_r, interval.prime_vector.to_a].flatten.rpad(max_pad, 0) << interval.difference)
    #      end
    #    end
    #    @l ||= Terminal::Table.new(rows: @inventory)
    #    @l.align_column(0, :center)
    #    1.upto(max_pad).each do |i|
    #      @l.align_column(i, :right)
    #    end
    #  end
    #  @l
    #end

    # TODO: Document
    #
    #def structure(table: true)
    #  rows = []
    #  scale.indices.each do |i|
    #    row = []
    #    scale.indices.each do |j|
    #      row << (scale[j+i] / scale[j])
    #    end
    #      rows << row
    #  end
    #
    #  if table
    #    Terminal::Table.new(rows: rows)
    #  else
    #    rows
    #  end
    #end

    def method_missing(m, *args, &block)
      _list(m)
    end

    private
    def _list(format)
      case format
      when :sequential
        [].tap do |intervals|
          scale.each_cons(2){|first, second| intervals << Interval.new(first, second)}
        end
      when :combination
        Hash.new {|h,k| h[k] = []}.tap do |h|
          scale.to_a.combination(2).to_a.each do |first, second|
            i = Interval.new(first, second)
            h[i.interval.to_r] << i
          end
        end
      else
        "Nothing to do"
      end
    end
  end

  class Statistics
    extend Forwardable
    def_delegators :@scale, :count, :efficiencies

    PRECISION = 2

    attr_reader :scale

    def initialize(scale)
      @scale = scale
    end

    # @return [Float] mean of the step efficiencies of the scale
    #
    # @example
    #   Tonal::Scale::Analysis::Statistics.new(Tonal::Scale.harmonic).mean => -16.56
    #
    # @param modulo [Integer] the EDO modulo used to compute step efficiencies, defaults to scale count
    # @param round [Integer] decimal places to round the result
    #
    def mean(modulo=count, round: PRECISION)
      (efficiencies(modulo).sum/count).round(round)
    end

    # @return [Float] variance of the step efficiencies of the scale
    #
    # @example
    #   Tonal::Scale::Analysis::Statistics.new(Tonal::Scale.harmonic).variance => 368.18
    #
    # @param modulo [Integer] the EDO modulo used to compute step efficiencies, defaults to scale count
    # @param round [Integer] decimal places to round the result
    #
    def variance(modulo=count, round: PRECISION)
      m = mean(modulo, round:)
      (efficiencies(modulo).map{|x| (x - m)**2}.sum/count).round(round)
    end

    # @return [Float] standard deviation of the step efficiencies of the scale
    #
    # @example
    #   Tonal::Scale::Analysis::Statistics.new(Tonal::Scale.harmonic).standard_deviation => 19.19
    #
    # @param modulo [Integer] the EDO modulo used to compute step efficiencies, defaults to scale count
    # @param round [Integer] decimal places to round the result
    #
    def standard_deviation(modulo=count, round: PRECISION)
      (Math.sqrt(variance(modulo, round:))).round(round)
    end
  end
end
