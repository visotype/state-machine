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


    decodeAsString =




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
      Msg.Eval object ->
        object
          |> parseOp

      Msg.UpdateModel object ->
        object
          |> parseOp

      Msg.UpdateKey object ->
        object
          |> parseKeyedOp

--- HELPERS ---

type alias Operation =
  { key : Maybe String
  , op : String
  , args : List Json.Decode.Value
  }

parseOp : Json.Decode.Value -> Operation
parseOp object =
  { op = object |> field "op" |> decodeAsString
  , args = object |> field "args" |> decodeAsList
  }

parseKeyedOp : Json.Decode.Value -> (Key, Operation)
parseKeyedOp object =
  ( key = object |> field "key" |> decodeAsString
  , { op = object |> field "op" |> decodeAsString
    , args = object |> field "args" |> decodeAsList
    }
  )

field : String -> Json.Decode.Value -> Maybe Json.Decode.Value
field key =
  Json.Decode.decodeValue (Json.Decode.field key Json.Decode.value)
    >> Result.withDefault Json.Encode.null

decodeAsString : Json.Decode.Value -> Maybe String
decodeAsString =
  Json.Decode.decodeValue Json.Decode.string
    >> Result.withDefault ""

decodeAsBool : Json.Decode.Value -> Bool
decodeAsBool =
  Json.Decode.decodeValue Json.Decode.bool
    >> Result.withDefault False

decodeAsList : Json.Decode.Value -> List Json.Decode.Value
decodeAsList =
  Json.Decode.decodeValue (Json.Decode.list Json.Decode.value)
    >> Result.withDefault []

decodeAsDict : Json.Decode.Value -> Dict.Dict String Json.Decode.Value
decodeAsDict =
  Json.Decode.decodeValue (Json.Decode.dict Json.Decode.value)
    >> Result.withDefault Dict.empty


----



        previous
          |> operation (object |> field "op", object |> field "data")
          |> (\x -> (x, x))
          |> Tuple.mapSecond (Model.toJson >> Ports.outgoing)
