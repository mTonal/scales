class Tonal::Sequence::ConvolvedProportional < Tonal::Sequence
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

    @sequence = denominized.tap do |arr|
      antecedent = antecedents.min_by{|ante| Rational(ante,lcm)}
      quotients_modulos.each do |quotient, modulo|
        (0...(segments-1)).each do |sd|
          pm = antecedent + (quotient * (sd+1))
          arr << Tonal::Ratio.new((pm * (segments ** modulo)).to_i, lcm * segments)
        end
      end
      quotients_modulos.each do |quotient, modulo|
        (0...left_range).each do |i|
          pm = antecedent - (quotient * (i+1))
          arr << Tonal::Ratio.new((pm * (segments ** modulo)).to_i, lcm * segments)
        end
      end
      antecedent = antecedents.max_by{|a| Rational(a,lcm)}
      quotients_modulos.each do |quotient, modulo|
        (0...right_range).each do |i|
          pm = antecedent + (quotient * (i+1))
          arr << Tonal::Ratio.new((pm * (segments ** modulo)).to_i, lcm * segments)
        end
      end
    end.uniq(&:to_r).sort.denominize
  end
end

class Tonal::Sequence::IntraProportional < Tonal::Sequence
  attr_reader :ratios, :segments, :left_range, :right_range

  def initialize(ratios: [], segments: 2, left_range: 0, right_range: 0)
    raise(ArgumentError, "Exactly two ratios are required", caller[0]) if ratios.count != 2
    @ratios = ratios
    @segments = segments
    @left_range = left_range
    @right_range = right_range

    denominized_and_factorized = ratios.denominize.map{|r| Tonal::Ratio.new(segments, segments) * r}
    antecedents = denominized_and_factorized.antecedents
    first_antecedent = antecedents.first
    last_antecedent = antecedents.last
    consequent = denominized_and_factorized.consequents.first
    factorized_length = (antecedents.first - antecedents.last).abs
    antecedent_increment = (factorized_length / segments).to_i

    @sequence = [].tap do |seq|
      (0...left_range).each do |i|
        seq << Tonal::Ratio.new(first_antecedent - (antecedent_increment * (i+1)), consequent)
      end

      base_ratio = denominized_and_factorized.first
      i = 0
      while i < factorized_length do
        step_ratio = Tonal::Ratio.new(i, consequent) + base_ratio
        seq << step_ratio
        i += antecedent_increment
      end
      seq << denominized_and_factorized.last

      (0...right_range).each do |i|
        seq << Tonal::Ratio.new(last_antecedent + (antecedent_increment * (i+1)), consequent)
      end
    end
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
