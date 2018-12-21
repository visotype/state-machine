module Try exposing
  ( field
  , string
  , float
  , bool
  , list
  , dict
  , tuple
  )


import Dict exposing (Dict)
import Json.Decode as Decode exposing (Value)


field : String -> Value -> Maybe Value
field key =
  Decode.decodeValue (Decode.field key Decode.value)
    >> Result.toMaybe

string : Value -> Maybe String
string =
  Decode.decodeValue Decode.string
    >> Result.toMaybe

float : Value -> Maybe Float
float =
  Decode.decodeValue Decode.float
    >> Result.toMaybe

bool : Value -> Maybe Bool
bool =
  Decode.decodeValue Decode.bool
    >> Result.toMaybe

list : Value -> Maybe (List Value)
list =
  Decode.decodeValue (Decode.list Decode.value)
    >> Result.toMaybe

dict : Value -> Maybe (Dict String Value)
dict =
  Decode.decodeValue (Decode.dict Decode.value)
    >> Result.toMaybe

tuple : Value -> Maybe (Value, Value)
tuple =
  let
    tupleFromList ls =
      case (ls, ls |> List.drop 1) of
        (first :: rest, second :: []) ->
          Just (first, second)
        (_, _) ->
          Nothing

  in
    Decode.decodeValue (Decode.list Decode.value)
      >> Result.toMaybe
      >> Maybe.andThen tupleFromList
