require "spec_helper"

RSpec.describe Tonal::Scale::Efficiency do
  subject { described_class.new(scale) }

  let(:scale) { Tonal::Scale.harmonic }

  describe "#efficiency_with" do
    let(:scale) { Tonal::Scale.edo(12) }

    it "returns the cents difference of the scale's best step approximation to the given ratio" do
      expect(subject.efficiency_with(81/64r)).to eq -7.82
    end
  end

  describe "#efficiencies" do
    it "returns the step efficiency of each ratio" do
      expect(subject.efficiencies).to eq [0.0, 53.91, -63.69, -48.68, -48.04, -59.47, 68.83, 38.27]
    end
  end

  describe "statistics of the efficiencies" do
    it { expect(subject.mean).to eq -7.36 }
    it { expect(subject.variance).to eq 2618.24 }
    it { expect(subject.standard_deviation).to eq 51.17 }
  end
end
