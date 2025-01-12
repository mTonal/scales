class Tonal::Scale::Superparticular < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Superparticular.new(start: @args[:start], number: @args[:number], limit: @args[:limit])
  end

  def name
    "Superparticular scale, #{@args[:start]}, #{@args[:number]}, #{@args[:limit]}"
  end

  def description
    @description = "Superparticular scale, start: #{@args[:start]}, number: #{@args[:number]}, limit: #{@args[:limit]}"
  end
end
