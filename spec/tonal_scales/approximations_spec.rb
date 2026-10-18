require "spec_helper"

RSpec.describe Tonal::Scale::Approximations do
  describe "instance methods" do

    subject { described_class.new(scale) }

    let(:scale) { Tonal::Scale.edo(12) }

    #describe "#step_best_expressing" do
    #  let(:ratio) { 3/2r }
    #  it "returns the step of scale best expressing the given ratio" do
    #    expect(subject.step_best_expressing(ratio)).to eq Tonal::Step.new(ratio: 3/2r, modulo: 12)
    #  end
    #end

    describe "#steps" do
      let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 81/64r, 3/2r, 7/4r) }

      it "maps the ratios onto the steps of an EDO the size of the scale" do
        expect(subject.steps).to eq [0, 2, 2, 3, 4].map{|step| Tonal::Scale::Step.new(modulo: 5, step: step)}
      end

      it "maps the ratios onto the steps of the given EDO" do
        expect(subject.steps(53)).to eq [0, 17, 18, 31, 43].map{|step| Tonal::Scale::Step.new(modulo: 53, step: step)}
      end
    end

    describe "#steps_in_cents" do
      let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) }

      it "returns the steps for the scale's ratios over the 1200 modulo" do
        expect(subject.steps_in_cents).to eq [0, 386, 702, 969].map{|step| Tonal::Scale::Step.new(modulo: 1200, step: step)}
      end
    end

    describe "#maps_on" do
      let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) }

      it "returns each ratio with its step and nearest-hundredth cents" do
        expect(subject.maps_on.map{|ratio, step, cents, diff| [ratio, step.step, cents, diff]}).to eq [[1/1r, 0, 0.0, 0.0], [5/4r, 1, 400.0, -13.69], [3/2r, 2, 700.0, 1.96], [7/4r, 3, 1000.0, -31.17]]
      end
    end

    describe "#negatives" do
      let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) }

      it "returns the steps of the Levy negatives of the ratios" do
        expect(subject.negatives.map(&:step)).to eq [2, 1, 0, 3]
      end
    end

    describe "#nearest_small_ratios" do
      let(:scale) { Tonal::Scale.harmonic }

      it { expect(subject.nearest_small_ratios).to eq [1/1r, 9/8r, 5/4r, 11/8r, 3/2r, 13/8r, 7/4r, 15/8r] }
    end

    describe "#differences" do
      let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) }

      it "returns the differences to the nearest hundredth of a cent" do
        expect(subject.differences.differences).to eq [0.0, -13.69, 1.96, -31.17]
      end
    end

    describe "#ratio_best_expressing" do
      let(:ratio) { 3/2r }
      it "returns the ratio of scale best expressing the given ratio" do
        expect(subject.ratio_best_expressing(ratio)).to eq 421735949569275/281474976710656r
      end
    end

    describe "approximate" do
      # Output is lenghthy, so we use a small scale
      let(:scale) { Tonal::Scale.new(2**(0.0/12), (2**(1.0/12))) }

      #it "returns the continued fraction approximations of the scale" do
      #  expect(subject.approximate.inspect).to eq "[[0, (1/1): [(1/1)]], [1, (4771397596969315/4503599627370496): [(17/16), (18/17), (89/84), (196/185), (1461/1379), (1657/1564), (3118/2943), (7893/7450), (18904/17843)]]]"
      #end

      describe "Error handling" do
        context "with bogus approximation argument" do
          it "raises an ArgumentError" do
            expect{subject.approximate(by: :blah)}.to raise_error(ArgumentError, "Unknown approximation type: blah. Use [:continued_fraction, :tree_path, :superparticular, :neighborhood]")
          end
        end

        context "with bogus measurement argument" do
          it "raises an ArgumentError" do
            expect{subject.approximate(sort_by: :blah)}.to raise_error(ArgumentError, "Unknown measure type: blah. Use [:benedetti, :wilson, :tenney, :log_weil, :weil]")
          end
        end
      end
    end
  end
end
