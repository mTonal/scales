require "spec_helper"
require "tmpdir"

# Where and how each exporter writes, so the exporters can share one implementation.
#
RSpec.describe "Scale exporters" do
  let(:dir) { Pathname.new(Dir.mktmpdir) }

  {
    to_scl: [Tonal::IO::Scl, ".scl", -> { Tonal::Scale.edo(12) }, ->(scale) { scale }],
    to_kbm: [Tonal::IO::Kbm, ".kbm", -> { Tonal::Scale.edo(12) }, ->(scale) { scale }],
    "ChordSet#to_musaic": [Tonal::IO::Musaic, ".yaml", -> { Tonal::Scale.cps }, ->(scale) { scale.chords }]
  }.each do |exporter, (writer, extension, build, receiver)|
    describe exporter.to_s do
      let(:scale) { build.call }
      let(:exporting) { ->(*args, **kwargs) { receiver.call(scale).public_send(exporter.to_s.split("#").last, *args, **kwargs) } }
      def export(*args, **kwargs) = exporting.call(*args, **kwargs)

      it "writes to <location>/<count>/<file name> and returns the byte count" do
        bytes = export("exported", location: dir)
        path = dir.join(scale.count.to_s, "exported#{extension}")
        expect(path).to exist
        expect(bytes).to eq path.size
      end

      it "writes to <location>/faves/<count> when fave: true" do
        export("exported", location: dir, fave: true)
        expect(dir.join("faves", scale.count.to_s, "exported#{extension}")).to exist
      end

      it "names the file after the scale when no file name is given" do
        scale.name = "Named scale"
        export(location: dir)
        expect(dir.join(scale.count.to_s, "Named scale#{extension}")).to exist
      end

      it "writes under the writer's root directory when no location is given" do
        allow(writer).to receive(:root_directory).and_return(dir)
        export("exported")
        expect(dir.join(scale.count.to_s, "exported#{extension}")).to exist
      end

      it "writes the scale's name" do
        scale.name = "Named scale"
        export("exported", location: dir)
        expect(dir.join(scale.count.to_s, "exported#{extension}").read).to include "Named scale"
      end
    end
  end

  describe "Tonal::IO::Scl.new" do
    it "defaults the location to the root directory" do
      allow(Tonal::IO::Scl).to receive(:root_directory).and_return(dir)
      Tonal::IO::Scl.new("default", name: "n", description: "d", pitches: ["2/1"]).write
      expect(dir.join("default.scl")).to exist
    end
  end
end
