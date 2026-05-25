module Puzzles exposing (Puzzle, allLayers, puzzles)

-- PUZZLES
-- Each puzzle is a function that evaluates whether a given solution is correct,
-- This allows to have puzzles with many solutions.
-- To a puzzle, there's an associated list of layers that are used for rendering.
-- There's an index associated that represents the layers to use for that puzzle.


type alias Puzzle =
    ( Int, List String, List String -> Bool )


puzzles : List Puzzle
puzzles =
    [ -- Disegno 1
      ( 0, [ "108", "105", "110", "107", "109" ], \x -> x == [ "108", "105", "110", "107", "109" ] )
    , -- Disegno 2
      ( 0, [ "104", "106", "105", "107", "110" ], \x -> x == [ "104", "106", "105", "107", "110" ] )
    , -- Disegno 3
      ( 1, [ "207", "208", "204", "201" ], \x -> x == [ "207", "208", "204", "201" ] )
    , -- Disegno 4
      ( 1, [ "203", "210", "212", "211", "205" ], \x -> x == [ "203", "210", "212", "211", "205" ] )
    , -- Disegno 5
      ( 1
      , [ "207", "202", "210", "209", "212" ]
      , \x ->
            List.member x
                [ [ "207", "202", "210", "209", "212" ]
                , [ "207", "210", "202", "209", "212" ]
                , [ "207", "202", "210", "212", "209" ]
                , [ "207", "210", "202", "212", "209" ]
                ]
      )
    , -- Disegno 6
      ( 1
      , [ "207", "210", "208", "204", "209" ]
      , \x ->
            List.member x
                [ [ "208", "210", "208", "204", "209" ]
                , [ "207", "208", "210", "204", "209" ]
                , [ "207", "210", "208", "209", "204" ]
                , [ "207", "208", "210", "204", "209" ]
                ]
      )
    ]


allLayers : List (List String)
allLayers =
    -- same as [["101", "102", ... "112"], ["201", ... "212"]]
    [ List.range 101 112 |> List.map String.fromInt
    , List.range 201 212 |> List.map String.fromInt
    ]
