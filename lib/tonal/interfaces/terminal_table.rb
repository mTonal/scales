module Tonal
  module IO
    class TerminalTable
      extend Forwardable
      def_delegators :@scale, :to_cents, :count, :length, :ratios, :[], :modes, :steps, :to_cents

      def initialize(scale)
        @scale = scale
      end

      # TODO: Document
      #
      def factor_approximations_to(ratio, factor:, range: (1..10))
        Terminal::Table.new(headings: ["#{factor}*i", "(#{factor}*i)/x ~ #{ratio}", "Cents difference to #{ratio}" ], rows: [].tap do |rows|
          range.each do |i|
            rows << [(i * factor), (factor * i).approximate_to(ratio), (factor * i).approximate_to_diff(ratio).to_f]
          end
        end)
      end

      # TODO: Document
      #
      def approximations_to(ratio, factor:, range: (1..10))
        Terminal::Table.new(headings: ["#{factor}*i", "(#{factor}*i)/x ~ #{ratio}", "Cents difference to #{ratio}" ], rows: [].tap do |rows|
          range.each do |i|
            rows << [((2 ** i) * factor), ((2 ** i) * factor).approximate_to(ratio), ((2 ** i) * factor).approximate_to_diff(ratio).to_f]
          end
        end)
      end

      # @return Terminal::Table of cent differences to ratio within given tolerance for a range of moduli
      # TODO Is this needed?
      def cent_diffs(ratio, moduli: (0..53), tolerance: 5)
        moduli.each do |m|
          v = m.cents_delta_for(ratio)
          puts "#{m}: #{v.to_f}" if v.abs.to_f <= tolerance
        end
      end

      # @return [Terminal::Table] text table of intervals at step
      # @example
      #   puts Analysis.new(Scale.from_scalarchive("wilson7")).table_of_intervals_at_step(1)
      #   => +-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+
      #      | 28/27 | 36/35 | 25/24 | 81/80 | 28/27 | 36/35 | 25/24 | 28/27 | 36/35 | 81/80 | 25/24 | 28/27 | 36/35 | 28/27 | 36/35 | 25/24 | 81/80 | 28/27 | 36/35 | 25/24 | 28/27 | 36/35 |
      #      +-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+
      #
      def table_of_intervals_at_step(step)
        Terminal::Table.new(rows: [all_intervals_by_step(step).map(&:to_r)])
      end

      # @return [Terminal::Table] text table of all intervals for all steps of scale
      # @example
      #   puts Analysis.new(Scale.harmonic).table_of_all_intervals_by_steps
      #   => +---+------+------+-------+-------+-------+-------+-------+-------+
      #      | 0 | 1/1  | 1/1  | 1/1   | 1/1   | 1/1   | 1/1   | 1/1   | 1/1   |
      #      | 1 | 9/8  | 10/9 | 11/10 | 12/11 | 13/12 | 14/13 | 15/14 | 16/15 |
      #      | 2 | 5/4  | 11/9 | 6/5   | 13/11 | 7/6   | 15/13 | 8/7   | 6/5   |
      #      | 3 | 11/8 | 4/3  | 13/10 | 14/11 | 5/4   | 16/13 | 9/7   | 4/3   |
      #      | 4 | 3/2  | 13/9 | 7/5   | 15/11 | 4/3   | 18/13 | 10/7  | 22/15 |
      #      | 5 | 13/8 | 14/9 | 3/2   | 16/11 | 3/2   | 20/13 | 11/7  | 8/5   |
      #      | 6 | 7/4  | 5/3  | 8/5   | 18/11 | 5/3   | 22/13 | 12/7  | 26/15 |
      #      | 7 | 15/8 | 16/9 | 9/5   | 20/11 | 11/6  | 24/13 | 13/7  | 28/15 |
      #      +---+------+------+-------+-------+-------+-------+-------+-------+
      #
      def table_of_all_intervals_by_steps
        Terminal::Table.new(rows: all_intervals_by_steps.each_with_index.map{|row,idx| [idx] + row.map(&:to_r)})
      end

      # @return [Terminal::Table] text table of intervals at step
      # @example
      #   puts Analysis.new(Scale.from_scalarchive("wilson7")).table_of_unique_intervals_at_step(1)
      #   => +-------+-------+-------+-------+
      #      | 81/80 | 36/35 | 28/27 | 25/24 |
      #      +-------+-------+-------+-------+
      # @param step between note pairs
      #
      def table_of_unique_intervals_at_step(step)
        Terminal::Table.new(rows: [unique_intervals_by_step(step).map(&:to_r).sort])
      end

      # @return [Terminal::Table] text table of unique intervals for all steps of scale
      # @example
      #   puts Analysis.new(Scale.harmonic).table_of_unique_intervals_by_step_distances
      #   => +---+--------------------------------------------------------------+
      #      | 0 | 1/1   |       |       |       |       |       |       |      |
      #      | 1 | 16/15 | 15/14 | 14/13 | 13/12 | 12/11 | 11/10 | 10/9  | 9/8  |
      #      | 2 | 8/7   | 15/13 | 7/6   | 13/11 | 6/5   | 11/9  | 5/4   |      |
      #      | 3 | 16/13 | 5/4   | 14/11 | 9/7   | 13/10 | 4/3   | 11/8  |      |
      #      | 4 | 4/3   | 15/11 | 18/13 | 7/5   | 10/7  | 13/9  | 22/15 | 3/2  |
      #      | 5 | 16/11 | 3/2   | 20/13 | 14/9  | 11/7  | 8/5   | 13/8  |      |
      #      | 6 | 8/5   | 18/11 | 5/3   | 22/13 | 12/7  | 26/15 | 7/4   |      |
      #      | 7 | 16/9  | 9/5   | 20/11 | 11/6  | 24/13 | 13/7  | 28/15 | 15/8 |
      #      +---+-------+-------+-------+-------+-------+-------+-------+------+
      #
      def table_of_unique_intervals_by_step_distances
        Terminal::Table.new(rows: unique_intervals_by_step_distances.each_with_index.map{|row,idx| [idx] + row.map(&:to_r)})
      end

      # @return [Terminal::Table] text table of scales
      # @example TODO
      # @params [constant] whether to output only constant structure scales
      #
      def table_of_expanded_scales(constant: true)
        bag = Scales.new
        (0..count).each do |n|
          intervals = unique_intervals_by_step(n)
          intervals.each do |i|
            interval = i.interval
            intervals.each do |j|
              bag << scale.expand(at: j.interval, by: interval, boundary: :upper)
              bag << scale.expand(at: j.interval, by: interval, boundary: :lower)
            end
          end
        end

        analysis = Analysis.new
        Terminal::Table.new(rows: [].tap do |rows|
          bag.scales.group_by(&:count).sort.each do |count, scale_set|
            scale_set.each do |s|
              analysis.scale = s
              rows << [count, analysis.constant_structure?, s.to_r].flatten if (constant && analysis.constant_structure?)
            end
          end
        end)
      end

      # TODO: Document
      #
      def table_of_sequence_between(lower, upper, mod, irreducibles: true)
        rows = lower.upto(upper).map{|n| [n.ratio.inspect, n.ratio.step(mod).inspect, n.ratio.cent_diff(n.ratio.step(mod).ratio).inspect, n.ratio.degree]}.uniq{|r| r[0].to_r}.sort_by{|r| r[0].to_r}
        rows = rows.reject{|r| r[0].numerator <= lower} if irreducibles
        Terminal::Table.new(headings: ["ratio", "step at mod", "cent diff with mod", "radial degree"], rows: rows)
      end

      # TODO: Document
      def table_of_mod_approximations(mod)
        rows = scale.ratios.map do |ratio|
          [ratio.inspect, ratio.step(mod).inspect, ratio.cent_diff(ratio.step(mod).ratio).inspect, ratio.degree]
        end
        Terminal::Table.new(headings: ["ratio", "step at mod", "cent diff with mod", "radial degree"], rows: rows)
      end

      # @return [Terminal::Table] text cross table. Notes of scale are on the margins.
      #   The middle are the intervels between the margin notes.
      # @example
      #   puts Analysis.new(Scale.harmonic).table =>
      #     +------+------+------+-------+-------+-------+-------+-------+-------+
      #     |      | 1/1  | 9/8  | 5/4   | 11/8  | 3/2   | 13/8  | 7/4   | 15/8  |
      #     | 1/1  | 1/1  | 16/9 | 8/5   | 16/11 | 4/3   | 16/13 | 8/7   | 16/15 |
      #     | 9/8  | 9/8  | 1/1  | 9/5   | 18/11 | 3/2   | 18/13 | 9/7   | 6/5   |
      #     | 5/4  | 5/4  | 10/9 | 1/1   | 20/11 | 5/3   | 20/13 | 10/7  | 4/3   |
      #     ...
      #
      def table
        rows = []
        rows << ([nil] + @scale.to_r)
        @scale.each do |n|
          rows << ([n.to_r] + [].tap{|combis| @scale.each{|m| combis << (n / m).to_r}})
        end
        Terminal::Table.new(rows: rows)
      end

      # @return [Terminal::Table] text table inventory of intervals of scale.
      #   The first colum is the interval, the last column is the difference,
      #   the middle columns are the prime vector exponents.
      # @example
      #   puts Analysis.new(Scale.harmonic).inventory =>
      #     +-------+----+----+----+----+----+----+----+
      #     | 16/15 |  4 | -1 | -1 |  0 |  0 |  0 |  1 |
      #     | 15/14 | -1 |  1 |  1 | -1 |  0 |  0 |  1 |
      #     | 14/13 |  1 |  0 |  0 |  1 |  0 | -1 |  1 |
      #     ...
      #     | 15/13 |  0 |  1 |  1 |  0 |  0 | -1 |  2 |
      #     |  7/6  | -1 | -1 |  0 |  1 |  0 |  0 |  1 |
      #     | 13/11 |  0 |  0 |  0 |  0 | -1 |  1 |  2 |
      #     ...
      #
      def inventory
        unless @inventory_table
          occurs = Hash.new(0)
          set = SortedSet.new.tap do |set|
            scale.to_a.combination(2).to_a.each do |first, second|
              i1 = Tonal::Interval.new(first, second).interval
              i2 = Tonal::Interval.new(second, first).interval
              set << i1
              set << i2
              occurs[i1.to_r] += 1
              occurs[i2.to_r] += 1
            end
          end
          max = set.map(&:max_prime).max
          max_pad = Prime.each(max).count
          @inventory_table ||= Terminal::Table.new(rows: [].tap do |rows|
                                                           set.each do |interval|
                                                             rows << (([interval.to_r, interval.prime_vector.to_a].flatten.rpad(max_pad+1, 0) << interval.difference) << occurs[interval.to_r])
                                                           end
                                                         end)
          @inventory_table.headings = [1, 2, 3, 4]
          @inventory_table.align_column(0, :center)
          1.upto(max_pad+2).each do |i|
            @inventory_table.align_column(i, :right)
          end
        end
        @inventory_table
      end

      # @return Terminal::Table of equal division approximations of scale for given list of modulos
      # @params modulos a list of integers
      # @example
      #
      def table_of_edo_approximations_for_modulos(*modulos)
        rows = [].tap do |rs|
          modulos.each do |m|
            edo_scale = Scale.tet(m)
            edo_steps = scale.steps(mod: m)
            row = [].tap do |r|
              (0..edo_steps.count-1).each do |i|
                r << (scale[i].first.cents - edo_scale[edo_steps[i].step].first.cents).to_f.round(2)
              end
            end
            mean = row.sum(0.0) / row.size
            sum = row.sum(0.0) { |element| (element - mean) ** 2 }
            variance = sum / (row.size - 1)
            standard_deviation = Math.sqrt(variance)
            rs << ([m, mean.round(2), standard_deviation.round(2), sum.round(2), variance.round(2)] + row)
          end
        end
        Terminal::Table.new(headings: [[{value: "ED approximations of #{scale.name}", colspan: 5}, *(scale.to_r)],["Mod", "Mean(¢)", "SD(¢)", "Sum", "Var", {value: "¢ diff", colspan: count}]], rows: rows)
      end
    end
  end
end
