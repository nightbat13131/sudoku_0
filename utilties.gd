class_name Utilties extends RefCounted

const SODOKU_GUESS = &"Sudoku Guess"
const SUDOKU_HINT = &"Sudoku Hint"
const INPUT_UNDO = &"input_undo"
const INPUT_REDO = &"input_redo"

const COLOR_SUBGRID_HIGHLIGHT : Color = Color(1, 1, 1)
const COLOR_SUBGRID_LOWLIGHT : Color = Color(.7, .7, .7,)


enum Difficulty {EASY = 0, MEDIUM = 1, HARD = 2}

## valid SUDOCU cell values are 1+. Map out the meaing of alternate values.
enum Sudoku_Cell_Alts {EMPTY = 0, GUESS_BLOCKED = -1 }

enum SudokuMode {NUMBERS = 0, ICONS = 1}
