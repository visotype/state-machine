module Core exposing
  ( get )


import Dict exposing (Dict)
import Json.Decode exposing (Value)
import Json.Encode as Encode
import Try


get : String -> Maybe ((Value, Value) -> Maybe Value)
get expression =
  let
    parts =
      expression |> String.split "."

    (moduleName, fName) =
      case (parts |> List.length, parts, parts |> List.drop 1) of
        (1, first :: rest, []) ->
          ("Basics", first)
        (2, first :: rest, second :: []) ->
          (first, second)
        (_, _, _) ->
          ("", "")

  in
    case moduleName of
      "Basics" ->
        basics fName
      "Dict" ->
        dict fName
      _ ->
        Nothing


basics : String -> Maybe ((Value, Value) -> Maybe Value)
basics fName =
  let
    wrap f (x, y) =
      Maybe.map2 f (Try.float x) (Try.float y)
        |> Maybe.map Encode.float

  in
  case fName of
    "(+)" ->
      Just (wrap (+))

    "(-)" ->
      Just (wrap (-))

    "(*)" ->
      Just (wrap (*))

    "(/)" ->
      Just (wrap (/))

    _ ->
      Nothing


dict : String -> Maybe ((Value, Value) -> Maybe Value)
dict fName =
  let
    wrap f (x, y) =
      Maybe.map2 f (Try.dict x) (Try.dict y)
        |> Maybe.map (Dict.toList >> Encode.object)

  in
    case fName of
      "union" ->
        Just (wrap Dict.union)

      "intersect" ->
        Just (wrap Dict.intersect)

      "diff" ->
        Just (wrap Dict.diff)

      _ ->
        Nothing
