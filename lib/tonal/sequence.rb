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
