module Main exposing (..)

import Browser
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Color as AVHC exposing (Color)
import Colorbrewer.Qualitative as ColorBrew
import Dict exposing (Dict)
import Html as H
import Html.Attributes as HA
import Html.Events exposing (onClick)
import Json.Decode exposing (Decoder, decodeString, dict, field, float, int, list, map2, string)
import List.Extra exposing (cycle)
import Svg exposing (rect, svg)
import Svg.Attributes exposing (fill, height, width)


type alias Flags =
    { source : String
    , names : String
    }


type alias TimeValue =
    { time : Int
    , value : Float
    }


type alias DecodedItem =
    { name : String
    , data : List TimeValue
    }


type alias Item =
    { name : String
    , data : List TimeValue
    , shown : Bool
    , colour : Color
    }


type alias Datum =
    { x : Float
    , y : Dict String Float
    }


type Message
    = Toggle String
    | OnHover (List (CI.One Datum CI.Dot))


type alias Model =
    { items : List Item
    , names : Dict String String
    , hovering : List (CI.One Datum CI.Dot)
    }


timeValueDecoder : Decoder TimeValue
timeValueDecoder =
    --map2 (\timetime timevalue -> TimeValue (timetime |> millisToPosix) timevalue)
    map2 TimeValue
        (field "time" int)
        (field "value" float)


all_colours : List Color
all_colours =
    ColorBrew.set28
        ++ ColorBrew.accent8
        ++ ColorBrew.set19
        ++ [ AVHC.red, AVHC.orange, AVHC.yellow, AVHC.green, AVHC.blue, AVHC.purple, AVHC.brown ]
        ++ [ AVHC.darkBlue, AVHC.darkBrown, AVHC.darkGreen, AVHC.darkOrange, AVHC.darkPurple, AVHC.darkYellow, AVHC.darkRed ]


itemDecoder : Dict String String -> Decoder DecodedItem
itemDecoder nameDict =
    -- default items to shown
    map2 (\recordId data -> DecodedItem (nameDict |> Dict.get recordId |> Maybe.withDefault "Unknown") data)
        (field "name" string)
        (field "data" (list timeValueDecoder))


init : Flags -> ( Model, Cmd Message )
init flags =
    case decodeString (dict string) flags.names of
        Ok nameDict ->
            case decodeString (list (itemDecoder nameDict)) flags.source of
                Ok decodedItems ->
                    let
                        enoughColours =
                            cycle (decodedItems |> List.length) all_colours

                        items =
                            List.map2 (\decoded colour -> Item decoded.name decoded.data True colour) decodedItems enoughColours
                    in
                    ( Model items nameDict [], Cmd.none )

                Err _ ->
                    ( Model [] nameDict [], Cmd.none )

        Err _ ->
            ( Model [] Dict.empty [], Cmd.none )



-- VIEW


type alias StringFloat =
    { name : String
    , value : Float
    }


itemsToValueList : List Item -> List Datum
itemsToValueList itemList =
    let
        values : Dict Int (List StringFloat)
        values =
            itemList
                |> List.foldl
                    (\item foldDict ->
                        let
                            items : Dict Int StringFloat
                            items =
                                item.data |> List.map (\datum -> ( datum.time, { name = item.name, value = datum.value } )) |> Dict.fromList
                        in
                        Dict.merge
                            (\key left result -> result |> Dict.insert key [ left ])
                            (\key left right result -> result |> Dict.insert key (left :: right))
                            (\key right result -> result |> Dict.insert key right)
                            items
                            foldDict
                            Dict.empty
                    )
                    Dict.empty

        -- time to a Dict of names and values
        valueDict : Dict Int (Dict String Float)
        valueDict =
            values |> Dict.map (\_ v -> v |> List.map (\sf -> ( sf.name, sf.value )) |> Dict.fromList)

        valueList : List Datum
        valueList =
            valueDict |> Dict.toList |> List.map (\( t, l ) -> Datum (t |> toFloat) l)
    in
    valueList


view : Model -> H.Html Message
view model =
    let
        rectangles : List (H.Html Message)
        rectangles =
            model.items
                |> List.map
                    (\item ->
                        let
                            rectangle =
                                svg [ height "20", width "50" ] [ rect [ height "15", width "50", fill (AVHC.toCssString item.colour) ] [] ]

                            font14 =
                                HA.style "font-size" "14px"

                            span =
                                if item.shown then
                                    H.span [ font14, onClick (Toggle item.name) ] [ H.text item.name ]

                                else
                                    H.del [ font14, onClick (Toggle item.name) ] [ H.text item.name ]
                        in
                        H.div [ HA.style "display" "inline", HA.style "padding-right" "10px", HA.style "padding-left" "10px" ] [ rectangle, span ]
                    )

        valueList : List Datum
        valueList =
            model.items |> itemsToValueList
    in
    H.div []
        [ H.h4 [ HA.style "display" "flex", HA.style "justify-content" "center" ] [ H.text "Elm Chart" ]
        , H.div [] rectangles
        , H.div []
            [ C.chart
                [ CA.width 1500
                , CA.height 300
                , CE.onMouseMove OnHover (CE.getNearest CI.dots)
                , CE.onMouseLeave (OnHover [])
                , CA.margin { top = 0, bottom = 30, left = 20, right = 20 }
                ]
                ([ C.xTicks [ CA.noGrid ]
                 , C.yTicks []

                 --, C.xLabels [ CA.times utc, CA.amount 12 ]
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
                 -- x value is the first item in the Datum Tuple
                 , C.series .x
                    (model.items
                        |> List.filter .shown
                        |> List.map
                            (\item ->
                                C.interpolatedMaybe
                                    (\v -> v.y |> Dict.get item.name)
                                    [ CA.color (AVHC.toCssString item.colour) ]
                                    --[]
                                    -- The dots scale with the display
                                    -- so they are smaller on a small screen
                                    [ CA.circle, CA.size 6 ]
                                    |> C.named item.name
                            )
                    )
                    valueList
                 , C.each model.hovering <|
                    \plane item ->
                        [ C.tooltip item [] [] [] ]
                 ]
                 --++ (data
                 --        |> List.map
                 --            (\item ->
                 --                C.series (\v -> v.time |> toFloat)
                 --                    [ C.interpolated (\x -> x.value) [] [ CA.circle, CA.size 3 ] ]
                 --                    item
                 --            )
                 --   )
                )
            ]
        ]


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        Toggle itemName ->
            let
                list =
                    model.items
                        |> List.map
                            (\old ->
                                if old.name == itemName then
                                    { old | shown = not old.shown }

                                else
                                    old
                            )
            in
            ( { model | items = list }, Cmd.none )

        OnHover hovering ->
            ( { model | hovering = hovering }, Cmd.none )


subscriptions : Model -> Sub Message
subscriptions _ =
    Sub.none


main : Program Flags Model Message
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
