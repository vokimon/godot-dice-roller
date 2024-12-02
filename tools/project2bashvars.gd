#! ../Godot_v4.3-stable_linux.x86_64 --display-driver headless --quit -s 
# https://raw.githubusercontent.com/vokimon/godot-dice-roller/refs/heads/main/icon.svg
extends MainLoop

func printvar(shellvar, setting_value):
	if not setting_value.contains('\n'):
		print('{0}="{1}"'.format([shellvar, setting_value]))
	else:
		print('{0}=$(cat <<EOF\n{1}\nEOF\n)'.format([shellvar, setting_value]))

func printvar_fromgodot(shellvar, setting, default):
	var setting_value = ProjectSettings.get_setting(setting, default)
	printvar(shellvar, setting_value)


func _init():
	printvar_fromgodot('PROJECT_NAME', "application/config/name", "Noname")
	printvar_fromgodot('PROJECT_DESC', "application/config/description", "No description specified.")
	printvar_fromgodot('PROJECT_VERSION', "application/config/version", "0.0.0")
	printvar_fromgodot('PROJECT_ICON', "application/config/icon", "icon.svg")
	var godot_required = ProjectSettings.get_setting('application/config/features')[0]
	printvar("GODOT_VERSION", godot_required)



