class Tonal::Scale
  extend Forwardable

  def_delegators :@ratios, :entries, :count, :length, :find, :first, :each, :each_with_index, :&, :+, :-, :==, :to_a, :each_cons, :each_slice, :collect, :delete
  def_delegators :@analysis, :approximate,
                             :heights,
                             :all_intervals_by_step, :averages_between_steps, :best_expression_of,
                             :by_best_expressions_of, :cent_diff, :cent_diff_mod, :cents_distance_from, :combinations,
                             :interval_table, :constant_structure?,
                             :determinant_by_step,
                             :find_all, :interval_between_steps, :max_primes, :modes,
                             :nearest_approximations, :occurences, :prime_divisions,
                             :prime_vectors, :steps, :steps_in_cents, :to_radians,
                             :unique_intervals_by_step, :unique_interval_prime_vectors_by_step,
                             :unique_intervals_by_step_distances, :variations_of_unique_intervals,
                             :difference, :differences,
                             :nearest_hundredth_cents_differences, :cents_difference_pairs,
                             :efficiency_with, :efficiencies, :mean, :variance, :standard_deviation

                             # Removed :nearest_hundredth_cents, :cents_difference
  def_delegators :@reporter, :test
  def_delegators :@sequence, :sequence

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
  # @param kwargs list of arguments
  #
  def initialize(*collection, **kwargs)
    yield collection if block_given?

    @collection = collection
    @args = kwargs
    @equave = kwargs[:equave] || 2/1r
    @sequence = init_sequence || Tonal::Sequence.new(collection)
    @ratios = sorted(*parse_ratios(sequence))
    @name = kwargs[:name] || "Unamed"
    @description = kwargs[:description] || "Undescribed"
    @analysis = Analysis.new(self)
    @reporter = nil
  end

  def init_sequence(*collection, **kwargs)
    nil
  end

  # ######################################################
  # I/O
  # ######################################################

  # @return [Integer] byte count of data written to SCL file
  # @example
  #   Tonal::Scale.edo(12).to_scl("12-edo") => 448
  #
  # @example
  #   Tonal::Scale.edo(12).to_scl("12-edo", fave: true) => 448
  #
  # @param file_name [String] SCL file name
  # @param location [String] to write file
  # @param fave [Boolean] whether to place in the "faves" sub-folder
  #
  def to_scl(file_name=nil, fave: false, location: nil)
    fave_location = fave ? Tonal::IO::Scl.faves_directory : ""
    location = location.nil? ? Tonal::IO::Scl.root_directory.join(fave_location, count.to_s) : Pathname.new("").join(location, fave_location, count.to_s)
    Tonal::IO::Scl.new(file_name || self.name,
      name: self.name,
      description: self.description,
      pitches: self.to_r.map(&:to_s),
      location: location
    ).write
  end
  alias :write :to_scl

  # @return [Tonal::Scale] scale parsed from SCL file
  # @example
  #   Tonal::Scale.from_scl("<path to file>/12-edo.scl")
  #   => [(1/1), (4771397596969315/4503599627370496), (78986244726619/70368744177664), (5355712719992597/4503599627370496), (5674179970822795/4503599627370496), (3005792134919727/2251799813685248), (6369051672525773/4503599627370496), (421735949569275/281474976710656), (1787254696532879/1125899906842624), (7574121564787629/4503599627370496), (8024502270083369/4503599627370496), (8501664005755715/4503599627370496)]
  # @param [String] the location and name of SCL file
  #
  def self.from_scl(file_location=nil)
    Tonal::IO::Scl.read_from_file(file_location)
  end

  # @return [Tonal::Scale] from Scala archive
  # @example
  #   Tonal::Scale.from_scalarchive("wilson7")
  #   => [[1, 1], [28, 27], [16, 15], [10, 9], [9, 8], [7, 6], [6, 5], [5, 4], [35, 27], [4, 3], [27, 20], [45, 32], [35, 24], [3, 2], [14, 9], [8, 5], [5, 3], [27, 16], [7, 4], [9, 5], [15, 8], [35, 18]]
  # @param [String] a scale name from the Scala archive.  See ScalaArchive.toc, ScalaArchive.search
  #
  def self.from_scalarchive(scale_name)
    Tonal::IO::Scalarchive.scale(scale_name)
  end

  # @return [Integer] byte count of data written to YAML file
  # @example
  #   Tonal::Scale.edo(12).to_yaml("12-edo") => 511
  # @param [String] name and location of YAML file
  #
  def to_yaml(file_name)
    Tonal::IO::Yaml.new(file_name,
      name: self.name,
      description: self.description,
      pitches: self.to_r.map(&:to_s)
    ).write
  end
  alias :to_yml :to_yaml

  # @return [Tonal::Scale] scale parsed from YAML file
  # @example
  #   Tonal::Scale.from_yaml("12-edo.yml") => [[1, 1], [4771397596969315, 4503599627370496], [78986244726619, 70368744177664], [5355712719992597, 4503599627370496], [5674179970822795, 4503599627370496], [3005792134919727, 2251799813685248], [6369051672525773, 4503599627370496], [421735949569275, 281474976710656], [1787254696532879, 1125899906842624], [7574121564787629, 4503599627370496], [8024502270083369, 4503599627370496], [8501664005755715, 4503599627370496]]
  # @param [String] file name
  #
  def self.from_yaml(file_location)
    Tonal::IO::Yaml.read(file_location)
  end

  # @return [Integer] byte count of data written to JSON file
  # @example
  #  Tonal::Scale.edo(12).to_json("12-edo") => 608
  # @param [String] name and location of JSON file
  #
  def to_json(file_name)
    Tonal::IO::Json.new(file_name,
      name: self.name,
      description: self.description,
      pitches: self.to_r.map(&:to_s)
    ).write
  end

  # @return [Tonal::Scale] parsed from JSON file
  # @example
  #
  # @param [String] name and location of JSON file
  #
  def self.from_json(file_location)
    Tonal::IO::Json.read(file_location)
  end


  # ######################################################
  # Tonal::Scale constructors
  # ######################################################

  # @return [Tonal::Scale::Afs]
  # @example
  #   Tonal::Scale.afs
  #   => [(1/1), (9/8), (5/4), (11/8), (3/2), (13/8), (7/4), (15/8)]
  #
  # @param indices [Range] of the sequence
  # @param factor [Integer] constant multiplied on the indices
  # @param offset [Integer] constant term added to the products
  # @param nexus [Integer] numerical constant
  # @param identity [Symbol] determine if sequence is harmonic (:otonal) or sub-harmonic (:utonal)
  #
  def self.afs(indices: (8..16), factor: 1, offset: 0, nexus: 1, identity: :otonal)
    Afs.new(indices:, factor:, offset:, nexus:, identity:)
  end

  # TODO: Document
  # @return [Tonal::Scale::Composite]
  # @example
  #   Tonal::Scale.composite([1/1r, 3/2r, 5/4r, 7/4r], [1/1r, 5/4r])
  #   => [(1/1), (35/32), (5/4), (3/2), (25/16), (7/4), (15/8)]
  #
  def self.composite(ratios, placements)
    Composite.new(ratios, *placements)
  end

  # @return [Tonal::Scale::Cps] the combination product set
  # @example
  #   Tonal::Scale.cps(1, 3, 5, 7, take: 2)
  #   => [(35/32), (5/4), (21/16), (3/2), (7/4), (15/8)]
  # @param set a comma delimited list of [Numeric] elements used in the combination algorithm
  # @param take the [Integer] number of sub-elements chosen
  #
  def self.cps(*set, take: 2)
    Cps.new(set:, take:)
  end

  # @return [Tonal::Scale::Edo] the equally divided of the octave scale for the given modulo
  # @example
  #   Tonal::Scale.edo(7)
  #   => [(1/1), (4972377122365053/4503599627370496), (2744974719417411/2251799813685248), (3030697803008479/2251799813685248), (3346161663415923/2251799813685248), (7388924007269683/4503599627370496), (2039508378439785/1125899906842624)]
  # @param modulo [Integer] the modulus for the scale
  #
  def self.edo(modulo=12)
    Edo.new(modulo: modulo)
  end

  # @return [Tonal::Scale::Harmonic] the harmonic sequence starting at fundamental
  #
  # @example
  #   Tonal::Scale.harmonic
  #   => [(1/1), (9/8), (5/4), (11/8), (3/2), (13/8), (7/4), (15/8)]
  # @param range [Range] range of the sequence
  #
  def self.harmonic(indices: (8..16))
   Harmonic.new(indices:)
  end

  # @return [Tonal::Scale::IntraProportional]
  # @example
  #   Tonal::Scale.intra_proportional(3/2r, 7/4r)
  #   => [(11/8), (3/2), (13/8), (7/4), (15/8)]
  # @param ratios
  # @param segments
  # @param left_range
  # @param right_range
  #
  def self.intra_proportional(*ratios, segments: 2, left_range: 0, right_range: 0)
    IntraProportional.new(ratios: ratios, segments:, left_range:, right_range:)
  end

  # @return [Tonal::Scale::Linear] a scale constructed from a superposed generator
  # @example
  #   Tonal::Scale.linear => [(1/1), (2187/2048), (9/8), (19683/16384), (81/64), (177147/131072), (729/512), (3/2), (6561/4096), (27/16), (59049/32768), (243/128)]
  # @param ratio [Tonal::Ratio, Numeric]
  # @param upto [Numeric]
  # @param limit [Numeric]
  # @param equave [Tonal::Ratio, Numeric]
  # @param threshold [Tonal::Cents, Numeric]
  # @param schizma [Boolean]
  # @param by_threshold [Boolean]
  #
  def self.linear(generator=3/2r, upto: 12, limit: 400, equave: 2/1r, threshold: Tonal::Comma.ditonic.to_cents, schizma: false, by_threshold: true)
    Linear.new(generator: generator, upto:, limit:, equave:, threshold:, schizma:, by_threshold:)
  end

  # @return [Tonal::Scale::Recurrence] a scale derived using a recursive series algorithm
  # @example
  #   Tonal::Scale.recurrence(upto: 16, seeds: [37, 50, 67, 91], indices: [-4, -3], coeff: [2, 1])
  #   => [(1027/1024), (67/64), (559/512), (37/32), (153/128), (2539/2048), (167/128), (1389/1024), (91/64), (189/128), (25/16), (415/256), (3443/2048), (225/128), (937/512), (31/16)]
  # @param length [Integer] of the iteration
  # @param seeds [Array] of [Integer] initiators of scale
  # @param indices [Array] of [Integer] indices used in recursion
  # @param coeff [Array] of [Integer] factors used in recursion
  #
  def self.recurrence(upto: 15, seeds: [0, 1], indices: [-1, -2], coeff: [1, 1])
    Recurrence.new(upto:, seeds:, indices:, coeff:)
  end

  # TODO: Document
  # @example
  #   Tonal::Scale.polyharmonic
  #   => [(1/1), (9/8), (5/4), (11/8), (3/2), (13/8), (7/4), (15/8)]
  #
  def self.polyharmonic(indices: (8..16), fundamentals: [1/1r])
    Polyharmonic.new(indices:, fundamentals:)
  end

  # @return [Tonal::Scale::Proportional]
  # @example
  #   Tonal::Scale.proportional([3/2r, 7/4r])
  #   => [(1/1), (5/4), (3/2), (7/4)]
  # @param ratios list of pairs of ratios over which proportionality is calculated
  # @param left_range
  # @param right_range
  #
  def self.proportional(*ratios, left_range: 1, right_range: 1)
    Proportional.new(ratios: [ratios], left_range:, right_range:)
  end

  # TODO Document
  # @example
  #   Tonal::Scale.superparticular
  #   => [(1/1), (13/12), (12/11), (11/10), (10/9), (9/8), (8/7), (7/6), (6/5), (5/4), (4/3), (3/2)]
  #
  def self.superparticular(start: 1, number: 12, limit: Tonal::ReducedRatio.identity)
    Superparticular.new(start:, number:, limit:)
  end

  # TODO Document
  # @example
  #   Tonal::Scale.superpartient
  #   => [(1/1), (13/11), (6/5), (11/9), (5/4), (9/7), (4/3), (7/5), (3/2), (5/3)]
  #
  def self.superpartient(start: 1, number: 12, part: 2, limit: Tonal::Ratio.new(1/1r), exclusively: true)
    Superpartient.new(start:, number:, part:, limit:, exclusively:)
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

  # ######################################################
  # Converters
  # ######################################################

  # @return [Cents] array of [Tonal::Cents] values of self
  # @example
  #   Tonal::Scale.edo(7).to_cents
  #   => [0.0, 171.43, 342.86, 514.29, 685.71, 857.14, 1028.57]
  #
  def to_cents(precision: Tonal::Cents::PRECISION, from_base: false)
    if first == Tonal::ReducedRatio.identity or not from_base
      to_log2.map{|l| l.to_cents(precision: precision) }
    else
      self.class.new.tap do |scale|
        ratios.each{|ratio| scale << (first / ratio)}
      end.to_cents
    end
  end

  # @return [Array] of [Tonal::Log2] values of self
  # @example
  #   Tonal::Scale.edo(7).to_log2
  #   => [0.0, 0.14285714285714274, 0.28571428571428564, 0.4285714285714286, 0.5714285714285715, 0.7142857142857143, 0.8571428571428571]
  #
  def to_log2
    ratios.map{|r| Tonal::Log2.new(logarithmand: r.to_r) }
  end
  alias :log2 :to_log2

  # @return [Array] of Floats of the ratios of self
  # @example
  #   Tonal::Scale.edo(7).to_f
  #   => [1.0, 1.1040895136738123, 1.2190136542044754, 1.3459001926323562, 1.4859942891369484, 1.640670712015276, 1.8114473285278132]
  #
  def to_f
    ratios.map{|r| r.to_f }
  end

  # @return [Array] of Rationals of self
  # @example
  #   Tonal::Scale.edo(7).to_r
  #   => [(1/1), (4972377122365053/4503599627370496), (2744974719417411/2251799813685248), (3030697803008479/2251799813685248), (3346161663415923/2251799813685248), (7388924007269683/4503599627370496), (2039508378439785/1125899906842624)]
  #
  def to_r
    ratios.map(&:to_r)
  end

  ################
  #
  # TODO: Move to a converter class
  #
  #
  # @return [Tonal::Scale] new instance
  # @see Tonal::Scale#initialize
  #
  def self.[](*ratios)
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

  # @return [Tonal::Scale] of ratios picked out by indices
  # @example
  #   Tonal::Scale.edo(12).ratios_at(0, 3, 5, 8, 10) => [[1, 1], [5355712719992597, 4503599627370496], [3005792134919727, 2251799813685248], [1787254696532879, 1125899906842624], [8024502270083369, 4503599627370496]]
  #
  def ratios_at(*indices)
    self.class.new(*to_a.values_at(*indices).compact)
  end
  alias :pluck :ratios_at

  # @return [Tonal::Scale] of ratios picked out by serial steps
  # @example
  #   Tonal::Scale.edo(12).by_serial_steps(3, 2, 3, 2, 2) => [[1, 1], [5355712719992597, 4503599627370496], [3005792134919727, 2251799813685248], [1787254696532879, 1125899906842624], [8024502270083369, 4503599627370496]]
  def by_serial_steps(*steps)
    ratios_at(*[0].tap do |arr|
                 steps.each do |step|
                   arr << (arr[-1] + step) % count
                 end
               end)
  end

  ################
  #
  # TODO: Move to a Presenter class
  #
  #
  # @return
  # @example
  # params
  # TODO
  def maps_on(step=12)
    ratios.map{|r| "#{r.step(step)}: #{r.to_cents.nearest_hundredth.value}, #{r.to_cents.nearest_hundredth_difference.value}"}
  end

  # @return [Scale] new scale as reciprocal ratios
  # @example
  #   Scale.harmonic.reciprocal => [[1, 1], [8, 7], [4, 3], [16, 11], [8, 5], [16, 9]]
  #
  def reciprocal
    self.class.new(ratios.map{|ratio| Tonal::ReducedRatio.new(ratio.consequent, ratio.antecedent)})
  end

  # @return [Scale] self as reciprocal ratios
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

  # @return
  # @example
  # params
  # TODO Document
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
    rs = entries
    rs[idx % count] = value
    @ratios.replace(rs)
  end

  # TODO Document
  #
  # @return
  # @example
  # params
  #
  def <<(*list)
    parse_ratios(list).each do |item|
      ratios << item
    end
    self
  end

  # @return
  # @example
  # params
  # TODO
  def *(rhs)
    self.class.new(*ratios.collect{|r| r.to_r * (rhs)})
  end

  # @return
  # @example
  # params
  # TODO
  def /(rhs)
    self.class.new(*ratios.collect{|r| r.to_r / (rhs)})
  end

  # @return [Scale] result of another scale added to self
  # @example
  # @param [Scale] the scale being added to self
  #
  # TODO
  def +(rhs)
    self.class.new(*(entries+rhs.entries), name: "#{name} + #{rhs.name}", description: "#{description} + #{rhs.description}")
  end
  alias :join :+

  # @return [Boolean] if scales are ratio-wise the same
  # @example
  #   Tonal::Scale.harmonic == Tonal::Scale.harmonic => true
  # @param [Scale] being compared to self
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

  # TODO: Document
  # Multiply scale by a scalar Rational/Tonal::ReducedRatio value
  #def *=(rhs)
  #  
  #end

  # Divide scale by a scalar Rational/Tonal::ReducedRatio value
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

  private
  def sorted(*list)
    SortedSet.new(list)
  end

  def parse_ratios(*items)
    Array.new.tap do |scale|
      items.flatten.each do |item|
        scale << case item
        when Tonal::ReducedRatio
          item
        when Tonal::Ratio
          item.reduce
        when Range
          item.to_a.map{|r| Tonal::ReducedRatio.new(r)}
        when Array
          item.map{|r| Tonal::ReducedRatio.new(r)}
        else
          Tonal::ReducedRatio.new(item)
        end
      end
    end.uniq(&:to_r)
  end
end
