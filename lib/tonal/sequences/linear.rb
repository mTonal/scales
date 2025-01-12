class Tonal::Sequence::Linear < Tonal::Sequence
  def initialize(generator: 3/2r, upto: 12, limit: 400, equave: 2/1r, threshold: Tonal::Comma.ditonic.to_cents, schizma: false, by_threshold: false)
    @sequence = unless by_threshold
      initialize_simply(generator:, upto:)
    else
      initialize_by_threshold(generator:, limit:, equave:, threshold:, schizma:)
    end
  end

  private
  def initialize_by_threshold(generator:, limit:, equave:, threshold:, schizma:)
    scale = Tonal::Cents::CENT_SCALE

    generator = Tonal::Ratio.new(generator) if generator.kind_of?(Numeric)
    equave = equave.to_r
    threshold = Tonal::Cents.new(cents: threshold) if threshold.kind_of?(Numeric)

    ranges = equave.to_cents.plus_minus(threshold).map{|r| r % scale }
    ranges = ranges.first > ranges.last ? [ranges.first..scale, (0.0).next_float..ranges.last] : [ranges.first..ranges.last]

    (0...limit).each_with_object([]) do |p, accumulator|
      r = (generator**p)
      case r.reduce(equave).to_cents
      when *ranges
        accumulator << r if schizma
        break accumulator
      else
        accumulator << r
      end
    end
  end

  def initialize_simply(generator:, upto:)
    0.upto(upto-1).map{|i| generator ** i}
  end
end
