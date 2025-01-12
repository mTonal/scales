class Tonal::Scale::Afs < Tonal::Scale
  def init_sequence
    Tonal::Sequence::Afs.new(indices: @args[:indices], factor: @args[:factor], offset: @args[:offset], nexus: @args[:nexus], identity: @args[:identity])
  end

  def name
    "AFS, indices: #{@args[:indices]}, factor: #{@args[:factor]}, offset: #{@args[:offset]}, nexus: #{@args[:nexus]}, identity: #{@args[:identity]}"
  end

  def description
    "Arithmetic Frequency Sequence: indices: #{@args[:indices]}, factor: #{@args[:factor]}, offset: #{@args[:offset]}, nexus: #{@args[:nexus]}, identity: #{@args[:identity]}"
  end
end
