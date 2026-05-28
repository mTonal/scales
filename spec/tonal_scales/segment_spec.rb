require "spec_helper"

RSpec.describe Tonal::Sequence::Segment do
  describe "#inspect" do
    it "returns the tones" do
      segment = described_class.new(1/1r, 9/8r, 5/4r)
      expect(segment.inspect).to eq [1/1r, 9/8r, 5/4r]
    end
  end

  describe "#notes" do
    it "returns the tones" do
      segment = described_class.new(1/1r, 9/8r, 5/4r)
      expect(segment.notes).to eq [1/1r, 9/8r, 5/4r]
    end
  end

  describe "#to_a" do
    it "returns the tones as array" do
      segment = described_class.new(1/1r, 9/8r, 5/4r)
      expect(segment.to_a).to eq [1/1r, 9/8r, 5/4r]
    end
  end
end
