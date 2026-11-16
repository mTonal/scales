class Tonal::Scale::Composite < Tonal::Scale
  def init_sequence
    Tonal::Sequence.new(@args[:placements].product(@args[:ratios]).map{|placement, ratio| placement * ratio})
  end

  def default_name
    "Composite, ratios: #{@args[:ratios]}, placed at: #{@args[:placements]}"
  end

  def default_description
    "Composite of ratios #{@args[:ratios]} placed at #{@args[:placements]}"
  end
end
