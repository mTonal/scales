# Sandi Metz's Four Rules — Detailed Reference

These rules come from Sandi Metz (author of *Practical Object-Oriented Design in
Ruby*) and the Rails Conf "Rules" talk. They are **heuristics, not laws**: their
purpose is to make you pause and justify a design, not to be obeyed blindly. The
original framing: *"You can break these rules only if you can talk your pair (or
your reviewer) into agreeing with you."*

---

## Rule 1 — A class can be no longer than 100 lines of code

### Rationale

- A class that fits on one or two screens can be understood as a whole.
- Length is a proxy for **number of responsibilities**. Long classes almost
  always violate the Single Responsibility Principle (SRP).
- Small classes are easier to name, test in isolation, reuse, and delete.

### Counting

Count lines of *actual code*. Exclude:

- the `class`/`end` lines
- blank lines
- comment-only lines

Namespacing modules and their `end` don't count. `private`/`protected` markers
are borderline — usually not counted.

### Common violations & causes

| Symptom | Underlying cause |
| --- | --- |
| God object (`User`, `Order`, `Account` with 400 lines) | Every feature bolted onto the central model |
| Class mixes persistence, formatting, and business rules | No separation between domain logic and I/O |
| Many private helper methods around one public method | A hidden collaborator wanting to be its own class |
| Long `case`/`when` on a `type` attribute | Missing polymorphism / STI-style branching |

### Refactoring strategies

1. **Extract Class** — group methods and the instance variables they touch;
   move them into a new class that the original delegates to.
2. **Single Responsibility split** — name the class out loud. If the name needs
   "and" (`InvoiceCalculatorAndMailer`), split on the "and".
3. **Replace conditional with polymorphism** — turn a `type` switch into a small
   class hierarchy or a set of strategy objects.
4. **Extract module** for genuinely shared behavior (but prefer composition over
   a pile of mixins).
5. **Move method** — a method that talks mostly to another object's data belongs
   on that object.

```ruby
# Before: Report does formatting AND aggregation AND delivery (130 lines)
class Report
  def initialize(orders) = @orders = orders

  def total          = @orders.sum(&:amount)
  def average         = total / @orders.size
  def by_region       = @orders.group_by(&:region).transform_values { |o| o.sum(&:amount) }

  def to_csv          = # ...20 lines...
  def to_html         = # ...25 lines...

  def email_to(user)  = # ...15 lines building and sending a Mail object...
end

# After: three focused classes
class ReportStats
  def initialize(orders) = @orders = orders
  def total   = @orders.sum(&:amount)
  def average = total / @orders.size
  def by_region
    @orders.group_by(&:region).transform_values { |o| o.sum(&:amount) }
  end
end

class ReportCsv
  def initialize(stats) = @stats = stats
  def render = # ...
end

class ReportMailer
  def initialize(stats, renderer) = (@stats, @renderer = stats, renderer)
  def deliver_to(user) = # ...
end
```

---

## Rule 2 — A method can be no longer than 5 lines of code

### Rationale

