class Tonal::Sequence::Recurrence < Tonal::Sequence
  LIMIT = 10

  def initialize(upto: 15, seeds: [0, 1], indices: [-1, -2], coeff: [1, 1], start_at: 0)
    max_index = indices.map(&:abs).max
    accumulator = seeds + Array.new((max_index - seeds.length).abs, 1)
    n = accumulator.length
    #i = 1
    #@sequence = accumulator.tap do |result|
    #              while i < upto do
    #                result << result.values_at(*indices).zip(coeff).map{|t| t.inject(&:*)}.reduce(:+)
    #                i += 1
    #              end
    #            end.reject{|e| e.zero?}
    @sequence = accumulator.tap do |result|
                  (n+1..upto).each do
                    result << result.values_at(*indices).zip(coeff).map{|t| t.inject(&:*)}.reduce(:+)
                  end
                end.reject{|e| e.zero?}[start_at..-1]
  end

  def convergent
    sequence[-2..-1].inject{|a,b| b.to_f / a}
  end

  def log2
    convergent.log2
  end

  def moses(limit: LIMIT)
    FareyTree.quotient_walk(convergent.to_f, limit: limit)
  end
end
