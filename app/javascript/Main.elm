module Main exposing (..)

import Browser
import Chart as C
import Chart.Attributes as CA
import Dict exposing (Dict)
import Html exposing (Html, div, h4, text)
import Html.Attributes exposing (style)
import Json.Decode exposing (Decoder, decodeString, dict, field, float, int, list, map2, string)



-- MODEL


type alias Model =
    { items : List Item
    , names : Dict String String
    }


type alias Flags =
    { source : String
    , names : String
    }


type alias TimeValue =
    { time : Int
    , value : Float
    }


type alias Item =
    { name : String
    , data : List TimeValue
    }


timeValueDecoder : Decoder TimeValue
timeValueDecoder =
    --map2 (\timetime timevalue -> TimeValue (timetime |> millisToPosix) timevalue)
    map2 TimeValue
        (field "time" int)
        (field "value" float)


itemDecoder : Decoder Item
itemDecoder =
    map2 Item
        (field "name" string)
        (field "data" (list timeValueDecoder))


init : Flags -> ( Model, Cmd Message )
init flags =
    case decodeString (dict string) flags.names of
        Ok nameDict ->
            case decodeString (list itemDecoder) flags.source of
                Ok items ->
                    ( Model items nameDict, Cmd.none )

                Err _ ->
                    ( Model [] nameDict, Cmd.none )

        Err _ ->
            ( Model [] Dict.empty, Cmd.none )



-- VIEW


view : Model -> Html Message
view model =
    let
        first =
            model.items |> List.head |> Maybe.map (\item -> item.data) |> Maybe.withDefault []

        -- The inline style is being used for example purposes in order to keep this example simple and
        -- avoid loading additional resources. Use a proper stylesheet when building your own app.
    in
    div []
        [ h4 [ style "display" "flex", style "justify-content" "center" ] [ text "Hello Elm!" ]
        , div []
            [ --text (model.names |> Dict.values |> String.join " ")
              C.chart
                [ CA.width 1500
                , CA.height 300
                , CA.margin { top = 0, bottom = 30, left = 20, right = 20 }
                ]
                [ C.xTicks [ CA.noGrid ]
                , C.yTicks []
                , C.xLabels []
                , C.yLabels []

                --, C.yAxis [ CA.highest 1 CA.exactly ]
                --, C.series .age
                --    [ C.interpolated .height [] []
                --    , C.interpolated .weight [] []
                --    ]
                --    [ { age = 0, height = 40, weight = 4 }
                --    , { age = 5, height = 80, weight = 24 }
                --    , { age = 10, height = 120, weight = 36 }
                --    , { age = 15, height = 180, weight = 54 }
                --    , { age = 20, height = 184, weight = 60 }
                --    ]
                , C.series (\tv -> tv.time |> toFloat)
                    [ C.interpolated .value [] [ CA.circle, CA.size 3 ]
                    ]
                    first
                ]
            ]

        --(model.items
        --    |> List.map
        --        (\item ->
        --            let
        --                v1 =
        --                    item.data |> List.map (\x -> x.time |> posixToMillis |> String.fromInt)
        --
        --                v : List (Html msg)
        --                v =
        --                    v1 |> List.map (\x -> text x)
        --            in
        --            div []
        --                ([ span [] [ text item.name ] ] ++ v)
        --        )
        --)
        ]



--[text "Hello Elm!", text "ready"]
-- MESSAGE


type Message
    = Never



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions _ =
    Sub.none



-- MAIN


main : Program Flags Model Message
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
