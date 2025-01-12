class Tonal::Scale::Composite < Tonal::Scale
  def initialize(ratios, *placements)
    @ratios = sorted(*parse_ratios(*[].tap do |collection|
      placements.each do |placement|
        ratios.each do |ratio|
          collection << Tonal::ReducedRatio.new(ratio * placement)
        end
      end
    end))
    @name = "Composite, ratios: #{ratios}, placed at: #{placements}"
    @description = "Composite: ratios: #{ratios}, place at: #{placements}"
  end
end
