port module Main exposing (main)

-- visotype/elm-eval
import Eval

-- Core
import Platform.Sub
import Json.Encode as Encode exposing (Value)


port getModel : msg -> Sub msg

port getKey : (Value -> msg) -> Sub msg

port updateKey : (Value -> msg) -> Sub msg

port outgoing : Value -> Cmd msg


type Msg
  = GetModel
  | GetKey Value
  | UpdateKey Value


type alias Call =
  { f : String
  , args : List Value
  }


main : Program Value (Maybe Call) Msg
main =
  { init = \object ->
      (object |> Model.fromJson, Cmd.none)

  , update = \(Receive object) _ ->
      object
        |> Eval.parse
        |> (\r -> (r, r))
        |> Tuple.mapBoth Just (Eval.call Eval.coreLib >> encodeResult >> outgoing)

  , subscriptions = \_ ->
      [ getModel GetModel
      , getKey GetKey
      , updateKey UpdateKey
      ]
        |> Platform.Sub.batch

  }
    |> Platform.worker


update : Msg.Msg -> Model.Model -> (Model.Model, Cmd Msg.Msg)
update msg previous =
  case msg of
    Msg.GetModel ->
      (previous, Cmd.none)

    Msg.GetKey key ->
      (previous, Cmd.none)

    Msg.UpdateKey object ->
      (previous, Cmd.none)


encodeResult : Result String Value -> Value
encodeResult result =
  case result of
    Ok value ->
      [ ("resolve", True |> Encode.bool)
      , ("value", value)
      , ("error", Encode.null)
      ]
        |> Encode.object

    Err message ->
      [ ("resolve", False |> Encode.bool)
      , ("value", Encode.null)
      , ("error", message |> Encode.string)
      ]
        |> Encode.object
