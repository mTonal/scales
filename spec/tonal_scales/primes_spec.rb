require "spec_helper"

RSpec.describe Tonal::Scale::Primes do
  subject { described_class.new(scale) }

  describe "#max_primes" do
    let(:scale) { Tonal::Scale.cps }

    it "returns the largest prime of each ratio" do
      expect(subject.max_primes).to eq [7, 5, 7, 3, 7, 5]
    end
  end

  describe "#heights" do
    let(:scale) { Tonal::Scale.harmonic }

    it "returns the Benedetti height of each ratio by default" do
      expect(subject.heights).to eq [1, 72, 20, 88, 6, 104, 28, 120]
    end

    it "reports an unknown measure" do
      expect(subject.heights(method: :blah)).to eq "Unknown measure blah. Use #{described_class::MEASURES}"
    end
  end

  describe "#prime_divisions" do
    let(:scale) { Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r) }

    it "returns an array of prime divisors of the ratio's numerators and denominators" do
      expect(subject.prime_divisions).to eq [[[], []], [[[5, 1]], [[2, 2]]], [[[3, 1]], [[2, 1]]], [[[7, 1]], [[2, 2]]]]
    end
  end

  describe "#prime_vectors" do
    let(:scale) { Tonal::Scale.new(3/2r, 7/4r) }

    it "returns a Vector with the prime factors of the notes of the scale" do
      expect(subject.prime_vectors).to eq [Vector[-1, 1], Vector[-2, 0, 0, 1]]
    end
  end

  context "with the irrational ratios of an EDO" do
    let(:scale) { Tonal::Scale.edo(7) }

    it "gives nil for prime-based values instead of factoring them" do
      expect(subject.prime_vectors.compact).to be_empty
      expect(subject.max_primes.compact).to be_empty
      expect(subject.prime_divisions.drop(1).compact).to be_empty
    end
  end

  describe "limit:" do
    let(:scale) { Tonal::Scale.new(1/1r, Tonal::ReducedRatio.new(3**26, 2**41), Tonal::ReducedRatio.new(10_007, 8192)) }

    it "keeps large ratios built from small primes, and primes above the default limit's own range" do
      expect(subject.max_primes).to eq [nil, 3, 10_007]
    end

    it "gives nil for ratios with a prime that can't be confirmed within the limit" do
      expect(subject.max_primes(limit: 100)).to eq [nil, 3, nil]
      expect(subject.prime_vectors(limit: 100).last).to be_nil
    end
  end
end
