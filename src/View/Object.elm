module View.Object exposing (..)

import Config
import Dict exposing (Dict)
import Game exposing (Object, ObjectId, ObjectSort(..))
import Html exposing (Html)
import Html.Attributes
import Html.Events
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
                View.Common.calcPlatformPosition
                    { ratioToNextBeat = args.ratioToNextBeat
                    , beatsPlayed = args.beatsPlayed
                    , start = start
                    , note = note
                    }
                    |> (case sort of
                            LilyPad { active } ->
                                lilyPad { active = active, onClick = args.onClick platformId }

                            Wave ->
                                wave
                       )
            )


lilyPad : { active : Bool, onClick : msg } -> ( Float, Float ) -> Html msg
lilyPad args ( x, y ) =
    Html.button
        ([ Html.Attributes.style "width" (String.fromFloat Config.platformWidth ++ "px")
         , Html.Attributes.style "height" (String.fromFloat Config.platformHeight ++ "px")
         , Html.Attributes.style "position" "absolute"
         , Html.Attributes.style "border-radius" "100%"
         , Html.Attributes.style "top" (String.fromFloat y ++ "px")
         , Html.Attributes.style "left" (String.fromFloat x ++ "px")
         , Html.Events.onClick args.onClick
         ]
            ++ (if args.active then
                    [ Html.Attributes.style "background-color" Config.lilyPadColor
                    , Html.Attributes.style "border" ("8px solid " ++ Config.lilyPadColor)
                    ]

                else
                    [ Html.Attributes.style "background-color" "transparent"
                    , Html.Attributes.style "border" ("8px dashed " ++ Config.lilyPadColor)
                    , Html.Attributes.style "z-index" "10"
                    ]
               )
        )
        []


wave : ( Float, Float ) -> Html msg
wave ( x, y ) =
    Html.div
        [ Html.Attributes.style "width" (String.fromFloat Config.platformWidth ++ "px")
        , Html.Attributes.style "height" (String.fromFloat Config.platformHeight ++ "px")
        , Html.Attributes.style "top" (String.fromFloat y ++ "px")
        , Html.Attributes.style "left" (String.fromFloat x ++ "px")
        ]
        []
