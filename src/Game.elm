module Game exposing (..)

import Array
import Dict exposing (Dict)
import Note exposing (Note)
import Song exposing (Song)


type alias ObjectId =
    Int


type PlayerPos
    = OnPlatform ObjectId
    | Jumping { from : ObjectId, to : ObjectId }


type alias Object =
    { start : Int, note : Note, sort : ObjectSort }


type ObjectSort
    = LilyPad { active : Bool }
    | Wave


type alias Game =
    { track : Song
    , objects : Dict ObjectId Object
    , rows : Dict Int (List ObjectId)
    , player : PlayerPos
    , songPosition : Int
    }


activatePlatform : ObjectId -> Game -> Game
activatePlatform id game =
    { game
        | objects =
            game.objects
                |> Dict.update id
                    (Maybe.map
                        (\platform ->
                            case platform.sort of
                                LilyPad lilyPad ->
                                    { platform | sort = LilyPad { lilyPad | active = True } }

                                Wave ->
                                    platform
                        )
                    )
    }


getNextPossiblePlatforms : Game -> ObjectId -> List ObjectId
getNextPossiblePlatforms game from =
    game.objects
        |> Dict.get from
        |> Maybe.map .start
        |> Maybe.andThen (\y -> game.rows |> Dict.get (y + 1))
        |> Maybe.withDefault []
        |> List.filter
            (\next ->
                game.objects
                    |> Dict.get next
                    |> Maybe.map
                        (\object ->
                            case object.sort of
                                LilyPad { active } ->
                                    active

                                Wave ->
                                    False
                        )
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


platformIdOfPlayer : Game -> ObjectId
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
                game.objects
                    |> Dict.get id
            )
        |> List.filterMap
            (\{ note, sort } ->
                case sort of
                    LilyPad { active } ->
                        if active then
                            Just note

                        else
                            Nothing

                    Wave ->
                        Just note
            )
    )


new : Game
new =
    let
        track =
            Song.default

        objects =
            track
                |> Array.indexedMap
                    (\j list ->
                        list
                            |> List.map
                                (\note ->
                                    { start = j
                                    , sort = LilyPad { active = j == 0 }
                                    , note = note
                                    }
                                )
                    )
                |> Array.toList
                |> List.concat
                |> List.indexedMap Tuple.pair
                |> Dict.fromList

        rows =
            objects
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
    , objects = objects
    , player = player
    , rows = rows
    , songPosition = currentRow
    }
