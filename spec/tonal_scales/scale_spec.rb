require "spec_helper"

RSpec.describe Tonal::Scale do
  describe "initialization" do
    context "with rationals" do
      let(:ratios) { [1/1r, 3/2r, 7/4r] }
      it { expect(described_class.new(ratios).to_a).to eq ratios }
    end

    context "with ratios" do
      let(:ratios) { [Tonal::ReducedRatio.new(1/1r), Tonal::Ratio.new(3/2r), Tonal::Ratio.new(7,4)] }
      it { expect(described_class.new(ratios).to_a).to eq ratios }
    end

    context "with rationals and ratios" do
      let(:ratios) { [Tonal::ReducedRatio.new(1/1r), 3/2r, Tonal::Ratio.new(7,4)] }
      it { expect(described_class.new(ratios).to_a).to eq ratios }
    end

    context "with a block" do
      let(:scale) { described_class.new{|scale| scale << 1/1r << 3/2r << 7/4r}}
      it { expect(scale.to_a).to eq [1/1r, 3/2r, 7/4r] }
    end

    describe "#description" do
      let(:description) { "My scale" }
      let(:scale) { described_class.new(1/1r, 5/4r, 3/2r) }

      context "when not provided" do
        it "returns a default" do
          expect(scale.description).to eq "Undescribed"
        end

        context "when set after initialization" do
          it "returns the assigned description" do
            scale.description = description
            expect(scale.description).to eq description
          end
        end
      end

      context "when provided" do
        let(:scale) { described_class.new(1/1r, 5/4r, 3/2r, description: description) }
        it "returns the assigned description" do
          expect(scale.description).to eq description
        end
      end
    end

    describe "#name" do
      let(:name) { "My scale" }
      let(:scale) { described_class.new(1/1r, 5/4r, 3/2r) }

      context "when not provided" do
        it "returns a default" do
          expect(scale.name).to eq "Unamed"
        end

        context "when set after initialization" do
          it "returns the assigned name" do
            scale.name = name
            expect(scale.name).to eq name
          end
        end
      end

      context "when provided" do
        let(:scale) { described_class.new(1/1r, 5/4r, 3/2r, name: name) }
        it "returns the assigned name" do
          expect(scale.name).to eq name
        end
      end
    end
  end

  describe "Comparing" do
    context "when notes are the same" do
      let(:ratios1) { [1/1r, 5/4r, 3/2r, 7/4r] }
      let(:scale1) { described_class.new(ratios1) }
      let(:scale2) { described_class.new(ratios1)}

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

  describe "instance methods" do
    describe "#count" do
      let(:modulo) { 12 }

      it "returns the number of notes of the scale" do
        expect(described_class.edo(modulo).count).to eq modulo
      end
    end

    describe "#indices" do
      let(:modulo) { 12 }

      it "returns the indices of each note of the scale" do
        expect(described_class.edo(modulo).indices).to eq [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
      end
    end

    describe "#to_cents" do
      it "returns the cents values of the notes of the scale" do
        expect(described_class.edo(7).to_cents).to eq [0.0, 171.43, 342.86, 514.29, 685.71, 857.14, 1028.57]
      end
    end

    describe "#to_log2" do
      it "returns the log2 values of the notes of the scale" do
        expect(described_class.edo(7).to_log2).to eq [0.0, 0.14285714285714274, 0.28571428571428564, 0.4285714285714286, 0.5714285714285714, 0.7142857142857143, 0.8571428571428571]
      end
    end

    describe "#to_f" do
      it "returns the float values of the notes of the scale" do
        expect(described_class.edo(7).to_f).to eq [1.0, 1.1040895136738123, 1.2190136542044754, 1.3459001926323562, 1.4859942891369484, 1.640670712015276, 1.8114473285278132]
      end
    end

    describe "#to_r" do
      it "returns the rational values of the notes of the scale" do
        expect(described_class.edo(7).to_r).to eq [1/1r, 4972377122365053/4503599627370496r, 2744974719417411/2251799813685248r, 3030697803008479/2251799813685248r, 3346161663415923/2251799813685248r, 7388924007269683/4503599627370496r, 2039508378439785/1125899906842624r]
      end
    end

    describe "#to_radians" do
    end

    describe "#to_degrees" do
    end

    describe "#to_circle" do
    end

    describe "#invert" do
    end

    describe "#rotate" do
    end

    describe "#mirror" do
    end

    describe "#mirror2" do
    end

    describe "#negative" do
    end

    describe "#reciprocal" do
    end

    describe "#reciprocal!" do
    end

    describe "Inspectors" do
      describe "#efficiency_of" do
      end

      describe "#nearest_hundredth_cents" do
      end

      describe "#nearest_hundredth_diffs" do
      end

      describe "#nearest_ratios" do
      end

      describe "#sample" do
      end

      describe "#ratios_at" do
      end

      describe "#by_serial_steps" do
      end

      describe "#by_best_expressions_of" do
      end

      describe "#maps_on" do
      end

      describe "#line_plot" do
      end

      describe "#frets" do
      end

      describe "#cents_distance_from" do
      end

      describe "#norm_on_step" do
      end

      # TODO Still needed?
      describe "Still needed?" do
        describe "#nearest_rationals" do
          it "does something" do

          end
        end

        describe "#table" do
          it "does something" do

          end
        end
      end
    end
  end

  describe "class methods" do
    describe ".afs" do
      it { expect(described_class.afs).to eq Tonal::Scale.new(1/1r, 9/8r, 5/4r, 11/8r, 3/2r, 13/8r, 7/4r, 15/8r) }
    end

    describe ".composite" do
      it { }
    end

    describe ".cps" do
      it { expect(described_class.cps).to eq Tonal::Scale.new(35/32r, 5/4r, 21/16r, 3/2r, 7/4r, 15/8r) }
    end

    describe ".edo" do
      it { expect(described_class.edo(3)).to eq Tonal::Scale.new(2**(0.0/3), 2**(1.0/3), 2**(2.0/3)) }
    end

    describe ".harmonic" do
      it { expect(described_class.harmonic).to eq Tonal::Scale.new(1/1r, 9/8r, 5/4r, 11/8r, 3/2r, 13/8r, 7/4r, 15/8r) }
    end

    describe ".intra_proportional" do
      it { expect(described_class.intra_proportional(3/2r, 7/4r)).to eq Tonal::Scale.new(3/2r, 13/8r, 7/4r) }
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

    describe ".superparticular" do
      it { expect(described_class.superparticular).to eq Tonal::Scale.new(1/1r, 13/12r, 12/11r, 11/10r, 10/9r, 9/8r, 8/7r, 7/6r, 6/5r, 5/4r, 4/3r, 3/2r) }
    end

    describe ".superpartient" do
      it { expect(described_class.superpartient).to eq Tonal::Scale.new(1/1r, 13/11r, 6/5r, 11/9r, 5/4r, 9/7r, 4/3r, 7/5r, 3/2r, 5/3r) }
    end
  end

  describe "Operators" do
    describe "#[]" do
      let(:ratios) { [1/1r, 9/8r, 5/4r, 11/8r, 3/2r, 13/8r, 7/4r, 15/8r] }
      context "with a single index" do
        it { expect(described_class.new(*ratios)[1]).to eq 9/8r }
      end

      context "with a couple of discontiguous indices" do
        it { expect(described_class.new(*ratios)[1, 3]).to eq [9/8r, 11/8r] }
      end

      context "with a range of indices" do
        it { expect(described_class.new(*ratios)[1..3]).to eq [9/8r, 5/4r, 11/8r] }
      end

      context "with a mix of indices" do
        it { expect(described_class.new(*ratios)[1..3, 5, 7]).to eq [9/8r, 5/4r, 11/8r, 13/8r, 15/8r] }
      end
    end

    describe "#[]=" do
    end

    describe "#<<" do
    end

    describe "#*" do
    end

    describe "#/" do
    end

    describe "#+" do
    end

    describe "#*=" do
    end

    describe "#/=" do
    end

    describe "#&=" do
    end

    describe "#|=" do
    end
  end

  describe "Describers" do
    describe "#labels" do
    end

    describe "#indices" do
      it { expect(described_class.new(5/4r, 7/4r).indices).to eq [0, 1] }
    end

    describe "#steps" do
      it { expect(described_class.new(5/4r, 7/4r).steps).to eq [Tonal::Step.new(modulo: 2, step: 1), Tonal::Step.new(modulo: 2, step: 2)] }
    end

    describe "#first" do
      it { expect(described_class.new(5/4r, 7/4r).first).to eq Tonal::Ratio.new(5/4r) }
    end

    describe "#steps_in_cents" do
    end

    describe "#steps_nearest_hundredth_cents" do
    end

    describe "#steps_nearest_whole_step_difference" do
    end

    describe "#best_expression_of" do
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

    describe "#inspect" do
    end
  end
end

# Scale constructor classes
# DONE - SPEC RUNS, EXECUTED IN ERB
# .edo(modulo)
# .linear(ratio=3/2r, upto: 12)
# .proportional
# .intra_proportional

# TO DO
# .afs(k: 12, p: 1, num: 1, start: 1)
# .meru(upto = 15, seeds: [0, 1], indices: [-1, -2], coeff: [1, 1])
# .cps(*set, take: 2)
# .harmonic(range=(8..16), fund: 1)
# .subharmonic(range=(8..16), fund: 1)

# .superparticulars(start=1, number=12, limit: RaducedRatio.new(ROS::IDENTITY_RATIO))
# .superpartients(start=1, number=12, part: 2, limit: RaducedRatio.new(ROS::IDENTITY_RATIO), exclusively: true)

# TO RECONSIDER
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
