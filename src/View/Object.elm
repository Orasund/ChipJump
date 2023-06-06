module View.Object exposing (..)

import Config
import Dict exposing (Dict)
import Game exposing (Object, ObjectId, ObjectSort(..))
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode as Decode
import View.Common


fromDict :
    { ratioToNextBeat : Float
    , onClick : ObjectId -> msg
    , beatsPlayed : Int
    }
    -> Dict ObjectId Object
    -> List (Html msg)
fromDict args dict =
    dict
        |> Dict.toList
        |> List.map
            (\( platformId, { start, note, sort } ) ->
                View.Common.calcLilyPadPosition
                    { ratioToNextBeat = args.ratioToNextBeat
                    , beatsPlayed = args.beatsPlayed
                    , start = start
                    , note = note
                    }
                    |> (case sort of
                            LilyPad { active } ->
                                lilyPad
                                    { active = active
                                    , onClick = args.onClick platformId
                                    , size =
                                        case start |> modBy Config.maxJumpSize of
                                            1 ->
                                                0.75

                                            _ ->
                                                1
                                    }

                            Wave ->
                                wave
                       )
            )


lilyPad : { active : Bool, onClick : msg, size : Float } -> ( Float, Float ) -> Html msg
lilyPad args ( x, y ) =
    let
        lilyPadSize =
            args.size * Config.lilyPadSize

        offSet =
            Config.lilyPadSize / 2 - lilyPadSize / 2
    in
    Html.button
        ([ Html.Attributes.style "width" (String.fromFloat lilyPadSize ++ "px")
         , Html.Attributes.style "height" (String.fromFloat lilyPadSize ++ "px")
         , Html.Attributes.style "position" "absolute"
         , Html.Attributes.style "border-radius" "100%"
         , Html.Attributes.style "top" (String.fromFloat (y + offSet) ++ "px")
         , Html.Attributes.style "left" (String.fromFloat (x + offSet) ++ "px")
         , Html.Attributes.style "background-color" "transparent"
         , Html.Events.onMouseDown args.onClick
         ]
            ++ (if args.active then
                    [ Html.Attributes.style "background-image" "url('assets/images/lilyPad.png')"
                    , Html.Attributes.style "background-size" "100%"
                    , Html.Attributes.style "border" "0px"
                    ]

                else
                    [ Html.Attributes.style "border" ("8px dashed " ++ Config.lilyPadColor)
                    , Html.Attributes.style "z-index" "10"
                    ]
               )
        )
        []


wave : ( Float, Float ) -> Html msg
wave ( x, y ) =
    Html.div
        [ Html.Attributes.style "width" (String.fromFloat Config.lilyPadSize ++ "px")
        , Html.Attributes.style "height" (String.fromFloat Config.lilyPadSize ++ "px")
        , Html.Attributes.style "position" "absolute"
        , Html.Attributes.style "top" (String.fromFloat y ++ "px")
        , Html.Attributes.style "left" (String.fromFloat x ++ "px")
        , Html.Attributes.style "background-color" "black"
        ]
        []
