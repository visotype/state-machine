module Handler exposing
  ( Operation
  , parse
  , parseKeyed
  -- , withModel
  -- , withModelKeyed
  , exec
  , modelUpdate
  , returnMessage
  )

import Function exposing (Function(..))
import Try
import Resolve
import Core

import Json.Encode as Encode exposing (Value)
import Dict exposing (Dict)


type alias Operation =
  { f : String
  , args : List Value
  }

parse : Value -> Operation
parse object =
  { f = object |> Try.field "op" |> Resolve.string
  , args = object |> Try.field "args" |> Resolve.list
  }

parseKeyed : Value -> (String, Operation)
parseKeyed object =
  ( object |> Try.field "key" |> Resolve.string
  , { f = object |> Try.field "op" |> Resolve.string
    , args = object |> Try.field "args" |> Resolve.list
    }
  )

exec : Operation -> Result String Value
exec op =
  case (op.f |> Core.get) of
    Just f ->
      case f of
        F1 f1 ->
          op.args
            |> List.head
            |> Maybe.andThen f1
            |> Result.fromMaybe (
              "Failed at coercing JavaScript input values to the expected "
              ++ "parameter types for the Elm function "
              ++ op.f
            )

        F2 f2 ->
          op.args
            |> Try.tuple2
            |> Maybe.andThen f2
            |> Result.fromMaybe (
              "Failed at coercing JavaScript input values to the expected "
              ++ "parameter types for the Elm function "
              ++ op.f
            )

        F3 f3 ->
          op.args
            |> Try.tuple3
            |> Maybe.andThen f3
            |> Result.fromMaybe (
              "Failed at coercing JavaScript input values to the expected "
              ++ "parameter types for the Elm function "
              ++ op.f
            )

    Nothing ->
      Err (
        "Specified Elm function was not found. Some core module functions "
        ++ "are not available through this interface."
      )


modelUpdate : Dict String Value -> Result String Value -> Dict String Value
modelUpdate previous result =
  case result of
    Ok value ->
      value
        |> Try.dict
        |> Maybe.withDefault previous

    Err message ->
      previous


keyUpdate : (Dict String Value, String) -> Result String Value -> Dict String Value
keyUpdate (previous, key) result =
  case result of
    Ok value ->
      previous
        |> Dict.insert key value

    Err message ->
      previous


returnMessage : Result String Value -> Value
returnMessage result =
  case result of
    Ok value ->
      [ ("value", value)
      , ("resolve", True |> Encode.bool)
      , ("error", Encode.null)
      ]
        |> Encode.object

    Err message ->
      [ ("value", Encode.null)
      , ("resolve", False |> Encode.bool)
      , ("error", message |> Encode.string)
      ]
        |> Encode.object
