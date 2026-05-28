class Tonal::Sequence::Harmonic < Tonal::Sequence::Afs
  def initialize(indices: (8..16), nexus: 1)
    super(indices:, nexus:, identity: :otonal)
  end
end
