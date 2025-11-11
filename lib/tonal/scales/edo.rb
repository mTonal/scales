class Tonal::Scale::Edo < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Edo.new(modulo: @args[:modulo])
  end

  def label_ratios!
    @ratios.each_with_index do |ratio, idx|
      exponent = "#{idx}/#{@args[:modulo]}"
      ratio.label = "2^#{exponent}"
    end
  end

  def name
    "#{@args[:modulo]} edo"
  end

  def description
    "#{@args[:modulo]}-tone equal division of the octave scale"
  end

  # TODO: Document
  # Return a set of lower rational numbered alternative ratios
  #
  def simplify(by: :continued_fraction)
    Tonal::Scale.new(*approximate(by:).map{|r| r[1].ratios.entries[0]}.map{|r| r.nil? ? 1/1r : r}, name: "#{self.name} simplified", description: "#{self.name} simplified using #{by}")
  end
end
