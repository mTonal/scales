require "spec_helper"

RSpec.describe Tonal::IO::Scl do
  let(:fixtures_path) { Pathname.new(__dir__).join("fixtures") }

  describe ".read_from_file" do
    let(:file) { fixtures_path.join("sample_scale").sub_ext(".scl") }
    let(:scale) { described_class.read_from_file(file) }
    let(:ratios) { [1/1r, 17/16r, 9/8r, 5/4r, 11/8r, 3/2r, 13/8r, 7/4r, 15/8r] }

    it "parses an SCL file and returns a Tonal::Scale" do
      expect(scale).to be_a_kind_of(Tonal::Scale)
      expect(scale.description).to eq "Sample scale intended for Tonal::Scale specs"
      expect(scale.count).to eq 9
      expect(scale.to_r).to eq ratios
    end
  end
end
