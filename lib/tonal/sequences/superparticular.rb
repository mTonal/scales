class Tonal::Sequence::Superparticular < Tonal::Sequence::Asymptotic
  def initialize(start: 1, number: 12)
    super(start: start, number: number, limit: 1/1r)
  end
end
