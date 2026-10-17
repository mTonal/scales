require "spec_helper"

RSpec.describe Tonal::Scale do
  let(:ratios) { [1/1r, 3/2r, 7/4r] }

  describe "Initialization" do
    describe "ratio inputs" do
      context "with Rationals" do
        let(:ratios) { [1/1r, 3/2r, 7/4r] }
        it { expect(described_class.new(ratios).to_a).to eq ratios }
      end

      context "with Tonal::*Ratios" do
        let(:ratios) { [Tonal::ReducedRatio.new(1/1r), Tonal::Ratio.new(3/2r), Tonal::Ratio.new(7,4)] }
        it { expect(described_class.new(ratios).to_a).to eq ratios }
      end

      context "with Rationals and Tonal::*Ratios" do
        let(:ratios) { [Tonal::ReducedRatio.new(1/1r), 3/2r, Tonal::Ratio.new(7,4)] }
        it { expect(described_class.new(ratios).to_a).to eq ratios }
      end

      context "with a block" do
        it { expect(described_class.new{|scale| scale << 1/1r << 3/2r << 7/4r}.to_a).to eq [1/1r, 3/2r, 7/4r] }
      end

      context "with unordered inputs" do
        let(:ordered_ratios) { [1/1r, 3/2r, 7/4r] }
        let(:unordered_ratios) { [1/1r, 7/4r, 3/2r] }
        let(:scale) { described_class.new(unordered_ratios) }

        it "an ordered scale is returned" do
          expect(scale).to eq described_class.new(ordered_ratios)
        end
      end
    end
  end

  describe "Comparisons" do
    context "when notes are the same" do
      let(:ratios) { [1/1r, 5/4r, 3/2r, 7/4r] }
      let(:scale1) { described_class.new(ratios) }
      let(:scale2) { described_class.new(ratios)}

      it "scales are equal" do
        expect(scale1).to eq scale2
      end
    end

    context "when notes are not the same" do
      let(:ratios1) { [1/1r, 5/4r, 3/2r, 7/4r] }
      let(:ratios2) { [1/1r, 7/6r, 3/2r, 15/8r] }
      let(:scale1) { described_class.new(ratios1) }
      let(:scale2) { described_class.new(ratios2) }

      it "scales are not equal" do
        expect(scale1).to_not eq scale2
      end
    end

    context "when lengths are not the same" do
      let(:ratios1) { [1/1r, 5/4r, 3/2r, 7/4r] }
      let(:ratios2) { [1/1r, 7/6r, 3/2r] }
      let(:scale1) { described_class.new(ratios1) }
      let(:scale2) { described_class.new(ratios2) }

      it "scales are not equal" do
        expect(scale1).to_not eq scale2
      end
    end
  end

  describe "#name" do
    context "default" do
      it { expect(described_class.new(ratios).name).to eq "Unamed" }
    end

    context "when initialized" do
      let(:name) { "This is a name" }
      it { expect(described_class.new(ratios, name: name).name).to eq name }
    end
  end

  describe "#name=" do
    let(:scale) { described_class.new(ratios) }
    let(:name) { "This is a name" }

    it "returns the assigned name" do
      scale.name = name
      expect(scale.name).to eq name
    end
  end

  describe "#description" do
    context "default" do
      it { expect(described_class.new(ratios).description).to eq "Undescribed" }
    end

    context "when initialized" do
      let(:description) { "This is a description" }
      it { expect(described_class.new(ratios, description: description).description).to eq description }
    end
  end

  describe "#=description" do
    let(:scale) { described_class.new(ratios) }
    let(:description) { "This is a description" }

    it "returns the assigned description" do
      scale.description = description
      expect(scale.description).to eq description
    end
  end

  describe "#count" do
    let(:modulo) { 12 }

    it "returns the number of notes of the scale" do
      expect(described_class.edo(modulo).count).to eq modulo
    end
  end

  describe "#labels" do
    context "with small numbered Rationals" do
      it("returns the rationals") { expect(described_class.new(1/1r, 3/2r, 7/4r).labels).to eq %w{1/1 3/2 7/4} }
    end

    context "with large numbered Rationals" do
      it("returns rounded floats") { expect(described_class.new(4771397596969315/4503599627370496r, 3005792134919727/2251799813685248r).labels).to eq %w{1.06 1.33} }
    end
  end

  describe "#steps" do
    it { expect(described_class.new(5/4r, 7/4r).steps).to eq [Tonal::Scale::Step.new(modulo: 2, step: 1), Tonal::Scale::Step.new(modulo: 2, step: 2)] }
  end

  describe "#first" do
    it { expect(described_class.new(5/4r, 7/4r).first).to eq Tonal::Ratio.new(5/4r) }
  end

  describe "#indices" do
    let(:modulo) { 12 }

    it "returns the indices of each note of the scale" do
      expect(described_class.edo(modulo).indices).to eq [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    end
  end

  describe "#[]" do
    let(:ratios) { [1/1r, 9/8r, 5/4r, 11/8r, 3/2r, 13/8r, 7/4r, 15/8r] }
    context "with a single index" do
      it { expect(described_class.new(ratios)[1]).to eq 9/8r }
    end

    context "with a couple of discontiguous indices" do
      it { expect(described_class.new(ratios)[1, 3]).to eq [9/8r, 11/8r] }
    end

    context "with a range of indices" do
      it { expect(described_class.new(ratios)[1..3]).to eq [9/8r, 5/4r, 11/8r] }
    end

    context "with a mix of indices" do
      it { expect(described_class.new(ratios)[1..3, 5, 7]).to eq [9/8r, 5/4r, 11/8r, 13/8r, 15/8r] }
    end
  end

  describe "#[]=" do
    let(:ratios) { [1/1r, 9/8r, 5/4r, 11/8r, 3/2r, 13/8r, 7/4r, 15/8r] }
    let(:scale) { described_class.new(ratios) }
    let(:replacing_ratio) { 7/6r }

    it "replaces the ratio at the given index with the new ratio" do
      scale[2] = replacing_ratio
      expect(scale[2]).to eq replacing_ratio
    end
  end

  describe "#<<" do
    let(:ratios) { [1/1r, 9/8r, 11/8r, 3/2r, 13/8r, 7/4r, 15/8r] }
    let(:scale) { described_class.new(ratios) }
    let(:inserting_ratio) { 5/4r }

    it "inserts the ratio into the scale" do
      expect(scale.count).to eq 7
      scale << inserting_ratio
      expect(scale.count).to eq 8
      expect(scale[2]).to eq inserting_ratio
    end
  end

  describe "#*" do
    let(:ratios) { [1/1r, 3/2r, 5/4r, 7/4r] }
    let(:scale) { described_class.new(ratios) }
    let(:factor) { 4/3r }

    it "returns a new scale translated by the factor" do
      expect(scale * factor).to eq described_class.new(1/1r, 7/6r, 4/3r, 5/3r)
    end

    context "with factor on the left-hand side" do
      it "returns a new scale translated by the factor" do
        expect(factor * scale).to eq described_class.new(1/1r, 7/6r, 4/3r, 5/3r)
      end
    end
  end

  describe "#/" do
    let(:ratios) { [1/1r, 3/2r, 5/4r, 7/4r] }
    let(:scale) { described_class.new(ratios) }
    let(:factor) { 4/3r }

    it "returns a new scale translated by the factor" do
      expect(scale / factor).to eq described_class.new(9/8r, 21/16r, 3/2r, 15/8r)
    end

    context "with factor on the left-hand side" do
      it "returns a new scale translated by the factor" do
        expect(factor / scale).to eq described_class.new(9/8r, 21/16r, 3/2r, 15/8r)
      end
    end
  end

  describe "#+" do
    let(:scale1) { described_class.new(1/1r, 5/4r, 3/2r) }
    let(:scale2) { described_class.new(7/4r, 15/8r) }

    it "joins two scales into a new scale containing all ratios" do
      expect((scale1 + scale2).to_a).to eq [1/1r, 5/4r, 3/2r, 7/4r, 15/8r]
    end

    it "returns a Tonal::Scale" do
      expect(scale1 + scale2).to be_a described_class
    end
  end

  describe "#delete" do
    let(:ratios) { [1/1r, 5/4r, 3/2r, 7/4r] }
    let(:scale) { described_class.new(ratios) }

    it "removes the given ratio from the scale" do
      scale.delete(5/4r)
      expect(scale.to_a).to eq [1/1r, 3/2r, 7/4r]
    end
  end

  describe "#delete_at" do
    let(:ratios) { [1/1r, 5/4r, 3/2r, 7/4r] }
    let(:scale) { described_class.new(ratios) }

    it "removes the ratio at the given index" do
      scale.delete_at(1)
      expect(scale.to_a).to eq [1/1r, 3/2r, 7/4r]
    end
  end

  describe "#sample" do
    let(:scale) { described_class.new(1/1r, 5/4r, 3/2r, 7/4r) }

    it "returns a scale with n ratios drawn from self" do
      result = scale.sample(2)
      expect(result).to be_a described_class
      expect(result.count).to eq 2
      result.to_a.each { |r| expect(scale.to_a).to include(r) }
    end

    it "defaults to a single-ratio scale" do
      expect(scale.sample.count).to eq 1
    end
  end

  describe "#invert" do
    let(:scale) { described_class.new(5/4r, 3/2r, 7/4r) }

    it "returns a new scale with antecedents and consequents exchanged" do
      expect(scale.invert).to eq described_class.new(4/5r, 2/3r, 4/7r)
    end
  end

  describe "#rotate" do
    let(:scale) { described_class.new(1/1r, 5/4r, 3/2r, 7/4r) }

    it "returns a new scale with each ratio rotated by the distance" do
      expect(scale.rotate(3/2r)).to eq described_class.new(2/3r, 5/6r, 1/1r, 7/6r)
    end
  end

  describe "#mirror" do
    let(:scale) { described_class.new(1/1r, 9/8r, 5/4r, 3/2r) }

    it "returns a new scale mirrored around the axis" do
      expect(scale.mirror).to eq described_class.new(1/1r, 4/3r, 8/5r, 16/9r)
    end
  end

  describe "#negative" do
    let(:scale) { described_class.new(1/1r, 5/4r, 3/2r) }

    it "returns a new scale as Levy negative transformation" do
      expect(scale.negative).to be_a described_class
    end
  end

  describe "#reciprocal" do
    let(:scale) { described_class.harmonic }

    it "returns a new scale with ratios inverted" do
      expect(scale.reciprocal).to eq described_class.subharmonic
    end

    it "does not mutate self" do
      original = scale.to_a
      scale.reciprocal
      expect(scale.to_a).to eq original
    end
  end

  describe "#reciprocal!" do
    let(:scale) { described_class.harmonic }

    it "mutates self to contain inverted ratios" do
      scale.reciprocal!
      expect(scale).to eq described_class.subharmonic
    end
  end

  describe "#inspect" do
    let(:ratios) { [1/1r, 3/2r, 7/4r] }

    it "returns the string representation of the scale's ratios" do
      expect(described_class.new(ratios).inspect).to eq "[#{ratios.map(&:to_s).join(", ")}]"
    end
  end

  describe "#prime_divisions" do
    it { expect(described_class.new(5/4r, 7/4r).prime_divisions).to eq [[[[5, 1]], [[2, 2]]], [[[7, 1]], [[2, 2]]]] }
  end

  describe "#antecedents" do
    it { expect(described_class.cps.antecedents).to eq [35, 5, 21, 3, 7, 15] }
  end

  describe "#consequents" do
    it { expect(described_class.cps.consequents).to eq [32, 4, 16, 2, 4, 8] }
  end

  describe "Constructors" do
    describe "#branching" do
      it { expect(described_class.new(1/1r, 3/2r, 7/4r).branching).to eq Tonal::Scale.new(1/1r, 8/7r, 3/2r, 12/7r, 7/4r) }
    end
    describe ".afs" do
      it { expect(described_class.afs).to eq Tonal::Scale.new(1/1r, 9/8r, 5/4r, 11/8r, 3/2r, 13/8r, 7/4r, 15/8r) }
    end

    describe ".cps" do
      it { expect(described_class.cps).to eq Tonal::Scale.new(35/32r, 5/4r, 21/16r, 3/2r, 7/4r, 15/8r) }
    end

    describe ".diamond" do
      it { expect(described_class.diamond(1, 3, 5, 7)).to eq Tonal::Scale.new(1/1r, 8/7r, 7/6r, 6/5r, 5/4r, 4/3r, 7/5r, 10/7r, 3/2r, 8/5r, 5/3r, 12/7r, 7/4r) }
    end

    describe ".edo" do
      it { expect(described_class.edo(3)).to eq Tonal::Scale.new(2**(0.0/3), 2**(1.0/3), 2**(2.0/3)) }
    end

    describe ".genus" do
      it { expect(described_class.genus(factors: {3 => 2, 5 => 1})).to eq Tonal::Scale.new(1/1r, 9/8r, 5/4r, 45/32r, 3/2r, 15/8r) }
    end

    describe ".harmonic" do
      it { expect(described_class.harmonic).to eq Tonal::Scale.new(1/1r, 9/8r, 5/4r, 11/8r, 3/2r, 13/8r, 7/4r, 15/8r) }
    end

    describe ".intra_proportional" do
      it { expect(described_class.intra_proportional(3/2r, 7/4r)).to eq Tonal::Scale.new(3/2r, 13/8r, 7/4r) }
    end

    describe ".lattice" do
      it { expect(described_class.lattice.count).to eq 51 }
      it { expect(described_class.lattice(primes: [3, 5], max_weight: 1)).to eq Tonal::Scale.new(1/1r, 5/4r, 4/3r, 3/2r, 8/5r) }
      it { expect(described_class.lattice(primes: [3, 5], max_weight: 2)).to eq Tonal::Scale.new(1/1r, 16/15r, 6/5r, 5/4r, 4/3r, 3/2r, 8/5r, 5/3r, 15/8r) }
    end

    describe ".linear" do
      it { expect(described_class.linear).to eq Tonal::Scale.new(1/1r, 2187/2048r, 9/8r, 19683/16384r, 81/64r, 177147/131072r, 729/512r, 3/2r, 6561/4096r, 27/16r, 59049/32768r, 243/128r) }
    end

    describe ".recurrence" do
      it { expect(described_class.recurrence).to eq Tonal::Scale.new(1/1r, 17/16r, 9/8r, 5/4r, 21/16r, 89/64r, 377/256r, 3/2r, 13/8r, 55/32r, 233/128r) }
    end

    describe ".polyharmonic" do
      it { expect(described_class.polyharmonic).to eq Tonal::Scale.new(1/1r, 9/8r, 5/4r, 11/8r, 3/2r, 13/8r, 7/4r, 15/8r) }
    end

    describe ".proportional" do
      it { expect(described_class.proportional(3/2r, 7/4r)).to eq Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) }
    end

    describe ".subharmonic" do
      it { expect(described_class.subharmonic).to eq Tonal::Scale.new(1/1r, 8/9r, 4/5r, 8/11r, 2/3r, 8/13r, 4/7r, 8/15r) }
    end

    describe ".superparticular" do
      it { expect(described_class.superparticular).to eq Tonal::Scale.new(1/1r, 13/12r, 12/11r, 11/10r, 10/9r, 9/8r, 8/7r, 7/6r, 6/5r, 5/4r, 4/3r, 3/2r) }
    end

    describe ".superpartient" do
      it { expect(described_class.superpartient).to eq Tonal::Scale.new(1/1r, 13/11r, 6/5r, 11/9r, 5/4r, 9/7r, 4/3r, 7/5r, 3/2r, 5/3r) }
    end
  end
