class Tonal::Scale::Branching < Tonal::Scale
  # TODO Consider renaming to ModularSegmentsScale, or TranslocatedSubchainsScale, or TransposedSegmentsScale
  def init_sequence
    Tonal::Sequence::Branching.new(segments: @args[:segments], starting_nodes: @args[:starting_nodes])
  end

  def name
    "Branched Scale, segments: #{@args[:segments]}, starting_nodes: #{@args[:starting_nodes]}"
  end

  def description
    "Branched Scale generated from segments: #{@args[:segments]} and starting nodes: #{@args[:starting_nodes]}"
  end
end
