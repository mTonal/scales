class Tonal::Scale::Mappers
  extend Forwardable

  def_delegators :@scale, :count, :length, :ratios, :first, :modulo, :ratio_best_expressing

  def initialize(scale=nil)
    @scale = scale
  end

  # @return [Array] array of [Tonal::Cents] values of self
  # @example
  #   Tonal::Scale::Mappers.new(Tonal::Scale.edo(7)).to_cents
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
  #   Tonal::Scale::Mappers.new(Tonal::Scale.edo(7)).to_log2
  #   => [0.0, 0.14, 0.29, 0.43, 0.57, 0.71, 0.86]
  #
  def to_log2
    ratios.map{|r| Tonal::Log2.new(logarithmand: r.to_r) }
  end
  alias :log2 :to_log2

  # @return [Array] of Floats of the ratios of self
  # @example
  #   Tonal::Scale::Mappers.new(Tonal::Scale.edo(7)).to_f
  #   => [1.0, 1.1, 1.22, 1.35, 1.49, 1.64, 1.81]
  #
  def to_f(round: 2)
    ratios.map{|r| r.to_f.round(round) }
  end

  # @return [Array] of Rationals of self
  # @example
  #   Tonal::Scale::Mappers.new(Tonal::Scale.edo(7)).to_r
  #   => [(1/1), (4972377122365053/4503599627370496), (2744974719417411/2251799813685248), (3030697803008479/2251799813685248), (3346161663415923/2251799813685248), (7388924007269683/4503599627370496), (2039508378439785/1125899906842624)]
  #
  def to_r
    ratios.map(&:to_r)
  end

  # @return [Array] of Floats representing radians of self
  # @example
  #   Tonal::Scale::Mappers.new(Tonal::Scale.edo(7)).to_radians
  #   => [0.0, 0.9, 1.8, 2.69, 3.59, 4.49, 5.39]
  #
  def to_radians
    ratios.map{|r| r.period_radians}
  end
  alias :radians :to_radians

  # @return [Array] of Floats representing degrees of self
  # @example
  #   Tonal::Scale::Mappers.new(Tonal::Scale.edo(7)).to_degrees
  #   => [0.0, 51.43, 102.86, 154.29, 205.71, 257.14, 308.57]
  #
  def to_degrees
    ratios.map{|r| r.period_degrees}
  end
  alias :degrees :to_degrees

  # @return [Array] of Floats pairs representing circle coordinates of self
  # @example
  #   Tonal::Scale::Mappers.new(Tonal::Scale.edo(7)).to_circle
  #   => [[-6.123233995736766e-17, 1.0],[0.7833269096274833, 0.6216099682706646],..,[-0.9753733187046665, -0.22056039798441862],[-0.7790726726314032, 0.6269336254811688]]
  #
  def to_circle
    rotation = Math::PI / 2
    to_radians.map{|r| [-Math.cos(r + rotation), Math.sin(r + rotation)]}
  end
  alias :circle :to_circle

  # TODO Document
  #
  # * Standard tuning frequency
  # * Root note frequency
  # * Scale note closest to standard tuning frequency
  #
  # Example 1
  #   standard tuning frequence: 440.0
  #   root note frequency: 261.63
  #
  def adjusted_standard_tuning_frequency(standard_tuning_frequency: 440.0, reference_frequency: 261.63)
    while(reference_frequency < standard_tuning_frequency) do
      reference_frequency *= 2
    end
    reference_frequency * ratio_best_expressing((standard_tuning_frequency/reference_frequency).to_reduced_ratio.to_f).to_f / 2.0
  end

  # TODO Document
  #
  #
  def negatives
    ratios.map(&:negative).map{|r| r.step(modulo)}
  end

  # TODO Document
  #
  def nearest_small_ratios(sort_by: :benedetti)
    sort_by = :benedetti unless Tonal::Scale::Analysis::ACCEPTED_MEASURES.include?(sort_by)
    sort_by = "#{sort_by}_height".to_sym
    ratios.map{|r| r.approximate.by_continued_fraction.sort_by(&sort_by).ratios.first}
  end

  ################
  # TODO Document
  # @return
  # @example
  # @param
  #
  def maps_on(step=modulo)
    ratios.map{|r| [r, r.step(step), r.to_cents.nearest_hundredth.value, r.to_cents.nearest_hundredth_difference.value]}
  end
end
