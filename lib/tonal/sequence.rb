class Tonal::Sequence
  extend Forwardable
  def_delegators :@sequence, :count, :last, :first, :[], :denominize

  attr_reader :sequence

  def initialize(*ratios)
    @sequence = parse_ratios(*ratios)
    yield @sequence if block_given?
  end

  # ######################################
  # Class methods
  # ######################################

  # TODO Document
  #
  def self.afs(indices: (1..16), factor: 1, offset: 0, nexus: 1)
    Afs.new(indices:, factor:, offset:, nexus:)
  end

  # TODO Implement
  #
  def self.composite
        
  end

  # TODO Document
  #
  def self.cps(set: [], take: 2)
    Cps.new(set:, take:)
  end

  # TODO Document
  #
  def self.edo(modulo:)
    Edo.new(modulo:)
  end

  # TODO Document
  #
  def self.harmonic(indices: (8..16))
    Harmonic.new(indices:)
  end

  # TODO Document
  #
  def self.intra_proportional(ratios: [], subdivision: 2, left_range: subdivision-1, right_range: subdivision-1)
    IntraProportional.new(ratios:, subdivision:, left_range:, right_range:)
  end

  # TODO Document
  #
  def self.linear(generator: 3/2r, upto: 12, limit: 400, equave: 2/1r, threshold: Tonal::Comma.ditonic.to_cents, schizma: false, by_threshold: false)
    Linear.new(generator:, upto:, limit:, equave:, threshold:, schizma:, by_threshold:)
  end

  # TODO Document
  #
  def self.recurrence(upto: 15, seeds: [0, 1], indices: [-1, -2], coeff: [1, 1])
    Recurrence.new(upto: upto, seeds: seeds, indices: indices, coeff: coeff)
  end

  # TODO Document
  #
  def self.polyharmonic(indices: (8..16), fundamentals: [1/1r])
    Polyharmonic.new(indices:, fundamentals:)
  end

  # TODO Document
  #
  def self.proportional(ratios: [], left_range: 1, right_range: 1)
    Proportional.new(ratios:, left_range: left_range, right_range: right_range)
  end

  # TODO Document
  #
  def self.subharmonic(range: (8..16))
    Subharmonic.new(range:)
  end

  # @return [Superparticular] superparticulars up to number
  # @example
  #   Tonal::Sequence.superparticular => [(1/1), (3/2), (4/3), (5/4), (6/5), (7/6), (8/7), (9/8), (10/9), (11/10), (12/11), (13/12)]
  # @param start the starting point of series
  # @param number the number of ratios generated
  # @param limit of the convergence
  #
  def self.superparticular(start: 1, number: 12, limit: Tonal::Ratio.new(1/1r))
    Superparticular.new(start:, number:, limit:)
  end

  # TODO: Document
  #
  def self.superpartient(start: 1, number: 12, part: 2, limit: Tonal::Ratio.new(1/1r), exclusively: true)
    Superpartient.new(start:, number:, part:, limit:, exclusively:)
  end

  # ######################################
  # Instance methods
  # ######################################

  # TODO Document
  #
  def to_scale
    Tonal::Scale.new(sequence)
  end

  # TODO Document
  # This method could be inheritable, if Tonal::Scale < Tonal::Sequence
  #
  def inspect
    sequence.to_a.to_s
  end

  # TODO Document
  # This method could be inheritable, if ::Scale < Tonal::Sequence
  #
  def to_r
    sequence.map(&:to_r)
  end

  # @return [Boolean] if sequences are ratio-wise the same
  # @example
  #   Tonal::Scale.harmonic == Tonal::Scale.harmonic => true
  # @param [Scale] being compared to self
  #
  def ==(rhs)
    false unless rhs.kind_of?(Tonal::Sequence) && self.count != rhs.count
    to_r == rhs.to_r
  end

  private
  def parse_ratios(*items)
    Array.new.tap do |scale|
      items.flatten.each do |item|
        scale << case item
        when Tonal::ReducedRatio
          item.to_basic_ratio
        when Tonal::Ratio
          item
        when Range
          item.to_a.map{|r| Tonal::Ratio.new(r)}
        when Array
          item.map{|r| Tonal::Ratio.new(r)}
        else
          Tonal::Ratio.new(item)
        end
      end
    end
  end
end
