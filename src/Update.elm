module Update exposing
  ( update )


-- Project
import Ports
import Model
import Msg
import Core
-- Core
import Dict
import Json.Decode
import Json.Encode


update : Msg.Msg -> Model.Model -> (Model.Model, Cmd Msg.Msg)
update msg previous =
  case msg of
    Msg.Eval object ->
      object
        |> parse
        |> exec

    Msg.UpdateModel object ->
      object
        |> parse

    Msg.UpdateKey object ->
      object
        |> parseKeyed


--- HELPERS ---

type alias Operation =
  { f : String
  , args : List Json.Decode.Value
  }

parse : Json.Decode.Value -> Operation
parse object =
  { f = object |> Try.field "op" |> Try.string
  , args = object |> Try.field "args" |> Try.list
  }

parseKeyed : Json.Decode.Value -> (String, Operation)
parseKeyed object =
  ( object |> Try.field "key" |> Try.string
  , { f = object |> Try.field "op" |> Try.string
    , args = object |> Try.field "args" |> Try.list
    }
  )

exec : Operation -> Maybe Value
exec op =
  case (op.f |> Core.get) of
    Just f ->
      op.args
        |> Try.tuple
        |> Maybe.andThen f

    Nothing ->
      Nothing
