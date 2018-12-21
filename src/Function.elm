module Function exposing
  ( Function(..) )


import Json.Encode exposing (Value)


type Function
  = F1 (Value -> Maybe Value)
  | F2 ((Value, Value) -> Maybe Value)
  | F3 ((Value, Value, Value) -> Maybe Value)
