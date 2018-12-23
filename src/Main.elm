import Base64
import Browser
import Html exposing (Html, text, pre)
import Http
import Regex
import Json.Decode exposing (Decoder, field, string, decodeString)


-- MAIN

main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }



-- MODEL

type Model
  = Failure String
  | Loading
  | Success String


init : () -> (Model, Cmd Msg)
init _ =
  ( Loading
  , Http.request
      { method = "GET"
      , headers = [ ]
      , url = "https://oriel.madarch.org/NorthWalesTech20181219/" -- Can't use "https://pastebin.com/raw/KzwWFYJL" due to CORS
      , body = Http.emptyBody
      , expect = Http.expectString GotText
      , timeout = Nothing
      , tracker = Nothing
      }
  )


-- UPDATE

type Msg
  = GotText (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotText result ->
      case result of
        Ok fullText ->
          case extractCode fullText of
            Ok codeStr ->
              case decodeCode codeStr of
                Ok jsonStr ->
                  case extractMsg jsonStr of
                    Ok msgStr -> (Success msgStr, Cmd.none)
                    Err errStr -> (Failure errStr, Cmd.none)
                Err errStr -> (Failure errStr, Cmd.none)
            Err errStr -> (Failure errStr, Cmd.none)
        Err failure ->
          (Failure (errorText failure), Cmd.none)


extractCode : String -> Result String String
extractCode str =
  if (String.startsWith "START:" str) && (String.endsWith ":END" str) then
    Ok (str |> String.slice 6 -4)
  else
    Err <| "Unable to extract code from " ++ str

decodeCode : String -> Result String String
decodeCode str =
  Base64.decode str

extractMsg : String -> Result String String
extractMsg str =
  case decodeString msgDecoder str of
    Ok value -> Ok value
    Err _ -> Err "Unable to decode JSON"

msgDecoder : Decoder String
msgDecoder =
  field "msg" string

errorText : Http.Error -> String
errorText err =
  case err of
    Http.Timeout -> "Timeout"
    Http.BadUrl str -> "Badurl " ++ str
    Http.NetworkError -> "NetworkError"
    Http.BadStatus i -> "BadStatus " ++ String.fromInt i
    Http.BadBody str -> "BadBody " ++ str



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- VIEW

view : Model -> Html Msg
view model =
  case model of
    Failure failure ->
      pre [] [ text failure ]

    Loading ->
      text "Loading..."

    Success fullText ->
      pre [] [ text fullText ]