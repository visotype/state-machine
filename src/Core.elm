module Core exposing
  ( get )


import Dict exposing (Dict)
import Json.Decode exposing (Value)
import Json.Encode as Encode

import Function exposing (Function(..))
import Wrap
import Try


get : String -> Maybe Function
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


basics : String -> Maybe Function
basics fName =
  case fName of
    "(+)" ->
      Wrap.a2 (+) (Try.float, Try.float) Encode.float
        |> F2
        |> Just

    "(-)" ->
      Wrap.a2 (-) (Try.float, Try.float) Encode.float
        |> F2
        |> Just

    "(*)" ->
      Wrap.a2 (*) (Try.float, Try.float) Encode.float
        |> F2
        |> Just

    "(/)" ->
      Wrap.a2 (/) (Try.float, Try.float) Encode.float
        |> F2
        |> Just

    _ ->
      Nothing


dict : String -> Maybe Function
dict fName =
  case fName of
    "union" ->
      Wrap.a2 (Dict.union) (Try.dict, Try.dict) (Dict.toList >> Encode.object)
        |> F2
        |> Just

    "intersect" ->
      Wrap.a2 (Dict.intersect) (Try.dict, Try.dict) (Dict.toList >> Encode.object)
        |> F2
        |> Just

    "diff" ->
      Wrap.a2 (Dict.diff) (Try.dict, Try.dict) (Dict.toList >> Encode.object)
        |> F2
        |> Just

    _ ->
      Nothing
