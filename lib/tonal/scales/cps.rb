class Tonal::Scale::Cps < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Cps.new(set: assigned_set, take: assigned_take)
  end

  def name
    "CPS, #{assigned_set}"
  end

  def description
    "Cross Product Set: #{prettified_set}, take: #{assigned_take} - #{self.labels.join(', ')}"
  end

  private
  def assigned_set
    @set ||= @args[:set].empty? ? [1, 3, 5, 7] : @args[:set]
  end

  def assigned_take
    @take ||= (@args[:take] || (assigned_set.count/2))
  end

  def prettified_set
    assigned_set.map{|input| input.kind_of?(Float) ? input.round(2) : input}
  end
end
