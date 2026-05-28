class Tonal::Sequence
  module Constructors
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # TODO Document
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

      # TODO Document
      #
      def cps(set: [], take: 2)
        Cps.new(set:, take:)
      end

      # TODO Document
      #
      def edo(modulo:)
        Edo.new(modulo:)
      end

      # TODO Document
      #
      def harmonic(indices: (8..16), nexus: 1)
        Harmonic.new(indices:, nexus:)
      end

      # TODO Document
      #
      def intra_proportional(ratios: [], subdivision: 2, left_range: subdivision-1, right_range: subdivision-1)
        IntraProportional.new(ratios:, subdivision:, left_range:, right_range:)
      end

      # TODO Document
      #
      def linear(generator: 3/2r, upto: 12, limit: 400, equave: Tonal::Scale::DEFAULT_EQUAVE, threshold: Tonal::Comma.ditonic.to_cents, schizma: false, by_threshold: false)
        Linear.new(generator:, upto:, limit:, equave:, threshold:, schizma:, by_threshold:)
      end

      # TODO Document
      #
      def recurrence(upto: 15, seeds: [0, 1], indices: [-1, -2], coeff: [1, 1])
        Recurrence.new(upto: upto, seeds: seeds, indices: indices, coeff: coeff)
      end

      # TODO Document
      #
      def polyharmonic(indices: (8..16), fundamentals: [1/1r])
        Polyharmonic.new(indices:, fundamentals:)
      end

      # TODO Document
      #
      def proportional(ratios: [], left_range: 1, right_range: 1)
        Proportional.new(ratios:, left_range: left_range, right_range: right_range)
      end

      # TODO Document
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

      # TODO Document
      def branching(segments: [[1/1r, 28/27r, 16/15r, 4/3r]], starting_nodes: [1/1r, 3/2r])
        Branching.new(segments:, starting_nodes:)
      end
    end
  end
end
