# Changelog

## 1.5.3 (2025-07-09)

- ✨ Preset preview when loading presets
- ✨ Preset preview when saving a preset
- ✨ Delete an existing preset
- 🐛 Responsive dialogs (diceset editor, loader...)
- 🐛 Published Linux and Windows binaries missed the PCK
- 🐛 Example: crash on empty diceset
- 💄 Example: added splash screen
- 💄 Bigger diceset button
- 🏗️ fdroid requires fastlane data to be committed

## 1.5.2 (2025-07-05)

- 🏗️ Changes to enable F-Droid release
- 💄 Updated screenshots
- 🔧 Unify and cleanup binary export and deploy workflow
- 🧹 Remove `ssh_export` options in pressets
- 🧹 Removed most print traces

## 1.5.1 (2025-06-22)

- 🐛 Using slightly absorvent dice material to avoid prolonged wobbling
- 🐛 Misaligned 11 face in d12
- 💄 Dices cast shadows, lights adjusted
- 💄 Class icon for Poker dice
- 🔧 Automated builds for Android, Windows, Linux and Web
- 🔧 Automated uploads to github and itch.io

## 1.5.0 (2025-06-05)

- 🏗️ Bump to Godot 4.4: Using Jolt physics and damn uuid
- ✨ Simpler and documented way to add and customize dices. Adresses #02.
- ✨ New dices: d8, d12
- ✨ New skined d6: Poker dice (in the example)
- ✨ Example app: loading and saving dice sets
- ✨ Example app: roller box adapts its size to the number of dices
- 💥 BREAKING: DiceDef.sides -> 'DiceDefshape'
    - 'sides' (int) -> 'shape' (DiceShape: D6, D10, D10x10)
    - Legacy DiceDefs automagically migrated after load and save
- 💄 DiceShape icons shown in Property Editor
- 💄 Unified d10 text font with the one used in other dices
- 🐛 Import d10 and d10x10 as glb and not as blend.
     Not requiring blender installed. Fixes #01.
- 🔧 Unit tests. Setup CI and notifications.
- 🚧 WIP: FDroid metadata generation

## 1.4.0 (2025-02-10)

- ✨ New dice: d20
- ✨ New dice: d10x10
- ✨ `interactive` flag to enable/disable roll on click
- ✨ Expose in control the `show_faces` method to represent external rolls
- 💄Control icon clearer without outline and bigger dices
- 📝 Improved documentation (README and reference)

## 1.3.0 (2025-01-28)

- ✨ New dice: d10
- 🐛 d4: proper shape for the highlight
- ✨ Android support
- ✨ Example scene, now available as Android App
- 🏗️ Generate F-Droid metadata

## 1.2.1 (2025-01-07)

- ✨ Example: Full dice set editor: Add, Remove, Edit
- ♻️ d4 and d6 code mostly merged

## 1.2.0 (2025-01-06)

- ✨ New dice: d4
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



