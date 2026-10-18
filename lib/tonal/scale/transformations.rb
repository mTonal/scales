# Operations that turn a scale into another scale. Included in Tonal::Scale so they chain:
#
#   Tonal::Scale.harmonic.mode(2).invert
#
module Tonal::Scale::Transformations
  # @return [Tonal::Scale] mode on step of self (step becomes 1/1 of self)
  #
  # @example
  #   Tonal::Scale.harmonic(indices: 4..7).mode(4) => [1/1, 7/6, 4/3, 5/3]
  #
  # @param step [Integer] step index of the source scale on which the tonic of the mode is set
  #
  def mode(step)
    Tonal::Scale.new(*scale.collect{|r| r / self[step]}, name: "#{self.name} - mode #{step}", description: "#{self.description} - mode #{step}")
  end

  # @return [Array<Tonal::Scale>] every mode of self, one per step
  #
  # @example
  #   Tonal::Scale.new(1/1r, 5/4r, 3/2r).modes => [[1/1, 5/4, 3/2], [1/1, 6/5, 8/5], [1/1, 4/3, 5/3]]
  #
  def modes
    indices.map{|step| mode(step)}
  end

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

  # @return [Tonal::Scale] a new scale with an additional ratio placed at `at`, scaled by `by`
  #
  # @example
  #  Tonal::Scale.new(1/1r, 9/8r, 5/4r, 3/2r, 5/3r).expand(at: 5/4r, by: 9/8r, boundary: :upper) => [1/1, 9/8, 5/4, 45/32, 3/2, 5/3]
  #
  # @param at [Rational] the interval to find between notes of self and expand from
  # @param by [Rational] the interval to multiply against the boundary notes of intervals found at `at`
  # @param boundary [:lower, :upper] which boundary notes to operate on
  # @param operator [Symbol] the arithmetic operator to apply
  #
  def expand(at:, by:, boundary: :lower, operator: :*)
    scale = Tonal::Scale.new(*self.scale).tap do |r|
      r << structure.find_all(at).map(&:"#{boundary}_ratio").map{|r| r.send(operator, by)}
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
end
