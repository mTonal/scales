require "spec_helper"

RSpec.describe Tonal::Scale::Analysis do
  describe "#modes" do
    let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) }

    it "returns all modes of the scale" do
      expect(described_class.new(scale).modes).to be_an Array
      expect(described_class.new(scale).modes.count).to eq scale.count
    end

    it "each mode is a Tonal::Scale" do
      described_class.new(scale).modes.each { |m| expect(m).to be_a Tonal::Scale }
    end

    it "each mode starts from 1/1" do
      described_class.new(scale).modes.each { |m| expect(m.first).to eq 1/1r }
    end
  end

  describe "#efficiency_with" do
    let(:ratio) { 81/64r }
    let(:scale) { Tonal::Scale.edo(12) }

    it "returns the cents difference of the scale's best step approximation to the given ratio" do
      expect(described_class.new(scale).efficiency_with(ratio)).to eq -7.82
    end
  end

  describe "#max_primes" do
    let(:scale) { Tonal::Scale.cps }

    it "does something" do
      expect(described_class.new(scale).max_primes).to eq [7, 5, 7, 3, 7, 5]
    end
  end

  describe "#approximate" do

  end

  describe "#prime_divisions" do
    let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) }

    it "returns an array of prime divisors of the ratio's numerators and denominators" do
      expect(described_class.new(scale).prime_divisions).to eq [[[], []], [[[5, 1]], [[2, 2]]], [[[3, 1]], [[2, 1]]], [[[7, 1]], [[2, 2]]]]
    end
  end

  describe "#prime_vectors" do
    let(:scale) { Tonal::Scale.new(3/2r, 7/4r) }

    it "returns a Vector with the prime factors of the notes of the scale" do
      expect(described_class.new(scale).prime_vectors).to eq [Vector[-1, 1], Vector[-2, 0, 0, 1]]
    end
  end

  describe "#steps" do
    let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 81/64r, 3/2r, 7/4r) }

    context "default" do
      let(:expected_steps) { [0, 2, 2, 3, 4] }
      let(:modulo) { 5 }

      it "steps are calculated from the scale ratio's logarithms times the scale's count" do
        expect(described_class.new(scale).steps).to eq expected_steps.map{|step| Tonal::Scale::Step.new(modulo: modulo, step: step)}
      end
    end

    context "with mod passed in" do
      let(:expected_steps) { [0, 17, 18, 31, 43] }
      let(:modulo) { 53 }

      it "steps are calculated from the scale ratio's logarithms times the provided modulo" do
        expect(described_class.new(scale).steps(modulo)).to eq expected_steps.map{|step| Tonal::Scale::Step.new(modulo: modulo, step: step)}
      end
    end
  end

  describe "#steps_in_cents" do
    let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) }
    let(:expected_steps) { [0, 386, 702, 969] }
    let(:modulo) { 1200 }

    it "returns the steps for the scale's ratios over the 1200 modulo" do
      expect(described_class.new(scale).steps_in_cents).to eq expected_steps.map{|step| Tonal::Scale::Step.new(modulo: modulo, step: step)}
    end
  end
end
