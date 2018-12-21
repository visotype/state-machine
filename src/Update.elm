module Update exposing
  ( update )


-- Project
import Ports
import Model
import Msg
import Handler


update : Msg.Msg -> Model.Model -> (Model.Model, Cmd Msg.Msg)
update msg previous =
  case msg of
    Msg.Eval object ->
      object
        |> Handler.parse
        |> Handler.exec
        |> (\result -> (previous, result))
        |> Tuple.mapSecond (Handler.returnMessage >> Ports.outgoing)

    Msg.UpdateModel object ->
      (previous, Cmd.none)

    Msg.UpdateKey object ->
      (previous, Cmd.none)
