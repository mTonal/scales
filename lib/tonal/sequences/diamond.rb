class Tonal::Sequence::Diamond < Tonal::Sequence
  def initialize(set: [1, 3, 5, 7])
    @sequence = set.product(set).map{|p, q| Tonal::Ratio.new(p, q)}
  end
end
