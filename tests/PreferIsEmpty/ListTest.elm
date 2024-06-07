module PreferIsEmpty.ListTest exposing (all)

import PreferIsEmpty.List exposing (rule)
import Review.Test
import Test exposing (Test, describe, only, test)


testFile : String
testFile =
    """module A exposing (..)


emptyList = []


notEmptyList = [1]


emptyIsZero : Bool
emptyIsZero = List.length emptyList == 0


emptyIsEmpty : Bool
emptyIsEmpty = List.isEmpty emptyList

emptyIsZeroWithPizza : Bool
emptyIsZeroWithPizza = emptyList |> List.length |> (==) 0


emptyIsZeroWithSomePizza : Bool
emptyIsZeroWithSomePizza = 0 == (emptyList |> List.length)


badIsEmpty : List a -> Bool
badIsEmpty = List.length >> (==) 0
"""


all : Test
all =
    describe "PreferIsEmpty.List"
        [ test "should not report an error when we don't even call List dot anything" <|
            \() ->
                """module A exposing (..)


emptyList = []"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , describe "should report an error when equal to zero"
            [ test "with the 'List.length' application on the left" <|
                \() ->
                    """module A exposing (..)

emptyIsZero : Bool
emptyIsZero = List.length emptyList == 0
                """
                        |> Review.Test.run rule
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "You are checking if the length of a list is equal to zero"
                                , details =
                                    [ "You can replace this with a call to `List.isEmpty`"
                                    , "List.length takes as long to run as the list is long"
                                    , "whereas List.isEmpty just checks if the first element exists in constant time."
                                    ]
                                , under = "List.length emptyList == 0"
                                }
                            ]
            , test "with the 'List.length' application on the right" <|
                \() ->
                    """module A exposing (..)

emptyIsZero : Bool
emptyIsZero = 0 == List.length emptyList
                """
                        |> Review.Test.run rule
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "You are checking if the length of a list is equal to zero"
                                , details =
                                    [ "You can replace this with a call to `List.isEmpty`"
                                    , "List.length takes as long to run as the list is long"
                                    , "whereas List.isEmpty just checks if the first element exists in constant time."
                                    ]
                                , under = "0 == List.length emptyList"
                                }
                            ]
            , test "blah" <|
                \() ->
                    """module A exposing (..)

emptyIsZero : Bool
emptyIsZero = ([] |> List.length) == 0
                """
                        |> Review.Test.run rule
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "You are checking if the length of a list is equal to zero"
                                , details =
                                    [ "You can replace this with a call to `List.isEmpty`"
                                    , "List.length takes as long to run as the list is long"
                                    , "whereas List.isEmpty just checks if the first element exists in constant time."
                                    ]
                                , under = "([] |> List.length) == 0"
                                }
                            ]
            , test "more blah" <|
                \() ->
                    """module A exposing (..)

emptyIsZero : Bool
emptyIsZero = 0 == ([] |> List.length)
                """
                        |> Review.Test.run rule
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "You are checking if the length of a list is equal to zero"
                                , details =
                                    [ "You can replace this with a call to `List.isEmpty`"
                                    , "List.length takes as long to run as the list is long"
                                    , "whereas List.isEmpty just checks if the first element exists in constant time."
                                    ]
                                , under = "0 == ([] |> List.length)"
                                }
                            ]
            ]
        ]
