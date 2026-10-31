-- Migrated from hyprland.conf for Hyprland 0.56.
-- The original files remain available for the existing menus and scripts.
local home = os.getenv("HOME")
local root = home .. "/.config/hypr"
local paths = {
	scriptsDir = root .. "/scripts",
	UserScripts = root .. "/UserScripts",
	UserBinsDir = root .. "/UserBins",
	UserConfigs = root .. "/UserConfigs",
	term = "kitty --single-instance",
	files = "thunar",
	mainMod = "SUPER",
}
local function expand(s)
	for _ = 1, 3 do
		s = s:gsub("%$([%w_]+)", function(k)
			return paths[k] or os.getenv(k) or "$" .. k
		end)
	end
	return s
end
local function each_setting(path, cb)
	local file = io.open(path)
	if not file then
		return
	end
	for raw in file:lines() do
		local line = raw:gsub("\r$", "")
		line = line:gsub("%s+#.*$", ""):gsub("^%s+", ""):gsub("%s+$", "")
		if line ~= "" and not line:match("^#") then
			cb(line)
		end
	end
	file:close()
end
local function fields(s)
	local t = {}
	for item in s:gmatch("[^,]+") do
		t[#t + 1] = item:match("^%s*(.-)%s*$")
	end
	return t
end
local function colors()
	local result = {}
	each_setting(root .. "/wallust/wallust-hyprland.conf", function(line)
		local key, value = line:match("^%$(%w+)%s*=%s*rgb%((%x+)%)$")
		if key then
			result[key] = "rgb(" .. value .. ")"
		end
	end)
	each_setting(root .. "/wallust/custom-colors.conf", function(line)
		local key, value = line:match("^%$(%w+)%s*=%s*rgb%((%x+)%)$")
		if key then
			result[key] = "rgb(" .. value .. ")"
		end
	end)
	return result
end
local c = colors()

-- Keep the touchpad toggle used by scripts/TouchPad.sh.
local touchpad_enabled = true
local status_path = os.getenv("XDG_RUNTIME_DIR")
if status_path then
	local status = io.open(status_path .. "/touchpad.status")
	if status then
		touchpad_enabled = status:read("*a") ~= "false"
		status:close()
	end
end
hl.device({ name = "asue1209:00-04f3:319f-touchpad", enabled = touchpad_enabled })

-- Environment, including the values formerly in ENVariables.conf.
local env = {
	{ "GDK_BACKEND", "wayland,x11,*" },
	{ "QT_QPA_PLATFORM", "wayland;xcb" },
	{ "CLUTTER_BACKEND", "wayland" },
	{ "WLR_NO_HARDWARE_CURSORS", "1" },
	{ "XDG_CURRENT_DESKTOP", "Hyprland" },
	{ "XDG_SESSION_DESKTOP", "Hyprland" },
	{ "XDG_SESSION_TYPE", "wayland" },
	{ "QT_AUTO_SCREEN_SCALE_FACTOR", "1" },
	{ "QT_WAYLAND_DISABLE_WINDOWDECORATION", "1" },
	{ "QT_QPA_PLATFORMTHEME", "qt5ct" },
	{ "QT_QPA_PLATFORMTHEME", "qt6ct" },
	{ "QT_QUICK_CONTROLS_STYLE", "org.hyprland.style" },
	{ "GDK_SCALE", "1" },
	{ "QT_SCALE_FACTOR", "1" },
	{ "HYPRCURSOR_THEME", "Bibata-Modern-Ice" },
	{ "HYPRCURSOR_SIZE", "24" },
	{ "MOZ_ENABLE_WAYLAND", "1" },
	{ "ELECTRON_OZONE_PLATFORM_HINT", "auto" },
	{ "LIBVA_DRIVER_NAME", "nvidia" },
	{ "__GLX_VENDOR_LIBRARY_NAME", "nvidia" },
	{ "NVD_BACKEND", "direct" },
	{ "GBM_BACKEND", "nvidia-drm" },
	{ "WLR_DRM_NO_ATOMIC", "1" },
	{ "EDITOR", "nvim" },
}
for _, pair in ipairs(env) do
	hl.env(pair[1], pair[2])
end

-- Monitors and workspaces are still read from files written by nwg-displays
-- and the monitor profile selector, using the native Lua API.
local function monitor_file(path)
	each_setting(path, function(line)
		local spec = line:match("^monitor%s*=%s*(.*)$")
		if spec then
			local f = fields(spec)
			if f[2] == "disable" then
				hl.monitor({ output = f[1], disabled = true })
			else
				hl.monitor({ output = f[1], mode = f[2], position = f[3], scale = tonumber(f[4]) or f[4] })
			end
		end
	end)
end
monitor_file(root .. "/UserConfigs/LaptopDisplay.conf")
monitor_file(root .. "/monitors.conf")
each_setting(root .. "/workspaces.conf", function(line)
	local spec = line:match("^workspace%s*=%s*(.*)$")
	if spec then
		local f = fields(spec)
		local rule = { workspace = f[1] }
		for i = 2, #f do
			local k, v = f[i]:match("^(%w+):(.+)$")
			if k == "monitor" then
				rule.monitor = v
			end
			if k == "default" then
				rule.default = v == "true"
			end
		end
		hl.workspace_rule(rule)
	end
end)

hl.config({
	dwindle = { preserve_split = true, special_scale_factor = 0.8 },
	master = { new_status = "master", new_on_top = true, mfact = 0.5 },
	general = {
		resize_on_border = true,
		layout = "dwindle",
		border_size = 3,
		gaps_in = 1,
		gaps_out = 1,
		col = { active_border = c.color12, inactive_border = c.color10 },
	},
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		repeat_rate = 50,
		repeat_delay = 300,
		sensitivity = 0,
		accel_profile = "flat",
		numlock_by_default = true,
		left_handed = false,
		follow_mouse = 1,
		float_switch_override_focus = 0,
		touchpad = {
			disable_while_typing = true,
			natural_scroll = true,
			clickfinger_behavior = false,
			middle_button_emulation = false,
			tap_to_click = true,
			drag_lock = false,
		},
		touchdevice = { enabled = true },
		tablet = { transform = 0, left_handed = false },
	},
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		vrr = 0,
		mouse_move_enables_dpms = true,
		enable_swallow = false,
		swallow_regex = "^(kitty)$",
		focus_on_activate = false,
		initial_workspace_tracking = 0,
		middle_click_paste = false,
	},
	binds = { workspace_back_and_forth = true, allow_workspace_cycles = true, pass_mouse_when_bound = false },
	xwayland = { enabled = true, force_zero_scaling = true },
	render = { direct_scanout = 0 },
	cursor = {
		sync_gsettings_theme = true,
		no_hardware_cursors = 1,
		enable_hyprcursor = true,
		warp_on_change_workspace = 0,
		no_warps = true,
	},
	decoration = {
		rounding = 0,
		active_opacity = 1,
		inactive_opacity = 1,
		fullscreen_opacity = 1,
		dim_inactive = true,
		dim_strength = 0.1,
		dim_special = 0.8,
		shadow = { enabled = true, range = 2, render_power = 1, color = c.color12, color_inactive = c.color10 },
		blur = {
			enabled = true,
			size = 4,
			passes = 2,
			ignore_opacity = true,
			new_optimizations = true,
			special = true,
			popups = true,
		},
	},
	group = { col = { border_active = c.color15 }, groupbar = { col = { active = c.color0 } } },
	animations = { enabled = true },
})

