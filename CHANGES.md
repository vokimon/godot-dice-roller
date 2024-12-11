# Changelog

## 1.0.3 (2024-12-11)

- Dices set can be defined with control properties
- Dices are auto-named if no name given or the name conflicts with other dices
- Lights adjustments.
- Fix: Dice colors looked as dark as far they were from yellow.
  Svg texture was loaded with a yellow background. Using png export instead.
- Fix: Dice highlight position degradated with each roll.
  Floor offset was not properly oriented and accomulated.
- Fix: Freeze when when quick rolling a set bigger than two.

## 1.0.2 (2024-12-02)

- CI to release from github actions
- Icon and classname for RollerBox

## 1.0.1 (2024-12-02)

- Example out of the addon
- Documentation and metadata

## 1.0.0 (2024-12-02)

- First public release
- Extracted from godatan project
- Reorganized object responsability
- Code distributed into a folder per scene
- Roller box can be resized
- Generated collision shapes to enable dinamic
- Set camera so that the viewport adjust the floor of the box
- Rotate the camera so that box and viewport matches portrait/landscape orientation
- Added an example of usage within a UI
- Debug tools



