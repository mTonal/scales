require_relative "scale_io"

# Writes a CPS scale as a +musaic/1.0+ YAML program for Musaic (the user's
# algorithmic-music app). The scale becomes a Just-Intonation +tuning+, and its
# embedded chords (Tonal::Scale::Cps#chords) become a matrix that Musaic's
# +across_rows+ transitions walk by shared tones - i.e. by shared generating
# factors.
#
# Two output forms:
# * +:chords+ (default) - a +chords+ matrix, one CPS chord per row, sounded as
#   block simultaneities.
# * +:arpeggio+ - a +notes+ matrix, one CPS chord per row, sounded one tone at a
#   time; +within_row+ reorders each chord's tones.
#
# Musaic inserts an implicit +1/1+ at degree 0, so a Musaic degree +n+ plays this
# scale's degree +n - 1+; the chord rows are emitted with that +1 shift.
#
class Tonal::IO::Musaic < Tonal::IO::Scale
  DEFAULT_BASE_MIDI = 60
  DEFAULT_FORM = :chords
  DEFAULT_DURATIONS = {chords: ["1/2"].freeze, arpeggio: ["1/4"].freeze}.freeze
  PERIOD = "2/1".freeze

  def self.file_extension
    ".yaml"
  end

  def self.root_directory
    Tonal::IO.musaic_directory
  end

  def self.faves_directory
    Pathname.new("faves")
  end

  # @param scale [Tonal::Scale::Cps]
  # @param base_midi [Integer] MIDI note of degree 0 (1/1)
  # @param tempo [Integer, nil] program tempo; omitted from the output when nil
  # @param form [Symbol] +:chords+ (block simultaneities) or +:arpeggio+
  # @param durations [Array<String>, nil] the region's duration row
  #
  def initialize(file_name, scale:, base_midi: DEFAULT_BASE_MIDI, tempo: nil, form: DEFAULT_FORM, durations: nil, **kwargs)
    super(file_name, **kwargs)
    @scale = scale
    @base_midi = base_midi || DEFAULT_BASE_MIDI
    @tempo = tempo
    @form = form&.to_sym || DEFAULT_FORM
    raise ArgumentError, "form must be :chords or :arpeggio" unless DEFAULT_DURATIONS.key?(@form)
    @durations = durations || DEFAULT_DURATIONS.fetch(@form)
  end

  # @return [Hash] the musaic/1.0 program document (string keys throughout)
  #
  def to_h
    {
      "program" => {
        "tempo" => @tempo,
        "base_midi" => @base_midi,
        "mpe" => true,
        "tuning" => {"ratios" => tuning_ratios},
        "tracks" => [{"regions" => [harmonic_region]}]
      }.compact
    }
  end

  # @return [Integer] count of bytes written
  #
  def write
    super(render)
  end

  private

  # The scale's ratios as an ascending Scala-style list with the period last.
  # A leading 1/1 (only from a degenerate generating set) is dropped since
  # Musaic supplies degree 0 itself.
  #
  def tuning_ratios
    ratios = @pitches.reject { |ratio| ratio == "1/1" }
    ratios << PERIOD unless ratios.last == PERIOD
    ratios
  end

  def harmonic_region
    @form == :chords ? chords_region : arpeggio_region
  end

  # One CPS chord per row, each row a single chord slot: block simultaneities
  # that `across_rows` migrates between by shared tones (hence factors).
  def chords_region
    {
      "chords" => chord_rows.map { |degrees| [degrees] },
      "durations" => @durations,
      "chords_process" => {"across_rows" => across_rows_transitions}
    }
  end

  # One CPS chord per row of single tones: an arpeggio that `within_row`
  # reorders and `across_rows` migrates between by shared tones.
  def arpeggio_region
    {
      "notes" => chord_rows,
      "durations" => @durations,
      "notes_process" => {
        "within_row" => [{"method" => "sequential"}],
        "across_rows" => across_rows_transitions
      }
    }
  end

  # Each ordered CPS chord as Musaic degrees (scale degree + 1).
  def chord_rows
    ordered_chords.map { |chord| chord.steps.map { |step| step + 1 } }
  end

  # CPS chords ordered so each is adjacent to the previous by the most shared
  # tones possible - a greedy nearest-neighbour walk. Musaic's shared-tone
  # transitions do the real navigation; this just gives a sensible starting row
  # order and a meaningful `sequential` fallback.
  #
  def ordered_chords
    @ordered_chords ||= begin
      remaining = @scale.chords.dup
      ordered = [remaining.shift]
      until remaining.empty?
        current = ordered.last.steps
        nearest = remaining.max_by { |chord| (chord.steps & current).size }
        ordered << remaining.delete(nearest)
      end
      ordered
    end
  end

  # Only the factor-coherent moves (chords sharing one or two tones), plus a
  # `sequential` fallback so the walk always advances.
  #
  def across_rows_transitions
    overlaps = ordered_chords.combination(2).map { |a, b| (a.steps & b.steps).size }.uniq
    [].tap do |transitions|
      transitions << {"transition" => "one_common"} if overlaps.include?(1)
      transitions << {"transition" => "two_common"} if overlaps.include?(2)
      transitions << {"transition" => "sequential"}
    end
  end

  def render
    header + "\n" + YAML.dump(to_h)
  end

  def header
    legend = ordered_chords.each_with_index.map do |chord, row|
      "#   row #{row}  #{chord.name}  #{chord.factors}"
    end
    material = @form == :chords ? "`chords`" : "`notes`"
    [
      "# #{@name}",
      "# #{@description}",
      "# Generated by #{@origination}, #{Date.today.strftime("%b %d, %Y")}",
      "#",
      "# The CPS scale is emitted as Musaic `tuning.ratios` (ascending, period",
      "# #{PERIOD} last, degree 0 = 1/1 implicit). A Musaic degree n plays this",
      "# scale's degree n-1. #{material} is a matrix, one row per CPS chord;",
      "# `across_rows` migrates between chords sharing tones (hence factors):",
      *legend
    ].join("\n") + "\n"
  end
end
