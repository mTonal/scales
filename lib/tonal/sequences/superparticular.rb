class Tonal::Sequence::Superparticular < Tonal::Sequence
  def initialize(start: 1, number: 12, limit: Tonal::ReducedRatio.identity)
    limit = limit.kind_of?(Tonal::Ratio) ? limit : Tonal::Ratio.new(limit)
    @sequence = ((1+start)..(number+start)).map{|step| limit * Tonal::Ratio.new(step, step-1)}
  end
end
