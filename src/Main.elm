port module Main exposing (main)

-- visotype/elm-eval
import Eval

-- Core
import Debug
import Dict exposing (Dict)
import Platform.Sub
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)


port getModel : (Value -> msg) -> Sub msg

port getKey : (Value -> msg) -> Sub msg

port updateKey : (Value -> msg) -> Sub msg

port outgoing : Value -> Cmd msg


type Msg
  = GetModel Value
  | GetKey Value
  | UpdateKey Value


type alias Model =
  Dict String Value


main : Program Value Model Msg
main =
  { init = \object -> (tryDict object, Cmd.none)

  , update = update

  , subscriptions = \_ ->
      [ getModel GetModel
      , getKey GetKey
      , updateKey UpdateKey
      ]
        |> Platform.Sub.batch

  }
    |> Platform.worker


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GetModel _ ->
      model
        |> (\d -> (d, d))
        |> Tuple.mapSecond (
          Dict.toList
            >> Encode.object
            >> Ok
            >> encodeResult
            >> outgoing
        )

    GetKey object ->
      model
        |> (\d -> (d, d))
        |> Tuple.mapSecond (
          (object |> tryStringField "key" |> tryDictGet)
            >> encodeResult
            >> outgoing
        )

    UpdateKey object ->
      model
        |> updateModel object
        |> (\d -> (d, d))
        |> Tuple.mapFirst (Result.withDefault model)
        |> Tuple.mapSecond (
          Result.andThen (object |> tryStringField "key" |> tryDictGet)
            >> encodeResult
            >> outgoing
        )


-- HELPERS

tryDict : Value -> Dict String Value
tryDict =
  Decode.decodeValue (Decode.dict Decode.value)
    >> Result.withDefault Dict.empty


tryStringField : String -> Value -> Result String String
tryStringField name object =
  case (object |> Decode.decodeValue (Decode.field name Decode.value)) of
    Ok value ->
      case (value |> Decode.decodeValue Decode.string) of
        Ok string ->
          Ok string

        Err _ ->
          Err ("The `" ++ name ++ "` argument must be a string.")

    Err _ ->
      Err ("This function requires a `" ++ name ++ "` argument.")


tryListField : String -> Value -> Result String (List Value)
tryListField name object =
  case (object |> Decode.decodeValue (Decode.field name Decode.value)) of
    Ok value ->
      case (value |> Decode.decodeValue (Decode.list Decode.value)) of
        Ok list ->
          Ok list

        Err _ ->
          Err ("The `" ++ name ++ "` argument must be an array.")

    Err _ ->
      Err ("This function requires a `" ++ name ++ "` argument.")


tryDictGet : Result String String -> Dict String Value -> Result String Value
tryDictGet result =
  case result of
    Ok key ->
      Dict.get key
        >> Result.fromMaybe ("'" ++ key ++ "' is not a key in your model.")

    Err error ->
      always (Err error)


updateModel : Value -> Model -> Result String Model
updateModel object previous =
  let
    keyResult =
      object
        |> tryStringField "key"

    callResult =
      case (object |> tryStringField "f", object |> tryListField "args") of
        (Ok f, Ok args) ->
          Ok { f = f, args = args }

        (Err a, Err b) ->
          Err (a ++ " : " ++ b)

        (Err a, _) ->
          Err a

        (_, Err b) ->
          Err b

    appendToCall lastArg =
      case callResult of
        Ok call ->
          Ok { call | args = call.args ++ [lastArg]}

        Err error ->
          Err error

    tryCall =
      previous
        |> tryDictGet keyResult
        |> Result.andThen appendToCall
        |> Result.andThen (Eval.call Eval.coreLib)

    tryInsert v =
      case keyResult of
        Ok ks ->
          Dict.insert ks v
            >> Ok

        Err error ->
          always (Err error)

  in
    case tryCall of
      Ok value ->
        previous
          |> tryInsert value

      Err error ->
        Err error



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