-- Read the selected animation preset so the existing selector continues to work.
local curve_names = {}
each_setting(root .. "/UserConfigs/UserAnimations.conf", function(line)
	local value = line:match("^enabled%s*=%s*(%w+)$")
	if value then
		hl.config({ animations = { enabled = value == "1" or value == "true" or value == "yes" } })
	end
end)
each_setting(root .. "/UserConfigs/UserAnimations.conf", function(line)
	local value = line:match("^bezier%s*=%s*(.+)$")
	if value then
		local f = fields(value)
		local valid = true
		for i = 2, 5 do
			local n = tonumber(f[i])
			if not n or n < -2 or n > 2 then
				valid = false
			end
		end
		-- Legacy presets can contain curves outside Lua's accepted range.
		if valid then
			curve_names[f[1]] = true
			hl.curve(
				f[1],
				{ type = "bezier", points = { { tonumber(f[2]), tonumber(f[3]) }, { tonumber(f[4]), tonumber(f[5]) } } }
			)
		end
	end
end)
each_setting(root .. "/UserConfigs/UserAnimations.conf", function(line)
	local value = line:match("^animation%s*=%s*(.+)$")
	if value then
		local f = fields(value)
		local rule = { leaf = f[1], enabled = f[2] == "1" or f[2] == "true" or f[2] == "yes", speed = tonumber(f[3]) }
		if curve_names[f[4]] then
			rule.bezier = f[4]
		end
		if f[5] then
			rule.style = f[5]
		end
		hl.animation(rule)
	end
end)