end

RSpec.describe Tonal::Scale::Diamond do
  describe "#name" do
    it { expect(described_class.new(set: [1, 3, 5, 7]).name).to eq "Tonality diamond, [1, 3, 5, 7]" }
  end

  describe "#description" do
    it { expect(described_class.new(set: [1, 3, 5, 7]).description).to eq "Tonality diamond: all ratios p/q for p, q in [1, 3, 5, 7], reduced to the octave" }
  end

  describe "#chords" do
    let(:diamond) { Tonal::Scale.diamond(1, 3, 5, 7) }

    it { expect(diamond.chords).to be_a(Tonal::Scale::ChordSet) }
    it { expect(diamond.chords.scale).to be(diamond) }
    it { expect(diamond.chords).to all(be_an_instance_of(Tonal::Scale::Chord)) }
    it { expect(diamond.chords).to all(satisfy { |chord| chord.steps.none?(&:nil?) }) }

    it "defaults n to the generating-set count - the full otonality/utonality" do
      expect(diamond.chords.count).to eq 8
      expect(diamond.chords).to all(have_attributes(count: 4))
      expect(diamond.chords.map(&:name)).to eq [
        "Otonal tetrad, 1.3.5.7/1", "Otonal tetrad, 1.3.5.7/3",
        "Otonal tetrad, 1.3.5.7/5", "Otonal tetrad, 1.3.5.7/7",
        "Utonal tetrad, 1/1.3.5.7", "Utonal tetrad, 3/1.3.5.7",
        "Utonal tetrad, 5/1.3.5.7", "Utonal tetrad, 7/1.3.5.7"
      ]
    end

    it { expect(diamond.chords.first.ratios).to eq [
      Tonal::ReducedRatio.new(1, 1), Tonal::ReducedRatio.new(5, 4),
      Tonal::ReducedRatio.new(3, 2), Tonal::ReducedRatio.new(7, 4)
    ] }

    it { expect(diamond.chords.first.steps).to eq [0, 4, 8, 12] }
    it { expect(diamond.chords.first.factors).to eq "(1)/(1),(5)/(1),(3)/(1),(7)/(1)" }
    it { expect(diamond.chords[4].factors).to eq "(1)/(1),(1)/(7),(1)/(3),(1)/(5)" }

    it "takes the Ntad number as an argument, drawn from the leading harmonic-limit subset" do
      triads = diamond.chords(3)
      expect(triads.count).to eq 8
      expect(triads).to all(have_attributes(count: 3))
      expect(triads.map(&:name)).to eq [
        "Otonal triad, 1.3.5/1", "Otonal triad, 1.3.5/3",
        "Otonal triad, 1.3.5/5", "Otonal triad, 1.3.5/7",
        "Utonal triad, 1/1.3.5", "Utonal triad, 3/1.3.5",
        "Utonal triad, 5/1.3.5", "Utonal triad, 7/1.3.5"
      ]
    end

    it "names larger Ntads by Wilson's terms" do
      expect(Tonal::Scale.diamond(1, 3, 5, 7, 9, 11).chords.map(&:name).first).to eq "Otonal hexad, 1.3.5.7.9.11/1"
    end

    it { expect(diamond.chords(1)).to be_empty }
    it { expect(diamond.chords(5)).to be_empty }

    context "with a range - every nested sub-Ntad up to the limit, smallest first" do
      it { expect(diamond.chords(2..4).map(&:count)).to eq [2] * 8 + [3] * 8 + [4] * 8 }

      it "skips out-of-range levels rather than raising" do
        expect(diamond.chords(3..9).map(&:count)).to eq [3] * 8 + [4] * 8
      end

      it "reads a beginless range as starting at dyads" do
        expect(diamond.chords(..3).first.name).to eq "Otonal dyad, 1.3/1"
      end

      it "reads an endless range as running to the full generating-set count" do
        eleven_limit = Tonal::Scale.diamond(1, 3, 5, 7, 9, 11)
        expect(eleven_limit.chords(4..).map(&:count).uniq).to eq [4, 5, 6]
      end
    end
  end
