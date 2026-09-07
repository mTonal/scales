class Tonal::Scale::Chord
  attr_reader :ratios, :steps, :name, :description, :factors

  # @param ratios [Array<Tonal::Ratio>] the notes of the chord
  # @param steps [Array<Integer, nil>] each ratio's index within the scale it was drawn from, same order as ratios
  # @param name [String]
  # @param description [String]
  # @param factors [String, nil] the factor tuple behind each note, parenthesized and voice-wise
  #   comma-delimited in ratio order, e.g. "(3)(5),(3)(7),(5)(7)"; nil when the chord's notes
  #   don't decompose into a generating set
  #
  def initialize(ratios:, steps:, name: "Unnamed", description: "Undescribed", factors: nil)
    @ratios = ratios
    @steps = steps
    @name = name
    @description = description
    @factors = factors
  end

  def to_a
    ratios
  end

  def count
    ratios.count
  end

  def inspect
    "#{ratios} (steps: #{steps}#{", factors: #{factors}" if factors})"
  end
end
