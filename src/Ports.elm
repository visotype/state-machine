port module Ports exposing
  ( incoming
  , outgoing
  )


-- Core
import Json.Decode


port incoming : (Json.Decode.Value -> msg) -> Sub msg

port outgoing : Json.Decode.Value -> Cmd msg
