require "spec_helper"

RSpec.describe Tonal::Scale::Conversions do
  let(:scale) { Tonal::Scale.edo(7) }

  describe "#to_cents" do
    it "returns the cents values of the notes of the scale" do
      expect(described_class.new(scale).to_cents).to eq [0.0, 171.43, 342.86, 514.29, 685.71, 857.14, 1028.57]
    end

    context "with from_base: true" do
      let(:scale) { Tonal::Scale.new(5/4r, 3/2r, 15/8r) }

      it "returns the cents of the notes measured up from the first note" do
        expect(described_class.new(scale).to_cents(from_base: true)).to eq [0.0, 315.64, 701.96]
      end
    end
  end

  describe "#to_log2" do
    #it "returns the log2 values of the notes of the scale" do
    #  expect(described_class.new(scale).to_log2).to eq [0.0, 0.14285714285714274, 0.28571428571428564, 0.4285714285714286, 0.5714285714285714, 0.7142857142857143, 0.8571428571428571]
    #end
  end

  describe "#to_f" do
    it "returns the float values of the notes of the scale" do
      expect(described_class.new(scale).to_f).to eq [1.0, 1.1, 1.22, 1.35, 1.49, 1.64, 1.81]
    end
  end

  describe "#to_r" do
    it "returns the rational values of the notes of the scale" do
      expect(described_class.new(scale).to_r).to eq [1/1r, 4972377122365053/4503599627370496r, 2744974719417411/2251799813685248r, 3030697803008479/2251799813685248r, 3346161663415923/2251799813685248r, 7388924007269683/4503599627370496r, 2039508378439785/1125899906842624r]
    end
  end

  describe "#to_midi" do
    it "returns the MIDI numbers of the notes of the scale" do
      expect(described_class.new(scale).to_midi).to eq [60, 61, 62, 63, 64, 65, 66]
    end

    it "returns the MIDI note objects of the notes of the scale" do
      expect(described_class.new(scale).to_midi(values_only: false)).to eq [Tonal::Midi::Note.new(number: 60), Tonal::Midi::Note.new(number: 61), Tonal::Midi::Note.new(number: 62), Tonal::Midi::Note.new(number: 63), Tonal::Midi::Note.new(number: 64), Tonal::Midi::Note.new(number: 65), Tonal::Midi::Note.new(number: 66)]
    end
  end

  describe "#to_pitch_bends" do
    let(:just_scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) }

    it "returns the nearest 12-TET MIDI note, cents offset and MPE pitch bends of the notes of the scale" do
      expect(described_class.new(just_scale).to_pitch_bends).to eq [[1/1r, 60, 0.0, 8192, 0], [5/4r, 64, -13.69, 8169, -23], [3/2r, 67, 1.96, 8195, 3], [7/4r, 70, -31.17, 8139, -53]]
    end

    it "scales the bend to the given bend range" do
      expect(described_class.new(just_scale).to_pitch_bends(bend_range: 2)[1]).to eq [5/4r, 64, -13.69, 7631, -561]
    end

    it "places the 1/1 on the given MIDI root" do
      expect(described_class.new(just_scale).to_pitch_bends(midi_root: 57).map{|bend| bend[1]}).to eq [57, 61, 64, 67]
    end

    it "rounds to the next equave's MIDI note when the ratio is nearer to it" do
      expect(described_class.new(Tonal::Scale.new(1/1r, 1999/1000r)).to_pitch_bends.last[1..2]).to eq [72, -0.87]
    end

    it "clamps bends that exceed the bend range" do
      expect(described_class.new(Tonal::Scale.new(1/1r, 13/8r, 7/4r)).to_pitch_bends(bend_range: 0.1).map{|bend| bend[3]}).to eq [8192, 16383, 0]
    end
  end

  describe "#to_radians" do
    it "returns the radians of the scale" do
      expect(described_class.new(scale).to_radians).to eq [0.0, 0.9, 1.8, 2.69, 3.59, 4.49, 5.39]
    end
  end

  describe "#to_degrees" do
    it "returns the degrees of the scale" do
      expect(described_class.new(scale).to_degrees).to eq [0.0, 51.43, 102.86, 154.29, 205.71, 257.14, 308.57]
    end
  end

  describe "#to_circle" do
    it "returns the circular coordinates of the scale" do
      expect(described_class.new(scale).to_circle).to eq [[-6.123233995736766e-17, 1.0],[0.7833269096274833, 0.6216099682706646],[0.9738476308781953, -0.22720209469308683],[0.4363990821601268, -0.8997532112139411],[-0.4335308827527177, -0.9011387094668886],[-0.9753733187046665, -0.22056039798441862],[-0.7790726726314032, 0.6269336254811688]]
    end
  end
end
