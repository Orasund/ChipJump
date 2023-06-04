module Game exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Note exposing (Note)
import Track exposing (Track)


type alias PlatformId =
    Int


type PlayerPos
    = OnPlatform PlatformId
    | Jumping { from : PlatformId, to : PlatformId }


type alias Platform =
    { start : Int, active : Bool, note : Note }


type alias Game =
    { track : Track
    , platforms : Dict PlatformId Platform
    , rows : Dict Int (List PlatformId)
    , player : PlayerPos
    , songPosition : Int
    }


activatePlatform : PlatformId -> Game -> Game
activatePlatform id game =
    { game
        | platforms =
            game.platforms
                |> Dict.update id
                    (Maybe.map (\platform -> { platform | active = True }))
    }


getNextPossiblePlatforms : Game -> PlatformId -> List PlatformId
getNextPossiblePlatforms game from =
    game.platforms
        |> Dict.get from
        |> Maybe.map .start
        |> Maybe.andThen (\y -> game.rows |> Dict.get (y + 1))
        |> Maybe.withDefault []
        |> List.filter
            (\next ->
                game.platforms
                    |> Dict.get next
                    |> Maybe.map .active
                    |> (==) (Just True)
            )


recheckNextPlayerPos : Game -> Game
recheckNextPlayerPos game =
    case game.player of
        OnPlatform platformId ->
            if getNextPossiblePlatforms game platformId /= [] then
                nextPlayerPos game

            else
                game

        Jumping _ ->
            game


platformIdOfPlayer : Game -> PlatformId
platformIdOfPlayer game =
    case game.player of
        OnPlatform platformId ->
            platformId

        Jumping { to } ->
            to


nextPlayerPos : Game -> Game
nextPlayerPos game =
    let
        currentPos =
            platformIdOfPlayer game

        player =
            currentPos
                |> getNextPossiblePlatforms game
                |> List.head
                |> Maybe.map
                    (\next ->
                        Jumping { from = currentPos, to = next }
                    )
                |> Maybe.withDefault (OnPlatform currentPos)
    in
    { game | player = player }


nextBeat : Game -> ( Game, List Note )
nextBeat game =
    ( { game | songPosition = game.songPosition + 1 } |> nextPlayerPos
    , game.rows
        |> Dict.get (game.songPosition + 1)
        |> Maybe.withDefault []
        |> List.filterMap
            (\id ->
                game.platforms
                    |> Dict.get id
            )
        |> List.filterMap
            (\{ note, active } ->
                if active then
                    Just note

                else
                    Nothing
            )
    )


new : Game
new =
    let
        track =
            Track.default

        platforms =
            track
                |> Array.indexedMap
                    (\j list ->
                        list
                            |> List.map
                                (\note ->
                                    { start = j
                                    , active = False
                                    , note = note
                                    }
                                )
                    )
                |> Array.toList
                |> List.concat
                |> List.indexedMap Tuple.pair
                |> Dict.fromList

        rows =
            platforms
                |> Dict.foldl
                    (\id { start } ->
                        Dict.update start
                            (\maybe ->
                                maybe
                                    |> Maybe.withDefault []
                                    |> (::) id
                                    |> Just
                            )
                    )
                    Dict.empty

        player =
            OnPlatform 0

        currentRow =
            0
    in
    { track = track
    , platforms = platforms
    , player = player
    , rows = rows
    , songPosition = currentRow
    }
