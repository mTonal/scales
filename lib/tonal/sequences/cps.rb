class Tonal::Sequence::Cps < Tonal::Sequence
  def initialize(set: [], take: 2)
    @sequence = set.combination(take).to_a.map{|group| group.inject(&:*)}.map{|product| Tonal::Ratio.new(product)}
  end
end
