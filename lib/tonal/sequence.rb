require "tonal/sequences/constructors"

class Tonal::Sequence
  extend Forwardable
  def_delegators :@sequence, :count, :last, :first, :[], :denominize, :to_a, :each

  include Tonal::Sequence::Constructors

  attr_reader :sequence

  def initialize(*ratios)
    @sequence = parse_ratios(*ratios)
    yield @sequence if block_given?
  end

  # ######################################
  # Instance methods
  # ######################################

  # @return [Tonal::Scale] a scale built from the ratios of self
  #
  # @example
  #   Tonal::Sequence.harmonic.to_scale => [(1/1), (9/8), (5/4), (11/8), (3/2), (13/8), (7/4), (15/8)]
  #
  def to_scale
    Tonal::Scale.new(sequence)
  end

  # @return [String] string representation of the sequence's ratios
  #
  # @example
  #   Tonal::Sequence.harmonic.inspect => "[(1/1), (9/8), (5/4), (11/8), (3/2), (13/8), (7/4), (15/8)]"
  #
  # This method could be inheritable, if Tonal::Scale < Tonal::Sequence
  #
  def inspect
    sequence.to_a.to_s
  end

  # @return [Array<Rational>] the ratios of self as Ruby Rationals
  #
  # @example
  #   Tonal::Sequence.harmonic.to_r => [(1/1), (9/8), (5/4), (11/8), (3/2), (13/8), (7/4), (15/8)]
  #
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
