module Update exposing
  ( update )


-- Project
import Ports
import Model
import Msg
-- Core
import Dict
import Json.Decode
import Json.Encode


update : Msg.Msg -> Model.Model -> (Model.Model, Cmd Msg.Msg)
update msg previous =
  let
    field key =
      Json.Decode.decodeValue (Json.Decode.field key Json.Decode.value)
        >> Result.withDefault Json.Encode.null

    decodeAsString =
      Json.Decode.decodeValue Json.Decode.string
        >> Result.withDefault ""

    decodeAsBool =
      Json.Decode.decodeValue Json.Decode.bool
        >> Result.toMaybe

    toggleState =
      Maybe.andThen decodeAsBool
        >> Maybe.map Basics.not
        >> Maybe.map Json.Encode.bool

    operation (flag, content) =
      case (flag |> decodeAsString) of
        "union" ->
          Dict.union (content |> Model.fromJson)

        "intersect" ->
          Dict.intersect (content |> Model.fromJson)

        "diff" ->
          Dict.diff (content |> Model.fromJson)

        "toggle" ->
          Dict.update (content |> decodeAsString) toggleState

        "remove" ->
          Dict.remove (content |> decodeAsString)

        "empty" ->
          always Dict.empty

        "identity" ->
          always (content |> Model.fromJson)

        _ ->
          identity

  in
    case msg of
      Msg.Received object ->
        previous
          |> operation (object |> field "op", object |> field "data")
          |> (\x -> (x, x))
          |> Tuple.mapSecond (Model.toJson >> Ports.outgoing)
