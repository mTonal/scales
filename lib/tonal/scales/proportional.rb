class Tonal::Scale::ConvolvedProportional < Tonal::Scale
  def init_sequence
    Tonal::Sequence::ConvolvedProportional.new(ratios: @args[:ratios], left_range: @args[:left_range], right_range: @args[:right_range])
  end

  def name
    "Convolved interval proportional over #{@args[:ratios].map(&:inspect).join(',')}, left range: #{@args[:left_range]}, right_range: #{@args[:right_range]}"
  end

  def description
    "Convolved interval proportional over ratios #{@args[:ratios].map(&:inspect).join}, left range: #{@args[:left_range]}, right_range: #{@args[:right_range]}"
  end
end

class Tonal::Scale::IntraProportional < Tonal::Scale
  def init_sequence
    Tonal::Sequence::IntraProportional.new(ratios: @args[:ratios], segments: @args[:segments], left_range: @args[:left_range], right_range: @args[:right_range])
  end

  def name
    "Intra-interval proportional over #{@args[:ratios]}, #{@args[:segments]}"
  end

  def description
    "Intra-interval proportional over ratios #{@args[:ratios]} with segments #{@args[:segments]}"
  end
end

class Tonal::Scale::Proportional < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Proportional.new(ratios: @args[:ratios], left_range: @args[:left_range], right_range: @args[:right_range])
  end

  def name
    "Interval proportional over #{@args[:ratios].map(&:inspect).join}, left range: #{@args[:left_range]}, right_range: #{@args[:right_range]}"
  end

  def description
    "Interval proportional over ratios #{@args[:ratios].map(&:inspect).join}, left range: #{@args[:left_range]}, right_range: #{@args[:right_range]}"
  end
end
