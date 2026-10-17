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

  describe "#table_of_pitch_bends" do
    it "returns a Terminal::Table with a row for each note" do
      table = described_class.new(scale).table_of_pitch_bends
      expect(table).to be_a Terminal::Table
      expect(table.rows.count).to eq scale.count
    end

    it "names the 12-TET notes, with middle C as C4" do
      expect(described_class.new(scale).table_of_pitch_bends.rows.map{|row| row.cells[1].value}).to eq %w[C4 D4 E4 F#4 G4 G#4 A#4 B4]
    end
  end
end