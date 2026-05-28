class Tonal::Sequence::Mos < Tonal::Sequence
  def generate_combinations(limit, element1: 'A', element2: 'B')
    combinations = []
    (1..limit).each do |r|
      combinations += [element1, element2].repeated_permutation(r).to_a
    end
    combinations
  end

  def self.gen(ratio)
    
  end

  # From Chat
  def self.calculate_mos(generator_ratio, period_ratio)
    # Convert ratios to cents for easier calculation
    generator_cents = 1200 * Math.log2(generator_ratio)
    period_cents = 1200 * Math.log2(period_ratio)

    # Initialize variables
    current_cents = 0
    steps = []

    # Calculate steps until we exceed the period
    while current_cents < period_cents
      steps << current_cents % period_cents
      current_cents += generator_cents
    end

    # Sort steps and calculate intervals (differences) to find MOS pattern
    steps.sort!
    intervals = []
    (0...steps.size).each do |i|
      next_step = steps[(i + 1) % steps.size]
      interval = next_step - steps[i]
      interval += period_cents if interval < 0
      intervals << interval
    end

    # Normalize intervals to ensure they add up to the period
    normalized_intervals = intervals.map { |i| (i / period_cents * 12).round }

    return normalized_intervals
  end
  ## Generator and period ratios
  #generator_ratio = 3.0 / 2.0
  #period_ratio = 2.0 / 1.0
  #
  ## Calculate MOS
  #mos_pattern = calculate_mos(generator_ratio, period_ratio)
  #
  #puts "MOS Pattern: #{mos_pattern.inspect}"
end