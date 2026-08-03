class Tonal::Scale::Chord
  attr_reader :ratios, :steps, :name, :description

  # @param ratios [Array<Tonal::Ratio>] the notes of the chord
  # @param steps [Array<Integer, nil>] each ratio's index within the scale it was drawn from, same order as ratios
  # @param name [String]
  # @param description [String]
  #
  def initialize(ratios:, steps:, name: "Unnamed", description: "Undescribed")
    @ratios = ratios
    @steps = steps
    @name = name
    @description = description
  end

  def to_a
    ratios
  end

  def count
    ratios.count
  end

  def inspect
    "#{ratios} (steps: #{steps})"
  end
end