end

RSpec.describe Tonal::Scale::Genus do
  describe "#name" do
    it { expect(described_class.new(factors: {3 => 2, 5 => 1}).name).to eq "Euler-Fokker genus, 3^2.5^1" }
  end

  describe "#description" do
    it { expect(described_class.new(factors: {3 => 2, 5 => 1}).description).to eq "Euler-Fokker genus: harmonic-space lattice generated by 3^2.5^1" }
  end
end

RSpec.describe Tonal::Scale::Lattice do
  describe "#name" do
    it { expect(described_class.new(primes: [3, 5], max_weight: 1).name).to eq "Lattice, [3, 5], max_weight: 1" }
  end

  describe "#description" do
    it { expect(described_class.new(primes: [3, 5], max_weight: 1).description).to eq "Euler-Fokker/Wilson lattice: [3, 5] as independent bidirectional axes, up to 1 simultaneously active" }
  end

  describe "#chords" do
    let(:full_lattice) { described_class.new(primes: [3, 5, 7, 11, 13], max_weight: 2) }

    it { expect(full_lattice.chords).to be_a(Tonal::Scale::ChordSet) }
    it { expect(full_lattice.chords.count).to eq 40 }
    it { expect(full_lattice.chords).to all(be_an_instance_of(Tonal::Scale::Chord)) }
    it { expect(full_lattice.chords).to all(satisfy{|chord| chord.steps.none?(&:nil?)}) }

    context "with a two-prime lattice" do
      let(:lattice) { described_class.new(primes: [3, 5], max_weight: 2) }

      it { expect(lattice.chords.map(&:ratios)).to eq [
        [Tonal::ReducedRatio.new(1,1), Tonal::ReducedRatio.new(16,15), Tonal::ReducedRatio.new(4,3), Tonal::ReducedRatio.new(8,5)],
        [Tonal::ReducedRatio.new(1,1), Tonal::ReducedRatio.new(5,4), Tonal::ReducedRatio.new(4,3), Tonal::ReducedRatio.new(5,3)],
        [Tonal::ReducedRatio.new(1,1), Tonal::ReducedRatio.new(6,5), Tonal::ReducedRatio.new(3,2), Tonal::ReducedRatio.new(8,5)],
        [Tonal::ReducedRatio.new(1,1), Tonal::ReducedRatio.new(5,4), Tonal::ReducedRatio.new(3,2), Tonal::ReducedRatio.new(15,8)],
      ] }

      it { expect(lattice.chords.map(&:steps)).to eq [[0, 1, 4, 6], [0, 3, 4, 7], [0, 2, 5, 6], [0, 3, 5, 8]] }
    end
  end
