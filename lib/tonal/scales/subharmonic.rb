class Tonal::Scale::Subharmonic < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Subharmonic.new(indices: @args.fetch(:indices, (8..16)), nexus: @args.fetch(:nexus, 1))
  end

  def name
    "Subharmonic sequence, #{@args[:indices]}, #{@args[:nexus]}"
  end

  def description
    "Subharmonic sequence, indices: #{@args[:indices]}, nexus: #{@args[:nexus]}"
  end
end
