class Tonal::Scale::Linear < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Linear.new(generator: @args[:generator], upto: @args[:upto], limit: @args[:limit], equave: @args[:equave], threshold: @args[:threshold], schizma: @args[:schizma], by_threshold: @args[:by_threshold])
  end

  def name
    if @args[:by_threshold]
      "Linear scale, generator: #{@args[:generator]}, error: #{@args[:threshold]} cents"
    else
      "Linear scale, generator: #{@args[:generator]}, up to #{@args[:upto]}"
    end
  end

  def description
    if @args[:by_threshold]
      "Linear scale, generator: #{@args[:generator]}, error: #{@args[:threshold]} cents"
    else
      "Linear scale. Generator: #{@args[:generator]}, up to #{@args[:upto]}"
    end
  end
end
