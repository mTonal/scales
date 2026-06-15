class Tonal::Sequence
  module Constructors
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # @return [Tonal::Sequence::Afs] an arithmetic-factor sequence
      #
      # @example
      #   Tonal::Sequence.afs => [1/1, 2/1, 3/1, 4/1, 5/1, 6/1, 7/1, 8/1, 9/1, 10/1, 11/1, 12/1, 13/1, 14/1, 15/1, 16/1]
      #
      # @param indices [Range] range of indices for the sequence
      # @param factor [Integer] constant multiplied on each index
      # @param offset [Integer] constant added to each product
      # @param nexus [Integer] the denominator constant
      #
      def afs(indices: (1..16), factor: 1, offset: 0, nexus: 1)
        Afs.new(indices:, factor:, offset:, nexus:)
      end

      # @return [Tonal::Sequence::Arithmetic]
      # @example
      #   Tonal::Sequence.arithmetic => [1/1, 2/1, 3/1, 4/1, 5/1, 6/1, 7/1, 8/1, 9/1, 10/1, 11/1, 12/1]
      # @param lower the lower bound of series
      # @param upper the upper bound of series
      # @param factor the step size of series
      # @param nexus the nexus of series
      # @param identity the identity of series, either :utonal or :otonal
      #
      def arithmetic(lower: 1, upper: 12, factor: 1, nexus: 1, identity: :otonal)
        Arithmetic.new(lower:, upper:, factor:, nexus:, identity:)
      end

      # @return [Tonal::Sequence::Asymptotic]
      # @example
      #   Tonal::Sequence.asymptotic => [2/1, 3/2, 4/3, 5/4, 6/5, 7/6, 8/7, 9/8, 10/9, 11/10, 12/11, 13/12]
      # @param start the starting point of series
      # @param number the number of ratios generated
      # @param limit the limiting ratio
      #
      def asymptotic(start: 1, number: 12, limit: 1/1r)
        Asymptotic.new(start:, number:, limit:)
      end

      # TODO Implement
      #
      def composite

      end

      # @return [Tonal::Sequence::Cps] a combination product set sequence
      #
      # @example
      #   Tonal::Sequence.cps(set: [1,3,5,7], take: 2) => [35/32, 5/4, 21/16, 3/2, 7/4, 15/8]
      #
      # @param set [Array<Integer>] the set of factors to combine
      # @param take [Integer] the number of factors chosen per combination
      #
      def cps(set: [], take: Tonal::Scale::Cps.default_take(set.count))
        Cps.new(set:, take:)
      end

      # @return [Tonal::Sequence::Diamond] a tonality diamond sequence for the given set of odd integers
      #
      # @example
      #   Tonal::Sequence.diamond(set: [1, 3, 5, 7]) => [1/1, 8/7, 7/6, 6/5, 5/4, 4/3, 7/5, 10/7, 3/2, 8/5, 5/3, 12/7, 7/4]
      #
      # @param set [Array<Integer>] the odd integers used to build the diamond
      #
      def diamond(set: [1, 3, 5, 7])
        Diamond.new(set:)
      end

      # @return [Tonal::Sequence::Edo] an equal division of the octave sequence
      #
      # @example
      #   Tonal::Sequence.edo(modulo: 12) => [1/1, 1.06, 1.12, 1.19, 1.26, 1.33, 1.41, 1.5, 1.59, 1.68, 1.78, 1.89]
      #
      # @param modulo [Integer] the number of equal divisions of the octave
      #
      def edo(modulo:)
        Edo.new(modulo:)
      end

      # @return [Tonal::Sequence::Harmonic] a harmonic series sequence
      #
      # @example
      #   Tonal::Sequence.harmonic => [1/1, 9/8, 5/4, 11/8, 3/2, 13/8, 7/4, 15/8]
      #
      # @param indices [Range] range of harmonics to include
      # @param nexus [Integer] the common denominator (fundamental)
      #
      def harmonic(indices: (8..16), nexus: 1)
        Harmonic.new(indices:, nexus:)
      end

      # @return [Tonal::Sequence::IntraProportional] ratios proportionally interpolated within each pair of given ratios
      #
      # @example
      #   Tonal::Sequence.intra_proportional(ratios: [3/2r, 7/4r]) => [3/2, 13/8, 7/4]
      #
      # @param ratios [Array<Rational>] the bounding ratios
      # @param subdivision [Integer] number of subdivisions between each pair
      # @param left_range [Integer] extra ratios added to the left of each interval
      # @param right_range [Integer] extra ratios added to the right of each interval
      #
      def intra_proportional(ratios: [], subdivision: 2, left_range: subdivision-1, right_range: subdivision-1)
        IntraProportional.new(ratios:, subdivision:, left_range:, right_range:)
      end

      # @return [Tonal::Sequence::Linear] a sequence derived by stacking a generator interval
      #
      # @example
      #   Tonal::Sequence.linear => [1/1, 2187/2048, 9/8, 81/64, 729/512, 3/2, 27/16, 243/128, ...]
      #
      # @param generator [Rational] the interval stacked to generate the sequence, default 3/2
      # @param upto [Integer] maximum number of tones to generate
      # @param limit [Integer] prime limit for including tones
      # @param equave [Rational] the interval of equivalence, default 2/1
      # @param threshold [Tonal::Cents] minimum step size below which tones are collapsed
      # @param schizma [Boolean] whether to include schismatic tones
      # @param by_threshold [Boolean] whether to filter by the comma threshold
      #
      def linear(generator: 3/2r, upto: 12, limit: 400, equave: Tonal::Scale::DEFAULT_EQUAVE, threshold: Tonal::Comma.ditonic.to_cents, schizma: false, by_threshold: false)
        Linear.new(generator:, upto:, limit:, equave:, threshold:, schizma:, by_threshold:)
      end

      # @return [Tonal::Sequence::Recurrence] a sequence derived from a recurrence relation
      #
      # @example
      #   Tonal::Sequence.recurrence => [0/1, 1/1, 1/1, 2/1, 3/1, 5/1, 8/1, 13/1, 21/1, ...]
      #
      # @param upto [Integer] number of terms to generate
      # @param seeds [Array<Integer>] initial values of the sequence
      # @param indices [Array<Integer>] back-reference indices used in the recurrence
      # @param coeff [Array<Integer>] coefficients applied to each back-reference term
      #
      def recurrence(upto: 15, seeds: [0, 1], indices: [-1, -2], coeff: [1, 1])
        Recurrence.new(upto: upto, seeds: seeds, indices: indices, coeff: coeff)
      end

      # @return [Tonal::Sequence::Polyharmonic] a harmonic series built from multiple fundamentals
      #
      # @example
      #   Tonal::Sequence.polyharmonic => [1/1, 9/8, 5/4, 11/8, 3/2, 13/8, 7/4, 15/8]
      #
      # @param indices [Range] range of harmonics to include from each fundamental
      # @param fundamentals [Array<Rational>] the fundamental pitches whose harmonic series are combined
      #
      def polyharmonic(indices: (8..16), fundamentals: [1/1r])
        Polyharmonic.new(indices:, fundamentals:)
      end

      # @return [Tonal::Sequence::Proportional] a sequence of proportionally derived ratios between given pairs
      #
      # @example
      #   Tonal::Sequence.proportional(ratios: [3/2r, 7/4r]) => [1/1, 5/4, 3/2, 7/4]
      #
      # @param ratios [Array<Rational>] pairs of ratios over which proportionality is calculated
      # @param left_range [Integer] number of proportional steps added to the left of each pair
      # @param right_range [Integer] number of proportional steps added to the right of each pair
      #
      def proportional(ratios: [], left_range: 1, right_range: 1)
        Proportional.new(ratios:, left_range: left_range, right_range: right_range)
      end

      # @return [Tonal::Sequence::Subharmonic] a subharmonic (undertone) series sequence
      #
      # @example
      #   Tonal::Sequence.subharmonic => [1/1, 16/15, 8/7, 16/13, 4/3, 16/11, 8/5, 16/9]
      #
      # @param indices [Range] range of subharmonics to include
      # @param nexus [Integer] the common numerator (fundamental)
      #
      def subharmonic(indices: (8..16), nexus: 1)
        Subharmonic.new(indices:, nexus:)
      end

      # @return [Tonal::Sequence::Superparticular]
      # @example
      #   Tonal::Sequence.superparticular => [2/1, 3/2, 4/3, 5/4, 6/5, 7/6, 8/7, 9/8, 10/9, 11/10, 12/11, 13/12]
      # @param start the starting point of series
      # @param number the number of ratios generated
      #
      def superparticular(start: 1, number: 12)
        Superparticular.new(start:, number:)
      end

      # TODO: Document
      #
      def superpartient(start: 1, number: 12, part: 2, limit: Tonal::Ratio.new(1/1r), exclusively: true)
        Superpartient.new(start:, number:, part:, limit:, exclusively:)
      end

      # @return [Tonal::Sequence::Branching] a sequence grown by branching from starting nodes through scale segments
      #
      # @example
      #   Tonal::Sequence.branching => [1/1, 28/27, 16/15, 4/3, 3/2, 112/81, 64/45, 8/3]
      #
      # @param segments [Array<Array<Rational>>] the interval patterns used to grow branches
      # @param starting_nodes [Array<Rational>] the initial pitches from which branches grow
      #
      def branching(segments: [[1/1r, 28/27r, 16/15r, 4/3r]], starting_nodes: [1/1r, 3/2r])
        Branching.new(segments:, starting_nodes:)
      end
    end
  end
end
