require "spec_helper"

RSpec.describe Tonal::Scale::Analysis do
  #def best_expression_of(ratio, from_step: 0, epsilon: 1.cents, as_step: true)
  #def averages_between_steps
  #def unique_intervals_by_step(step)
  #def unique_interval_prime_vectors_by_step(step)
  #def determinant_by_step(step)
  #def unique_intervals_by_step_distances
  #def find_all(ratio)
  #def variations_of_unique_intervals
  #def occurences
  #def mos? TODO Do we need this here?
  #def combinations TODO Consider eliminating or renaming
  #def differences TODO Consider eliminating or renaming
  #def by_best_expressions_of(*rats)
  #def cent_diff_mod(mod)
  #def cent_diff

  describe "class methods" do
    describe ".efficiencies" do
      
    end

    describe ".partitionings" do
      
    end
  end

  describe "initialization" do
    
  end

  describe "#modes" do
    
  end

  describe "#interval_between_steps" do
    let(:scale) { Tonal::Scale.afs }

    it "expects two arguments" do
      expect{ described_class.new(scale).interval_between_steps }.to raise_error ArgumentError, "wrong number of arguments (given 0, expected 2)"
    end

    it "returns the interval between the given steps" do
      expect(described_class.new(scale).interval_between_steps(0, 1)).to eq Tonal::Interval.new(1/1r, 9/8r)
    end

    context "When the inputs are reversed" do
      it "returns the reciprocol interval between the steps" do
        expect(described_class.new(scale).interval_between_steps(1, 0)).to eq Tonal::Interval.new(9/8r, 1/1r)
      end
    end
  end

  # TODO Eliminate method?
  #def all_intervals_by_step(step)
  #def all_intervals_by_steps
  describe "#all_intervals_by_step" do
    let(:scale) { Tonal::Scale.harmonic }

    it("expects an argument") do
      expect{ described_class.new(scale).all_intervals_by_step }.to raise_error ArgumentError, "wrong number of arguments (given 0, expected 1)"
    end

    #it("does something") do
    #  expect(described_class.new(scale).all_intervals_by_step(0)).to eq []
    #end
  end

  describe "#cents_distance_from" do
    
  end

  describe "#constant_structure?" do
    context "with non-constant structure scale" do
      let(:scale) { Tonal::Scale.harmonic }

      it "returns false" do
        expect(described_class.new(scale).constant_structure?).to eq false
      end
    end

    context "with constant structure scale" do
      let(:scale) { Tonal::Scale.linear }

      it "returns true" do
        expect(described_class.new(scale).constant_structure?).to eq true
      end
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

  # TODO Consolodate
  describe "#best_expression_of" do
    it "does something" do
      skip "unimplemented"
    end
  end

  #describe "#cents_difference" do
  #  let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) }
  #
  #  context "by :scale_step" do
  #    it "returns the ratios' cents differences with the scale's steps" do
  #      expect(described_class.new(scale).cents_difference(unit: :scale_step)).to eq [0.0, 86.31, 101.96, 68.83]
  #      #0.0, 400.0, 700.0, 1000.0]
  #    end
  #  end
  #
  #  context "by :hundredth_cent" do
  #    it "returns the ratios' nearest hundredth cent differences" do
  #      expect(described_class.new(scale).cents_difference(unit: :hundredth_cent)).to eq [0.0, -13.69, 1.96, -31.17]
  #      #0.0, 400.0, 700.0, 1000.0]
  #    end
  #  end
  #end

  #describe "#nearest_hundredth_cents" do
  #  let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) }
  #
  #  it "returns the map of nearest hundredth cents values for each scale's ratios" do
  #    expect(described_class.new(scale).nearest_hundredth_cents).to eq [0.0, 400.0, 700.0, 1000.0]
  #  end
  #end

  #describe "#nearest_hundredth_cents_differences" do
  #  let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) }
  #
  #  it "returns the nearest hundredth cent differences" do
  #    expect(described_class.new(scale).nearest_hundredth_cents_differences).to eq [0.0, -13.69, 1.96, -31.17]
  #  end
  #end

  describe "#nearest_hundredth_cents_pairs" do
    
  end

  describe "#prime_divisions" do
    let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) }

    it "returns an array of prime divisors of the ratio's numerators and denominators" do
      expect(described_class.new(scale).prime_divisions).to eq [[[[2, 1]], [[2, 1]]], [[[5, 1]], [[2, 2]]], [[[3, 1]], [[2, 1]]], [[[7, 1]], [[2, 2]]]]
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
        expect(described_class.new(scale).steps).to eq expected_steps.map{|step| Tonal::Step.new(modulo: modulo, step: step)}
      end
    end

    context "with mod passed in" do
      let(:expected_steps) { [0, 17, 18, 31, 43] }
      let(:modulo) { 53 }

      it "steps are calculated from the scale ratio's logarithms times the provided modulo" do
        expect(described_class.new(scale).steps(mod: 53)).to eq expected_steps.map{|step| Tonal::Step.new(modulo: modulo, step: step)}
      end
    end
  end

  describe "#steps_in_cents" do
    let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) }
    let(:expected_steps) { [0, 386, 702, 969] }
    let(:modulo) { 1200 }

    it "returns the steps for the scale's ratios over the 1200 modulo" do
      expect(described_class.new(scale).steps_in_cents).to eq expected_steps.map{|step| Tonal::Step.new(modulo: modulo, step: step)}
    end
  end

  describe "#to_radians" do
    
  end

  #def to_degrees
  #def to_circle

  describe "#nearest_ratio_to" do
    
  end
end

RSpec.describe Tonal::Scale::Analysis::Differences do
  describe "" do
    
  end
end
