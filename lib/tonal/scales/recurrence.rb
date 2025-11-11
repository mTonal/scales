class Tonal::Scale::Recurrence < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Recurrence.new(upto: @args[:upto], seeds: @args[:seeds], indices: @args[:indices], coeff: @args[:coeff], start_at: @args[:start_at])
  end

  def name
    "Recurrence #{@ratios.count}-tone, #{@args[:seeds]}, #{@args[:indices]}, #{@args[:coeff]}, #{@args[:start_at]}"
  end

  def description
    "Recurrence #{@ratios.count}-tone, seeds: #{@args[:seeds]}, indices: #{@args[:indices]}, coefficients: #{@args[:coeff]}, start_at: #{@args[:start_at]}"
  end
end
