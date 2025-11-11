class Tonal::Scale
  module Constructors
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # TODO Develop
      # Generalized Tetrachordal constructor
      # https://en.wikipedia.org/wiki/Tetrachord


      # @return [Tonal::Scale::Afs]
      # @example
      #   Tonal::Scale.afs
      #   => [(1/1), (9/8), (5/4), (11/8), (3/2), (13/8), (7/4), (15/8)]
      #
      # @param indices [Range] of the sequence
      # @param factor [Integer] constant multiplied on the indices
      # @param offset [Integer] constant term added to the products
      # @param nexus [Integer] numerical constant
      # @param identity [Symbol] determine if sequence is harmonic (:otonal) or sub-harmonic (:utonal)
      #
      def afs(indices: (8..16), factor: 1, offset: 0, nexus: 1, identity: :otonal)
        Afs.new(indices:, factor:, offset:, nexus:, identity:)
      end

      # TODO: Document
      # @return [Tonal::Scale::Composite]
      # @example
      #   Tonal::Scale.composite([1/1r, 3/2r, 5/4r, 7/4r], [1/1r, 5/4r])
      #   => [(1/1), (35/32), (5/4), (3/2), (25/16), (7/4), (15/8)]
      #
      def composite(ratios, placements)
        Composite.new(ratios, *placements)
      end

      # @return [Tonal::Scale::ConvolvedProportional]
      # @example
      #   Tonal::Scale.convolved_proportional(3/2r, 7/4r)
      #   => [(3/2), (13/8), (7/4)]
      # @param ratios
      # @param segments
      # @param left_range
      # @param right_range
      #
      def convolved_proportional(*ratios, segments: 2, left_range: 0, right_range: 0)
        ConvolvedProportional.new(ratios: ratios, segments:, left_range:, right_range:)
      end

      # @return [Tonal::Scale::Cps] the combination product set
      # @example
      #   Tonal::Scale.cps
      #   => [(35/32), (5/4), (21/16), (3/2), (7/4), (15/8)]
      # @param set a comma delimited list of [Numeric] elements used in the combination algorithm
      # @param take the [Integer] number of sub-elements chosen
      #
      def cps(*set, take: nil)
        Cps.new(set:, take:)
      end

      # @return [Tonal::Scale::Edo] the equally divided of the octave scale for the given modulo
      # @example
      #   Tonal::Scale.edo(7)
      #   => [(1/1), (4972377122365053/4503599627370496), (2744974719417411/2251799813685248), (3030697803008479/2251799813685248), (3346161663415923/2251799813685248), (7388924007269683/4503599627370496), (2039508378439785/1125899906842624)]
      # @param modulo [Integer] the modulus for the scale
      #
      def edo(modulo=12)
        Edo.new(modulo: modulo)
      end

      # @return [Tonal::Scale::Harmonic] the harmonic sequence starting at fundamental
      #
      # @example
      #   Tonal::Scale.harmonic
      #   => [(1/1), (9/8), (5/4), (11/8), (3/2), (13/8), (7/4), (15/8)]
      # @param range [Range] range of the sequence
      #
      def harmonic(indices: (8..16))
       Harmonic.new(indices:)
      end

      # @return [Tonal::Scale::IntraProportional]
      # @example
      #   Tonal::Scale.intra_proportional(3/2r, 7/4r)
      #   => [(3/2), (13/8), (7/4)]
      # @param ratios
      # @param segments
      # @param left_range
      # @param right_range
      #
      def intra_proportional(*ratios, segments: 2, left_range: 0, right_range: 0)
        IntraProportional.new(ratios: ratios, segments:, left_range:, right_range:)
      end

      # @return [Tonal::Scale::Linear] a scale constructed from a superposed generator
      # @example
      #   Tonal::Scale.linear => [(1/1), (2187/2048), (9/8), (19683/16384), (81/64), (177147/131072), (729/512), (3/2), (6561/4096), (27/16), (59049/32768), (243/128)]
      # @param ratio [Tonal::Ratio, Numeric]
      # @param upto [Numeric]
      # @param limit [Numeric]
      # @param equave [Tonal::Ratio, Numeric]
      # @param threshold [Tonal::Cents, Numeric]
      # @param schizma [Boolean]
      # @param by_threshold [Boolean]
      #
      def linear(generator=3/2r, upto: 12, limit: 400, equave: 2/1r, threshold: Tonal::Comma.ditonic.to_cents, schizma: false, by_threshold: true)
        Linear.new(generator: generator, upto:, limit:, equave:, threshold:, schizma:, by_threshold:)
      end

      # @return [Tonal::Scale::Recurrence] a scale derived using a recursive series algorithm
      # @example
      #   Tonal::Scale.recurrence(upto: 16, seeds: [37, 50, 67, 91], indices: [-4, -3], coeff: [2, 1])
      #   => [(1027/1024), (67/64), (559/512), (37/32), (153/128), (2539/2048), (167/128), (1389/1024), (91/64), (189/128), (25/16), (415/256), (3443/2048), (225/128), (937/512), (31/16)]
      # @param upto [Integer] length of the iteration
      # @param seeds [Array] of [Integer] initiators of scale
      # @param indices [Array] of [Integer] indices used in recursion
      # @param coeff [Array] of [Integer] factors used in recursion
      #
      def recurrence(upto: 15, seeds: [0, 1], indices: [-1, -2], coeff: [1, 1], start_at: 0)
        Recurrence.new(upto:, seeds:, indices:, coeff:, start_at:)
      end

      # TODO: Document
      # @example
      #   Tonal::Scale.polyharmonic
      #   => [(1/1), (9/8), (5/4), (11/8), (3/2), (13/8), (7/4), (15/8)]
      #
      def polyharmonic(indices: (8..16), fundamentals: [1/1r])
        Polyharmonic.new(indices:, fundamentals:)
      end

      # @return [Tonal::Scale::Proportional]
      # @example
      #   Tonal::Scale.proportional([3/2r, 7/4r])
      #   => [(1/1), (5/4), (3/2), (7/4)]
      # @param ratios list of pairs of ratios over which proportionality is calculated
      # @param left_range
      # @param right_range
      #
      def proportional(*ratios, left_range: 1, right_range: 1)
        Proportional.new(ratios: [ratios], left_range:, right_range:)
      end

      # TODO Document
      # @example
      #   Tonal::Scale.superparticular
      #   => [(1/1), (13/12), (12/11), (11/10), (10/9), (9/8), (8/7), (7/6), (6/5), (5/4), (4/3), (3/2)]
      #
      def superparticular(start: 1, number: 12, limit: Tonal::ReducedRatio.identity)
        Superparticular.new(start:, number:, limit:)
      end

      # TODO Document
      #
      def exploded_superparticular(basis: 5/4r)
        pds = basis.prime_divisions
        nums, dens = pds.first, pds.last
        prods = nums.product(dens)
        
      end

      # TODO Document
      # @example
      #   Tonal::Scale.superpartient
      #   => [(1/1), (13/11), (6/5), (11/9), (5/4), (9/7), (4/3), (7/5), (3/2), (5/3)]
      #
      def superpartient(start: 1, number: 12, part: 2, limit: Tonal::Ratio.new(1/1r), exclusively: true)
        Superpartient.new(start:, number:, part:, limit:, exclusively:)
      end
    end
  end
end
