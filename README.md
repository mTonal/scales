# tonal/scales

A Ruby library for creating and analyzing microtonal scales built on rational arithmetic.

## Installing

    gem install tonal-scales

## Architecture

`tonal/scales` is organized around two core abstractions — **Sequence** and **Scale** — supported by analysis, mapping, and I/O helpers.

```
Tonal::Sequence          # generates a raw (unreduced, unordered) series of ratios
       ↓
Tonal::Scale             # wraps a sequence; reduces ratios to the equave, sorts, deduplicates
       ├── Analysis      # intervals, efficiency, approximations, constant structure, modes
       ├── Mappers       # converts the scale to cents, log2, floats, degrees, radians, etc.
       └── IO            # reads/writes SCL files and the Scala archive
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

### Tonal::Scale::Analysis

Provides analytical tools delegated directly from `Scale`:

- **Approximations** — best-fitting EDO, continued-fraction approximations
- **Descriptions** — prime divisions, heights, steps in cents
- **Efficiencies** — cent distance from a target ratio to the nearest scale step
- **Intervals** — all intervals (occurrences, unique intervals)
- **Statistics** — mean, variance, standard deviation of the scale's cent values
- Constant structure detection, modes, combinations

### Tonal::Scale::Mappers

Converts a scale's ratios to other representations:

```ruby
scale = Tonal::Scale.edo(7)
scale.to_cents    # => [0.0, 171.43, 342.86, 514.29, 685.71, 857.14, 1028.57]
scale.to_log2     # => [0.0, 0.14, 0.29, 0.43, 0.57, 0.71, 0.86]
scale.to_degrees  # => [0.0, 51.43, 102.86, 154.29, 205.71, 257.14, 308.57]
scale.to_circle   # circular coordinates for visualization
```

### Tonal::Scale::IO

Reads and writes scales in standard formats:

```ruby
Tonal::Scale.from_scl("path/to/scale.scl")     # parse a Scala SCL file
Tonal::Scale.from_scalarchive("wilson7")        # load from the Scala archive
scale.to_scl("my-scale")                        # write to SCL file
```

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
| `.harmonic` | Harmonic series over a range | `Tonal::Scale.harmonic` → `[1/1, 9/8, 5/4, 11/8, 3/2, 13/8, 7/4, 15/8]` |
| `.intra_proportional` | Proportional intervals within a range | `Tonal::Scale.intra_proportional(3/2r, 7/4r)` → `[3/2, 13/8, 7/4]` |
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
scale.constant_structure?  # => false
scale.efficiency_with(3/2r) # how well the scale approximates 3/2

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
