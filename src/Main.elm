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
  = Failure Http.Error
  | Loading
  | Success String


init : () -> (Model, Cmd Msg)
init _ =
  ( Loading
  , Http.request
      { method = "GET"
      , headers = [ Http.header "Access-Control-Request-Method" "GET" ] --[ Http.header "Access-Control-Allow-Origin" "http://localhost:8000" ]
      , url = "https://oriel.madarch.org/NorthWalesTech20181219/" -- "https://pastebin.com/raw/KzwWFYJL"
      , body = Http.emptyBody
      , expect = Http.expectString GotText
      , timeout = Nothing
      , tracker = Nothing
      }
  )

extractCode : String -> Maybe String
extractCode str =
  if (String.startsWith "START:" str) && (String.endsWith ":END" str) then
    str |> String.slice 6 -4 |> Just
  else
    Nothing

decodeCode : String -> Maybe String
decodeCode str =
  case Base64.decode str of
    (Result.Ok decodedStr) -> Just decodedStr
    _ -> Nothing

msgDecoder : Decoder String
msgDecoder =
  field "msg" string

extractMsg : String -> Maybe String
extractMsg str =
  case decodeString msgDecoder str of
    Result.Ok msg -> Just msg
    _ -> Nothing

doStuff : List (String -> Maybe String) -> String -> Maybe String
doStuff funcs str =
  case funcs of
   [] -> Just str
   fn::remaining ->
    case fn str of
      Nothing -> Nothing
      Just newStr -> doStuff remaining newStr


-- UPDATE


type Msg
  = GotText (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotText result ->
      case result of
        Ok fullText ->
            case doStuff [ extractCode, decodeCode, extractMsg ] fullText of
              Nothing -> (Success "Unable to decode", Cmd.none)
              Just decodedMessage -> (Success decodedMessage, Cmd.none)
            --case (extractCode fullText) of
            -- Just s ->
            --   case (decodeCode s) of
            --     Just decoded -> (Success decoded, Cmd.none)
            --     Nothing -> (Success s, Cmd.none)
            -- Nothing ->              
            --   (Success fullText, Cmd.none)

        Err failure ->
          (Failure failure, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW
errorText : Http.Error -> String
errorText err =
  case err of
    Http.Timeout -> "Timeout"
    Http.BadUrl str -> "Badurl " ++ str
    Http.NetworkError -> "NetworkError"
    Http.BadStatus i -> "BadStatus " ++ String.fromInt i
    Http.BadBody str -> "BadBody " ++ str

view : Model -> Html Msg
view model =
  case model of
    Failure failure ->
      pre [] [ text (errorText failure) ]

    Loading ->
      text "Loading..."

    Success fullText ->
      pre [] [ text fullText ]