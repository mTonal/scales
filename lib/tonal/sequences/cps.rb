class Tonal::Sequence::Cps < Tonal::Sequence
  def initialize(set: [], take: Tonal::Scale::Cps.default_take(set.count))
    @sequence = set.combination(take).map{|group| group.inject(&:*)}.map{|product| Tonal::Ratio.new(product)}
  end
end
