# tonal/scales

A collection of helpers and tools for creating and analyzing microtonal scales.

## Installing

    gem install tonal-scales

## Architecture

`tonal/scales` is organized around two core abstractions, **Sequence** and **Scale**. A scale is explored through a few areas, each reached from the scale itself.

```
Tonal::Sequence          # generates a raw (unreduced, unordered) series of ratios
       ↓
Tonal::Scale                 # wraps a sequence; reduces ratios to the equave, sorts, deduplicates
       ├── Transformations   # scale.mode, invert, rotate, mirror, negative, expand… (new scales)
       ├── Conversions       # scale.to_cents, to_log2, to_midi, to_pitch_bends, to_degrees…
       ├── Structure         # scale.structure: intervals, occurrences, constant structure, MOS
       ├── Primes            # scale.primes: prime vectors, prime divisions, heights
       ├── Approximations    # scale.approximations: EDO steps, best-fitting EDO, simpler ratios
       ├── Efficiency        # scale.efficiency: EDO step efficiencies, mean, variance, std dev
       ├── Reporter          # scale.report: Terminal::Table reports
       └── IO                # scale.to_scl, Tonal::Scale.from_scl, the Scala archive
```

### Tonal::Sequence

A `Sequence` generates ratios using a mathematical rule before any octave reduction or sorting is applied.  Every `Scale` subclass delegates to a matching `Sequence` subclass via `init_sequence`.

### Tonal::Scale

A `Scale` owns a `SortedSet` of `Tonal::ReducedRatio` values (ratios reduced to the equave, default `2/1`).  It can be constructed from arbitrary ratios or from any named constructor.

```ruby
# From raw ratios
Tonal::Scale.new(1/1r, 9/8r, 5/4r, 3/2r, 7/4r)

# Block form
Tonal::Scale.new { |s| s << 1/1r << 5/4r << 3/2r }
```

### Exploring a scale

Transformations (which return new scales) and conversions (the `to_*` methods) are called on the scale directly. Each other area is a small service object reached through an accessor:

```ruby
scale = Tonal::Scale.harmonic
scale.mode(2).invert                     # Transformations
scale.structure.constant_structure?      # => false
scale.structure.occurrences              # every interval between notes, with its note pairs
scale.primes.heights                     # => [1, 72, 20, 88, 6, 104, 28, 120]
scale.approximations.best_fitting_edo
scale.approximations.steps(12)           # the ratios as 12-EDO steps
scale.efficiency.standard_deviation      # => 51.17
puts scale.report.cross_table            # intervals between every pair of notes
puts scale.report.inventory              # intervals with prime vectors and occurrences
```

### Tonal::Scale::Conversions

Converts a scale's ratios to other representations:

```ruby
scale = Tonal::Scale.edo(7)
scale.to_cents    # => [0.0, 171.43, 342.86, 514.29, 685.71, 857.14, 1028.57]
scale.to_log2     # => [0.0, 0.14, 0.29, 0.43, 0.57, 0.71, 0.86]
scale.to_degrees  # => [0.0, 51.43, 102.86, 154.29, 205.71, 257.14, 308.57]
scale.to_circle   # circular coordinates for visualization
```

#### MPE pitch bend in Logic

`to_pitch_bends` gives, for each ratio, the nearest 12-TET MIDI note and the pitch bend that retunes it: `[ratio, MIDI number, cents offset, 14-bit bend, signed bend]`. The bend range must match the instrument's (MPE member channels default to ±48 semitones).

```ruby
Tonal::Scale.new(1/1r, 5/4r, 3/2r, 7/4r).to_pitch_bends
# => [[1/1, 60, 0.0, 8192, 0], [5/4, 64, -13.69, 8169, -23], [3/2, 67, 1.96, 8195, 3], [7/4, 70, -31.17, 8139, -53]]
scale.to_pitch_bends(midi_root: 57, bend_range: 2)   # 1/1 on A3, ±2 semitone bend

puts Tonal::Scale.harmonic.report.pitch_bends
# ratio | note | MIDI | cents offset | bend (14-bit) | bend (signed)
```

### Tonal::Scale::IO

Reads and writes scales in standard formats:

```ruby
Tonal::Scale.from_scl("path/to/scale.scl")     # parse a Scala SCL file
Tonal::Scale.from_scalarchive("wilson7")        # load from the Scala archive
scale.to_scl("my-scale")                        # write to SCL file
scale.to_kbm("my-scale")                        # write a Scala keyboard map
Tonal::Scale.cps.to_musaic("hexany")            # write a musaic/1.0 program - block chords
Tonal::Scale.cps.to_musaic("hexany", form: :arpeggio)  # ...one tone at a time instead
Tonal::Scale.diamond.chords(4..6).to_musaic("diamond")  # a chosen slice of a scale's chords
```

`to_musaic` works for any scale whose `#chords` returns a `Tonal::Scale::ChordSet` — CPS, tonality diamond, and lattice. `scale.to_musaic(...)` exports the whole set (a diamond defaults to every nested sub-Ntad); call `to_musaic` on `scale.chords(...)` itself to write a narrower selection.

