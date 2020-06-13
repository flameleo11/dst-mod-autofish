name = "autofish"
description = "Rework of Auto Cook, Auto Fish and More"

--description = "TEST BUILD"

author = "flameleo"
version = "1.00"

--changelog: 1.1 added hotkeys to cooking and fishing toggle
--changelog: 1.15 im a dummy and had to hotfix a little mistake
--changelog: 1.16 not attempting to have a mod icon until I know what im doing :\
--changelog: 1.20 character now says what the nearby boss entity is; tweaked tracker for pigheads and walrus camps, added tracker for "totally normal tree"
--changelog: 1.21 added warly cooking support
--changelog: 1.22 added warly spicing support,added gestalt indicator
--changelog: 1.23 fixed minor bug and corrected info
--changelog: 1.24 addressed crashes when running Keep Following mod, potentially fixed backpack related crashes with big thanks to mod author DemonBlink
--changelog: 1.25 added tracking of pipspook toys

forumthread = ""

api_version = 10
dst_compatible = true

client_only_mod = true
all_clients_require_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"
--priority = 10

local string = ""
local keys = {"J","K","L","M","N"}
local keylist = {}
for i = 1, #keys do
    keylist[i] = {description = keys[i], data = string.upper(keys[i])}
end
keylist[#keylist + 1] = {description = "Disabled", data = false}

configuration_options =
{

	{
		name = "fish_key",
		hover = "Change hotkey of fishing",
		label = "fish key",
		options = keylist,
		default = "J",
	},

	{
		name = "gan_view",
		hover = "Allows massive zooming out",
		label = "Zoom",
		options =
	{
	  {description = "active", data = "true",hover = ""},
		{description = "disabled", data = "false",hover = ""},
	},
		default = "true",
	},

	{
		name = "gan_hunter",
		hover = "Shows warning/indicator graphics on screen particularly related to tracking dirt piles but also for many other mobs",
		label = "Informational Graphics",
		options =
	{
	  {description = "active", data = "true",hover = ""},
		{description = "disabled", data = "false",hover = ""},
	},
		default = "true",
	},
		-- {
		-- name = "early_toggle",
		-- hover = "Toggles whether to show indicator for early game stuff like moon island indicators",
		-- label = "Early game toggle",
		-- options =
	-- {
	  -- {description = "on", data = "true",hover = ""},
		-- {description = "off", data = "false",hover = ""},
	-- },
		-- default = "true",
	-- },

}