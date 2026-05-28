require "spec_helper"

RSpec.describe Tonal::Scale::Mappers do
  let(:scale) { Tonal::Scale.edo(7) }

  describe "#to_cents" do
    it "returns the cents values of the notes of the scale" do
      expect(described_class.new(scale).to_cents).to eq [0.0, 171.43, 342.86, 514.29, 685.71, 857.14, 1028.57]
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