-- Active rules from the old configuration.
hl.window_rule({ match = { title = ".*is sharing.*" }, workspace = "special:screenshare silent" })

-- The original startup list remains editable by the wallpaper chooser.
hl.on("hyprland.start", function()
	hl.exec_cmd(root .. "/initial-boot.sh")
	hl.exec_cmd("fcitx5")
	each_setting(root .. "/UserConfigs/Startup_Apps.conf", function(line)
		local key, value = line:match("^%$(%w+)%s*=%s*(.+)$")
		if key then
			paths[key] = value
		end
	end)
	each_setting(root .. "/UserConfigs/Startup_Apps.conf", function(line)
		local cmd = line:match("^exec%-once%s*=%s*(.+)$")
		if cmd then
			hl.exec_cmd(expand(cmd))
		end
	end)
end)

-- Keybindings migrated from the three active keybind files.
-- configs/Keybinds.conf
hl.bind("SUPER + T", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/Toggles.sh"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exit())
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/KillActiveProcess.sh"))
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/LockScreen.sh"))
hl.bind("CTRL + ALT + P", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/Wlogout.sh"))
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/Kool_Quick_Settings.sh"))
hl.bind("SUPER + CTRL + D", hl.dsp.layout("removemaster"))
hl.bind("SUPER + I", hl.dsp.layout("addmaster"))
hl.bind("SUPER + J", hl.dsp.window.cycle_next())
hl.bind("SUPER + K", hl.dsp.window.cycle_next({ next = false }))
hl.bind("SUPER + CTRL + Return", hl.dsp.layout("swapwithmaster"))
hl.bind("SUPER + P", hl.dsp.window.pseudo({ action = "toggle" }))
hl.bind("SUPER + M", hl.dsp.layout("splitratio 0.3"))
hl.bind("SUPER + G", hl.dsp.group.toggle({}))
hl.bind("SUPER + CTRL + tab", hl.dsp.group.next({}))
hl.bind("ALT + tab", hl.dsp.window.cycle_next({ next = true }))
hl.bind("ALT + tab", hl.dsp.window.alter_zorder({ mode = "top" }))
hl.bind(
	"xf86audioraisevolume",
	hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/Volume.sh --inc"),
	{ repeating = true, locked = true }
)
hl.bind(
	"xf86audiolowervolume",
	hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/Volume.sh --dec"),
	{ repeating = true, locked = true }
)
hl.bind(
	"xf86AudioMicMute",
	hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/Volume.sh --toggle-mic"),
	{ locked = true }
)
hl.bind("xf86audiomute", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/Volume.sh --toggle"), { locked = true })
hl.bind("xf86Sleep", hl.dsp.exec_cmd("systemctl suspend"), { locked = true })
hl.bind("xf86Rfkill", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/AirplaneMode.sh"), { locked = true })
hl.bind("code:172", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/MediaCtrl.sh --pause"), { locked = true })
hl.bind("xf86AudioPause", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/MediaCtrl.sh --pause"), { locked = true })
hl.bind("xf86AudioPlay", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/MediaCtrl.sh --pause"), { locked = true })
hl.bind("xf86AudioNext", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/MediaCtrl.sh --nxt"), { locked = true })
hl.bind("xf86AudioPrev", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/MediaCtrl.sh --prv"), { locked = true })
hl.bind("xf86audiostop", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/MediaCtrl.sh --stop"), { locked = true })
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/ScreenShot.sh"))
hl.bind("SUPER + SHIFT + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + h", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + j", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + k", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + l", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + CTRL + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + CTRL + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + CTRL + down", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + CTRL + h", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + CTRL + j", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + CTRL + k", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + CTRL + l", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + ALT + left", hl.dsp.window.swap({ direction = "left" }))
hl.bind("SUPER + ALT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind("SUPER + ALT + up", hl.dsp.window.swap({ direction = "up" }))
hl.bind("SUPER + ALT + down", hl.dsp.window.swap({ direction = "down" }))
hl.bind("SUPER + ALT + h", hl.dsp.window.swap({ direction = "left" }))
hl.bind("SUPER + ALT + j", hl.dsp.window.swap({ direction = "down" }))
hl.bind("SUPER + ALT + k", hl.dsp.window.swap({ direction = "up" }))
hl.bind("SUPER + ALT + l", hl.dsp.window.swap({ direction = "right" }))
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + h", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + tab", hl.dsp.focus({ workspace = "m+1" }))
hl.bind("SUPER + SHIFT + tab", hl.dsp.focus({ workspace = "m-1" }))
hl.bind("SUPER + SHIFT + U", hl.dsp.window.move({ workspace = "special", follow = true }))
hl.bind("SUPER + U", hl.dsp.workspace.toggle_special(""))
hl.bind("SUPER + code:10", hl.dsp.focus({ workspace = "1" }))
hl.bind("SUPER + code:11", hl.dsp.focus({ workspace = "2" }))
hl.bind("SUPER + code:12", hl.dsp.focus({ workspace = "3" }))
hl.bind("SUPER + code:13", hl.dsp.focus({ workspace = "4" }))
hl.bind("SUPER + code:14", hl.dsp.focus({ workspace = "5" }))
hl.bind("SUPER + code:15", hl.dsp.focus({ workspace = "6" }))
hl.bind("SUPER + code:16", hl.dsp.focus({ workspace = "7" }))
hl.bind("SUPER + code:17", hl.dsp.focus({ workspace = "8" }))
hl.bind("SUPER + code:18", hl.dsp.focus({ workspace = "9" }))
hl.bind("SUPER + code:19", hl.dsp.focus({ workspace = "10" }))
hl.bind("SUPER + SHIFT + code:10", hl.dsp.window.move({ workspace = "1", follow = true }))
hl.bind("SUPER + SHIFT + code:11", hl.dsp.window.move({ workspace = "2", follow = true }))
hl.bind("SUPER + SHIFT + code:12", hl.dsp.window.move({ workspace = "3", follow = true }))
hl.bind("SUPER + SHIFT + code:13", hl.dsp.window.move({ workspace = "4", follow = true }))
hl.bind("SUPER + SHIFT + code:14", hl.dsp.window.move({ workspace = "5", follow = true }))
hl.bind("SUPER + SHIFT + code:15", hl.dsp.window.move({ workspace = "6", follow = true }))
hl.bind("SUPER + SHIFT + code:16", hl.dsp.window.move({ workspace = "7", follow = true }))
hl.bind("SUPER + SHIFT + code:17", hl.dsp.window.move({ workspace = "8", follow = true }))
hl.bind("SUPER + SHIFT + code:18", hl.dsp.window.move({ workspace = "9", follow = true }))
hl.bind("SUPER + SHIFT + code:19", hl.dsp.window.move({ workspace = "10", follow = true }))
hl.bind("SUPER + SHIFT + bracketleft", hl.dsp.window.move({ workspace = "-1", follow = true }))
hl.bind("SUPER + SHIFT + bracketright", hl.dsp.window.move({ workspace = "+1", follow = true }))
hl.bind("SUPER + CTRL + code:10", hl.dsp.window.move({ workspace = "1", follow = false }))
hl.bind("SUPER + CTRL + code:11", hl.dsp.window.move({ workspace = "2", follow = false }))
hl.bind("SUPER + CTRL + code:12", hl.dsp.window.move({ workspace = "3", follow = false }))
hl.bind("SUPER + CTRL + code:13", hl.dsp.window.move({ workspace = "4", follow = false }))
hl.bind("SUPER + CTRL + code:14", hl.dsp.window.move({ workspace = "5", follow = false }))
hl.bind("SUPER + CTRL + code:15", hl.dsp.window.move({ workspace = "6", follow = false }))
hl.bind("SUPER + CTRL + code:16", hl.dsp.window.move({ workspace = "7", follow = false }))
hl.bind("SUPER + CTRL + code:17", hl.dsp.window.move({ workspace = "8", follow = false }))
hl.bind("SUPER + CTRL + code:18", hl.dsp.window.move({ workspace = "9", follow = false }))
hl.bind("SUPER + CTRL + code:19", hl.dsp.window.move({ workspace = "10", follow = false }))
hl.bind("SUPER + CTRL + bracketleft", hl.dsp.window.move({ workspace = "-1", follow = false }))
hl.bind("SUPER + CTRL + bracketright", hl.dsp.window.move({ workspace = "+1", follow = false }))
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + period", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + comma", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
-- UserConfigs/Laptops.conf
hl.bind(
	"xf86KbdBrightnessDown",
	hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/BrightnessKbd.sh --dec"),
	{ repeating = true }
)
hl.bind(
	"xf86KbdBrightnessUp",
	hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/BrightnessKbd.sh --inc"),
	{ repeating = true }
)
hl.bind("xf86Launch1", hl.dsp.exec_cmd("rog-control-center"))
hl.bind("xf86Launch3", hl.dsp.exec_cmd("asusctl led-mode -n"))
hl.bind("xf86Launch4", hl.dsp.exec_cmd("asusctl profile -n"))
hl.bind(
	"xf86MonBrightnessDown",
	hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/Brightness.sh --dec"),
	{ repeating = true }
)
hl.bind(
	"xf86MonBrightnessUp",
	hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/Brightness.sh --inc"),
	{ repeating = true }
)
hl.bind("xf86TouchpadToggle", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/TouchPad.sh"))
hl.bind("SUPER + F6", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/ScreenShot.sh --now"))
hl.bind("SUPER + SHIFT + F6", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/ScreenShot.sh --area"))
hl.bind("SUPER + CTRL + F6", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/ScreenShot.sh --in5"))
hl.bind("SUPER + ALT + F6", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/ScreenShot.sh --in10"))
hl.bind("ALT + F6", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/ScreenShot.sh --active"))
-- UserConfigs/UserKeybinds.conf
hl.bind("SUPER + D", hl.dsp.exec_cmd("pkill rofi || true && rofi -show drun -modi drun,filebrowser,run,window"))
hl.bind("SUPER + B", hl.dsp.exec_cmd('xdg-open "https://"'))
hl.bind("SUPER + Return", hl.dsp.exec_cmd(paths.term))
hl.bind("SUPER + E", hl.dsp.exec_cmd("thunar"))
hl.bind("PRINT", hl.dsp.exec_cmd("/home/walk/.config/hypr/UserScripts/ClipBuffer.sh"))
hl.bind("SUPER + ALT + CTRL + W", hl.dsp.exec_cmd("/home/walk/.config/hypr/UserBins/whatsappweb"))
hl.bind("SUPER + ALT + CTRL + A", hl.dsp.exec_cmd("/home/walk/.config/hypr/UserBins/archwiki"))
hl.bind("SUPER + ALT + G", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/KeyHints.sh"))
hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/Refresh.sh"))
hl.bind("SUPER + ALT + E", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/RofiEmoji.sh"))
hl.bind("SUPER + S", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/RofiSearch.sh"))
hl.bind("SUPER + ALT + O", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/ChangeBlur.sh"))
hl.bind("SUPER + ALT + Z", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/ChangeLayout.sh"))
hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/ClipManager.sh"))
hl.bind("SUPER + CTRL + R", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/RofiThemeSelector.sh"))
hl.bind(
	"SUPER + CTRL + SHIFT + R",
	hl.dsp.exec_cmd("pkill rofi || true && /home/walk/.config/hypr/scripts/RofiThemeSelector-modified.sh")
)
hl.bind("SUPER + CTRL + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind("SUPER + SPACE", hl.dsp.window.float({ action = "toggle" }))
local allfloat_workspaces = {}
hl.on("window.open", function(window)
	if window and window.workspace and allfloat_workspaces[window.workspace.name] then
		hl.dispatch(hl.dsp.window.float({ action = "set", window = window }))
	end
end)
hl.bind("SUPER + ALT + SPACE", function()
	local workspace = hl.get_active_workspace()
	if workspace then
		local enabled = not allfloat_workspaces[workspace.name]
		allfloat_workspaces[workspace.name] = enabled
		for _, window in ipairs(hl.get_workspace_windows(workspace.name)) do
			hl.dispatch(hl.dsp.window.float({ action = enabled and "set" or "unset", window = window }))
		end
	end
end)
local function zoom(multiplier)
	local current = hl.get_config("cursor.zoom_factor") or 1
	hl.config({ cursor = { zoom_factor = math.max(1, current * multiplier) } })
end
hl.bind("SUPER + ALT + mouse_down", function()
	zoom(2)
end)
hl.bind("SUPER + ALT + mouse_up", function()
	zoom(0.5)
end)
hl.bind("SUPER + CTRL + ALT + B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
hl.bind("SUPER + CTRL + B", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/WaybarStyles.sh"))
hl.bind("SUPER + ALT + B", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/WaybarLayout.sh"))
hl.bind("SUPER + W", hl.dsp.exec_cmd("/home/walk/.config/hypr/UserScripts/WallpaperSelect.sh"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("/home/walk/.config/hypr/UserScripts/WallpaperEffects.sh"))
hl.bind("SUPER + CTRL + O", hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }))
hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/KeyBinds.sh"))
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/Animations.sh"))
hl.bind(
	"ALT_L + SHIFT_L",
	hl.dsp.exec_cmd("/home/walk/.config/hypr/scripts/SwitchKeyboardLayout.sh"),
	{ locked = true, non_consuming = true }
)
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd("/home/walk/.config/hypr/UserScripts/RofiCalc.sh"))
