module Msg exposing
  ( Msg(..) )


-- Core
import Json.Decode


type Msg
  = Received Json.Decode.Value
