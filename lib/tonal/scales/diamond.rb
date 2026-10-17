class Tonal::Scale::Diamond < Tonal::Scale
  # Erv Wilson's name for a full otonal/utonal chord, keyed by voice count.
  NTAD_NAMES = {
    2 => "dyad", 3 => "triad", 4 => "tetrad", 5 => "pentad", 6 => "hexad",
    7 => "heptad", 8 => "octad", 9 => "nonad", 10 => "decad", 11 => "hendecad", 12 => "dodecad"
  }.freeze

  def init_sequence
    Tonal::Sequence::Diamond.new(set: assigned_set)
  end

  def name
    "Tonality diamond, #{assigned_set}"
  end

  def description
    "Tonality diamond: all ratios p/q for p, q in #{assigned_set}, reduced to the octave"
  end

  # @return [Tonal::Scale::ChordSet] the otonal and utonal n-ads of the diamond,
  #   following Erv Wilson's nested tetrad/pentad/hexad/heptad groupings. The n-ad is
  #   the leading harmonic-limit subset of the generating set (n = 4 -> the first four
  #   factors, n = 5 -> the first five, ...). For every common tone drawn from the full
  #   generating set there is one otonal chord (n numerators sharing that denominator)
  #   and one utonal chord (n denominators sharing that numerator), so each n-ad level
  #   contributes +2 * assigned_set.count+ chords. With the default n these are the rows
  #   and columns of the rhombus - for +[1, 3, 5, 7]+ the four major and four minor tetrads.
  #
  #   Pass a Range to list every sub-n-ad up to a limit, smallest first - the nested
  #   chords Wilson draws inside a diamond figure. A beginless range starts at 2 (dyads);
  #   an endless range runs up to the full generating-set count; out-of-range levels are
  #   skipped.
  #
  # @param n [Integer, Range] the Ntad number, or a range of them (default: the full
  #   generating-set count, i.e. the diamond's own otonality/utonality)
  #
  # @example
  #   Tonal::Scale.diamond.chords.count       => 8    # tetrads only
  #   Tonal::Scale.diamond.chords(3).count    => 8    # triads only
  #   Tonal::Scale.diamond.chords(2..4).count => 24   # dyads + triads + tetrads
  #   Tonal::Scale.diamond(1,3,5,7,9,11).chords(4..).map(&:name)
  #   => ["Otonal tetrad, 1.3.5.7/1", ..., "Otonal pentad, 1.3.5.7.9/1", ..., "Otonal hexad, 1.3.5.7.9.11/1", ...]
  #
  def chords(n = assigned_set.count)
    Tonal::Scale::ChordSet.new(scale: self, chords: ntad_levels(n).flat_map { |level| ntad_chords(level) })
  end

  # Writes every nested sub-n-ad (dyads up through the full otonality/utonality) to
  # a musaic/1.0 YAML file. Pass a narrower selection explicitly via
  # +chords(n).to_musaic(...)+ - e.g. +diamond.chords(4).to_musaic("tetrads")+.
  #
  # @see Tonal::Scale::ChordSet#to_musaic
  #
  def to_musaic(file_name = nil, **kwargs)
    chords(2..).to_musaic(file_name, **kwargs)
  end

  private

  # @return [Range] the n-ad levels to build, clamped to buildable sizes
  #
  def ntad_levels(n)
    return n..n unless n.is_a?(Range)
    (n.begin || 2)..(n.end || assigned_set.count)
  end

  # @return [Array<Tonal::Scale::Chord>] the otonal and utonal chords at one n-ad level,
  #   or [] when the level is too small (< 2) or larger than the generating set
  #
  def ntad_chords(n)
    return [] if n < 2 || n > assigned_set.count

    group = assigned_set.first(n)
    ntad = NTAD_NAMES.fetch(n, "#{n}-ad")

    otonal = assigned_set.map { |common| otonal_chord(group, common, ntad) }
    utonal = assigned_set.map { |common| utonal_chord(group, common, ntad) }
    otonal + utonal
  end

  def assigned_set
    @set ||= @args[:set].empty? ? [1, 3, 5, 7] : @args[:set]
  end

  def otonal_chord(group, common, ntad)
    build_chord(group.map { |harmonic| [harmonic, common] },
      name: "Otonal #{ntad}, #{group.join(".")}/#{common}",
      description: "Otonal #{ntad} of #{name}: harmonics #{group.join(", ")} over #{common}")
  end

  def utonal_chord(group, common, ntad)
    build_chord(group.map { |subharmonic| [common, subharmonic] },
      name: "Utonal #{ntad}, #{common}/#{group.join(".")}",
      description: "Utonal #{ntad} of #{name}: subharmonics #{group.join(", ")} under #{common}")
  end

  # @param pairs [Array<[Integer, Integer]>] each voice as its unreduced [numerator, denominator]
  #
  def build_chord(pairs, name:, description:)
    notes = pairs.map { |p, q| [Tonal::ReducedRatio.new(p, q), [p, q]] }.sort_by(&:first)
    ratios = notes.map(&:first)

    Tonal::Scale::Chord.new(
      ratios: ratios,
      steps: ratios.map { |ratio| find_index(ratio) },
      name: name,
      description: description,
      factors: notes.map { |(_, (p, q))| "(#{p})/(#{q})" }.join(",")
    )
  end
end
