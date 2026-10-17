require "spec_helper"
require "tmpdir"

RSpec.describe Tonal::IO::Musaic do
  let(:hexany) { Tonal::Scale.cps }

  def writer(**overrides)
    described_class.new("hexany", **{
      chords: hexany.chords,
      name: hexany.name,
      description: hexany.description,
      pitches: hexany.to_r.map(&:to_s),
      location: Dir.mktmpdir,
      tempo: 110
    }.merge(overrides))
  end

  describe "#to_h" do
    subject(:program) { writer.to_h.fetch("program") }

    it { expect(program["mpe"]).to be true }
    it { expect(program["tempo"]).to eq 110 }
    it { expect(program["base_midi"]).to eq 60 }
    it { expect(program.dig("tuning", "ratios")).to eq ["35/32", "5/4", "21/16", "3/2", "7/4", "15/8", "2/1"] }

    it "omits tempo entirely when not given" do
      expect(writer(tempo: nil).to_h.fetch("program")).not_to have_key("tempo")
    end

    it "rejects an unknown form" do
      expect { writer(form: :nonsense) }.to raise_error(ArgumentError)
    end

    describe "the :chords region (default)" do
      subject(:region) { program.dig("tracks", 0, "regions", 0) }

      it { expect(program.dig("tracks", 0, "regions", 0)).to have_key("chords") }

      it "is one CPS chord per row, each row a single chord slot, degrees +1" do
        expect(region["chords"].size).to eq hexany.chords.count
        expect(region["chords"]).to all(have_attributes(size: 1))
        expect(region["chords"].flatten).to all(be_between(1, hexany.count))
      end

      it "each slot matches a CPS chord's steps + 1" do
        shifted = hexany.chords.map { |chord| chord.steps.map { |step| step + 1 }.sort }
        expect(region["chords"].map { |row| row.first.sort }).to match_array(shifted)
      end

      it "walks by shared tones with a sequential fallback" do
        expect(region.dig("chords_process", "across_rows")).to eq [
          {"transition" => "one_common"},
          {"transition" => "two_common"},
          {"transition" => "sequential"}
        ]
      end

      it "orders rows so each shares a tone with the previous" do
        region["chords"].map(&:first).each_cons(2) { |a, b| expect(a & b).not_to be_empty }
      end
    end

    describe "the :arpeggio region" do
      subject(:region) { writer(form: :arpeggio).to_h.dig("program", "tracks", 0, "regions", 0) }

      it { expect(region).to have_key("notes") }
      it { expect(region["notes"].size).to eq hexany.chords.count }
      it { expect(region.dig("notes_process", "within_row")).to eq [{"method" => "sequential"}] }
      it { expect(region.dig("notes_process", "across_rows")).to include({"transition" => "one_common"}) }
    end
  end

  describe "#write" do
    def write_to(dir, **opts)
      hexany.to_musaic("hexany", location: dir, **opts)
      Dir[File.join(dir, "**", "hexany.yaml")].first
    end

    it "renders a header legend naming each chord and its factors" do
      output = File.read(write_to(Dir.mktmpdir))
      expect(output).to include("# #{hexany.name}")
      expect(output).to match(/#   row 0  (Otonal|Utonal)/)
      expect(output).to include("(1)(5)")
    end

    it "produces :chords YAML that round-trips with the period last" do
      doc = YAML.load_file(write_to(Dir.mktmpdir))
      expect(doc.dig("program", "tuning", "ratios").last).to eq "2/1"
      expect(doc.dig("program", "tracks", 0, "regions", 0, "chords")).to be_an(Array)
    end

    it "produces :arpeggio YAML with a notes matrix" do
      doc = YAML.load_file(write_to(Dir.mktmpdir, form: :arpeggio))
      expect(doc.dig("program", "tracks", 0, "regions", 0, "notes")).to be_an(Array)
    end
  end

  describe "Tonal::Scale::IO#to_musaic" do
    it "supports the eikosany" do
      dir = Dir.mktmpdir
      Tonal::Scale.cps(1, 3, 5, 7, 9, 11, take: 3).to_musaic("eikosany", location: dir)
      doc = YAML.load_file(Dir[File.join(dir, "**", "eikosany.yaml")].first)
      expect(doc.dig("program", "tuning", "ratios").size).to eq 21
    end

    it "raises for a scale without embedded chords" do
      expect { Tonal::Scale.edo(12).to_musaic("nope", location: Dir.mktmpdir) }
        .to raise_error(NotImplementedError)
    end

    describe "a tonality diamond" do
      let(:diamond) { Tonal::Scale.diamond(1, 3, 5, 7) }

      def diamond_doc(name, **opts)
        dir = Dir.mktmpdir
        diamond.to_musaic(name, location: dir, **opts)
        YAML.load_file(Dir[File.join(dir, "**", "#{name}.yaml")].first)
      end

      it "defaults to every nested sub-Ntad (dyads through the full Ntad)" do
        rows = diamond_doc("diamond7").dig("program", "tracks", 0, "regions", 0, "chords")
        expect(rows.size).to eq diamond.chords(2..).count
        expect(rows.flatten).to all(be_between(1, diamond.count))
      end

      it "names each otonal/utonal chord in the header legend" do
        dir = Dir.mktmpdir
        diamond.to_musaic("diamond7", location: dir)
        output = File.read(Dir[File.join(dir, "**", "diamond7.yaml")].first)
        expect(output).to match(/#   row 0  (Otonal|Utonal) \w+, /)
        expect(output).to include("(1)/(1)")
      end
    end
  end
end
