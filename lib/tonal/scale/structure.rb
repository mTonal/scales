# The interval structure of a scale: the intervals between its notes, grouped by step distance, and the properties that follow from them.
#
# @example
#   Tonal::Scale.harmonic.structure.constant_structure?
#
class Tonal::Scale::Structure < Tonal::Scale::Service
  def_delegators :@scale, :count, :[], :to_a, :to_cents

  # @return [Array<Tonal::Interval>] intervals between consecutive notes of the scale
  # @example
  #   Tonal::Scale.new(1/1r, 5/4r, 3/2r).structure.sequential_intervals
  #   => [8/5 (1/1 / 5/4), 5/3 (5/4 / 3/2)]
  #
  def sequential_intervals
    to_a.each_cons(2).map{|first, second| Tonal::Interval.new(first, second)}
  end

  # @return [Hash] mapping each interval ratio to the Tonal::Interval instances spanning it, for every pair of notes
  # @example
  #   Tonal::Scale.new(1/1r, 5/4r, 3/2r).structure.combinations
  #   => {(8/5)=>[8/5 (1/1 / 5/4)], (4/3)=>[4/3 (1/1 / 3/2)], (5/3)=>[5/3 (5/4 / 3/2)]}
  #
  def combinations
    Hash.new{|h,k| h[k] = []}.tap do |h|
      to_a.combination(2).each do |first, second|
        i = Tonal::Interval.new(first, second)
        h[i.intervalic_ratio.to_r] << i
      end
    end
  end

  # @return [Array] of [interval_ratio, span_string] pairs summarizing each interval combination in the scale
  #
  # @example
  #   Tonal::Scale.new(1/1r, 5/4r, 3/2r).structure.combinations_description
  #   => [[(8/5), "8/5 (1/1 / 5/4)"], [(4/3), "4/3 (1/1 / 3/2)"], [(5/3), "5/3 (5/4 / 3/2)"]]
  #
  def combinations_description
    combinations.map{|k,v| [k, v.map(&:inspect).join(', ')]}
  end

  # @return [Hash] mapping each interval ratio to all Tonal::Interval instances of that ratio found in the scale, for every ordered pair of notes
  #
  # @example
  #   Tonal::Scale.harmonic.structure.occurrences
  #   => {(1/1) => [...], (9/8) => [...], ...}
  #
  def occurrences
    Hash.new{|h,k| h[k] = []}.tap do |hsh|
      to_a.each do |n|
        to_a.each do |m|
          i = Tonal::Interval.new(n, m)
          hsh[i.intervalic_ratio.to_r] << i
        end
      end
    end.sort.to_h
  end

  # @return [Array] averages between consecutive ratios of scale
  # @example
  #   Tonal::Scale.harmonic.structure.averages_between_steps
  #   => [17/16, 19/16, 21/16, 23/16, 25/16, 27/16, 29/16]
  #
  def averages_between_steps
    to_a.each_cons(2).map{|r1, r2| ((r1.to_r + r2.to_r) / 2).to_ratio}
  end

  # @return [Tonal::Interval] interval between given steps of scale
  # @example
  #   Tonal::Scale.harmonic.structure.interval_between_steps(3, 4)
  #   => 12/11 (3/2 / 11/8)
  #
  # @param lower_step [Integer] scale step of the divisor
  # @param upper_step [Integer] scale step of the dividend
  #
  def interval_between_steps(lower_step, upper_step)
    Tonal::Interval.new(self[lower_step], self[upper_step])
  end

  # @return [Array] of all intervals for step of scale
  # @example
  #   Tonal::Scale.harmonic.structure.all_intervals_by_step(2)
  #   => [8/5 (1/1 / 5/4), 18/11 (9/8 / 11/8), 5/3 (5/4 / 3/2), 22/13 (11/8 / 13/8), 12/7 (3/2 / 7/4), 26/15 (13/8 / 15/8), 7/4 (7/4 / 1/1), 5/3 (15/8 / 9/8)]
  #
  # @param step between note pairs
  #
  def all_intervals_by_step(step)
    0.upto(count-1).map{|i| interval_between_steps(i, i+step)}
  end

  # @return [Array] array of all intervals for all steps of scale
  # @example
  #   Tonal::Scale.harmonic.structure.all_intervals_by_steps
  #     => [[1/1 (1/1 / 1/1), 1/1 (9/8 / 9/8), ...],
  #         [16/9 (1/1 / 9/8), 9/5 (9/8 / 5/4), ...],
  #        ...
  #
  def all_intervals_by_steps
    0.upto(count-1).map{|i| all_intervals_by_step(i)}
  end

  # @return [Array] array of unique intervals with a given step distance
  # @example
  #   Tonal::Scale.from_scalarchive("wilson7").structure.unique_intervals_by_step(1)
  #   => [(81/80) ((9/8) / (10/9)), (25/24) ((10/9) / (16/15)), (36/35) ((16/15) / (28/27)), (28/27) ((28/27) / (1/1))]
  # @param step between note pairs
  #
  def unique_intervals_by_step(step)
    all_intervals_by_step(step).uniq(&:to_r).sort_by(&:to_r)
  end

  # @return [Array<Array<Integer>>] prime vectors of the unique intervals at the given step distance, zero-padded to equal length
  #
  # @example
  #   Tonal::Scale.harmonic.structure.unique_interval_prime_vectors_by_step(1)
  #   => [[-4, 0, 1], [-3, 1], ...]
  #
  # @param step [Integer] the step distance between note pairs
  #
  def unique_interval_prime_vectors_by_step(step)
    pvs = unique_intervals_by_step(step).map(&:intervalic_ratio).map(&:prime_vector).map(&:to_a)
    max_count = pvs.map(&:length).max
    pvs.map{|e| e.rpad!(max_count, 0)}
  end

  # @return [Array] array of unique intervals for all steps of scale
  # @example
  #   Tonal::Scale.harmonic.structure.unique_intervals_by_step_distances
  #   => [[1/1 (1/1 / 1/1)],
  #       [16/15 (1/1 / 15/8), 15/14 (15/8 / 7/4), ...],
  #      ...
  #
  def unique_intervals_by_step_distances
    0.upto(count-1).map{|i| unique_intervals_by_step(i)}
  end

  # @return [Hash] containing ratio varieties between pairs of ratios at each step of scale
  #
  def variations_of_unique_intervals
    Hash.new{|h, k| h[k] = []}.tap do |hsh|
      unique_intervals_by_step_distances.each do |row|
        next if row.one?
        row.combination(2).map do |comb|
          variation = (comb[1].to_r > comb[0].to_r) ? comb[1].to_r / comb[0].to_r : comb[0].to_r / comb[1].to_r
          hsh[variation] << comb
        end
      end
    end
  end

  # @return [Boolean] if scale is a constant structure: no interval appears at more than one step distance
  # @example
  #   Tonal::Scale.harmonic.structure.constant_structure?
  #   => false
  #
  def constant_structure?
    unique_intervals_by_steps_flattened = unique_intervals_by_step_distances.flatten.map(&:to_r)
    unique_intervals_by_steps_flattened.count == unique_intervals_by_steps_flattened.uniq.count
  end

  # @return [Boolean] if the consecutive intervals of the scale come in one or two sizes (compared to the hundredth of a cent)
  # @example
  #   Tonal::Scale.edo(12).structure.mos?
  #   => true
  #
  def mos?
    sequential_intervals.map{|interval| interval.to_cents.to_f.round(2)}.uniq.count.between?(1, 2)
  end

  # @return [Numeric] determinant of the prime vectors of the unique intervals at step
  #
  # @param step [Integer] the step distance between note pairs
  #
  def determinant_by_step(step)
    Matrix[*unique_interval_prime_vectors_by_step(step)].determinant
  end

  # @return [Array] of all intervals found in scale that span ratio
  # @params [Rational] being searched
  # @example
  #   Tonal::Scale.from_scalarchive("wilson7").structure.find_all(15/14r)
  #   => [15/14 (10/9 / 28/27), 15/14 (5/4 / 7/6), 15/14 (5/3 / 14/9), 15/14 (15/8 / 7/4)]
  #
  def find_all(ratio)
    all_intervals_by_steps.flatten.find_all{|i| i.intervalic_ratio == ratio}
  end

  # @return [Array] Cent differences between consecutive ratios of scale
  # @example
  #   Tonal::Scale.harmonic.structure.cent_diff
  #   => [203.91 ¢, 182.4 ¢, 165.01 ¢, 150.64 ¢, 138.57 ¢, 128.3 ¢, 119.44 ¢]
  #
  def cent_diff
    to_cents.each_cons(2).map{|lower, upper| upper - lower}
  end
end
