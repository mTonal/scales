require "spec_helper"
require "tmpdir"
require "yaml"

RSpec.describe Tonal::Scale::ChordSet do
  let(:scale) { Tonal::Scale.diamond(1, 3, 5, 7) }
  let(:chord_set) { scale.chords }

  describe "the Array-ish surface" do
    it { expect(chord_set).to be_a(Enumerable) }
    it { expect(chord_set.scale).to be(scale) }
    it { expect(chord_set.count).to eq 8 }
    it { expect(chord_set.size).to eq 8 }
    it { expect(chord_set.length).to eq 8 }
    it { expect(chord_set).not_to be_empty }
    it { expect(chord_set.first).to be_an_instance_of(Tonal::Scale::Chord) }
    it { expect(chord_set.last).to eq chord_set.to_a.last }
    it { expect(chord_set[0]).to be(chord_set.first) }
    it { expect(chord_set[1, 2].size).to eq 2 }
    it { expect(chord_set.map(&:name)).to eq chord_set.to_a.map(&:name) }
    it { expect(chord_set).to eq chord_set.to_a }
    it { expect(scale.chords(1)).to eq [] }
  end

  describe "#to_musaic" do
    def written(set, name, **opts)
      dir = Dir.mktmpdir
      set.to_musaic(name, location: dir, **opts)
      YAML.load_file(Dir[File.join(dir, "**", "#{name}.yaml")].first)
    end

    it "writes a musaic/1.0 program from the chords it holds" do
      doc = written(scale.chords(4), "diamond-tetrads")
      region = doc.dig("program", "tracks", 0, "regions", 0)
      expect(doc.dig("program", "tuning", "ratios").last).to eq "2/1"
      expect(region["chords"].size).to eq 8
      expect(region["chords"].flatten).to all(be_between(1, scale.count))
    end

    it "names the file and the tuning after the parent scale" do
      doc = written(scale.chords(4), "diamond-tetrads")
      expect(doc.dig("program", "tracks", 0, "regions", 0)).to have_key("chords")
      expect(doc.dig("program")).to have_key("tuning")
    end

    it "raises rather than write an empty program" do
      expect { scale.chords(1).to_musaic("nope", location: Dir.mktmpdir) }
        .to raise_error(ArgumentError, /no chords/)
    end

    it "works for a lattice's chords too" do
      lattice = Tonal::Scale.lattice(primes: [3, 5], max_weight: 2)
      doc = written(lattice.chords, "lattice-squares")
      expect(doc.dig("program", "tracks", 0, "regions", 0, "chords").size).to eq 4
    end
  end
end
