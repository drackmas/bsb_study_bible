# Book Picker Redesign Plan

## Problem
Current book picker uses `SliverGridDelegateWithMaxCrossAxisExtent` which allows vertical scrolling. On tall/narrow screens, tiles shrink but scrolling still occurs. Requirement: ALL 66 books must be visible simultaneously with zero scrolling.

## Solution Architecture

### Core Algorithm (`_findBestFit`)
Calculate the optimal grid configuration dynamically:
```
For each candidate column count C (1 to 66):
  rows = ceil(66 / C)
  tileW = availWidth / C
  tileH = availHeight / rows
  tile = min(tileW, tileH)
  if tile > bestTile:
    bestTile = tile
    bestCols = C
```

### Layout Structure
```
Scaffold
├── AppBar (fixed height)
├── BottomBar (fixed height)
└── CustomScrollView
    └── SliverGrid
        ├── SliverGridDelegateWithFixedCrossAxisCount(cols: bestCols)
        ├── childAspectRatio: 1.0 (square tiles)
        ├── mainAxisSpacing: 8
        └── crossAxisSpacing: 8
```

### Key Changes to `book_picker.dart`
1. Add `_bookCount = 66` constant
2. Implement `_findBestFit(availWidth, availHeight)` returning `(cols, tile)`
3. Replace `SliverGridDelegateWithMaxCrossAxisExtent` with `SliverGridDelegateWithFixedCrossAxisCount`
4. Use `SliverGrid` with `childAspectRatio: 1.0` in a `CustomScrollView`
5. Calculate `availHeight = constraints.maxHeight - appBarHeight - bottomBarHeight - padding`
6. Calculate `availWidth = constraints.maxWidth - horizontalPadding`

### Key Changes to `bible_screen.dart`
- Ensure the book picker screen uses `Scaffold` with no extra scrollable wrappers
- `_showBookPicker()` already pushes as `MaterialPageRoute` — no change needed

## Implementation Steps
1. Rewrite `book_picker.dart` with the fit algorithm
2. Use `SliverGridDelegateWithFixedCrossAxisCount` for strict column enforcement
3. Ensure `childAspectRatio: 1.0` for perfect squares
4. Test at multiple constraints (320x568, 390x844, 768x1024, 1024x768, foldable)
