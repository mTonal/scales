class Tonal::Sequence::Linear < Tonal::Sequence
  def initialize(generator: 3/2r, upto: 12, limit: 400, equave: Tonal::Scale::DEFAULT_EQUAVE, threshold: Tonal::Comma.ditonic.to_cents, schizma: false, by_threshold: false, centered: false)
    @sequence = unless by_threshold
      initialize_simply(generator:, upto:, centered:)
    else
      initialize_by_threshold(generator:, limit:, equave:, threshold:, schizma:, centered:)
    end
  end

  private
  def initialize_by_threshold(generator:, limit:, equave:, threshold:, schizma:, centered: false)
    scale = Tonal::Cents::CENT_SCALE

    generator = Tonal::Ratio.new(generator) if generator.kind_of?(Numeric)
    threshold = Tonal::Cents.new(cents: threshold) if threshold.kind_of?(Numeric)

    ranges = equave.to_cents.plus_minus(threshold).map{|r| r % scale }
    ranges = ranges.first > ranges.last ? [ranges.first..scale, (0.0).next_float..ranges.last] : [ranges.first..ranges.last]

    sequence = (0...limit).each_with_object([]) do |p, accumulator|
      r = (generator**p)
      case r.reduce(equave).to_cents
      when *ranges
        accumulator << r if schizma
        break accumulator
      else
        accumulator << r
      end
    end

    if centered
      n = sequence.length
      offset = -(n / 2)
      (0...n).map { |i| generator ** (i + offset) }
    else
      sequence
    end
  end

  def initialize_simply(generator:, upto:, centered: false)
    start = centered ? -(upto / 2) : 0
    start.upto(start + upto - 1).map { |i| generator ** i }
  end
end
