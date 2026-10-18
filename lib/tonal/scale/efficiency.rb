# How efficiently the ratios of a scale are expressed by the steps of an equal division, and the statistics of those efficiencies.
#
# @example
#   Tonal::Scale.harmonic.efficiency.standard_deviation
#
class Tonal::Scale::Efficiency < Tonal::Scale::Service
  PRECISION = 2

  def_delegators :@scale, :count, :ratios

  # @return [Array<Float>] the EDO step efficiency of each ratio in the scale
  #
  # @example
  #   Tonal::Scale.harmonic.efficiency.efficiencies
  #   => [0.0 ¢, 53.91 ¢, -63.69 ¢, -48.68 ¢, -48.04 ¢, -59.47 ¢, 68.83 ¢, 38.27 ¢]
  #
  # @param modulo [Integer] the EDO modulo used to compute step efficiency, defaults to scale count
  #
  def efficiencies(modulo=count)
    ratios.map{|r| r.efficiency(modulo, is_step_efficiency: true)}
  end

  # @return [Float] difference in cents between the provided ratio and the scale's best step approximation to it
  # @example
  #   Tonal::Scale.edo(12).efficiency.efficiency_with(81/64r) => -7.82
  #
  def efficiency_with(ratio)
    ratio = ratio.kind_of?(Tonal::ReducedRatio) ? ratio : ratio.kind_of?(Numeric) ? Tonal::ReducedRatio.new(ratio) : raise(ArgumentError, "Ratio must be Tonal::ReducedRatio or Numeric")
    ratio.efficiency(count)
  end

  # @return [Float] mean of the step efficiencies of the scale
  #
  # @example
  #   Tonal::Scale.harmonic.efficiency.mean => -7.36
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
  #   Tonal::Scale.harmonic.efficiency.variance => 2618.24
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
  #   Tonal::Scale.harmonic.efficiency.standard_deviation => 51.17
  #
  # @param modulo [Integer] the EDO modulo used to compute step efficiencies, defaults to scale count
  # @param round [Integer] decimal places to round the result
  #
  def standard_deviation(modulo=count, round: PRECISION)
    (Math.sqrt(variance(modulo, round:))).round(round)
  end
end
