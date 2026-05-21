module Puzzles exposing (Puzzle, allLayers, puzzles)

-- PUZZLES
-- Each puzzle is a list of layer IDs in bottom-to-top stacking order.
-- There's an index associated that represents the layers to use for that puzzle.


type alias Puzzle =
    ( Int, List String )


puzzles : List Puzzle
puzzles =
    [ -- Disegno 1
      ( 0, [ "108", "105", "110", "107", "109" ] )
    , -- Disegno 2
      ( 0, [ "104", "106", "105", "107", "110" ] )
    , -- Disegno 3
      ( 1, [ "207", "208", "204", "201" ] )
    , -- Disegno 4
      ( 1, [ "203", "210", "212", "211", "205" ] )
    ]


allLayers : List (List String)
allLayers =
    [ List.range 101 112 |> List.map String.fromInt
    , List.range 201 212 |> List.map String.fromInt
    ]
