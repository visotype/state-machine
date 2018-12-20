port module Ports exposing
  ( incoming
  , outgoing
  )


-- Core
import Json.Decode


port eval : (Json.Decode.Value -> msg) -> Sub msg

port updateModel : (Json.Decode.Value -> msg) -> Sub msg

port updateKey : (Json.Decode.Value -> msg) -> Sub msg

port outgoing : Json.Decode.Value -> Cmd msg