### CPS factor structure

A [Combination Product Set](https://en.xen.wiki/w/Combination_product_set) note is a product of `take` factors from the generating set. These methods expose that structure — useful for driving a walk between notes that share a generating factor:

```ruby
scale = Tonal::Scale.cps                        # the 2)4 hexany on 1·3·5·7
scale.note_factors                              # => [[5,7],[1,5],[3,7],[1,3],[1,7],[3,5]]  (by scale degree)
scale.shared_factor_graph[0]                    # => [[1,[5]],[2,[7]],[4,[7]],[5,[5]]]  (degree => [neighbour, shared factors])
scale.factor_walk                               # => [0,1,4,2,3,5]  — a degree ordering where every step shares a factor
```

`to_musaic` builds on this: it emits the scale as a Just-Intonation `tuning`, and its `#chords` as a matrix (block `chords`, or an `arpeggio` of single `notes`) that Musaic's `across_rows` transitions walk by shared tones — hence shared factors.

## Scale Types

Each scale type has a paired `Tonal::Sequence` subclass (raw series) and a `Tonal::Scale` subclass (octave-reduced, sorted):

| Constructor | Description | Example |
|-------------|-------------|---------|
| `.afs` | Arithmetic Frequency Sequence | `Tonal::Scale.afs` → `[1/1, 9/8, 5/4, 11/8, 3/2, 13/8, 7/4, 15/8]` |
| `.arithmetic` | Arithmetic series of partials | `Tonal::Scale.arithmetic` → `[1/1, 9/8, 5/4, 11/8, 3/2, 7/4]` |
| `.asymptotic` | Ratios converging to a limit | `Tonal::Scale.asymptotic` → `[1/1, 13/12, 12/11, ..., 3/2]` |
| `.branching` | Modular transposition of segments | `Tonal::Scale.branching` |
| `.convolved_proportional` | Proportional intervals convolved over segments | `Tonal::Scale.convolved_proportional(3/2r, 7/4r)` → `[3/2, 13/8, 7/4]` |
| `.cps` | Combination Product Set | `Tonal::Scale.cps` → `[35/32, 5/4, 21/16, 3/2, 7/4, 15/8]` |
| `.edo` | Equal Division of the Octave | `Tonal::Scale.edo(12)` |
| `.genus` | Euler-Fokker genus (harmonic-space lattice) | `Tonal::Scale.genus(factors: {3 => 2, 5 => 1})` → `[1/1, 9/8, 5/4, 45/32, 3/2, 15/8]` |
| `.harmonic` | Harmonic series over a range | `Tonal::Scale.harmonic` → `[1/1, 9/8, 5/4, 11/8, 3/2, 13/8, 7/4, 15/8]` |
| `.intra_proportional` | Proportional intervals within a range | `Tonal::Scale.intra_proportional(3/2r, 7/4r)` → `[3/2, 13/8, 7/4]` |
| `.lattice` | Multi-generator Euler-Fokker/Wilson harmonic lattice | `Tonal::Scale.lattice(primes: [3, 5, 7, 11, 13], max_weight: 2)` → 51 ratios |
| `.linear` | Linear (generator-based) scale | `Tonal::Scale.linear` → 12-tone Pythagorean |
| `.polyharmonic` | Multiple harmonic series | `Tonal::Scale.polyharmonic` |
| `.proportional` | Proportional series between two ratios | `Tonal::Scale.proportional(3/2r, 7/4r)` → `[1/1, 5/4, 3/2, 7/4]` |
| `.recurrence` | Recurrence relation sequence | `Tonal::Scale.recurrence` |
| `.subharmonic` | Subharmonic (undertone) series | `Tonal::Scale.subharmonic` |
| `.superparticular` | Superparticular (n+1)/n ratios | `Tonal::Scale.superparticular` |
| `.superpartient` | Superpartient (n+k)/n ratios | `Tonal::Scale.superpartient` |

## Usage Examples

```ruby
require "tonal/scales"

# Build a scale and analyze it
scale = Tonal::Scale.harmonic
scale.to_cents          # cent values of all notes
scale.modes             # all rotational modes
scale.structure.constant_structure?  # => false
scale.efficiency.efficiency_with(3/2r) # how well the scale approximates 3/2

# Transform a scale
scale.invert            # swap antecedents and consequents
scale.reciprocal        # return subharmonic mirror
scale.mode(2)           # rotate so step 2 becomes 1/1
scale.mirror            # Levy negative transformation mirror

# Arithmetic on scales
scale * (3/2r)          # transpose all notes by 3/2
scale1 + scale2         # join two scales

# Export
scale.to_scl("my-scale")           # write SCL file
scale.to_cents                     # array of cent values
```

## Authors

[Jose Hales-Garcia](mailto:jose@halesgarcia.com)

## License

This project is licensed under the [MIT] License.