end

RSpec.describe Tonal::Scale::Chord do
  let(:ratios) { [Tonal::ReducedRatio.new(1,1), Tonal::ReducedRatio.new(5,4), Tonal::ReducedRatio.new(3,2), Tonal::ReducedRatio.new(15,8)] }
  let(:chord) { described_class.new(ratios: ratios, steps: [0, 3, 5, 8], name: "Square, 3.5", description: "Unit-square tetrad") }

  describe "#ratios" do
    it { expect(chord.ratios).to eq ratios }
  end

  describe "#steps" do
    it { expect(chord.steps).to eq [0, 3, 5, 8] }
  end

  describe "#name" do
    it { expect(chord.name).to eq "Square, 3.5" }
  end

  describe "#description" do
    it { expect(chord.description).to eq "Unit-square tetrad" }
  end

  describe "#to_a" do
    it { expect(chord.to_a).to eq ratios }
  end

  describe "#count" do
    it { expect(chord.count).to eq 4 }
  end
end

RSpec.describe Tonal::Scale::Cps do
  describe ".default_take" do
    it "returns half the count of the set when the count is even" do
      expect(described_class.default_take(6)).to eq 3
    end

    it "returns half the count of the set minus one when the count is odd" do
      expect(described_class.default_take(7)).to eq 3
    end
  end

  describe "#chords" do
    let(:eikosany) { Tonal::Scale.cps(1, 3, 5, 7, 9, 11, take: 3) }

    it { expect(eikosany.chords).to be_a(Tonal::Scale::ChordSet) }
    it { expect(eikosany.chords.scale).to be(eikosany) }
    it { expect(eikosany.chords).to all(be_an_instance_of(Tonal::Scale::Chord)) }
    it { expect(eikosany.chords).to all(satisfy{|chord| chord.steps.none?(&:nil?)}) }
    it { expect(eikosany.chords.count).to eq 30 }

    context "with the default hexany" do
      let(:hexany) { Tonal::Scale.cps }

      it "has the eight faces of the octahedron - four otonal, four utonal" do
        expect(hexany.chords.count).to eq 8
        expect(hexany.chords.map(&:name)).to eq [
          "Otonal +1", "Otonal +3", "Otonal +5", "Otonal +7",
          "Utonal 1.3.5", "Utonal 1.3.7", "Utonal 1.5.7", "Utonal 3.5.7"
        ]
      end

      it { expect(hexany.chords.map(&:ratios)).to eq [
        [Tonal::ReducedRatio.new(5,4), Tonal::ReducedRatio.new(3,2), Tonal::ReducedRatio.new(7,4)],
        [Tonal::ReducedRatio.new(21,16), Tonal::ReducedRatio.new(3,2), Tonal::ReducedRatio.new(15,8)],
        [Tonal::ReducedRatio.new(35,32), Tonal::ReducedRatio.new(5,4), Tonal::ReducedRatio.new(15,8)],
        [Tonal::ReducedRatio.new(35,32), Tonal::ReducedRatio.new(21,16), Tonal::ReducedRatio.new(7,4)],
        [Tonal::ReducedRatio.new(5,4), Tonal::ReducedRatio.new(3,2), Tonal::ReducedRatio.new(15,8)],
        [Tonal::ReducedRatio.new(21,16), Tonal::ReducedRatio.new(3,2), Tonal::ReducedRatio.new(7,4)],
        [Tonal::ReducedRatio.new(35,32), Tonal::ReducedRatio.new(5,4), Tonal::ReducedRatio.new(7,4)],
        [Tonal::ReducedRatio.new(35,32), Tonal::ReducedRatio.new(21,16), Tonal::ReducedRatio.new(15,8)],
      ] }

      it { expect(hexany.chords.map(&:steps)).to eq [
        [1, 3, 4], [2, 3, 5], [0, 1, 5], [0, 2, 4],
        [1, 3, 5], [2, 3, 4], [0, 1, 4], [0, 2, 5]
      ] }

      it "exposes the factor tuple behind each note, parenthesized and ratio-ordered" do
        expect(hexany.chords.map(&:factors)).to eq [
          "(1)(5),(1)(3),(1)(7)", "(3)(7),(3)(1),(3)(5)", "(5)(7),(5)(1),(5)(3)", "(7)(5),(7)(3),(7)(1)",
          "(1)(5),(1)(3),(3)(5)", "(3)(7),(1)(3),(1)(7)", "(5)(7),(1)(5),(1)(7)", "(5)(7),(3)(7),(3)(5)"
        ]
      end
    end

    it "generalizes the factor column to take-tuples for larger CPS" do
      expect(eikosany.chords.first.factors).to eq "(1)(3)(11),(1)(3)(7),(1)(3)(9),(1)(3)(5)"
    end
  end

  describe "#note_factors" do
    let(:hexany) { Tonal::Scale.cps }
    let(:eikosany) { Tonal::Scale.cps(1, 3, 5, 7, 9, 11, take: 3) }

    it { expect(hexany.note_factors).to eq [[5, 7], [1, 5], [3, 7], [1, 3], [1, 7], [3, 5]] }
    it { expect(hexany.note_factors.size).to eq hexany.count }
    it { expect(hexany.note_factors).to all(have_attributes(size: 2)) }
    it { expect(eikosany.note_factors.compact.size).to eq eikosany.count }
    it { expect(eikosany.note_factors).to all(have_attributes(size: 3)) }

    it "each tuple's octave-reduced product is that degree's ratio" do
      hexany.note_factors.each_with_index do |tuple, degree|
        product = tuple.inject(:*)
        expect(Tonal::ReducedRatio.new(product).to_r).to eq hexany[degree].to_r
      end
    end
  end

  describe "#shared_factor_graph" do
    let(:hexany) { Tonal::Scale.cps }

    it { expect(hexany.shared_factor_graph[0]).to eq [[1, [5]], [2, [7]], [4, [7]], [5, [5]]] }
    it { expect(hexany.shared_factor_graph.values.map(&:size).uniq).to eq [4] }
    it "omits the complementary pair (no shared factor)" do
      expect(hexany.shared_factor_graph[0].map(&:first)).not_to include(3)
    end
    it "is symmetric" do
      graph = hexany.shared_factor_graph
      graph.each do |degree, neighbours|
        neighbours.each { |(other, shared)| expect(graph[other]).to include([degree, shared]) }
      end
    end
  end

  describe "#factor_walk" do
    let(:hexany) { Tonal::Scale.cps }

    it { expect(hexany.factor_walk).to match_array(hexany.indices) }
    it { expect(hexany.factor_walk(start: 2).first).to eq 2 }
    it { expect(Tonal::Scale.cps(1, 3, 5, 7, 9, take: 2).factor_walk.size).to eq 10 }

    it "every adjacent pair shares a generating factor" do
      tuples = hexany.note_factors
      hexany.factor_walk.each_cons(2) { |a, b| expect(tuples[a] & tuples[b]).not_to be_empty }
    end

    it "closes the loop when closed: true" do
      tuples = hexany.note_factors
      walk = hexany.factor_walk(closed: true)
      expect(tuples[walk.last] & tuples[walk.first]).not_to be_empty
    end

    it "stays factor-coherent for the eikosany" do
      eikosany = Tonal::Scale.cps(1, 3, 5, 7, 9, 11, take: 3)
      tuples = eikosany.note_factors
      eikosany.factor_walk.each_cons(2) { |a, b| expect(tuples[a] & tuples[b]).not_to be_empty }
    end
  end
end

# TO CONSIDER
# .exploded_superparticular(basis: 5/4r)
# .meru(upto = 15, seeds: [0, 1], indices: [-1, -2], coeff: [1, 1])
# .series(range:, base:, sub: false)
# .mirror(range=(8..16), fund: 1)
# .pcs
# .constant_structure
# .tetrachordal(scale_name = 'pythagoras.diatonic')
# .diatonic(scale_name = 'architas')
# .dodecatonic(scale_name = 'highschool1')
# .lambdoma
# .tempered
# .top(basis: [2/1r, 3/2r, 5/4r], superpart: 81/80r)

# def initialize(*ratios, name: "Unamed", description: "Undescribed")
# def self.identity_ratio
# def self.from_scl(file_location)
# def self.from_scalarchive(scale_name)
# def self.from_yaml(file_location)
# def self.from_json(file_location)
# def to_yaml(file_name)
# def to_scl(file_name=nil)
# def to_json(file_name)
# def Scale(*ratios, name: "Unamed", description: "Undescribed")
