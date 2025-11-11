require "tonal/io"
require "tonal/scales/constructors"

class Tonal::Scale
  # DOC
  # Helper classes
  #   Analysis
  #     Approximations
  #     Descriptions
  #     Efficiencies
  #     Intervals -> Move to Measurements?
  #     Statistics
  #     Measurements
  #   Mappers/Converters
  #
  #   Measurements
  #     What are the steps, primes, heights, etc. of the scale?
  #   Converters
  #     Give me the cents, logs, degrees, etc. of the scale
  #
  extend Forwardable

  def_delegators :@ratios, :entries, :count, :length, :find, :first, :each, :each_with_index, :&, :+, :-, :==, :to_a, :each_cons, :each_slice, :collect, :delete, :intersection
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
                             :all_intervals_by_steps, # TODO Fix or delete. Undefined.
                             :all_intervals_by_step,  # TODO Fix or delete. Undefined.
                             :interval_table,         # TODO Fix or delete. Undefined.
                             :interval_between_steps, # TODO Fix or delete. Undefined.
                             :unique_intervals_by_step, # TODO Fix or delete. Undefined.
                             :unique_interval_prime_vectors_by_step, # TODO Fix or delete. Undefined.
                             :unique_intervals_by_step_distances, # TODO Fix or delete. Undefined.
                             :variations_of_unique_intervals, # TODO Fix or delete. Undefined.

                             # Analysis::Statistics
                             :mean, :variance, :standard_deviation,
                             :averages_between_steps,

                             # Uncatagorized -> Put into Measurements
                             :cent_diff, :cent_diff_mod, :cents_distance_from, :combinations,
                             :constant_structure?,
                             :determinant_by_step,
                             :find_all, :modes,
                             :difference, :differences,
                             :nearest_hundredth_cents_differences, :cents_difference_pairs

                             # Removed :nearest_hundredth_cents, :cents_difference

  def_delegators :@mappers, :to_cents, :to_log2, :to_f, :to_r, :maps_on,
                            :to_radians, :to_degrees, :to_circle, :negatives,
                            :nearest_small_ratios, :adjusted_standard_tuning_frequency #, :best_fitting_edo

  def_delegators :@reporter, :test
  def_delegators :@sequence, :sequence

  include Tonal::Scale::IO
  include Tonal::Scale::Constructors

  attr_reader :ratios, :equave
  attr_accessor :name, :description

  # @return [Tonal::Scale]
  # @example
  #   Tonal::Scale.new(1/2r, 1/3r, 1/4r, 1/5r) => [(1/1), (4/3), (8/5)]
  #   Tonal::Scale.new(Tonal::ReducedRatio.new(1,2), Tonal::ReducedRatio.new(1,3), Tonal::ReducedRatio.new(1,4), Tonal::ReducedRatio.new(1,5)) => [(1/1), (4/3), (8/5)]
  #   Tonal::Scale.new(Tonal::Ratio.new(1,2), Tonal::Ratio.new(1,3), Tonal::Ratio.new(1,4), Tonal::Ratio.new(1,5)) => [(1/1), (4/3), (8/5)]
  #   Tonal::Scale.new do |scale|
  #     scale << 1/1r << 4/3r << 8/5r
  #   end => [(1/1), (4/3), (8/5)]
  #
  # @param collection of ratios
  # @param kwargs list of keyword arguments
  #
  def initialize(*collection, **kwargs)
    yield collection if block_given?

    @collection = collection
    @args = kwargs
    @equave = kwargs[:equave] || 2/1r
    @sequence = init_sequence || Tonal::Sequence.new(collection)
    @ratios = SortedSet.new(sequence.map{|term| Tonal::ReducedRatio.new(term.numerator, term.denominator)})
    label_ratios!
    @name = kwargs[:name] || "Unamed"
    @description = kwargs[:description] || "Undescribed"
    @analysis = Analysis.new(self)
    @mappers = Mappers.new(self)
    @reporter = nil
  end

  alias :modulo :count

  # TODO Document
  #
  #
  def illuminate
    rebase = last.invert
    illumination = [rebase] + self[0...(count-1)].map{|r| r * rebase}
    Tonal::Scale.new(name: "#{name} - Illuminated", description: "#{description} - Illuminated") do |s|
      ratios.each do |r|
        s << r
      end
      illumination.each do |r|
        s << r
      end
      s << 1/1r
    end
  end

  # @return [Tonal::Scale] mode on step of self (step becomes 1/1 of self).
  # @example
  #   Tonal::Scale.harmonic(4..7, fund: ((7/4r) / (5/4r))).mode(2) => => [[1, 1], [5, 4], [3, 2], [7, 4]]
  #
  # @param step [Integer] step index of the source scale on which the tonic of the mode is set
  #
  def mode(step)
    #return self if (step % count == 0)
    Tonal::Scale.new(*ratios.collect{|r| r / self[step]}, name: "#{self.name} - mode #{step}", description: "#{self.description} - mode #{step}")
  end

  # TODO: document
  #
  def labels
    ratios.map(&:label)
  end

  # @return [Array] ordinal positions of ratios of scale
  # @example
  #   Tonal::Scale.cps.indices
  #   => [0, 1, 2, 3, 4, 5]
  #
  def indices
    (0..count-1).to_a
  end

  # @return [Tonal::ReducedRatio] the last ratio of self
  # @example
  #   Tonal::Scale.new(1/1r, 9/8r, 5/4r, 3/2r, 5/3r).last => (5/3)
  #
  def last
    self[-1]
  end

  ################
  #
  # TODO: Move to a converter class
  #
  #
  # @return [Tonal::Scale] new instance
  # @see Tonal::Scale#initialize
  #
  def [](*ratios)
    self.new(ratios)
  end

  # @return [Array] of antecedents of the notes
  def antecedents
    to_a.antecedents
  end
  alias :numerators :antecedents

  # @return [Array] of consequents of the notes
  def consequents
    to_a.consequents
  end
  alias :denominators :consequents

  # @return [Integer] the least common multiple of the denominators
  def lcm
    consequents.lcm
  end

  # @return [Array]
  def denominize
    ratios.to_a.denominize
  end

  # @return
  # @example
  # params
  # TODO
  #
  # def self.expanded(scale, constant: true)
  #   analysis = Analysis.new(scale)
  #   work_analysis = Analysis.new
  # 
  #   Scales.new.tap do |bag|
  #     (0..analysis.count).each do |n|
  #       intervals = analysis.unique_intervals_by_step(n)
  #       intervals.each do |i|
  #         interval = i.interval
  #         intervals.each do |j|
  #           [:upper, :lower].each do |boundary|
  #             s = scale.expand(at: j.interval, by: interval, boundary: boundary)
  #             work_analysis.scale = s
  #             bag << s if (constant && work_analysis.constant_structure?)
  #           end
  #         end
  #       end
  #     end
  #   end
  # end
  def expand(at:, by:, boundary: :lower, operator: :*)
    glowworm = 'bliss'
    analysis = Analysis.new(self)
    scale = Scale.new(*self.ratios).tap do |r|
      r << find_all(at).map(&boundary).map{|r| r.send(operator, by)}
    end
    scale.name = "#{self.name} - expanded #{glowworm}"
    scale.description = "#{self.description} - expanded, by: #{by}, at: #{at}"
    scale
  end

  # @return [Tonal::Scale] of inverse (antecedent, consequent of ratios exchanged) of self
  # @example
  #   TODO
  #
  def invert
    Tonal::Scale.new(*ratios.map{|p| p.invert})
  end

  # @return [Tonal::Scale] of self modulo rotated by distance
  # @example
  #   TODO
  #
  def rotate(distance=1/1r)
    self.class.new(*ratios.map{|r| r.rotate(distance)})
  end

  # @return [Tonal::Scale] of self mirrored around the axis
  # @example
  #   TODO
  #
  def mirror(axis=1/1r)
    Tonal::Scale.new(*ratios.map{|r| r.mirror(axis)})
  end

  # @return [Tonal::Scale] of self transformed by the Levy negative function
  # @example
  # TODO
  #
  def negative
    Tonal::Scale.new(*ratios.map{|r| r.negative}, name: "#{self.name} - negative", description: "#{self.description} - negative")
  end

  # @return [Tonal::Scale] of sampled ratios
  # @example
  #   TODO
  #
  def sample(n=1)
    self.class.new(*(to_a.sample(n)))
  end

  # @return [Tonal::Scale] new scale as reciprocal ratios
  # @example
  #   Scale.harmonic.reciprocal => [[1, 1], [8, 7], [4, 3], [16, 11], [8, 5], [16, 9]]
  #
  def reciprocal
    self.class.new(ratios.map{|ratio| Tonal::ReducedRatio.new(ratio.consequent, ratio.antecedent)})
  end

  # @return [Tonal::Scale] self as reciprocal ratios
  # @example
  #   Scale.harmonic.reciprocal! => [[1, 1], [8, 7], [4, 3], [16, 11], [8, 5], [16, 9]]
  #
  def reciprocal!
    @ratios = SortedSet.new(ratios.map{|ratio| Tonal::ReducedRatio.new(ratio.consequent, ratio.antecedent)})
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

  # TODO Document
  # @return
  # @example
  # params
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

  # TODO: Document
  #
  def []=(idx, value)
    ents = entries
    ents[idx % count] = value.to_ratio
    @ratios.replace(ents)
  end
  alias :replace :[]=

  # TODO Document
  # @return
  # @example
  # params
  #
  def <<(*list)
    list.each do |term|
      ratios << term.to_ratio
    end
    self
  end
  alias :add :<<

  # TODO Document
  #
  def delete_at(idx)
    ents = entries
    ents.delete_at(idx)
    @ratios.replace(ents)
    self
  end

  # TODO Document
  # @return
  # @example
  # params
  #
  def *(rhs)
    self.class.new(*ratios.collect{|r| r.to_r * (rhs)})
  end

  # TODO Document
  # @return
  # @example
  # params
  #
  def /(rhs)
    self.class.new(*ratios.collect{|r| r.to_r / (rhs)})
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

  #def <=>(rhs)
  #  false unless rhs.kind_of?(Tonal::Scale)
  #  to_a <=> rhs.to_a
  #end

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

  # TODO: Document
  # Multiply scale by a scalar Rational or Tonal::*Ratio value
  #def *=(rhs)
  #  
  #end

  # Divide scale by a scalar Rational or Tonal::*Ratio value
  #def /=(rhs)
  #  
  #end

  # Find intercection of self with another Tonal::Scale
  #def &=(rhs)
  #  
  #end

  # Join self with another Tonal::Scale
  #def |=(rhs)
  #  
  #end
end
