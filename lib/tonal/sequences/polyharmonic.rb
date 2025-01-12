class Tonal::Sequence::Polyharmonic < Tonal::Sequence
  def initialize(indices: (8..16), fundamentals: [1/1r])
    @sequence = [].tap do |c|
      fundamentals.each do |f|
        indices.each{|r| c << r * f}
      end
    end
  end
end
