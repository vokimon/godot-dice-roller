# TODO's

- [ ] Fix: Dices have lost the initial random spin, noticeable with few dices
- [ ] Stop long/infinite rollings. How? Reroll? Put stopped dices aside?
- [ ] Visual queue to show rolling is available (bouncing dices?)
- [ ] Adapt the size of the box to the number of dices
- [ ] Do dices have to be 2 meters wide and weight kilos?
- [ ] Improve textures for the dices (wood, marble...)
- [ ] Example: Rolling box editor
- [ ] Example: Loading and saving dice sets
- [ ] Godot Editor for dice set attribute editor to look more than the example dice set editor
- [ ] More dice shapes: d8, d12
- [ ] D10x10: Should appear as "10x10" and not "100" in dice set editor
    - [ ] Unrelate shape identification from the number of sides
- [ ] d20: Review numbers position to match standard dice
- [ ] d20: Review stability conditions, too bumpy

## Done's

- [x] Signal for start rolling
- [x] One shot rolling, games controlling when a rolling is required -> interactive flag covers that
- [x] D10x10: Own icon (draw zeros on numbers)
- [x] d20: scale up
- [x] d20: adjust highlight
- [x] More dice shapes: d10x10
- [x] More dice shapes: d20
- [x] More dice shapes: d10
- [x] Android: UI controls appear small
- [x] Android: App icons look ugly
- [x] Fix: d4 highlight to adapt to the dice shape
- [x] Solve how to setup dices from the top level Node
- [x] Propagate the 3 ways of rolling to the top level
- [x] Fix: You can set face of one dice while the other still rolling
- [x] Fix: Add last tween for the face to face up after rolling
- [x] Example: add button for quick roll
- [x] Parametrizable box material/color
- [x] d4 dice shape
- [x] Abstract common d4 and d6 code
- [x] Add d6 a bevel
- [x] Example: Dice set editor
