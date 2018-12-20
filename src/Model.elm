module Model exposing
  ( Model
  , fromJson, toJson
  )


-- Core
import Json.Decode
import Json.Encode
import Dict


type alias Model =
  Dict.Dict String Json.Decode.Value


fromJson : Json.Decode.Value -> Model
fromJson =
  Json.Decode.decodeValue
    ( Json.Decode.value
      |> Json.Decode.dict
    )
      >> Result.withDefault Dict.empty


toJson : Model -> Json.Encode.Value
toJson =
  Dict.toList
    >> Json.Encode.object
