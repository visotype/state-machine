
-- Project
import Ports
import Model
import Msg
import Update
-- Core
import Platform.Sub
import Json.Decode
import Debug


main : Program Json.Decode.Value Model.Model Msg.Msg
main =
  { init = \object -> (object |> Model.fromJson, Cmd.none)
  , update = Update.update
  , subscriptions = \model ->
    [ Ports.eval Msg.Eval
    , Ports.updateModel Msg.UpdateModel
    , Ports.updateKey Msg.UpdateKey
    ]
      |> Platform.Sub.batch
  }
    |> Platform.worker
