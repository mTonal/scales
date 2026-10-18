require "spec_helper"

# The behaviour every Tonal::Scale must honour, whatever subclass it is.
# Run against each constructor so a subclass can't quietly break an inherited method.
#
RSpec.shared_examples "a Tonal::Scale" do
  let(:factor) { 3/2r }
  let(:other) { Tonal::Scale.new(7/6r) }

  def scale_of(ratios) = Tonal::Scale.new(*ratios)

  describe "#*" do
    it "returns a Tonal::Scale of the ratios multiplied by a factor" do
      result = subject * factor
      expect(result).to be_instance_of Tonal::Scale
      expect(result.to_a).to eq scale_of(subject.to_r.map { |r| r * factor }).to_a
    end

    it "returns the same scale with the factor on the left-hand side" do
      expect((factor * subject).to_a).to eq (subject * factor).to_a
    end

    it "returns a Tonal::Scale of the cross-product with another scale" do
      rhs = Tonal::Scale.new(1/1r, 3/2r)
      result = subject * rhs
      expect(result).to be_instance_of Tonal::Scale
      expect(result.to_a).to eq scale_of(subject.to_r.product(rhs.to_r).map { |a, b| a * b }).to_a
    end
  end

  describe "#/" do
    it "returns a Tonal::Scale of the ratios divided by a factor" do
      result = subject / factor
      expect(result).to be_instance_of Tonal::Scale
      expect(result.to_a).to eq scale_of(subject.to_r.map { |r| r / factor }).to_a
    end
  end

  describe "#**" do
    it "returns a Tonal::Scale of the ratios raised to a power" do
      result = subject ** 2
      expect(result).to be_instance_of Tonal::Scale
      expect(result.to_a).to eq scale_of(subject.to_r.map { |r| r ** 2 }).to_a
    end
  end

  describe "#+" do
    it "returns a Tonal::Scale joining the ratios of both scales" do
      result = subject + other
      expect(result).to be_instance_of Tonal::Scale
      expect(result.to_a).to eq scale_of(subject.to_r + other.to_r).to_a
    end
  end

  describe "#name" do
    it "has a default name" do
      expect(subject.name).to be_a(String).and(satisfy { |name| !name.empty? })
    end

    it "returns the assigned name" do
      subject.name = "Assigned name"
      expect(subject.name).to eq "Assigned name"
    end
  end

  describe "#description" do
    it "has a default description" do
      expect(subject.description).to be_a(String).and(satisfy { |description| !description.empty? })
    end

    it "returns the assigned description" do
      subject.description = "Assigned description"
      expect(subject.description).to eq "Assigned description"
    end
  end

  describe "area accessors" do
    {
      structure: Tonal::Scale::Structure,
      primes: Tonal::Scale::Primes,
      approximations: Tonal::Scale::Approximations,
      efficiency: Tonal::Scale::Efficiency,
      report: Tonal::Scale::Reporter
    }.each do |accessor, service|
      it "##{accessor} returns a #{service} of the scale" do
        expect(subject.public_send(accessor)).to be_instance_of(service).and(have_attributes(scale: subject))
      end
    end

    it "renders a pitch bend report" do
      expect(subject.report.pitch_bends.rows.count).to eq subject.count
    end
  end

  describe "#to_musaic" do
    it "is offered only by scales that have chords" do
      expect(subject.respond_to?(:to_musaic)).to eq subject.respond_to?(:chords)
    end
  end
end

RSpec.describe "Tonal::Scale contract" do
  {
    "Tonal::Scale.new" => -> { Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) },
    "afs" => -> { Tonal::Scale.afs },
    "arithmetic" => -> { Tonal::Scale.arithmetic },
    "asymptotic" => -> { Tonal::Scale.asymptotic },
    "branching" => -> { Tonal::Scale.branching },
    "convolved_proportional" => -> { Tonal::Scale.convolved_proportional(5/4r, 3/2r) },
    "cps" => -> { Tonal::Scale.cps },
    "diamond" => -> { Tonal::Scale.diamond },
    "edo" => -> { Tonal::Scale.edo(12) },
    "genus" => -> { Tonal::Scale.genus },
    "harmonic" => -> { Tonal::Scale.harmonic },
    "intra_proportional" => -> { Tonal::Scale.intra_proportional(5/4r, 3/2r) },
    "lattice" => -> { Tonal::Scale.lattice },
    "linear" => -> { Tonal::Scale.linear },
    "polyharmonic" => -> { Tonal::Scale.polyharmonic },
    "proportional" => -> { Tonal::Scale.proportional(5/4r, 3/2r) },
    "recurrence" => -> { Tonal::Scale.recurrence },
    "subharmonic" => -> { Tonal::Scale.subharmonic },
    "superparticular" => -> { Tonal::Scale.superparticular },
    "superpartient" => -> { Tonal::Scale.superpartient }
  }.each do |constructor, build|
    context constructor do
      subject { build.call }
      it_behaves_like "a Tonal::Scale"
    end
  end
end
