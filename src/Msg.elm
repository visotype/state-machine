module Msg exposing
  ( Msg(..) )


-- Core
import Json.Decode


type Msg
  = Eval Json.Decode.Value
  | UpdateModel Json.Decode.Value
  | UpdateKey Json.Decode.Value
