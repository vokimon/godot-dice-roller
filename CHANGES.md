# Changelog

## 1.2.1 (2025-01-07)

- ✨ Example: Full dice set editor: Add, Remove, Edit
- ♻️ d4 and d6 code mostly joined

## 1.2.0 (2025-01-06)

- ✨ Support for d4 dices
- 💄 Beveled borders for d6
- ♻️ Generalization to favor inclusion of more shapes of dices

## 1.1.1 (2025-01-03)

- ✨ Cleaner installs
	- screenshots and build files excluded from package
	- examples moved to `examples/dice_roller/` for cleaner
	  merge in user's project along with other plugins.

## 1.1.0 (2024-12-23)

- ✨ API stabilized. From now on, api changes will imply
  major and minor version changes following semantic versioning.
- 🐛 Highlights without artifacts
- 🔧 New script to upload to the asset lib using project metadata

## 1.0.5 (2024-12-19)

- ✨ DiceRollerControl can be created without instantiating
     the scene, just by creating selecting the node type.
- ✨ Expose roller attributes in Control (box size and color)
- ✨ Method `per_dice_result` returns the value of each dice
- ✨ Example: New button to add dices interactivelly
- 💄 Added Environment with ambient light for more natural look
- 🐛 Fix: rolling after fastrolling kept the highlight
- 🐛 Fix: avoid changing the dice set while rolling
- 🏗️ Removed non essential files from the package

## 1.0.4 (2024-12-13)

- 💄 More natural initial arrangement of dices
- ✨ `DiceRollerControl` signal `roll_started`
- ✨ `DiceRollerControl` method `quick_rolling`
- ✨ Example updated to show how to use them
- 🧹 Scenes cleanup of uneeded properties
- 🏗️ Packaging: Added previews and fixed name to match

## 1.0.3 (2024-12-11)

- ✨ Dices set can be defined with control properties
- ✨ Dices are auto-named if no name given or the name conflicts with other dices
- 💄 Lights adjustments.
- 🐛 Fix: Dice colors looked as dark as far they were from yellow.
     Svg texture was loaded with a yellow background. Using png export instead.
- 🐛 Fix: Dice highlight position degradated with each roll.
     Floor offset was not properly oriented and accomulated.
- 🐛 Fix: Freeze when when quick rolling a set bigger than two.

## 1.0.2 (2024-12-02)

- 🔧 CI to release from github actions
- ✨ Icon and classname for RollerBox

## 1.0.1 (2024-12-02)

- ♻️  Example out of the addon
- 📝 Documentation and metadata

## 1.0.0 (2024-12-02)

- ✨ First public release
- ♻️ Extracted from godatan project
- ♻️ Reorganized object responsability
- ♻️ Code distributed into a folder per scene
- ✨ Roller box can be resized
- ✨ Generated collision shapes to enable dinamic
- ♻️ Set camera so that the viewport adjust the floor of the box
- ✨ Rotate the camera so that box and viewport matches portrait/landscape orientation
- 📝 Added an example of usage within a UI
- ✨ Debug tools



