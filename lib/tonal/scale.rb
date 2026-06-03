require "tonal/io"
require "tonal/scales/constructors"

class Tonal::Scale
  extend Forwardable

  def_delegators :@scale, :entries, :count, :length, :find, :first, :each, :each_with_index, :&, :+, :-, :==, :to_a, :each_cons, :each_slice, :collect, :delete, :intersection, :replace
  def_delegators :@analysis, # Analysis::Approximations
                             :step_best_expressing,
                             :ratio_best_expressing,
                             :approximate,
                             :best_fitting_edo,

                             # Analysis::Descriptions
                             :max_primes,
                             :heights,
                             :prime_divisions,
                             :prime_vectors,
                             :steps,
                             :steps_in_cents,

                             # Analysis::Efficiencies
                             :efficiency_with,
                             :efficiencies,

                             # Analysis::Intervals
                             :occurrences,
                             :intervals,

                             # Analysis::Statistics
                             :mean, :variance, :standard_deviation,
                             :averages_between_steps,

                             # Analysis
                             :cent_diff, :cent_diff_mod, :cents_distance_from, :combinations,
                             :constant_structure?,
                             :determinant_by_step,
                             :find_all, :modes,
                             :difference, :differences,
                             :nearest_hundredth_cents_differences, :cents_difference_pairs

  def_delegators :@mappers, :to_cents, :to_log2, :to_f, :to_r, :to_midi, :maps_on,
                            :to_radians, :to_degrees, :to_circle, :negatives,
                            :nearest_small_ratios, :adjusted_standard_tuning_frequency #, :best_fitting_edo

  def_delegators :@reporter, :test
  def_delegators :@sequence, :sequence

  include Tonal::Scale::IO
  include Tonal::Scale::Constructors

  DEFAULT_EQUAVE = 2/1r

  attr_reader :equave
  attr_accessor :name, :description

  # @return [Tonal::Scale]
  #
  # @example
  #   Tonal::Scale.new(1/2r, 1/3r, 1/4r, 1/5r) => [(1/1), (4/3), (8/5)]
  #   Tonal::Scale.new(Tonal::ReducedRatio.new(1,2), Tonal::ReducedRatio.new(1,3), Tonal::ReducedRatio.new(1,4), Tonal::ReducedRatio.new(1,5)) => [(1/1), (4/3), (8/5)]
  #   Tonal::Scale.new(Tonal::Ratio.new(1,2), Tonal::Ratio.new(1,3), Tonal::Ratio.new(1,4), Tonal::Ratio.new(1,5)) => [(1/1), (4/3), (8/5)]
  #
  # @example with block
  #   Tonal::Scale.new do |scale|
  #     scale << 1/1r << 4/3r << 8/5r
  #   end => [(1/1), (4/3), (8/5)]
  #
  # @param collection of ratios, as Rational, Tonal::Ratio, or Tonal::ReducedRatio
  # @param kwargs list of keyword arguments
  #
  def initialize(*collection, **kwargs)
    yield collection if block_given?

    @args = kwargs
    @equave = kwargs[:equave] || DEFAULT_EQUAVE
    @sequence = init_sequence || Tonal::Sequence.new(collection)
    @scale = SortedSet.new(sequence.map{|term| Tonal::ReducedRatio.new(term.numerator, term.denominator)})
    @scale << Tonal::ReducedRatio.new(1/1r) if @args[:include_equave]
    label_ratios!
    @name = kwargs[:name] || "Unamed"
    @description = kwargs[:description] || "Undescribed"
    @analysis = Analysis.new(self)
    @mappers = Mappers.new(self)
    @reporter = nil
  end

  alias :modulo :count
  alias :ratios :entries

  # @return [Tonal::Scale] branching scale of self
  #
  # @example
  #   Tonal::Scale.proportional(35/27r, 2/1r).branching => [(1/1), (32/27), (35/27), (73/54), (108/73), (128/73), (140/73)]
  #
  # @param starting_tones [Array] of ratios to start branching from, default is first and last of self
  #
  def branching(starting_tones: [self.first, self.last.invert])
    Tonal::Scale.branching(segments: [to_a], starting_nodes: starting_tones)
  end

  # @return [Tonal::Scale] mode on step of self (step becomes 1/1 of self)
  #
  # @example
  #   Tonal::Scale.harmonic(indices: 4..7).mode(4) => [1/1, 7/6, 4/3, 5/3]
  #
  # @param step [Integer] step index of the source scale on which the tonic of the mode is set
  #
  def mode(step)
    #return self if (step % count == 0)
    Tonal::Scale.new(*scale.collect{|r| r / self[step]}, name: "#{self.name} - mode #{step}", description: "#{self.description} - mode #{step}")
  end

  # @return [Array] of labels of the ratios of self
  #
  # @example
  #  Tonal::Scale.harmonic.labels => ["1/1", "9/8", "5/4", "11/8", "3/2", "13/8", "7/4", "15/8"]
  #
  def labels
    scale.map(&:label)
  end

  # @return [Array] ordinal positions of ratios of scale
  #
  # @example
  #   Tonal::Scale.cps.indices
  #   => [0, 1, 2, 3, 4, 5]
  #
  def indices
    (0..count-1).to_a
  end

  # @return [Tonal::ReducedRatio] the last ratio of self
  #
  # @example
  #   Tonal::Scale.new(1/1r, 9/8r, 5/4r, 3/2r, 5/3r).last => 5/3
  #
  def last
    self[-1]
  end

  # @return [Array] of antecedents of the notes
  #
  # @example
  #  Tonal::Scale.new(1/1r, 9/8r, 5/4r, 3/2r, 5/3r).antecedents => [1, 9, 5, 3, 5]
  #
  def antecedents
    to_a.antecedents
  end
  alias :numerators :antecedents

  # @return [Array] of consequents of the notes
  #
  # @example
  # Tonal::Scale.new(1/1r, 9/8r, 5/4r, 3/2r, 5/3r).consequents => [1, 8, 4, 2, 3]
  #
  def consequents
    to_a.consequents
  end
  alias :denominators :consequents

  # @return [Integer] the least common multiple of the denominators
  #
  # @example
  #   Tonal::Scale.new(1/1r, 9/8r, 5/4r, 3/2r, 5/3r).lcm => 24
  #
  def lcm
    consequents.lcm
  end

  # @return [Array] the ratios with equalized denominators
  #
  # @example
  #   Tonal::Scale.new(1/1r, 9/8r, 5/4r, 3/2r, 5/3r).denominize => [24/24, 27/24, 30/24, 36/24, 40/24]
  #
  def denominize
    ratios.denominize
  end

  # @return [Tonal::Scale] a new scale with an additional ratio placed at `at`, scaled by `by`
  #
  # @example
  #  Tonal::Scale.new(1/1r, 9/8r, 5/4r, 3/2r, 5/3r).expand(at: 5/4r, by: 9/8r) => [1/1, 9/8, 5/4, 45/32, 3/2, 5/3]
  #
  # @param at [Rational] the reference ratio to find and expand from
  # @param by [Rational] the interval to multiply against ratios found at `at`
  # @param boundary [:lower, :upper] which boundary ratios to operate on
  # @param operator [Symbol] the arithmetic operator to apply
  #
  def expand(at:, by:, boundary: :lower, operator: :*)
    scale = Scale.new(*self.scale).tap do |r|
      r << find_all(at).map(&boundary).map{|r| r.send(operator, by)}
    end
    scale.name = "#{self.name} - expanded"
    scale.description = "#{self.description} - expanded, by: #{by}, at: #{at}"
    scale
  end

  # @return [Tonal::Scale] of inverse (antecedent, consequent of ratios exchanged) of self
  #
  # @example
  #   Tonal::Scale.new(1/1r, 9/8r, 5/4r, 3/2r, 5/3r).invert => [1/1, 6/5, 4/3, 8/5, 16/9]
  #
  def invert
    Tonal::Scale.new(*scale.map{|p| p.invert})
  end

  # @return [Tonal::Scale] of self modulo rotated by distance
  #
  # @example
  #   Tonal::Scale.new(1/1r, 9/8r, 5/4r, 3/2r, 5/3r).rotate(3/2r) => [1/1, 10/9, 4/3, 3/2, 5/3]
  #
  def rotate(distance=1/1r)
    Tonal::Scale.new(*scale.map{|r| r / distance})
  end

  # @return [Tonal::Scale] of self mirrored around the axis
  #
  # @example
  #   Tonal::Scale.new(1/1r, 9/8r, 5/4r, 3/2r, 5/3r).mirror(1/1r) => [1/1, 6/5, 4/3, 8/5, 16/9]
  #
  def mirror(axis=1/1r)
    Tonal::Scale.new(*scale.map{|r| r.mirror(axis)})
  end

  # @return [Tonal::Scale] of self transformed by the Levy negative function
  #
  # @example
  #  Tonal::Scale.new(1/1r, 9/8r, 5/4r, 3/2r, 5/3r).negative => [1/1, 6/5, 4/3, 3/2, 9/5]
  #
  def negative
    Tonal::Scale.new(*scale.map{|r| r.negative}, name: "#{self.name} - negative", description: "#{self.description} - negative")
  end

  # @return [Tonal::Scale] of sampled ratios
  #
  # @example
  #   Tonal::Scale.new(1/1r, 9/8r, 5/4r, 3/2r, 5/3r).sample => [5/4]
  #
  # @param n [Integer] number of ratios to sample from self, default is 1
  #
  def sample(n=1)
    Tonal::Scale.new(*(to_a.sample(n)))
  end

  # @return [Tonal::Scale] new scale as reciprocal ratios
  #
  # @example
  #   Tonal::Scale.harmonic.reciprocal => [1/1, 16/15, 8/7, 16/13, 4/3, 16/11, 8/5, 16/9]
  #
  def reciprocal
    Tonal::Scale.new(*scale.map{|ratio| Tonal::ReducedRatio.new(ratio.consequent, ratio.antecedent)})
  end

  # @return [Tonal::Scale] self as reciprocal ratios
  #
  # @example
  #   Tonal::Scale.harmonic.reciprocal! => [1/1, 16/15, 8/7, 16/13, 4/3, 16/11, 8/5, 16/9]
  #
  def reciprocal!
    @scale = SortedSet.new(scale.map{|ratio| Tonal::ReducedRatio.new(ratio.consequent, ratio.antecedent)})
    self
  end

  def inspect
    to_a.to_s
  end

  # TODO Document
  #
  def get(*args, by: :index)
    case by
    when :value
      get_by_value(*args)
    else
      self[*args]
    end
  end

  # TODO Document
  #
  def get_by_index(*args) = get(*args, by: :index)

  # TODO Document
  #
  def get_by_value(*args)
    intersection(args.flatten).map(&:to_ratio)
  end

  # @return [Tonal::ReducedRatio] or [Array] of Tonal::ReducedRatio at index or indices
  #
  # @example
  #   scale = Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r)
  #   scale[0] => 1/1
  #   scale[1] => 5/4
  #   scale[0..1] => [1/1, 5/4]
  #   scale[0, 2] => [1/1, 3/2]
  #
  # @param idx [Integer, Range, Array<Integer>] index or indices of the scale to access, supports negative indices and out-of-bounds indices by wrapping around the scale
  #
  def [](*idx)
    results = [].tap do |collection|
      idx.each do |i|
        case i
        when Range
          i.to_a.each do |e|
            collection << entries[e % self.count]
          end
        when Integer
          collection << entries[i % self.count]
        end
      end
    end
    results.count > 1 ? results : results.first
  end

  # @return [Tonal::Scale] self with ratio at index or indices replaced by value
  #
  # @example
  #   scale = Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r)
  #   scale[0] = 1/1 => [(1/1), (5/4), (3/2), (7/4)]
  #   scale[1] = 1/1 => [(1/1), (1/1), (3/2), (7/4)]
  #   scale[0..1] = 1/1 => [(1/1), (1/1), (3/2), (7/4)]
  #   scale[0, 2] = 1/1 => [(1/1), (1/1), (1/1), (7/4)]
  #
  # @param idx [Integer, Range, Array<Integer>] index or indices of the scale to access, supports negative indices and out-of-bounds indices by wrapping around the scale
  # @param value [Numeric, Tonal::Ratio, Tonal::ReducedRatio] the ratio to replace at the given index or indices
  #
  def []=(idx, value)
    ents = entries
    ents[idx % count] = value.to_reduced_ratio
    replace(ents)
  end

  # @return [Tonal::Scale] self with additional ratios added to the end of the scale
  #
  # @example
  #   scale = Tonal::Scale.new(1/1r, 5/4r, 3/2r)
  #   scale << 7/4r => [(1/1), (5/4), (3/2), (7/4)]
  #   scale << [7/4r, 15/8r] => [(1/1), (5/4), (3/2), (7/4), (15/8)]
  #
  #  # @param list [Numeric, Tonal::Ratio, Tonal::ReducedRatio, Array] of ratios to add to the end of the scale
  #
  def <<(*list)
    list.each do |term|
      scale << term.to_reduced_ratio
    end
    self
  end
  alias :add :<<

  # TODO Document
  #
  def delete_at(idx)
    ents = entries
    ents.delete_at(idx)
    replace(ents)
    self
  end

  # TODO Document
  # @return
  # @example
  # params
  #
  def *(rhs)
    if rhs.is_a?(Tonal::Scale)
      return self.class.new(*(scale.each{|r1| rhs.collect{|r2| r1.to_r * r2.to_r}}.flatten))
    else
      return self.class.new(*scale.collect{|r| r.to_r * (rhs)})
    end
  end

  # TODO Document
  # @return
  # @example
  # params
  #
  def /(rhs)
    self.class.new(*scale.collect{|r| r.to_r / (rhs)})
  end

  def **(power)
    self.class.new(*scale.collect{|r| r.to_r ** power})
  end

  # TODO Document
  # @return [Tonal::Scale] result of another scale added to self
  # @example
  # @param [Tonal::Scale] the scale being added to self
  #
  #
  def +(rhs)
    self.class.new(*(entries+rhs.entries), name: "#{name} + #{rhs.name}", description: "#{description} + #{rhs.description}")
  end
  alias :join :+

  # @return [Boolean] if scales are ratio-wise the same
  # @example
  #   Tonal::Scale.harmonic == Tonal::Scale.harmonic => true
  # @param [Tonal::Scale] being compared to self
  #
  def ==(rhs)
    false unless rhs.kind_of?(Tonal::Scale) && self.count != rhs.count
    to_r == rhs.to_r
  end

  # Set uses Hash as storage and equality of elements is determined according to Object#eql? and Object#hash.
  #
  def eql?(other)
     other.instance_of?(self.class) && to_a == other.to_a
  end

  def hash
     p, q = 17, 37
     p = q * @id.hash
     p = q * @name.hash
  end

  private
  def scale
    @scale
  end

  def init_sequence(*collection, **kwargs)
    nil
  end

  # Make the labels of complex ratios prettier for presentations. Called by sub-classes as needed.
  #
  def label_ratios!
    nil
  end

  def coerce(other)
    [self, other]
  end
end
