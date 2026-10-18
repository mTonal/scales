require "spec_helper"

RSpec.describe Tonal::Scale::Reporter do
  let(:scale) { Tonal::Scale.harmonic }

  describe "#cross_table" do
    it "returns a Terminal::Table" do
      expect(described_class.new(scale).cross_table).to be_a Terminal::Table
    end

    it "has a row for each note plus a header row" do
      table = described_class.new(scale).cross_table
      expect(table.rows.count).to eq scale.count + 1
    end
  end

  describe "#pitch_bends" do
    it "returns a Terminal::Table with a row for each note" do
      table = described_class.new(scale).pitch_bends
      expect(table).to be_a Terminal::Table
      expect(table.rows.count).to eq scale.count
    end

    it "names the 12-TET notes, with middle C as C4" do
      expect(described_class.new(scale).pitch_bends.rows.map{|row| row.cells[1].value}).to eq %w[C4 D4 E4 F#4 G4 G#4 A#4 B4]
    end
  end

  describe "#inventory" do
    let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r) }
    let(:table) { described_class.new(scale).inventory }

    it "has a row for each interval other than 1/1" do
      expect(table.rows.map{|row| row.cells[0].value}).to eq [6/5r, 5/4r, 4/3r, 3/2r, 8/5r, 5/3r]
    end

    it "lists the prime vector, difference and occurrences of each interval" do
      expect(table.rows.first.cells.map(&:value)).to eq [6/5r, 1, 1, -1, 1, 1]
    end

    it "leaves the exponents of the irrational intervals of an EDO blank" do
      row = described_class.new(Tonal::Scale.edo(5)).inventory.rows.first.cells.map(&:value)
      expect(row[1..-3]).to all(be_nil)
    end
  end
end
