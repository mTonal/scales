class Tonal::Sequence::Subharmonic < Tonal::Sequence
  def initialize(range: (8..16), fund: 1)
    @sequence = [].tap{|collection| range.each{|r| collection << Rational(1, r * fund)}}
  end
end
