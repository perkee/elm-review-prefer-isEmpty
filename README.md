# elm-review-prefer-isEmpty

Provides [`elm-review`](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) rules to REPLACEME.

## Provided rules

- [`PreferIsEmpty.List`](https://package.elm-lang.org/packages/perkee/elm-review-prefer-isEmpty/1.0.0/PreferIsEmpty-List) - Reports REPLACEME.

## Configuration

```elm
module ReviewConfig exposing (config)

import PreferIsEmpty.List
import Review.Rule exposing (Rule)

config : List Rule
config =
    [ PreferIsEmpty.List.rule
    ]
```

## Try it out

You can try the example configuration above out by running the following command:

```bash
elm-review --template perkee/elm-review-prefer-isEmpty/example
```
