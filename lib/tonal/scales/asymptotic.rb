class Tonal::Scale::Asymptotic < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Asymptotic.new(start: @args[:start], number: @args[:number], limit: @args[:limit])
  end

  def name
    "Asymptotic scale, #{@args[:start]}, #{@args[:number]}, #{@args[:limit]}"
  end

  def description
    @description = "Asymptotic scale, start: #{@args[:start]}, number: #{@args[:number]}, limit: #{@args[:limit]}"
  end
end
