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
      #   => [1/1, 9/8, 5/4, 11/8, 3/2, 13/8, 7/4, 15/8]
      # @param indices [Range] of the sequence
      # @param factor [Integer] constant multiplied on the indices
      # @param offset [Integer] constant term added to the products
      # @param nexus [Integer] numerical constant
      # @param identity [Symbol] determine if sequence is harmonic (:otonal) or sub-harmonic (:utonal)
      #
      def afs(indices: (8..16), factor: 1, offset: 0, nexus: 1, identity: :otonal)
        Afs.new(indices:, factor:, offset:, nexus:, identity:)
      end

      # @return [Tonal::Scale::Arithmetic]
      # @example
      #   Tonal::Scale.arithmetic
      #   => [1/1, 9/8, 5/4, 11/8, 3/2, 7/4]
      # @param lower [Integer] the lower bound of series
      # @param upper [Integer] the upper bound of series
      # @param factor [Integer] the step size of series
      # @param nexus [Integer] the nexus of series
      # @param identity [Symbol] the identity of series, either :utonal or :otonal
      # @param include_equave [Boolean] whether to include the equave in the scale
      #
      def arithmetic(lower: 1, upper: 12, factor: 1, nexus: 1, identity: :otonal, include_equave: true)
        Arithmetic.new(lower:, upper:, factor:, nexus:, identity:, include_equave:)
      end

      # @return [Tonal::Scale::Asymptotic]
      # @example
      #   Tonal::Scale.asymptotic
      #   => [1/1, 13/12, 12/11, 11/10, 10/9, 9/8, 8/7, 7/6, 6/5, 5/4, 4/3, 3/2]
      # @param start [Integer] starting index of the scale
      # @param number [Integer] number of elements in the scale
      # @param limit [Tonal::Ratio, Numeric] the limiting ratio of the scale
      #
      def asymptotic(start: 1, number: 12, limit: Tonal::ReducedRatio.identity)
        Asymptotic.new(start:, number:, limit:)
      end

      def branching(segments: [[1/1r, 28/27r, 16/15r, 4/3r]], starting_nodes: [1/1r, 3/2r])
        Branching.new(segments:, starting_nodes:)
      end

      # TODO: Document
      # @return [Tonal::Scale::Composite]
      # @example
      #   Tonal::Scale.composite([1/1r, 3/2r, 5/4r, 7/4r], [1/1r, 5/4r])
      #   => [1/1, 35/32, 5/4, 3/2, 25/16, 7/4, 15/8]
      #
      def composite(ratios, placements)
        Composite.new(ratios, *placements)
      end

      # @return [Tonal::Scale::ConvolvedProportional]
      # @example
      #   Tonal::Scale.convolved_proportional(3/2r, 7/4r)
      #   => [3/2, 13/8, 7/4]
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
      #   => [35/32, 5/4, 21/16, 3/2, 7/4, 15/8]
      # @param set a comma delimited list of [Numeric] elements used in the combination algorithm
      # @param take the [Integer] number of sub-elements chosen
      #
      def cps(*set, take: nil)
        Cps.new(set:, take:)
      end

      # @return [Tonal::Scale::Diamond] a tonality diamond scale for the given set of odd integers
      # @example
      #   Tonal::Scale.diamond(1, 3, 5, 7)
      #   => [1/1, 8/7, 7/6, 6/5, 5/4, 4/3, 7/5, 10/7, 3/2, 8/5, 5/3, 12/7, 7/4]
      # @param set [Array<Integer>] the set of odd integers used to build the diamond
      #
      def diamond(*set)
        Diamond.new(set:)
      end

      # @return [Tonal::Scale::Edo] the equally divided of the octave scale for the given modulo
      # @example
      #   Tonal::Scale.edo(7)
      #   => [1/1, 1.1, 1.22, 1.35, 1.49, 1.64, 1.81]
      # @param modulo [Integer] the modulus for the scale
      #
      def edo(modulo=12)
        Edo.new(modulo: modulo)
      end

      # @return [Tonal::Scale::Harmonic] the harmonic sequence starting at fundamental
      # @example
      #   Tonal::Scale.harmonic
      #   => [1/1, 9/8, 5/4, 11/8, 3/2, 13/8, 7/4, 15/8]
      # @param indices [Range] range of the sequence
      # @param nexus [Integer] numerical constant
      #
      def harmonic(indices: (8..16), nexus: 1)
       Harmonic.new(indices:, nexus:)
      end

      # @return [Tonal::Scale::IntraProportional]
      # @example
      #   Tonal::Scale.intra_proportional(3/2r, 7/4r)
      #   => [3/2, 13/8, 7/4]
      # @param ratios
      # @param segments
      # @param left_range
      # @param right_range
      #
      def intra_proportional(*ratios, segments: 2, left_range: 0, right_range: 0)
        IntraProportional.new(ratios: ratios, segments:, left_range:, right_range:)
      end

      # @return [Tonal::Scale::Linear] a scale constructed by stacking a generator interval
      # @example Uncentered (1/1 at one end of the generator chain)
      #   Tonal::Scale.linear => [1/1, 2187/2048, 9/8, 19683/16384, 81/64, 177147/131072, 729/512, 3/2, 6561/4096, 27/16, 59049/32768, 243/128]
      # @example Centered (1/1 in the middle of the generator chain, disjunction maximally distant from 1/1)
      #   Tonal::Scale.linear(centered: true) => [1/1, 256/243, 9/8, 32/27, 81/64, 4/3, 1024/729, 3/2, 128/81, 27/16, 16/9, 243/128]
      # @param generator [Tonal::Ratio, Numeric] the interval stacked to build the scale, default 3/2
      # @param upto [Integer] number of tones to generate (used when by_threshold is false)
      # @param limit [Integer] maximum number of iterations when searching by threshold
      # @param equave [Tonal::Ratio, Numeric] the interval of equivalence, default 2/1
      # @param threshold [Tonal::Cents, Numeric] proximity to equave at which generation stops (used when by_threshold is true)
      # @param schizma [Boolean] whether to include the schismatic closing tone when by_threshold is true
      # @param by_threshold [Boolean] whether to stop generation by threshold proximity rather than a fixed count
      # @param centered [Boolean] when true, 1/1 is placed in the middle of the generator chain so the disjunction falls maximally far from it
      #
      def linear(generator=3/2r, upto: 12, limit: 400, equave: Tonal::Scale::DEFAULT_EQUAVE, threshold: Tonal::Comma.ditonic.to_cents, schizma: false, by_threshold: true, centered: false)
        Linear.new(generator: generator, upto:, limit:, equave:, threshold:, schizma:, by_threshold:, centered:)
      end

      # @return [Tonal::Scale::Subharmonic] the sub-harmonic sequence starting at fundamental
      # @example
      #   Tonal::Scale.subharmonic
      #   => [1/1, 16/15, 8/7, 16/13, 4/3, 16/11, 8/5, 16/9]
      # @param indices [Range] range of the sequence
      # @param nexus [Integer] numerical constant
      #
      def subharmonic(indices: (8..16), nexus: 1)
        Subharmonic.new(indices:, nexus:)
      end

      # @return [Tonal::Scale::Recurrence] a scale derived using a recursive series algorithm
      # @example
      #   Tonal::Scale.recurrence(upto: 16, seeds: [37, 50, 67, 91], indices: [-4, -3], coeff: [2, 1])
      #   => [1027/1024, 67/64, 559/512, 37/32, 153/128, 2539/2048, 167/128, 1389/1024, 91/64, 189/128, 25/16, 415/256, 3443/2048, 225/128, 937/512, 31/16]
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
      #   => [1/1, 9/8, 5/4, 11/8, 3/2, 13/8, 7/4, 15/8]
      #
      def polyharmonic(indices: (8..16), fundamentals: [1/1r])
        Polyharmonic.new(indices:, fundamentals:)
      end

      # @return [Tonal::Scale::Proportional]
      # @example
      #   Tonal::Scale.proportional(3/2r, 7/4r)
      #   => [1/1, 5/4, 3/2, 7/4]
      # @param ratios list of pairs of ratios over which proportionality is calculated
      # @param left_range
      # @param right_range
      #
      def proportional(*ratios, left_range: 1, right_range: 1)
        Proportional.new(ratios: [ratios], left_range:, right_range:)
      end

      # @return [Tonal::Scale::Superparticular]
      # @example
      #   Tonal::Scale.superparticular
      #   => [1/1, 13/12, 12/11, 11/10, 10/9, 9/8, 8/7, 7/6, 6/5, 5/4, 4/3, 3/2]
      # @param start [Integer] starting index of the scale
      # @param number [Integer] number of elements in the scale
      #
      def superparticular(start: 1, number: 12)
        Superparticular.new(start:, number:)
      end

      # @return [Tonal::Scale] a scale derived by expanding a superparticular ratio via its prime divisions
      #
      # @example
      #   Tonal::Scale.exploded_superparticular(basis: 5/4r)
      #
      # @param basis [Rational] the superparticular ratio to explode into prime-divisional components
      #
      def exploded_superparticular(basis: 5/4r)
        pds = basis.prime_divisions
        nums, dens = pds.first, pds.last
        prods = nums.product(dens)

      end

      # @return [Tonal::Scale::Superpartient] a scale of superpartient ratios of the form n/(n-part)
      #
      # @example
      #   Tonal::Scale.superpartient
      #   => [1/1, 13/11, 6/5, 11/9, 5/4, 9/7, 4/3, 7/5, 3/2, 5/3]
      #
      # @param start [Integer] starting index of the series
      # @param number [Integer] number of ratios to generate
      # @param part [Integer] the difference between numerator and denominator (n vs n-part)
      # @param limit [Tonal::Ratio] upper bound ratio; ratios above this are excluded
      # @param exclusively [Boolean] whether to exclude ratios not strictly of the superpartient form
      #
      def superpartient(start: 1, number: 12, part: 2, limit: Tonal::Ratio.new(1/1r), exclusively: true)
        Superpartient.new(start:, number:, part:, limit:, exclusively:)
      end
    end
  end
end
