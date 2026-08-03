require "spec_helper"

RSpec.describe Tonal::Sequence do
  describe "initialization" do
    it "accepts initial values" do
      expect(described_class.new(2/1r, 3/2r)).to eq described_class.new(2/1r, 3/2r)
    end

    context "when a block is given" do
      let(:sequence) { described_class.new{|s| s << 2/1r << 3/2r} }

      it { expect(sequence).to eq described_class.new(2/1r, 3/2r) }
    end
  end

  describe "class methods" do
    #describe ".denominize" do
    #  let(:ratios) { [5/4r, 7/4r, 15/8r] }
    #
    #  it { expect(described_class.denominize(ratios)).to eq [Tonal::Ratio.new(10,8), Tonal::Ratio.new(14,8), Tonal::Ratio.new(15,8)] }
    #end

    describe ".afs" do
      it { expect(described_class.afs).to eq described_class.new(1/1r, 2/1r, 3/1r, 4/1r, 5/1r, 6/1r, 7/1r, 8/1r, 9/1r, 10/1r, 11/1r, 12/1r, 13/1r, 14/1r, 15/1r, 16/1r) }
    end

    #describe ".composite" do
    #  it { skip "implement or remove" }
    #end

    describe ".cps" do
      it { expect(described_class.cps(set: [1,3,5,7])).to eq described_class.new(3/1r, 5/1r, 7/1r, 15/1r, 21/1r, 35/1r) }
    end

    describe ".diamond" do
      it { expect(described_class.diamond(set: [1, 3])).to eq described_class.new(1/1r, 1/3r, 3/1r, 1/1r) }
    end

    describe ".genus" do
      it { expect(described_class.genus(factors: {3 => 2, 5 => 1})).to eq described_class.new(1/1r, 5/1r, 3/1r, 15/1r, 9/1r, 45/1r) }
    end

    describe ".harmonic" do
      it { expect(described_class.harmonic).to eq described_class.new(8/1r, 9/1r, 10/1r, 11/1r, 12/1r, 13/1r, 14/1r, 15/1r, 16/1r) }
    end

    describe ".lattice" do
      it { expect(described_class.lattice(primes: [3, 5], max_weight: 1)).to eq described_class.new(1/3r, 1/5r, 1/1r, 5/1r, 3/1r) }
    end

    #describe ".intra_proportional" do
    #  it { expect(described_class.intra_proportional(ratios: [3/2r, 4/3r])).to eq described_class.new(15/12r, 8/6r, 17/12r, 9/6r, 19/12r) }
    #end

    describe ".linear" do
      it { expect(described_class.linear).to eq described_class.new(1/1r, 3/2r, 9/4r, 27/8r, 81/16r, 243/32r, 729/64r, 2187/128r, 6561/256r, 19683/512r, 59049/1024r, 177147/2048r) }
    end

    describe ".recurrence" do
      it { expect(described_class.recurrence).to eq described_class.new(1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377) }
    end

    describe ".polyharmonic" do
      it { expect(described_class.polyharmonic).to eq described_class.new(8/1r, 9/1r, 10/1r, 11/1r, 12/1r, 13/1r, 14/1r, 15/1r, 16/1r) }
    end

    describe ".proportional" do
      it { expect(described_class.proportional(ratios: [[3/2r, 4/3r]])).to eq described_class.new(7/6r, 8/6r, 9/6r, 10/6r) }
    end

    describe ".subharmonic" do
      it { expect(described_class.subharmonic).to eq described_class.new(1/8r, 1/9r, 1/10r, 1/11r, 1/12r, 1/13r, 1/14r, 1/15r, 1/16r) }
    end

    describe ".superparticular" do
      let(:number) { 5 }
      it { expect(described_class.superparticular(number: number)).to eq described_class.new(2/1r, 3/2r, 4/3r, 5/4r, 6/5r) }
    end

    describe ".superpartient" do
      it { expect(described_class.superpartient).to eq described_class.new(3/1r, 4/2r, 5/3r, 6/4r, 7/5r, 8/6r, 9/7r, 10/8r, 11/9r, 12/10r, 13/11r) }
    end
#
#    #describe ".branching" do
#    #  it { expect(described_class.branching(segments: [[1/1r, 3/2r]], starting_nodes: [2/1r])).to eq described_class.new(2/1r, 3/1r) }
    #end
  end

  describe "instance methods" do
    describe "#sequence" do
      it { expect(described_class.new(3/2r, 2/1r, 3/2r).sequence).to eq [3/2r, 2/1r, 3/2r] }
    end

    describe "#count" do
      it { expect(described_class.superparticular.count).to eq 12 }
    end

    describe "#[]" do
      it { expect(described_class.superparticular[1]).to eq 3/2r }
    end

    describe "#first" do
      it { expect(described_class.superparticular.first).to eq 2/1r }
    end

    describe "#last" do
      it { expect(described_class.superparticular.last).to eq 13/12r }
    end

    describe "#to_scale" do
      it { expect(described_class.superparticular(number: 4).to_scale).to be_a_kind_of(Tonal::Scale) }
    end
  end
end
