require "spec_helper"

RSpec.describe Tonal::Scale::Analysis::Approximations do
  describe "instance methods" do

    subject { described_class.new(scale) }

    let(:scale) { Tonal::Scale.edo(12) }

    #describe "#step_best_expressing" do
    #  let(:ratio) { 3/2r }
    #  it "returns the step of scale best expressing the given ratio" do
    #    expect(subject.step_best_expressing(ratio)).to eq Tonal::Step.new(ratio: 3/2r, modulo: 12)
    #  end
    #end

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
