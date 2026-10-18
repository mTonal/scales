# Base of the objects that explore one area of a scale. Each is reached through an accessor on the scale:
#
#   scale.structure       # Tonal::Scale::Structure
#   scale.primes          # Tonal::Scale::Primes
#   scale.approximations  # Tonal::Scale::Approximations
#   scale.efficiency      # Tonal::Scale::Efficiency
#   scale.report          # Tonal::Scale::Reporter
#
class Tonal::Scale::Service
  extend Forwardable

  attr_reader :scale

  # @param scale [Tonal::Scale] the scale being explored
  #
  def initialize(scale)
    raise ArgumentError, "Scale required" unless scale.kind_of?(Tonal::Scale)

    @scale = scale
  end

  def inspect
    "#<#{self.class.name} #{scale.inspect}>"
  end
end
