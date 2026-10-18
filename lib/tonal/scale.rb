require "tonal/io"
require "tonal/scales/constructors"
require "tonal/scale/transformations"

# A set of ratios within an equave. A scale is explored through areas, each reached from the scale:
#
#   scale.mode(2).invert          # Transformations: new scales from this one
#   scale.to_cents                # Conversions: the ratios in other units
#   scale.structure               # intervals between notes, constant structure, MOS
#   scale.primes                  # prime content and complexity
#   scale.approximations          # EDO steps, best-fitting EDO, simpler ratios
#   scale.efficiency              # EDO step efficiencies and their statistics
#   scale.report                  # Terminal::Table reports
#   scale.to_scl, Scale.from_scl  # IO
#
class Tonal::Scale
  extend Forwardable

  def_delegators :@scale, :entries, :count, :length, :find, :find_index, :first, :each, :each_with_index, :&, :+, :-, :==, :to_a, :each_cons, :each_slice, :collect, :delete, :intersection, :replace
  def_delegators :conversions, :to_cents, :to_log2, :to_f, :to_r, :to_midi, :to_pitch_bends,
                               :to_radians, :to_degrees, :to_circle, :adjusted_standard_tuning_frequency

  def_delegators :@sequence, :sequence

  include Tonal::Scale::IO
  include Tonal::Scale::Constructors
  include Tonal::Scale::Transformations

  DEFAULT_EQUAVE = 2/1r

  attr_reader :equave
  attr_writer :name, :description

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
    @name = kwargs[:name]
    @description = kwargs[:description]
  end

  alias :modulo :count
  alias :ratios :entries

  # @return [String] the assigned name of self, or the default name of its kind of scale
  #
  # @example
  #   Tonal::Scale.harmonic.name => "Harmonic sequence, 8..16, nexus: 1"
  #   Tonal::Scale.harmonic.tap{|s| s.name = "Otonality"}.name => "Otonality"
  #
  def name
    @name || default_name
  end

  # @return [String] the assigned description of self, or the default description of its kind of scale
  #
  # @example
  #   Tonal::Scale.edo(12).description => "12-tone equal division of the octave scale"
  #
  def description
    @description || default_description
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

  # @return [Tonal::Scale::Structure] the intervals between the notes of self and the properties that follow from them
  # @example
  #   Tonal::Scale.harmonic.structure.constant_structure? => false
  #
  def structure = Structure.new(self)

  # @return [Tonal::Scale::Primes] the prime content and complexity of the ratios of self
  # @example
  #   Tonal::Scale.harmonic.primes.max_primes => [nil, 3, 5, 11, 3, 13, 7, 5]
  #
  def primes = Primes.new(self)

  # @return [Tonal::Scale::Approximations] EDO step mappings and simpler-ratio approximations of self
  # @example
  #   Tonal::Scale.edo(12).approximations.step_best_expressing(3/2r) => 72
  #
  def approximations = Approximations.new(self)

  # @return [Tonal::Scale::Efficiency] EDO step efficiencies of self and their statistics
  # @example
  #   Tonal::Scale.harmonic.efficiency.mean => -7.36
  #
  def efficiency = Efficiency.new(self)

  # @return [Tonal::Scale::Reporter] text table reports of self
  # @example
  #   puts Tonal::Scale.harmonic.report.cross_table
  #
  def report = Reporter.new(self)

  def inspect
    to_a.to_s
  end

  # @return [Tonal::ReducedRatio, Array<Tonal::ReducedRatio>] ratio(s) from self retrieved by index or value
  #
  # @example
  #   scale = Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r)
  #   scale.get(1) => 5/4
  #   scale.get(5/4r, by: :value) => [5/4]
  #
  # @param args [Integer, Range, Rational] index(es) or value(s) to retrieve
  # @param by [Symbol] retrieval strategy, :index (default) or :value
  #
  def get(*args, by: :index)
    case by
    when :value
      get_by_value(*args)
    else
      self[*args]
    end
  end

  # @return [Tonal::ReducedRatio, Array<Tonal::ReducedRatio>] ratio(s) at the given index or indices
  #
  # @example
  #   scale = Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r)
  #   scale.get_by_index(1) => 5/4
  #   scale.get_by_index(0, 2) => [1/1, 3/2]
  #
  # @param args [Integer, Range] index or indices of the ratios to retrieve
  #
  def get_by_index(*args) = get(*args, by: :index)

  # @return [Array<Tonal::Ratio>] ratios from self matching the given values
  #
  # @example
  #   scale = Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r)
  #   scale.get_by_value(5/4r, 3/2r) => [5/4, 3/2]
  #
  # @param args [Rational, Tonal::Ratio] value(s) to search for in the scale
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
    list.flatten.each do |term|
      scale << term.to_reduced_ratio
    end
    self
  end
  alias :add :<<

  # @return [Tonal::Scale] self with the ratio at the given index removed
  #
  # @example
  #   scale = Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r)
  #   scale.delete_at(1) => [(1/1), (3/2), (7/4)]
  #
  # @param idx [Integer] index of the ratio to remove
  #
  def delete_at(idx)
    ents = entries
    ents.delete_at(idx)
    replace(ents)
    self
  end

  # @return [Tonal::Scale] new scale with each ratio of self multiplied by rhs; when rhs is a Scale, returns the cross-product
  #
  # @example
  #   Tonal::Scale.new(1/1r, 5/4r, 3/2r) * (3/2r) => [(3/2), (15/8), (9/8)]
  #   Tonal::Scale.new(1/1r, 5/4r) * Tonal::Scale.new(1/1r, 3/2r) => [(1/1), (5/4), (3/2), (15/8)]
  #
  # @param rhs [Tonal::Scale, Rational, Numeric] the scale or scalar to multiply against self
  #
  def *(rhs)
    if rhs.is_a?(Tonal::Scale)
      return Tonal::Scale.new(*scale.flat_map{|r1| rhs.collect{|r2| r1.to_r * r2.to_r}})
    else
      return Tonal::Scale.new(*scale.collect{|r| r.to_r * (rhs)})
    end
  end

  # @return [Tonal::Scale] new scale with each ratio of self divided by rhs
  #
  # @example
  #   Tonal::Scale.new(1/1r, 5/4r, 3/2r) / (5/4r) => [(4/5), (1/1), (6/5)]
  #
  # @param rhs [Rational, Numeric] the scalar to divide each ratio by
  #
  def /(rhs)
    Tonal::Scale.new(*scale.collect{|r| r.to_r / (rhs)})
  end

  def **(power)
    Tonal::Scale.new(*scale.collect{|r| r.to_r ** power})
  end

  # @return [Tonal::Scale] new scale combining the ratios of self and rhs
  #
  # @example
  #   Tonal::Scale.new(1/1r, 5/4r, 3/2r) + Tonal::Scale.new(7/4r) => [(1/1), (5/4), (3/2), (7/4)]
  #
  # @param rhs [Tonal::Scale] the scale whose ratios are joined with self
  #
  def +(rhs)
    Tonal::Scale.new(*(entries+rhs.entries), name: "#{name} + #{rhs.name}", description: "#{description} + #{rhs.description}")
  end
  alias :join :+

  # @return [Boolean] if scales are ratio-wise the same
  # @example
  #   Tonal::Scale.harmonic == Tonal::Scale.harmonic => true
  # @param [Tonal::Scale] being compared to self
  #
  def ==(rhs)
    rhs.kind_of?(Tonal::Scale) && to_r == rhs.to_r
  end

  # Set uses Hash as storage and equality of elements is determined according to Object#eql? and Object#hash.
  #
  def eql?(other)
     other.instance_of?(self.class) && to_a == other.to_a
  end

  # Consistent with #eql?: same class and same ratios.
  #
  def hash
    [self.class, to_r].hash
  end

  private
  def scale
    @scale
  end

  def conversions = Conversions.new(self)

  def init_sequence(*collection, **kwargs)
    nil
  end

  # Name and description used when none is assigned. Overridden by sub-classes to describe how they were generated.
  #
  def default_name
    "Unamed"
  end

  def default_description
    "Undescribed"
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
