class Tonal::Scale::Superpartient < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Superpartient.new(start: @args[:start], number: @args[:number], part: @args[:part], limit: @args[:limit], exclusively: @args[:exclusively])
  end

  def name
    "Superpartient scale, #{@args[:start]}, #{@args[:number]}, #{@args[:limit]}"
  end

  def description
    "Superpartient scale, start: #{@args[:start]}, number: #{@args[:number]}, limit: #{@args[:limit]}"
  end
end
