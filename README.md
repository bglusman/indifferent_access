# IndifferentAccess

So, clearly this is inspired by `HashWithIndifferentAccess` from ActiveSupport, and I'm not at all sure it's a good or idiomatic idea in Elixir, but I wanted to play with it and get some community reaction/thoughts.  I want some kind of handling to happen at the boundaries of my application that imposes some guarantees deeper into business logic, and I'd prefer not to litter my codebase with a lot of string literals.  I haven't seen any kind of cohesive pattern for handling the transition from strings at the boundaries to mostly-atoms inside, and I wanted to play with something that might be a better alternative.


At this stage it's a proof of concept without tests but that appears to work reasonably well as a plug in a Phoenix app locally.  Before I put any more time into maturing it, I wanted to give others a chance to react to the general idea and perhaps educate me about alternative patterns/problems with this approach/etc.  Obviously not reccomended for production use at this point, but PR's and Issues are welcome. 

## Installation

The package can be installed by adding `indifferent_access` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:indifferent_access, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/indifferent_access](https://hexdocs.pm/indifferent_access).

