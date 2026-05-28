class Tonal::Sequence::Subharmonic < Tonal::Sequence::Afs
  def initialize(indices: (8..16), nexus: 1)
    super(indices:, nexus:, identity: :utonal)
  end
end
