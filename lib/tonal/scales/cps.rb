class Tonal::Scale::Cps < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Cps.new(set: @args[:set], take: @args[:take])
  end

  def name
    "CPS, #{@args[:set]}"
  end

  def description
    "Cross-product Set: #{@args[:set]}, take: #{@args[:take]} - #{self.labels.join(', ')}"
  end
end