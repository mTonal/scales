class Tonal::Sequence::Superpartient < Tonal::Sequence
  def initialize(start: 1, number: 12, part: 2, limit: Tonal::Ratio.new(1/1r), exclusively: true)
    limit = limit.kind_of?(Tonal::Ratio) ? limit : Tonal::Ratio.new(limit)

    @sequence = ((part+start)..(number+start)).map{|step| limit * Tonal::Ratio.new(step, step-part)}
  end
end
