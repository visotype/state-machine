module Wrap exposing
  ( a1, a2, a3 )

import Json.Decode exposing (Value)

a1 : (a -> o) -> (Value -> Maybe a) -> (o -> Value) -> Value -> Maybe Value
a1 f da eo a =
  Maybe.map f (da a) |> Maybe.map eo

a2 : (a -> b -> o) -> (Value -> Maybe a, Value -> Maybe b) -> (o -> Value) -> (Value, Value) -> Maybe Value
a2 f (da, db) eo (a, b)=
  Maybe.map2 f (da a) (db b) |> Maybe.map eo

a3 : (a -> b -> c -> o) -> (Value -> Maybe a, Value -> Maybe b, Value -> Maybe c) -> (o -> Value) -> (Value, Value, Value) -> Maybe Value
a3 f (da, db, dc) eo (a, b, c)=
  Maybe.map3 f (da a) (db b) (dc c) |> Maybe.map eo
