# Human-readable reports of a scale, rendered as Terminal::Table.
# A report only lays out data taken from the scale and its other services, it computes nothing of its own.
#
# @example
#   puts Tonal::Scale.harmonic.report.cross_table
#
class Tonal::Scale::Reporter < Tonal::Scale::Service
  NOTE_NAMES = %w[C C# D D# E F F# G G# A A# B]

  # @return [Terminal::Table] text table of the 12-TET MIDI notes and pitch bends that retune them to the ratios of scale
  # @example
  #   puts Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r).report.pitch_bends =>
  #     +-------+------+------+--------------+---------------+---------------+
  #     | ratio | note | MIDI | cents offset | bend (14-bit) | bend (signed) |
  #     +-------+------+------+--------------+---------------+---------------+
  #     | 1/1   | C4   | 60   | 0.0          | 8192          | 0             |
  #     | 5/4   | E4   | 64   | -13.69       | 8169          | -23           |
  #     | 3/2   | G4   | 67   | 1.96         | 8195          | 3             |
  #     | 7/4   | A#4  | 70   | -31.17       | 8139          | -53           |
  #     +-------+------+------+--------------+---------------+---------------+
  #
  # @param midi_root [Integer] MIDI number of the 1/1 of scale, default is middle C
  # @param bend_range [Numeric] pitch bend range in semitones, matching the instrument (MPE default 48)
  #
  def pitch_bends(**kwargs)
    rows = scale.to_pitch_bends(**kwargs).map do |ratio, midi, offset, bend, signed|
      [ratio.inspect, note_name(midi), midi, offset, bend, signed]
    end
    Terminal::Table.new(headings: ["ratio", "note", "MIDI", "cents offset", "bend (14-bit)", "bend (signed)"], rows: rows)
  end

  # @return [Terminal::Table] text cross table. Notes of scale are on the margins.
  #   The middle are the intervals between the margin notes.
  # @example
  #   puts Tonal::Scale.harmonic.report.cross_table =>
  #     +------+------+------+-------+-------+-------+-------+-------+-------+
  #     |      | 1/1  | 9/8  | 5/4   | 11/8  | 3/2   | 13/8  | 7/4   | 15/8  |
  #     | 1/1  | 1/1  | 16/9 | 8/5   | 16/11 | 4/3   | 16/13 | 8/7   | 16/15 |
  #     | 9/8  | 9/8  | 1/1  | 9/5   | 18/11 | 3/2   | 18/13 | 9/7   | 6/5   |
  #     | 5/4  | 5/4  | 10/9 | 1/1   | 20/11 | 5/3   | 20/13 | 10/7  | 4/3   |
  #     ...
  #
  def cross_table
    rows = [[nil] + scale.to_r]
    scale.each do |n|
      rows << ([n.to_r] + scale.collect{|m| (n / m).to_r})
    end
    Terminal::Table.new(rows: rows)
  end

  # @return [Terminal::Table] text table inventory of the intervals between the notes of scale.
  #   The columns are the interval, its prime vector exponents, its difference (antecedent - consequent) and how often it occurs.
  #   Intervals with a prime factor above Tonal::Ratio::PRIME_LIMIT, such as EDO steps, have blank exponents.
  # @example
  #   puts Tonal::Scale.new(1/1r, 5/4r, 3/2r).report.inventory =>
  #     +----------+----+---+---+------------+-------------+
  #     | interval | 2  | 3 | 5 | difference | occurrences |
  #     +----------+----+---+---+------------+-------------+
  #     |   6/5    |  1 | 1 | -1 |          1 |           1 |
  #     ...
  #
  def inventory
    intervals = scale.structure.occurrences.reject{|ratio, _| ratio == 1}.map{|_, found| [found.first.intervalic_ratio, found.count]}
    primes = Prime.each(intervals.filter_map{|interval, _| interval.max_prime}.max || 2).to_a
    rows = intervals.map do |interval, occurrences|
      exponents = interval.prime_vector&.to_a&.rpad(primes.count, 0) || Array.new(primes.count)
      [interval.to_r, *exponents, interval.difference, occurrences]
    end
    Terminal::Table.new(headings: ["interval", *primes, "difference", "occurrences"], rows: rows).tap do |table|
      table.align_column(0, :center)
      1.upto(primes.count + 2).each{|i| table.align_column(i, :right)}
    end
  end

  private

  # Middle C (MIDI 60) is C4, as in Logic Pro
  def note_name(midi_number)
    "#{NOTE_NAMES[midi_number % 12]}#{midi_number / 12 - 1}"
  end
end
