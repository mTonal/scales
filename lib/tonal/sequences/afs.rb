class Tonal::Sequence::Afs < Tonal::Sequence
  def initialize(indices: (8..16), factor: 1, offset: 0, nexus: 1, identity: :otonal)
    func = identity == :utonal ? ->(n){ [nexus, n * factor + offset] } : ->(n){ [n * factor + offset, nexus] }
    @sequence = indices.map{|i| Rational(*func.(i))}
  end
end
