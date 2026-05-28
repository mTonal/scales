class Tonal::Sequence::Branching < Tonal::Sequence
  def initialize(segments: [[1/1r, 28/27r, 16/15r, 4/3r]], starting_nodes: [1/1r, 3/2r])
    @sequence = []
    segments.each do |segment|
      starting_nodes.each do |starting_node|
        segment.each do |note|
          @sequence << starting_node * note
        end
      end
    end
    @sequence += starting_nodes
  end
end
