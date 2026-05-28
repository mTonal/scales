class Tonal::Sequence
  class Segment
    attr_reader :notes

    def initialize(*notes)
      @notes = notes
    end
    alias :to_a :notes

    def inspect
      @notes
    end
  end
end
