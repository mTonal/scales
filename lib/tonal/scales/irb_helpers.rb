module Tonal
  class Scale
    module IRBHelpers
      # @return [Tonal::Scale]
      #
      # @param [Array<Numeric, Tonal::Ratio, Tonal::ReducedRatio, Range>] ratios
      #
      # @example
      #   s(1/1r, 9/8r, 5/4r, 4/3r, 3/2r, 5/3r, 18/8r)
      #   => [(1/1), (9/8), (5/4), (4/3), (3/2), (5/3)]
      #
      # @example
      #   s.proportional(3/2r, 7/4r) => [(1/1), (5/4), (3/2), (7/4)]
      #
      # @example
      #   s.from_scalarchive("wilson7")
      #   => [(1/1), (28/27), (16/15), (10/9), (9/8), (7/6), (6/5), (5/4), (35/27), (4/3), (27/20), (45/32), (35/24), (3/2), (14/9), (8/5), (5/3), (27/16), (7/4), (9/5), (15/8), (35/18)]
      #
      def s(*ratios)
        ratios.empty? ? Tonal::Scale : Tonal::Scale.new(*ratios)
      end

      # @return [Tonal::Sequence]
      #
      # @param [Array<Numeric, Tonal::Ratio, Tonal::ReducedRatio, Range>] ratios
      #
      # @example
      #  seq(1/1r, 9/8r, 5/4r) => [(1/1), (9/8), (5/4)]
      #
      # @example
      #   seq.subharmonic => [(1/8), (1/9), (1/10), (1/11), (1/12), (1/13), (1/14), (1/15), (1/16)]
      #
      def seq(*ratios)
        ratios.empty? ? Tonal::Sequence : Tonal::Sequence.new(*ratios)
      end
      alias :seg :seq
    end

    # @note
    #   Intended for activation from +~/.irbrc+, by placing: +ENV["MTONAL_IRB_HELPERS" ] = "1"+, in the file
    #
    #   Invoking this command from the IRB will add the helper method: +s+ in +main+.
    #   This methods represents {Tonal::Scale}
    #
    # @see Tonal::Scale, Tonal::Scale::IRBHelpers
    #
    def self.include_irb_helpers
      Object.include(IRBHelpers)
    end
  end
end