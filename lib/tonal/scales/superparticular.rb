class Tonal::Scale::Superparticular < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Asymptotic.new(start: @args[:start], number: @args[:number], limit: 1/1r)
  end

  def name
    "Superparticular scale, #{@args[:start]}, #{@args[:number]}}"
  end

  def description
    @description = "Superparticular scale, start: #{@args[:start]}, number: #{@args[:number]}"
  end
end
