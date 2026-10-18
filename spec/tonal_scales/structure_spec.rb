require "spec_helper"

RSpec.describe Tonal::Scale::Structure do
  subject { described_class.new(scale) }

  let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r) }

  describe "#sequential_intervals" do
    it "returns the intervals between consecutive notes" do
      expect(subject.sequential_intervals.map(&:to_r)).to eq [8/5r, 5/3r]
    end
  end

  describe "#combinations" do
    it "maps each interval ratio to the note pairs spanning it" do
      expect(subject.combinations.transform_values(&:count)).to eq({8/5r => 1, 4/3r => 1, 5/3r => 1})
    end
  end

  describe "#combinations_description" do
    it "describes the note pairs spanning each interval" do
      expect(subject.combinations_description).to eq [[8/5r, "8/5 (1/1 / 5/4)"], [4/3r, "4/3 (1/1 / 3/2)"], [5/3r, "5/3 (5/4 / 3/2)"]]
    end
  end

  describe "#occurrences" do
    it "maps every interval between ordered note pairs to its occurrences" do
      expect(subject.occurrences.transform_values(&:count)).to eq({1/1r => 3, 6/5r => 1, 5/4r => 1, 4/3r => 1, 3/2r => 1, 8/5r => 1, 5/3r => 1})
    end
  end

  describe "#averages_between_steps" do
    let(:scale) { Tonal::Scale.harmonic }

    it { expect(subject.averages_between_steps).to eq [17/16r, 19/16r, 21/16r, 23/16r, 25/16r, 27/16r, 29/16r] }
  end

  describe "#all_intervals_by_step" do
    it "returns the interval from each note to the note step away, wrapping around" do
      expect(subject.all_intervals_by_step(1).map(&:to_r)).to eq [8/5r, 5/3r, 3/2r]
    end
  end

  describe "#unique_intervals_by_step_distances" do
    it "returns the unique intervals at each step distance" do
      expect(subject.unique_intervals_by_step_distances.map{|row| row.map(&:to_r)}).to eq [[1/1r], [3/2r, 8/5r, 5/3r], [6/5r, 5/4r, 4/3r]]
    end
  end

  describe "#unique_interval_prime_vectors_by_step" do
    it "returns zero-padded prime vectors" do
      expect(subject.unique_interval_prime_vectors_by_step(1)).to eq [[-1, 1, 0], [3, 0, -1], [0, -1, 1]]
    end
  end

  describe "#determinant_by_step" do
    it { expect(subject.determinant_by_step(1)).to eq -2 }
  end

  describe "#find_all" do
    it "returns the intervals spanning the ratio" do
      expect(subject.find_all(6/5r).map(&:inspect)).to eq ["6/5 (3/2 / 5/4)"]
    end
  end

  describe "#cent_diff" do
    it "returns the cents between consecutive notes" do
      expect(subject.cent_diff).to eq [386.31, 315.65]
    end
  end

  describe "#constant_structure?" do
    it { expect(subject.constant_structure?).to be true }
    it { expect(described_class.new(Tonal::Scale.harmonic).constant_structure?).to be false }
  end

  describe "#mos?" do
    it { expect(described_class.new(Tonal::Scale.edo(12)).mos?).to be true }
    it { expect(described_class.new(Tonal::Scale.new(1/1r, 9/8r, 5/4r, 4/3r, 3/2r, 5/3r, 15/8r)).mos?).to be false }
  end
end
