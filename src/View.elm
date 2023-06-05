module View exposing (..)

import Config
import Dict exposing (Dict)
import Game exposing (Game, Object, ObjectId, ObjectSort(..), PlayerPos(..))
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Layout
import Note exposing (Note(..))
import View.Common
import View.Object


titleScreen : { start : msg } -> Html msg
titleScreen args =
    [ "<Game Title>"
        |> Html.text
        |> Layout.heading1 [ Html.Attributes.style "color" Config.playerColor ]
    , Layout.textButton [ Html.Attributes.class "button" ] { onPress = Just args.start, label = "Start" }
    ]
        |> Layout.column [ Layout.gap 100 ]
        |> Layout.el
            (Layout.centered
                ++ [ Html.Attributes.style "position" "relative"
                   , Html.Attributes.style "background-color" Config.backgroundColor
                   , Html.Attributes.style "height" (String.fromFloat Config.screenHeight ++ "px")
                   , Html.Attributes.style "width" (String.fromFloat Config.screenWidth ++ "px")
                   ]
            )


fromGame :
    { ratioToNextBeat : Float
    , onClick : ObjectId -> msg
    }
    -> Game
    -> Html msg
fromGame args game =
    let
        getPlatformPosition id =
            game.objects
                |> Dict.get id
                |> Maybe.map (\{ start, note } -> ( note, start ))
                |> Maybe.withDefault ( C1, 0 )

        playerPos =
            case game.player of
                OnPlatform id ->
                    getPlatformPosition id
                        |> calcPlayerPositionOnPlatform
                            { ratioToNextBeat = args.ratioToNextBeat
                            , beatsPlayed = game.songPosition
                            }

                Jumping { from, to } ->
                    calcPlayerJumpingPosition
                        { from = getPlatformPosition from
                        , to = getPlatformPosition to
                        , ratioToNextBeat = args.ratioToNextBeat
                        , beatsPlayed = game.songPosition
                        }
    in
    [ game.objects
        |> View.Object.fromDict
            { ratioToNextBeat = args.ratioToNextBeat
            , onClick = args.onClick
            , beatsPlayed = game.songPosition
            }
    , [ playerPos |> player ]
    ]
        |> List.concat
        |> Html.div
            [ Html.Attributes.style "position" "relative"
            , Html.Attributes.style "background-color" Config.backgroundColor
            , Html.Attributes.style "height" (String.fromFloat Config.screenHeight ++ "px")
            , Html.Attributes.style "width" (String.fromFloat Config.screenWidth ++ "px")
            ]


player : ( Float, Float ) -> Html msg
player ( x, y ) =
    Html.div
        [ Html.Attributes.style "width" (String.fromFloat Config.playerSize ++ "px")
        , Html.Attributes.style "height" (String.fromFloat Config.playerSize ++ "px")
        , Html.Attributes.style "background-color" Config.playerColor
        , Html.Attributes.style "position" "absolute"
        , Html.Attributes.style "top" (String.fromFloat y ++ "px")
        , Html.Attributes.style "left" (String.fromFloat x ++ "px")
        ]
        []


calcPlayerJumpingPosition :
    { from : ( Note, Int )
    , to : ( Note, Int )
    , ratioToNextBeat : Float
    , beatsPlayed : Int
    }
    -> ( Float, Float )
calcPlayerJumpingPosition args =
    let
        calcPosition =
            calcPlayerPositionOnPlatform
                { ratioToNextBeat = args.ratioToNextBeat
                , beatsPlayed = args.beatsPlayed
                }

        ( x1, y1 ) =
            calcPosition args.to

        ( x2, y2 ) =
            calcPosition args.from

        ratio =
            if args.ratioToNextBeat > (1 - Config.jumpTime) then
                (args.ratioToNextBeat - (1 - Config.jumpTime)) / Config.jumpTime

            else
                0
    in
    ( x2 + (x1 - x2) * ratio, y2 + (y1 - y2) * ratio )


calcPlayerPositionOnPlatform :
    { ratioToNextBeat : Float
    , beatsPlayed : Int
    }
    -> ( Note, Int )
    -> ( Float, Float )
calcPlayerPositionOnPlatform args ( note, start ) =
    let
        ( x, y ) =
            View.Common.calcLilyPadPosition
                { ratioToNextBeat = args.ratioToNextBeat
                , beatsPlayed = args.beatsPlayed
                , start = start
                , note = note
                }
    in
    ( x + Config.lilyPadSize / 2 - Config.playerSize / 2
    , y + Config.lilyPadSize / 2 - Config.playerSize / 2
    )
