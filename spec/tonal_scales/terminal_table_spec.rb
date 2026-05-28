require "spec_helper"

RSpec.describe Tonal::IO::TerminalTable do
  let(:scale) { Tonal::Scale.harmonic }

  describe "#table" do
    it "returns a Terminal::Table" do
      expect(described_class.new(scale).table).to be_a Terminal::Table
    end

    it "has a row for each note plus a header row" do
      table = described_class.new(scale).table
      expect(table.rows.count).to eq scale.count + 1
    end
  end
end