port module Main exposing (main)

-- visotype/elm-eval
import Eval

-- Core
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
update msg previous =
  case msg of
    GetModel _ ->
      previous
        |> (\d -> (d, d))
        |> Tuple.mapSecond (
          Dict.toList
            >> Encode.object
            >> Ok
            >> encodeResult
            >> outgoing
        )

    GetKey object ->
      previous
        |> (\d -> (d, d))
        |> Tuple.mapSecond (
          (object |> tryStringField "key" |> tryDictGet)
            >> encodeResult
            >> outgoing
        )

    UpdateKey object ->
      previous
        |> updateModel object
        |> (\d -> (d, d))
        |> Tuple.mapFirst (Result.withDefault previous)
        |> Tuple.mapSecond (
          Result.map (Dict.toList >> Encode.object)
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
          case (allowedFunctions |> List.member f) of
            True ->
              Ok { f = f, args = args }

            False ->
              Err (
                "`" ++ f ++ "` cannot be applied to the selected key because "
                  ++ "it could change the type of value at that key. Keys and "
                  ++ "their corresponding value types can only be set once, "
                  ++ "when the program is initialized with an initial model."
              )

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


allowedFunctions : List String
allowedFunctions =
  [ "(+)", "Basics.(+)"
  , "(-)", "Basics.(-)"
  , "(*)", "Basics.(*)"
  , "(/)", "Basics.(/)"
  , "(//)", "Basics.(//)"
  , "(^)", "Basics.(^)"
  , "round", "Basics.round"
  , "floor", "Basics.floor"
  , "ceiling", "Basics.ceiling"
  , "truncate", "Basics.truncate"
  , "not", "Basics.not"
  , "(&&)", "Basics.(&&)"
  , "(||)", "Basics.(||)"
  , "xor", "Basics.(xor)"
  , "modby", "Basics.modby"
  , "remainderBy", "Basics.remainderBy"
  , "negate", "Basics.negate"
  , "abs", "Basics.abs"
  , "clamp", "Basics.clamp"
  , "sqrt", "Basics.sqrt"
  , "logBase", "Basics.logBase"
  , "degrees", "Basics.degrees"
  , "radians", "Basics.radians"
  , "turns", "Basics.turns"
  , "cos", "Basics.cos"
  , "sin", "Basics.sin"
  , "tan", "Basics.tan"
  , "acos", "Basics.acos"
  , "asin", "Basics.sin"
  , "atan", "Basics.atan"
  , "atan2", "Basics.atan2"
  , "identity", "Basics.identity"
  , "always.string", "Basics.always.string"
  , "always.char", "Basics.always.char"
  , "always.int", "Basics.always.int"
  , "always.float", "Basics.always.float"
  , "always.list", "Basics.always.list"
  , "always.array", "Basics.always.array"
  , "always.dict", "Basics.always.dict"
  , "Array.set.string"
  , "Array.set.char"
  , "Array.set.int"
  , "Array.set.float"
  , "Array.push.string"
  , "Array.push.char"
  , "Array.push.int"
  , "Array.push.float"
  , "Array.append.string"
  , "Array.append.char"
  , "Array.append.int"
  , "Array.append.float"
  , "Array.slice"
  , "Bitwise.and"
  , "Bitwise.or"
  , "Bitwise.xor"
  , "Bitwise.complement"
  , "Bitwise.shiftLeftBy"
  , "Bitwise.shiftRightBy"
  , "Bitwise.shiftRightZfBy"
  , "Char.toUpper"
  , "Char.toLower"
  , "Char.toLocaleUpper"
  , "Char.toLocaleLower"
  , "Dict.insert"
  , "Dict.remove"
  , "Dict.union"
  , "Dict.intersect"
  , "Dict.diff"
  , "(::)", "List.(::)"
  , "List.reverse"
  , "List.append"
  , "List.intersperse"
  , "List.tail"
  , "List.take"
  , "List.drop"
  , "Set.insert.string"
  , "Set.insert.char"
  , "Set.insert.int"
  , "Set.insert.float"
  , "Set.remove.string"
  , "Set.remove.char"
  , "Set.remove.int"
  , "Set.remove.float"
  , "Set.union.string"
  , "Set.union.char"
  , "Set.union.int"
  , "Set.union.float"
  , "Set.intersect.string"
  , "Set.intersect.char"
  , "Set.intersect.int"
  , "Set.intersect.float"
  , "Set.diff.string"
  , "Set.diff.char"
  , "Set.diff.int"
  , "Set.diff.float"
  , "String.reverse"
  , "String.repeat"
  , "String.replace"
  , "String.append"
  , "String.slice"
  , "String.left"
  , "String.right"
  , "String.dropLeft"
  , "String.dropRight"
  , "String.cons"
  , "String.toUpper"
  , "String.toLower"
  , "String.pad"
  , "String.padLeft"
  , "String.padRight"
  , "String.trim"
  , "String.trimLeft"
  , "String.trimRight"
  ]
