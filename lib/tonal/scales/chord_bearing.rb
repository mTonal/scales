class Tonal::Scale
  # Capabilities of a scale with embedded harmonies.
  #
  # Included by scales whose #chords, called with no arguments, returns a
  # Tonal::Scale::ChordSet: Tonal::Scale::Cps, Tonal::Scale::Diamond and Tonal::Scale::Lattice.
  #
  module ChordBearing
    # @return [Integer] byte count of data written to a musaic/1.0 YAML file
    # @note The scale's whole #chords set is exported; to write a narrower selection
    #   call #to_musaic on the set itself, e.g. Tonal::Scale.diamond.chords(4..6).to_musaic("diamond").
    #
    # @example
    #   Tonal::Scale.cps.to_musaic("hexany", tempo: 110)
    #   Tonal::Scale.diamond.chords(4).to_musaic("diamond-tetrads")
    #
    # @see Tonal::Scale::ChordSet#to_musaic for the parameters
    #
    def to_musaic(file_name=nil, **kwargs)
      chords.to_musaic(file_name, **kwargs)
    end
  end
end
