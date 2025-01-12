class Tonal::Sequence::IntraProportional < Tonal::Sequence
  attr_reader :ratios, :segments, :left_range, :right_range

  def initialize(ratios: [], segments: 2, left_range: 0, right_range: 0)
    @ratios = ratios
    @segments = segments
    @left_range = left_range
    @right_range = right_range

    lcm = ratios.denominators.lcm
    denominized = ratios.denominize
    antecedents = denominized.map(&:antecedent)

    quotients_modulos = antecedents.combination(2)
                          .map{|l, r| (l - r).abs}
                          .map{|n| [n / segments.to_f, n % segments]}

    # Build sequence steps:
    # 1. Start at minumum antecedent (numerator) increase segment steps
    # 2. If right_range, increase segment steps from maximum antecedent
    # 3. If left_range, decrease segment steps from minumum antecedent
    # TODO Rename right_range to upper_extension, left_range to lower_extension
    #
    @sequence = denominized.tap do |arr|
      antecedent = antecedents.min_by{|ante| Rational(ante,lcm)}
      quotients_modulos.each do |quotient, modulo|
        (0...(segments-1)).each do |sd|
          pm = antecedent + (quotient * (sd+1))
          arr << Tonal::Ratio.new((pm * (segments ** modulo)).to_i, lcm * segments)
        end
      end
      #puts "#{arr}"
      quotients_modulos.each do |quotient, modulo|
        (0...left_range).each do |i|
          pm = antecedent - (quotient * (i+1))
          arr << Tonal::Ratio.new((pm * (segments ** modulo)).to_i, lcm * segments)
        end
      end
      #puts "#{arr}"
      antecedent = antecedents.max_by{|a| Rational(a,lcm)}
      quotients_modulos.each do |quotient, modulo|
        (0...right_range).each do |i|
          pm = antecedent + (quotient * (i+1))
          arr << Tonal::Ratio.new((pm * (segments ** modulo)).to_i, lcm * segments)
        end
      end
      #puts "#{arr}"
    end.uniq(&:to_r).sort.denominize
  end

  def self.border_proportional(ratios, left_range: 1, right_range: 1)
    
  end
end

class Tonal::Sequence::NewProportional < Tonal::Sequence
  attr_reader :ratios, :segments, :left_range, :right_range

  def initialize(ratios: [], segments: 2, left_range: 0, right_range: 0)
    @ratios = ratios
    @segments = segments
    @left_range = left_range
    @right_range = right_range

    lcm = ratios.denominators.lcm
  end
end

class Tonal::Sequence::Proportional < Tonal::Sequence
  attr_reader :ratios, :left_range, :right_range
  def initialize(ratios: [], left_range: 1, right_range: 1)
    raise(ArgumentError, "Exactly two ratios per interval are required", caller[0]) if ratios.any?{|r| r.count != 2 }
    @ratios = ratios
    @left_range = left_range
    @right_range = right_range

    @sequence = [].tap do |arr|
      ratios.each do |ratio_pairs|
        lcm = ratio_pairs.denominators.lcm
        denominized = ratio_pairs.denominize
        antecedents = denominized.map(&:antecedent)
        denominized_proportion_term = antecedents.inject(&:-).abs

        arr << denominized
        antecedent = antecedents.min_by{|a| Rational(a,lcm)}
        (0..left_range).each do |i|
          pm = (antecedent - (denominized_proportion_term * i)).abs
          arr << Tonal::Ratio.new(pm, lcm)
        end
        antecedent = antecedents.max_by{|a| Rational(a,lcm)}
        (0..right_range).each do |i|
          pm = (antecedent + (denominized_proportion_term * i))
          arr << Tonal::Ratio.new(pm, lcm)
        end
      end
    end.flatten.uniq(&:to_r).sort
  end
end

class Tonal::Sequence::ExtraProportional < Tonal::Sequence
  
end