- Five lines is roughly the largest chunk you can hold in your head at once.
- Short methods force **one level of abstraction per method** (the "Composed
  Method" pattern): a method either orchestrates named steps or does one small
  concrete thing, never both.
- Short methods get descriptive names, which turns the method body into
  documentation and makes stack traces readable.
- `if`/`else` counts: an `if` with an `else` is already 5 lines (`if` / branch /
  `else` / branch / `end`), so a conditional is a whole method.

### Counting

Exclude the `def`/`end` lines, blank lines, and comments. A multi-line method
call chain formatted across lines still counts as its lines.

### Common violations & causes

| Symptom | Underlying cause |
| --- | --- |
| Method with a comment every few lines | Each comment marks a step that should be its own named method |
| Deep nesting (`if` inside `each` inside `if`) | Missing guard clauses; loop body should be a method |
| Method name contains "and" | Two operations in one method |
| Local variables threaded through 15 lines | A missing object; the method is an algorithm wanting a class |

### Refactoring strategies

1. **Extract Method** with an intention-revealing name.
2. **Guard clauses** — return/raise early instead of wrapping the body in `if`.
3. **Replace temp with query** — turn a computed local into a small method.
4. **Replace loop with a higher-order method** (`map`, `select`, `reduce`,
   `each_with_object`).
5. **Replace conditional with polymorphism** or a lookup hash / dispatch table.
6. **Introduce Parameter Object** if the length comes from unpacking many args.

```ruby
# Before
def notify(user)
  if user.active?
    if user.email.present?
      message = "Hi #{user.name}, "
      message += "your report for #{Date.today} is ready."
      Mailer.deliver(to: user.email, body: message)
      user.update(notified_at: Time.now)
    end
  end
end

# After
def notify(user)
  return unless notifiable?(user)

  Mailer.deliver(to: user.email, body: report_message(user))
  user.update(notified_at: Time.now)
end

private

def notifiable?(user) = user.active? && user.email.present?

def report_message(user)
  "Hi #{user.name}, your report for #{Date.today} is ready."
end
```

---

## Rule 3 — Pass no more than 4 parameters into a method

### Rationale

- Long parameter lists are hard to call correctly (which arg is which?) and
  signal that several values actually belong together as an object.
- More than 4 params usually means the method has too many responsibilities or
  is missing a **Parameter Object** / **Value Object**.
- Hashes-as-pseudo-params ("options hash with 9 keys") don't fix the smell, they
  hide it — those keys are still parameters.

### Counting

Count all explicit parameters: positional, optional (with defaults), and
keyword arguments. A `*splat` counts as one. A `&block` does **not** count.
Keyword args are preferred over positional for readability, but 5 keyword args
is still a violation.

### Common violations & causes

| Symptom | Underlying cause |
| --- | --- |
| `def initialize(street, city, state, zip, country)` | An `Address` value object is missing |
| `def draw(x, y, width, height, color, border)` | `Rect` + `Style` objects missing |
| Giant options hash | Configuration object missing |
| Same 3 params passed together through many methods | "Data clump" — bundle them |

### Refactoring strategies

1. **Introduce Parameter Object** — bundle related args into a small struct or
   value object.
2. **Preserve Whole Object** — if the caller extracts several fields from one
   object just to pass them in, pass the object.
3. **Move method** — if the method needs data from another object, it may belong
   there, cutting params.
4. **Builder / fluent interface** for genuinely complex construction.
5. **Replace parameter with method** — if a value is derivable from something the
   object already has, don't pass it.

```ruby
# Before
def schedule(title, starts_at, ends_at, timezone, attendees, room)
  # ...
end

# After
Meeting = Data.define(:title, :starts_at, :ends_at, :timezone)

def schedule(meeting, attendees, room)
  # ...
end
```

---

## Rule 4 — Controllers can instantiate only one object

Corollary often quoted alongside it: *a view can only know about one instance
variable, and it should send messages to only that object* ("one dot per view",
loosely).

### Rationale

- Keeps controllers thin: parse the request, call one thing, render.
- Forces business logic and orchestration into the domain layer where it can be
  unit-tested without the Rails request cycle.
- A controller action that news up 4 collaborators is doing a job that deserves
  its own named object (a Facade / Interactor / Use Case).

### What counts

- Instantiating (`.new`) or building domain objects in the action.
- Assigning multiple unrelated `@ivars` for the view.
- *Not* a violation: finding one existing record (`Post.find`), then handing off.

### Common violations & causes

| Symptom | Underlying cause |
| --- | --- |
| Action sets `@user`, `@orders`, `@recommendations`, `@promo` | No aggregate/presenter object for the page |
| Action contains transaction blocks and multi-step workflow | Missing service object / interactor |
| Callbacks + `respond_to` + business rules in one action | Controller doing the model's job |

### Refactoring strategies

1. **Facade object** — a single object that exposes everything the view needs:
   `@dashboard = Dashboard.new(current_user)` then `@dashboard.orders`, etc.
2. **Service object / Interactor** — encapsulate a workflow:
   `result = PlaceOrder.call(cart:, user:)`; controller inspects `result` and
   renders.
3. **Presenter / View Model** — wrap a record plus view-specific derived data.
4. **Query object** — move complex `where`/`joins` chains out of the action.

```ruby
# Before
def show
  @user     = User.find(params[:id])
  @orders   = @user.orders.recent
  @invoices = @user.invoices.unpaid
  @credit   = CreditCalculator.new(@user).available
end

# After
def show
  @account = AccountDashboard.new(User.find(params[:id]))
end

# app/dashboards/account_dashboard.rb
class AccountDashboard
  def initialize(user) = @user = user
  def user     = @user
  def orders   = @user.orders.recent
  def invoices = @user.invoices.unpaid
  def credit   = CreditCalculator.new(@user).available
end
```

---

## When it's OK to break a rule

State the reason explicitly; don't break a rule silently.

- **Config / declarative code** — `routes.rb`, initializers, `has_many` blocks,
  state-machine definitions, RSpec `describe` blocks. These are data, not logic.
- **DSLs** — a well-known DSL (ActiveRecord, RSpec, Rake) reads fine long.
- **Database migrations** and generated code.
- **A method that is genuinely one atomic step** at 6–7 lines, where extracting
  would create a worse name than the code it replaces.
- **A value object constructor** taking 5 trivially-named fields where a wrapper
  object adds no clarity (borderline — usually still worth a struct).
- **Performance-critical inner loops** where extraction adds real overhead
  (measure first).

Rule of thumb for reviews: flag every violation, but sort by severity. A
120-line class is a nudge; a 400-line class with 30-line methods is a problem.

---

## Enforcing with tools

- **RuboCop**: `Metrics/ClassLength` (Max: 100), `Metrics/MethodLength` (Max: 5),
  `Metrics/ParameterLists` (Max: 4, `MaxOptionalParameters: 3`),
  `Metrics/AbcSize`, `Metrics/CyclomaticComplexity`.
- **Reek**: detects `LargeClass`, `LongMethod` (via `TooManyStatements`),
  `LongParameterList`, `FeatureEnvy`, `DataClump`.
- **flog**: per-method complexity score (ABC metric). High flog = do too much.
- **flay**: structural duplication across the codebase (candidates for Extract).

```yaml
# .rubocop.yml
Metrics/ClassLength:
  Max: 100
Metrics/MethodLength:
  Max: 5
Metrics/ParameterLists:
  Max: 4
  MaxOptionalParameters: 3
```

## Related principles & patterns

- **Single Responsibility Principle** — a class should have one reason to change.
- **Composed Method** — every method at a single level of abstraction.
- **Tell, Don't Ask** — reduces the need for controllers to pull data out and
  recombine it.
- **Law of Demeter** — one dot; directly supports Rule 4's view corollary.
- **Value Object / Parameter Object** — the fix for Rule 3.
- **Facade, Interactor/Service Object, Presenter, Query Object** — the fixes for
  Rule 4.
- **Strategy, Decorator, Command** — common targets when splitting a large class.
