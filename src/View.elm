module View exposing (..)

import Config
import Dict
import Game exposing (Game, PlayerPos(..))
import Html exposing (Html)
import Html.Attributes


fromGame : Game -> Html msg
fromGame game =
    let
        getPlatformPosition id =
            game.platforms
                |> Dict.get id
                |> Maybe.withDefault ( 0, 0 )

        playerPos =
            case game.player of
                OnPlatform id ->
                    getPlatformPosition id
                        |> calcPlayerPositionOnPlatform

                Jumping args ->
                    calcPlayerJumpingPosition
                        { from = getPlatformPosition args.from
                        , to = getPlatformPosition args.to
                        }
    in
    [ game.platforms |> Dict.values |> platforms
    , [ playerPos |> player ]
    ]
        |> List.concat
        |> Html.div [ Html.Attributes.style "position" "relative" ]


player : ( Float, Float ) -> Html msg
player ( x, y ) =
    Html.div
        [ Html.Attributes.style "width" (String.fromFloat Config.playerSize ++ "px")
        , Html.Attributes.style "height" (String.fromFloat Config.playerSize ++ "px")
        , Html.Attributes.style "background-color" "blue"
        , Html.Attributes.style "position" "absolute"
        , Html.Attributes.style "top" (String.fromFloat y ++ "px")
        , Html.Attributes.style "left" (String.fromFloat x ++ "px")
        ]
        []


platforms : List ( Int, Int ) -> List (Html msg)
platforms list =
    list
        |> List.map
            (\( x, y ) ->
                platform (calcPlatformPosition ( x, y ))
            )


calcPlayerJumpingPosition : { from : ( Int, Int ), to : ( Int, Int ) } -> ( Float, Float )
calcPlayerJumpingPosition args =
    calcPlayerPositionOnPlatform args.from


calcPlayerPositionOnPlatform : ( Int, Int ) -> ( Float, Float )
calcPlayerPositionOnPlatform pos =
    let
        ( x, y ) =
            calcPlatformPosition pos
    in
    ( x + Config.platformWidth / 2 - Config.playerSize / 2, y - Config.playerSize )


calcPlatformPosition : ( Int, Int ) -> ( Float, Float )
calcPlatformPosition ( x, y ) =
    ( (Config.platformWidth + Config.horizontalSpaceBetweenPlatforms)
        * toFloat x
        - (Config.platformWidth / 2)
        + (Config.screenWidth / 2)
    , (Config.platformHeight + Config.verticalSpaceBetweenPlatforms) * toFloat -y + Config.screenHeight
    )


platform : ( Float, Float ) -> Html msg
platform ( x, y ) =
    Html.div
        [ Html.Attributes.style "width" (String.fromFloat Config.platformWidth ++ "px")
        , Html.Attributes.style "height" (String.fromFloat Config.platformHeight ++ "px")
        , Html.Attributes.style "background-color" "black"
        , Html.Attributes.style "position" "absolute"
        , Html.Attributes.style "top" (String.fromFloat y ++ "px")
        , Html.Attributes.style "left" (String.fromFloat x ++ "px")
        ]
        []
