class Tonal::Scale::Cps < Tonal::Scale
  # Raised when a CPS has no factor-coherent ordering of its notes (only
  # possible for a disconnected #shared_factor_graph - a pathological set/take).
  NoFactorWalk = Class.new(StandardError)

  def init_sequence
    Tonal::Sequence::Cps.new(set: assigned_set, take: assigned_take)
  end

  def name
    "CPS, #{assigned_set}"
  end

  def description
    "Cross Product Set: #{prettified_set}, take: #{assigned_take} - #{self.labels.join(', ')}"
  end

  # @return [Tonal::Scale::ChordSet] the harmonies embedded in the CPS - an otonal
  #   chord for every (take - 1)-subset of factors the products can share, and a utonal
  #   chord for every (take + 1)-subset of the generating set. For the default hexany
  #   these are the eight triangular faces of the octahedron: four otonal, four utonal.
  #
  # @example
  #   Tonal::Scale.cps.chords.count => 8
  #
  def chords
    factors = assigned_set
    take = assigned_take
    indices = (0...factors.count).to_a

    otonal = indices.combination(take - 1).filter_map do |shared|
      voices = (indices - shared).map { |i| shared + [i] }
      next if voices.count < 2
      shared_labels = shared.map { |i| factors[i] }
      build_chord(factors, voices,
        name: "Otonal#{" +#{shared_labels.join(".")}" unless shared.empty?}",
        description: "Otonal chord on the #{voices.count} products of #{name}" \
          "#{" sharing factor(s) #{shared_labels.join(", ")}" unless shared.empty?}")
    end

    utonal = indices.combination(take + 1).filter_map do |group|
      voices = group.combination(take).to_a
      next if voices.count < 2
      group_labels = group.map { |i| factors[i] }
      build_chord(factors, voices,
        name: "Utonal #{group_labels.join(".")}",
        description: "Utonal chord on the #{voices.count} products of #{name} drawn from factors #{group_labels.join(", ")}")
    end

    Tonal::Scale::ChordSet.new(scale: self, chords: otonal + utonal)
  end

  # @return [Array<Array>] scale-degree-indexed: element +d+ is the generating
  #   factor tuple (a +take+-length subset of the generating set) whose
  #   octave-reduced product is note +d+ of the scale.
  #
  # @note When two distinct combinations octave-reduce to the same pitch (rare -
  #   e.g. a generating set containing both 1 and 2), the first combination
  #   encountered wins that degree.
  #
  # @example
  #   Tonal::Scale.cps.note_factors
  #   => [[5, 7], [1, 5], [3, 7], [1, 3], [1, 7], [3, 5]]
  #
  def note_factors
    Array.new(count).tap do |mapping|
      factor_combinations.each do |tuple|
        degree = degree_of(*tuple)
        mapping[degree] ||= tuple if degree
      end
    end
  end

  # @return [Hash{Integer => Array<[Integer, Array]>}] each scale degree mapped to
  #   the list of +[neighbour_degree, shared_factors]+ pairs for every other
  #   degree whose generating tuple shares at least one factor with it. This is
  #   the Johnson graph J(assigned_set.count, assigned_take): every node has the
  #   same valence, +assigned_take * (assigned_set.count - assigned_take)+.
  #
  # @example
  #   Tonal::Scale.cps.shared_factor_graph[0]
  #   => [[1, [5]], [2, [7]], [4, [7]], [5, [5]]]
  #
  def shared_factor_graph
    tuples = note_factors
    indices.each_with_object({}) do |degree, graph|
      graph[degree] = indices.filter_map do |other|
        next if other == degree
        shared = tuples[degree] & tuples[other]
        [other, shared] unless shared.empty?
      end
    end
  end

  # @return [Array<Integer>] a permutation of every scale degree in which each
  #   adjacent pair shares a generating factor - a Hamiltonian path over
  #   #shared_factor_graph (which always exists for a connected Johnson graph).
  #
  # @raise [NoFactorWalk] when no such ordering exists (disconnected graph).
  #
  # @param start [Integer] the scale degree to begin the walk from
  # @param closed [Boolean] when true, also require the last and first degrees
  #   to share a factor (a Hamiltonian cycle)
  #
  # @example
  #   Tonal::Scale.cps.factor_walk => [0, 1, 4, 2, 3, 5]
  #
  def factor_walk(start: 0, closed: false)
    adjacency = shared_factor_graph.transform_values { |pairs| pairs.map(&:first) }
    hamiltonian(adjacency, start, closed) ||
      raise(NoFactorWalk, "no factor-coherent ordering for #{name}")
  end

  private
  def assigned_set
    @set ||= @args[:set].empty? ? [1, 3, 5, 7] : @args[:set]
  end

  def assigned_take
    @take ||= (@args[:take] || self.class.default_take(assigned_set.count))
  end

  def prettified_set
    assigned_set.map{|input| input.kind_of?(Float) ? input.round(2) : input}
  end

  def self.default_take(count)
    count.even? ? count / 2 : (count - 1) / 2
  end

  # @return [Array<Array>] every generating factor tuple of the scale, in
  #   generating-set order (same order as Tonal::Sequence::Cps's products).
  #
  def factor_combinations
    @factor_combinations ||= assigned_set.combination(assigned_take).to_a
  end

  # @return [Tonal::ReducedRatio] the octave-reduced product of the given factors
  #
  def product_ratio(*factors)
    product = factors.inject(1, :*)
    Tonal::ReducedRatio.new(product.numerator, product.denominator)
  end

  # @return [Integer, nil] the scale degree the given factors' product lands on
  #
  def degree_of(*factors)
    find_index(product_ratio(*factors))
  end

  # Depth-first search with Warnsdorff ordering (visit the neighbour with the
  # fewest onward moves first). The graphs here are tiny - hexany 6 nodes,
  # dekany 10, eikosany 20 - so plain backtracking is more than fast enough.
  #
  # @param adjacency [Hash{Integer => Array<Integer>}]
  # @param start [Integer]
  # @param closed [Boolean] require the path to close back to +start+
  # @return [Array<Integer>, nil] a Hamiltonian path, or nil if none exists
  #
  def hamiltonian(adjacency, start, closed)
    size = adjacency.size
    visited = {start => true}
    path = [start]

    search = lambda do
      return true if path.size == size && (!closed || adjacency[path.last].include?(start))

      adjacency[path.last]
        .reject { |node| visited[node] }
        .sort_by { |node| adjacency[node].count { |onward| !visited[onward] } }
        .each do |node|
          visited[node] = true
          path << node
          return true if search.call
          path.pop
          visited.delete(node)
        end
      false
    end

    search.call ? path : nil
  end

  # @param factors [Array] the generating set
  # @param voices [Array<Array<Integer>>] each voice as the indices into `factors` whose product is the note
  #
  def build_chord(factors, voices, name:, description:)
    notes = voices.map do |voice|
      tuple = voice.map { |i| factors[i] }
      [product_ratio(*tuple), tuple]
    end.sort_by(&:first)

    ratios = notes.map(&:first)

    Tonal::Scale::Chord.new(
      ratios: ratios,
      steps: ratios.map { |ratio| find_index(ratio) },
      name: name,
      description: description,
      factors: notes.map { |(_, tuple)| tuple.map { |f| "(#{f})" }.join }.join(",")
    )
  end
end
