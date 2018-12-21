module Resolve exposing
  ( string
  , bool
  , list
  , dict
  )


import Dict exposing (Dict)
import Json.Decode as Decode exposing (Value)


string : Maybe Value -> String
string =
  Maybe.andThen (Decode.decodeValue Decode.string >> Result.toMaybe)
    >> Maybe.withDefault ""


bool : Maybe Value -> Bool
bool =
  Maybe.andThen (Decode.decodeValue Decode.bool >> Result.toMaybe)
    >> Maybe.withDefault False


list : Maybe Value -> List Value
list =
  Maybe.andThen (Decode.decodeValue (Decode.list Decode.value) >> Result.toMaybe)
    >> Maybe.withDefault []


dict : Maybe Value -> Dict String Value
dict =
  Maybe.andThen (Decode.decodeValue (Decode.dict Decode.value) >> Result.toMaybe)
    >> Maybe.withDefault Dict.empty
