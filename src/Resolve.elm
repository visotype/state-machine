module Resolve exposing
  ( string )


import Dict exposing (Dict)
import Json.Decode as Decode exposing (Value)

string : Maybe Value -> String
string =
  Maybe.andThen (Decode.decodeValue Decode.string >> Result.toMaybe)
    >> Maybe.withDefault ""
