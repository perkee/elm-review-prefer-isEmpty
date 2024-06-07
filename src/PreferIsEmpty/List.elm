module PreferIsEmpty.List exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Expression exposing (Expression(..))
import Elm.Syntax.Node as Node exposing (Node(..))
import Review.Rule as Rule exposing (Rule)


{-| Reports... REPLACEME

    config =
        [ PreferIsEmpty.List.rule
        ]


## Fail

    a =
        "REPLACEME example to replace"


## Success

    a =
        "REPLACEME example to replace"


## When (not) to enable this rule

This rule is useful when REPLACEME.
This rule is not useful when REPLACEME.


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template perkee/elm-review-prefer-isEmpty/example --rules PreferIsEmpty.List
```

-}
rule : Rule
rule =
    Rule.newModuleRuleSchemaUsingContextCreator "PreferIsEmpty.List" initialContext
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


type alias Context =
    {}


initialContext : Rule.ContextCreator () Context
initialContext =
    Rule.initContextCreator
        (\() ->
            {}
        )


expressionVisitor : Node Expression -> Context -> ( List (Rule.Error {}), Context )
expressionVisitor node context =
    case Node.value node of
        OperatorApplication operator _ nodeL nodeR ->
            case operator of
                "==" ->
                    -- let
                    --     _ =
                    -- Debug.log "nodes" { nodeL = nodeL, nodeR = nodeR }
                    -- Debug.log "the nonzero side" <| maybeTheNonZeroNode nodeL nodeR
                    -- in
                    case maybeTheNonZeroNode nodeL nodeR of
                        Just nonZero ->
                            if isAnApplicationOfListDotLength nonZero || isAPizzaOfListDotLength nonZero then
                                ( [ Rule.error
                                        { message = "You are checking if the length of a list is equal to zero"
                                        , details =
                                            [ "You can replace this with a call to `List.isEmpty`"
                                            , "List.length takes as long to run as the list is long"
                                            , "whereas List.isEmpty just checks if the first element exists in constant time."
                                            ]
                                        }
                                        (Node.range node)
                                  ]
                                , context
                                )

                            else
                                ( [], context )

                        _ ->
                            ( [], context )

                ">" ->
                    ( [], context )

                "<" ->
                    ( [], context )

                "/=" ->
                    ( [], context )

                "<|" ->
                    case nodeL of
                        Node _ (OperatorApplication ">>" _ mightBeListDotLengthNode mightBeApplicationOfPrefixOperator) ->
                            ( [], context )

                        _ ->
                            ( [], context )

                _ ->
                    ( [], context )

        _ ->
            ( [], context )


isAListDotLengthNode : Node Expression -> Bool
isAListDotLengthNode node =
    case Node.value node of
        FunctionOrValue [ "List" ] "length" ->
            True

        _ ->
            False


isAnApplicationOfPrefixOperator : Node Expression -> Bool
isAnApplicationOfPrefixOperator node =
    case Node.value node of
        Application [ Node _ (PrefixOperator "=="), Node _ (Integer 0) ] ->
            True

        _ ->
            False


isAnApplicationOfListDotLength : Node Expression -> Bool
isAnApplicationOfListDotLength node =
    case Node.value node of
        Application [ Node _ (FunctionOrValue modulePath fnName), _ ] ->
            case ( modulePath, fnName ) of
                ( [ "List" ], "length" ) ->
                    True

                _ ->
                    False

        _ ->
            False


isAPizzaOfListDotLength : Node Expression -> Bool
isAPizzaOfListDotLength node =
    case Node.value node of
        ParenthesizedExpression (Node _ (OperatorApplication "|>" _ _ (Node _ (FunctionOrValue modulePath fnName)))) ->
            case ( modulePath, fnName ) of
                ( [ "List" ], "length" ) ->
                    True

                _ ->
                    False

        _ ->
            False


maybeTheNonZeroNode : Node Expression -> Node Expression -> Maybe (Node Expression)
maybeTheNonZeroNode nodeL nodeR =
    case ( Node.value nodeL, Node.value nodeR ) of
        ( Integer _, Integer _ ) ->
            Nothing

        ( Integer 0, _ ) ->
            Just nodeR

        ( _, Integer 0 ) ->
            Just nodeL

        _ ->
            Nothing



-- a =
--     Just
--         (Node { end = { column = 36, row = 11 }, start = { column = 15, row = 11 } }
--             (Application
--                 [ Node { end = { column = 26, row = 11 }, start = { column = 15, row = 11 } } (FunctionOrValue [ "List" ] "length")
--                 , Node { end = { column = 36, row = 11 }, start = { column = 27, row = 11 } } (FunctionOrValue [] "emptyList")
--                 ]
--             )
--         )
-- ([] |> List.length) == 0
-- a =
--     Just
--         (Node { end = { column = 59, row = 22 }, start = { column = 33, row = 22 } }
--             (ParenthesizedExpression
--                 (Node { end = { column = 58, row = 22 }, start = { column = 34, row = 22 } }
--                     (OperatorApplication "|>"
--                         Left
--                         (Node { end = { column = 43, row = 22 }, start = { column = 34, row = 22 } } (FunctionOrValue [] "emptyList"))
--                         (Node { end = { column = 58, row = 22 }, start = { column = 47, row = 22 } } (FunctionOrValue [ "List" ] "length"))
--                     )
--                 )
--             )
--         )


b =
    OperatorApplication "<|"
        Right
        (Node { end = { column = 36, row = 4 }, start = { column = 15, row = 4 } }
            (OperatorApplication ">>"
                Right
                (Node { end = { column = 26, row = 4 }, start = { column = 15, row = 4 } }
                    (FunctionOrValue [ "List" ] "length")
                )
                (Node { end = { column = 36, row = 4 }, start = { column = 30, row = 4 } }
                    (Application
                        [ Node { end = { column = 34, row = 4 }, start = { column = 30, row = 4 } }
                            (PrefixOperator "==")
                        , Node { end = { column = 36, row = 4 }, start = { column = 35, row = 4 } }
                            (Integer 0)
                        ]
                    )
                )
            )
        )
        (Node { end = { column = 42, row = 4 }, start = { column = 40, row = 4 } } (ListExpr []))


a =
    Node { end = { column = 36, row = 4 }, start = { column = 15, row = 4 } } (OperatorApplication ">>" Right (Node { end = { column = 26, row = 4 }, start = { column = 15, row = 4 } } (FunctionOrValue [ "List" ] "length")) (Node { end = { column = 36, row = 4 }, start = { column = 30, row = 4 } } (Application [ Node { end = { column = 34, row = 4 }, start = { column = 30, row = 4 } } (PrefixOperator "=="), Node { end = { column = 36, row = 4 }, start = { column = 35, row = 4 } } (Integer 0) ])))
