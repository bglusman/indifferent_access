# IndifferentAccess

So, clearly this is inspired by `HashWithIndifferentAccess` from ActiveSupport, and I'm not at all sure it's a good or idiomatic idea in Elixir, but I wanted to play with it and get some community reaction/thoughts.  I want some kind of handling to happen at the boundaries of my application that imposes some guarantees deeper into business logic, and I'd prefer not to litter my codebase with a lot of string literals.  I haven't seen any kind of cohesive pattern for handling the transition from strings at the boundaries to mostly-atoms inside, and I wanted to play with something that might be a better alternative.


At this stage it's a a pluralist mishmash of 2 general strategies each with 2 modes of operation, mainly intended to be used as plug in a Phoenix app. Most of the community is pretty much against this kind of thing, and I might include myself in that and generally think where possible using Ecto embedded schemas to handle arbitrry/non DB related params input is a better approach, but there's room for differences of opinion and for playing around with fun, bad ideas.  PR's, Issues and thoughts welcome.  You might also check out https://github.com/philosodad/morphix and/or https://github.com/vic/indifferent as alternatives/related ideas in Elixir.

## Installation

The package can be installed by adding `indifferent_access` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:indifferent_access, "~> 0.1"}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/indifferent_access](https://hexdocs.pm/indifferent_access).

