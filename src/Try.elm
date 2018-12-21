module Try exposing
  ( field
  , string
  , int
  , float
  , bool
  , list
  , dict
  , tuple2
  , tuple3
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


int : Value -> Maybe Int
int =
  Decode.decodeValue Decode.int
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


tuple2 : List Value -> Maybe (Value, Value)
tuple2 ls =
  case (ls, ls |> List.drop 1) of
    (first :: rest, second :: []) ->
      Just (first, second)
    (_, _) ->
      Nothing


tuple3 : List Value -> Maybe (Value, Value, Value)
tuple3 ls =
  case (ls, ls |> List.drop 1, ls |> List.drop 2) of
    (first :: slice1, second :: slice2, third :: []) ->
      Just (first, second, third)
    (_, _, _) ->
      Nothing
