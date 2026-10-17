# The chords embedded in a scale, together with a back-reference to the scale
# they were drawn from. Returned by +Tonal::Scale::Cps#chords+,
# +Tonal::Scale::Lattice#chords+ and +Tonal::Scale::Diamond#chords+.
#
# Quacks like an +Array<Tonal::Scale::Chord>+ (it is Enumerable and forwards the
# handful of Array methods Enumerable lacks), and adds +#scale+ plus +#to_musaic+
# - the Musaic export lives here rather than on the scale because it is a function
# of the chords, not of the scale class.
#
class Tonal::Scale::ChordSet
  include Enumerable

  # @return [Tonal::Scale] the scale these chords were drawn from
  attr_reader :scale

  # @param scale [Tonal::Scale]
  # @param chords [Array<Tonal::Scale::Chord>]
  #
  def initialize(scale:, chords:)
    @scale = scale
    @chords = chords
  end

  def each(&block)
    @chords.each(&block)
  end

  def [](*args) = @chords[*args]
  def size = @chords.size
  def length = @chords.length
  def last = @chords.last
  def empty? = @chords.empty?

  def ==(other)
    other.respond_to?(:to_a) && to_a == other.to_a
  end

  def inspect
    @chords.inspect
  end

  # @return [Integer] byte count of data written to a musaic/1.0 YAML file
  #
  # @example
  #   Tonal::Scale.diamond.chords(4..6).to_musaic("diamond")
  #
  # @param file_name [String] YAML file name
  # @param fave [Boolean] whether to place in the "faves" sub-folder of the Musaic folder
  # @param location [String] to write file to; if nil, writes to the root of the Musaic folder
  # @param base_midi [Integer] MIDI note assigned to degree 0 (1/1)
  # @param tempo [Integer, nil] program tempo; omitted from the file when nil
  # @param form [Symbol] :chords (block simultaneities, default) or :arpeggio (one tone at a time)
  # @param durations [Array<String>, nil] the region's duration row (default ["1/2"] for :chords, ["1/4"] for :arpeggio)
  #
  def to_musaic(file_name = nil, fave: false, location: nil, base_midi: 60, tempo: nil, form: :chords, durations: nil)
    raise ArgumentError, "no chords to export" if @chords.empty?

    Tonal::IO::Musaic.export(scale, file_name, fave:, location:, chords: @chords, base_midi:, tempo:, form:, durations:)
  end
end
