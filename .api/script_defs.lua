---@meta _

---@class TVec
---@field [0] number
---@field [1] number
---@field [2] number

---@class TQuat
---@field [0] number
---@field [1] number
---@field [2] number
---@field [3] number

---@class TTransform
---@field pos TVec
---@field rot TQuat

TSharedUserdata = {}
function TSharedUserdata.create(name) return nil end

---
--- Example:
--- ```lua
--- function init()
--- 	--Retrieve blinkcount parameter, or set to 5 if omitted
--- 	local parameterBlinkCount = GetIntParam("blinkcount", 5)
--- 	DebugPrint(parameterBlinkCount)
--- end
--- ```
---@param name string Parameter name
---@param default number Default parameter value
---@return number value Parameter value
function GetIntParam(name, default) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	--Retrieve speed parameter, or set to 10.0 if omitted
--- 	local parameterSpeed = GetFloatParam("speed", 10.0)
--- 	DebugPrint(parameterSpeed)
--- end
--- ```
---@param name string Parameter name
---@param default number Default parameter value
---@return number value Parameter value
function GetFloatParam(name, default) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	--Retrieve playsound parameter, or false if omitted
--- 	local parameterPlaySound = GetBoolParam("playsound", false)
--- 	DebugPrint(parameterPlaySound)
--- end
--- ```
---@param name string Parameter name
---@param default boolean Default parameter value
---@return boolean value Parameter value
function GetBoolParam(name, default) return false end

---
--- Example:
--- ```lua
--- function init()
--- 	--Retrieve mode parameter, or "idle" if omitted
--- 	local parameterMode = GetStringParam("mode", "idle")
--- 	DebugPrint(parameterMode)
--- end
--- ```
---@param name string Parameter name
---@param default string Default parameter value
---@return string value Parameter value
function GetStringParam(name, default) return "" end

---
--- Example:
--- ```lua
--- function init()
--- 	--Retrieve color parameter, or set to 0.39, 0.39, 0.39 if omitted
--- 	local color_r, color_g, color_b = GetColorParam("color", 0.39, 0.39, 0.39)
--- 	DebugPrint(color_r .. " " .. color_g .. " " .. color_b)
--- end
--- ```
---@param name string Parameter name
---@param default number Default parameter value
---@return number value Parameter value
function GetColorParam(name, default) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	local v = GetVersion()
--- 	--v is "0.5.0"
--- 	DebugPrint(v)
--- end
--- ```
---@return string version Dot separated string of current version of the game
function GetVersion() return "" end

---
--- Example:
--- ```lua
--- function init()
--- 	if HasVersion("1.5.0") then
--- 		--conditional code that only works on 0.6.0 or above
--- 		DebugPrint("New version")
--- 	else
--- 		--legacy code that works on earlier versions
--- 		DebugPrint("Earlier version")
--- 	end
--- end
--- ```
---@param version string Reference version
---@return boolean match True if current version is at least provided one
function HasVersion(version) return false end

--- Returns running time of this script. If called from update, this returns
--- the simulated time, otherwise it returns wall time.
---
--- Example:
--- ```lua
--- function update()
--- 	local t = GetTime()
--- 	DebugPrint(t)
--- end
--- ```
---@return number time The time in seconds since level was started
function GetTime() return 0 end

--- Returns timestep of the last frame. If called from update, this returns
--- the simulation time step, which is always one 60th of a second (0.0166667).
--- If called from tick or draw it returns the actual time since last frame.
---
--- Example:
--- ```lua
--- function tick()
--- 	local dt = GetTimeStep()
--- 	DebugPrint("tick dt: " .. dt)
--- end
--- 
--- function update()
--- 	local dt = GetTimeStep()
--- 	DebugPrint("update dt: " .. dt)
--- end
--- ```
---@return number dt The timestep in seconds
function GetTimeStep() return 0 end

---
--- Example:
--- ```lua
--- function tick()
--- 	local name = InputLastPressedKey()
--- 	if string.len(name) > 0 then
--- 		DebugPrint(name)
--- 	end
--- end
--- ```
---@return string name Name of last pressed key, empty if no key is pressed
function InputLastPressedKey() return "" end

---
--- Example:
--- ```lua
--- function tick()
--- 	if InputPressed("interact") then
--- 		DebugPrint("interact")
--- 	end
--- end
--- ```
---@param input string The input identifier
---@return boolean pressed True if input was pressed during last frame
function InputPressed(input) return false end

---
--- Example:
--- ```lua
--- function tick()
--- 	if InputReleased("interact") then
--- 		DebugPrint("interact")
--- 	end
--- end
--- ```
---@param input string The input identifier
---@return boolean pressed True if input was released during last frame
function InputReleased(input) return false end

---
--- Example:
--- ```lua
--- function tick()
--- 	if InputDown("interact") then
--- 		DebugPrint("interact")
--- 	end
--- end
--- ```
---@param input string The input identifier
---@return boolean pressed True if input is currently held down
function InputDown(input) return false end

---
--- Example:
--- ```lua
--- local scrollPos = 0
--- function tick()
--- 	scrollPos = scrollPos + InputValue("mousewheel")
--- 	DebugPrint(scrollPos)
--- end
--- ```
---@param input string The input identifier
---@return number value Depends on input type
function InputValue(input) return 0 end

function IsControllerButtonDown(...) end

--- All player input is "forgotten" by the game after calling this function
---
--- Example:
--- ```lua
--- function update()
---     -- Prints '2' because InputClear() allows the game to "forget" the player's input
--- 	if InputDown("interact") then
---         InputClear()
--- 		if InputDown("interact") then
--- 			DebugPrint(1)
--- 		else
--- 			DebugPrint(2)
--- 		end
--- 	end
--- end
--- ```
function InputClear() end

--- This function will reset everything we need to reset during state transition
---
--- Example:
--- ```lua
--- function update()
--- 	if InputDown("interact") then
---         -- In this form, you won't be able to notice the result of the function; you need a specific context
--- 		InputResetOnTransition()
--- 	end
--- end
--- ```
function InputResetOnTransition() end

--- Returns the last input device id.
--- 0 - none, 1 - mouse, 2 - gamepad
---
--- Example:
--- ```lua
--- #include "ui/ui_helpers.lua"
--- 
--- function update()
--- 	if LastInputDevice() == UI_DEVICE_GAMEPAD then
--- 		DebugPrint("Last input was from gamepad")
--- 	elseif LastInputDevice() == UI_DEVICE_MOUSE then
--- 		DebugPrint("Last input was mouse & keyboard")
--- 	elseif LastInputDevice() == UI_DEVICE_TOUCHSCREEN then
--- 		DebugPrint("Last input was touchscreen")
--- 	end
--- end
--- ```
---@return number value Last device id
function LastInputDevice() return 0 end

--- Set value of a number variable in the global context with an optional transition.
--- If a transition is provided the value will animate from current value to the new value during the transition time.
--- Transition can be one of the following:
--- BEGINTABLE Transition -- Description
--- linear	-- Linear transition
--- cosine	-- Slow at beginning and end
--- easein	-- Slow at beginning
--- easeout	-- Slow at end
--- bounce	-- Bounce and overshoot new value
--- ENDTABLE
---
--- Example:
--- ```lua
--- myValue = 0
--- function tick()
--- 	--This will change the value of myValue from 0 to 1 in a linear fasion over 0.5 seconds
--- 	SetValue("myValue", 1, "linear", 0.5)
--- 	DebugPrint(myValue)
--- end
--- ```
---@param variable string Name of number variable in the global context
---@param value number The new value
---@param transition? string Transition type. See description.
---@param time? number Transition time (seconds)
function SetValue(variable, value, transition, time) end

--- Chages the value of a table member in time according to specified args.
--- Works similar to SetValue but for global variables of trivial types
---
--- Example:
--- ```lua
--- local t = {}
--- function init()
--- 	SetValueInTable(t, "score", 1, "number", 1)
--- end
--- function update()
--- 	if InputPressed("interact") then
--- 		SetValueInTable(t, "score", t.score + 1, "number", 1)
---         DebugPrint(t.score)
--- 	end
--- end
--- ```
---@param tableId any Id of the table
---@param memberName string Name of the member
---@param newValue number New value
---@param type string Transition type
---@param length number Transition length
function SetValueInTable(tableId, memberName, newValue, type, length) end

--- Calling this function will add a button on the bottom bar or in the main pause menu (center of the screen) when the game is paused.
--- Identified by 'location' parameter, it can be below "Main menu" button (by passing "main_bottom" value)or above (by passing "main_top").
--- A primary button will be placed in the main pause menu if this function is called from a playable mod. There can be only one primary button.
--- Use this as a way to bring up mod settings or other user interfaces while the game is running.
--- Call this function every frame from the tick function for as long as the pause menu button
--- should still be visible.
--- Only one button per script is allowed. Consecutive calls replace button added in previous calls.
---
--- Example:
--- ```lua
--- function tick()
--- 
---     -- Primary button which will be placed in the main pause menu below "Main menu" button
--- 	if PauseMenuButton("Back to Hub", "main_bottom") then
--- 		StartLevel("hub", "level/hub.xml")
--- 	end
--- 
--- 	-- Primary button which will be placed in the main pause menu above "Main menu" button
--- 	if PauseMenuButton("Back to Hub", "main_top") then
--- 		StartLevel("hub", "level/hub.xml")
--- 	end
--- 
--- 	-- Button will be placed in the bottom bar of the pause menu
--- 	if PauseMenuButton("MyMod Settings") then
--- 		visible = true
--- 	end
--- end
--- 
--- function draw()
--- 	if visible then
--- 		UiMakeInteractive()
--- 	end
--- end
--- 
--- ```
---@param title string Text on button
---@param location? string Button location. If "bottom_bar" - bottom bar, if "main_bottom" - below "Main menu" button, if "main_top" - above "Main menu" button. Default "bottom_bar".
---@return boolean clicked True if clicked, false otherwise
function PauseMenuButton(title, location) return false end

--- Checks that file exists on the specified path.
--- It is preferable to use UiHasImage whenever possible - it has better performance
---
--- Example:
--- ```lua
--- local file = "gfx/circle.png"
--- 
--- function draw()
--- 	if HasFile(image) then
--- 		DebugPrint("file " .. file .. " exists")
--- 	end
--- end
--- ```
---@param path string Path to file
---@return boolean exists True if file exists
function HasFile(path) return false end

--- 	DEPRECATED_ALERT
--- Executes the command. Commands examples: <br>
--- game.quit, game.restart
---
--- Example:
--- ```lua
--- function update()
--- 	if (InputPressed("interact")) then
--- 		Command("game.quit")
--- 	end
--- end
--- ```
---@param command string Command to execute
---@param arg0? string Command argument if needed
---@param arg1? string Command argument if needed
---@param arg2? string Command argument if needed
---@param arg3? string Command argument if needed
---@param arg4? string Command argument if needed
function Command(command, arg0, arg1, arg2, arg3, arg4) end

--- Start a level
---
--- Example:
--- ```lua
--- function init()
--- 	--Start level with no active layers
--- 	StartLevel("level1", "MOD/level1.xml")
--- 
--- 	--Start level with two layers
--- 	StartLevel("level1", "MOD/level1.xml", "vehicles targets")
--- end
--- ```
---@param mission string An identifier of your choice
---@param path string Path to level XML file
---@param layers? string Active layers. Default is no layers.
---@param passThrough? boolean If set, loading screen will have no text and music will keep playing
function StartLevel(mission, path, layers, passThrough) end

function ResumeLevel(...) end

--- Set paused state of the game
---
--- Example:
--- ```lua
--- function tick()
--- 	if InputPressed("interact") then
--- 		--Pause game and bring up pause menu on HUD
--- 		SetPaused(true)
--- 	end
--- end
--- ```
---@param paused boolean True if game should be paused
function SetPaused(paused) end

--- Restart level
---
--- Example:
--- ```lua
--- function tick()
--- 	if InputPressed("interact") then
--- 		Restart()
--- 	end
--- end
--- ```
function Restart() end

--- Go to main menu
---
--- Example:
--- ```lua
--- function tick()
--- 	if InputPressed("interact") then
--- 		Menu()
--- 	end
--- end
--- ```
function Menu() end

function CompleteAchievement(...) end

function IsAchievementCompleted(...) end

function IndicateAchievementProgress(...) end

function ActivityAvailabilityChange(...) end

function ActivityStart(...) end

function ActivityEnd(...) end

function ActivityResume(...) end

function ActivityTerminate(...) end

function SetPresence(...) end

---
--- Example:
--- ```lua
--- function init()
--- 	local text = GetClipboardText()
--- end
--- ```
---@return string text Text from the clipboard
function GetClipboardText() return "" end

---
--- Example:
--- ```lua
--- function init()
--- 	SetClipboardText("text")
--- end
--- ```
---@param text string 
function SetClipboardText(text) end

--- Remove registry node, including all child nodes.
---
--- Example:
--- ```lua
--- function init()
--- 	--If the registry looks like this:
--- 	--	score
--- 	--		levels
--- 	--			level1 = 5
--- 	--			level2 = 4
--- 
--- 	ClearKey("score.levels")
--- 
--- 	--Afterwards, the registry will look like this:
--- 	--	score
--- end
--- ```
---@param key string Registry key to clear
function ClearKey(key) end

--- List all child keys of a registry node.
---
--- Example:
--- ```lua
--- --If the registry looks like this:
--- --	game
--- --		tool
--- --			steroid
--- --			rifle
--- --			...
--- 
--- function init()
--- 	local list = ListKeys("game.tool")
--- 	for i=1, #list do
--- 		DebugPrint(list[i])
--- 	end
--- end
--- 
--- --This will output:
--- --steroid
--- --rifle
--- -- ...
--- ```
---@param parent string The parent registry key
---@return any children Indexed table of strings with child keys
function ListKeys(parent) return nil end

--- Returns true if the registry contains a certain key
---
--- Example:
--- ```lua
--- function init()
--- 	DebugPrint(HasKey("score.levels"))
--- 	DebugPrint(HasKey("game.tool.rifle"))
--- end
--- ```
---@param key string Registry key
---@return boolean exists True if key exists
function HasKey(key) return false end

---
--- Example:
--- ```lua
--- function init()
--- 	SetInt("score.levels.level1", 4)
--- 	DebugPrint(GetInt("score.levels.level1"))
--- end
--- ```
---@param key string Registry key
---@param value number Desired value
function SetInt(key, value) end

---
--- Example:
--- ```lua
--- function init()
--- 	SetInt("score.levels.level1", 4)
--- 	DebugPrint(GetInt("score.levels.level1"))
--- end
--- ```
---@param key string Registry key
---@return number value Integer value of registry node or zero if not found
function GetInt(key) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	SetFloat("level.time", 22.3)
--- 	DebugPrint(GetFloat("level.time"))
--- end
--- ```
---@param key string Registry key
---@param value number Desired value
function SetFloat(key, value) end

---
--- Example:
--- ```lua
--- function init()
--- 	SetFloat("level.time", 22.3)
--- 	DebugPrint(GetFloat("level.time"))
--- end
--- ```
---@param key string Registry key
---@return number value Float value of registry node or zero if not found
function GetFloat(key) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	SetBool("level.robots.enabled", true)
--- 	DebugPrint(GetBool("level.robots.enabled"))
--- end
--- ```
---@param key string Registry key
---@param value boolean Desired value
function SetBool(key, value) end

---
--- Example:
--- ```lua
--- function init()
--- 	SetBool("level.robots.enabled", true)
--- 	DebugPrint(GetBool("level.robots.enabled"))
--- end
--- ```
---@param key string Registry key
---@return boolean value Boolean value of registry node or false if not found
function GetBool(key) return false end

---
--- Example:
--- ```lua
--- function init()
--- 	SetString("level.name", "foo")
--- 	DebugPrint(GetString("level.name"))
--- end
--- ```
---@param key string Registry key
---@param value string Desired value
function SetString(key, value) end

---
--- Example:
--- ```lua
--- function init()
--- 	SetString("level.name", "foo")
--- 	DebugPrint(GetString("level.name"))
--- end
--- ```
---@param key string Registry key
---@return string value String value of registry node or "" if not found
function GetString(key) return "" end

---
--- Example:
--- ```lua
--- local count = GetEventCount("playerdead")
--- for i=1, count do
--- 	local id, attacker = GetEvent("playerdead", i)
--- end
--- ```
---@param type string Event type
---@return number value Number of event available
function GetEventCount(type) return 0 end

---
--- Example:
--- ```lua
--- local count = GetEventCount("playerdead")
--- for i=1, count do
--- 	local id, attacker = GetEvent("playerdead", i)
--- end
--- ```
---@param type string Event type
---@param index number Event index (starting with one)
---@return any returnValues Return values depending on event type
function GetEvent(type, index) return nil end

--- Sets the color registry key value
---
--- Example:
--- ```lua
--- function init()
--- 	SetColor("game.tool.wire.color", 1.0, 0.5, 0.3)
--- end
--- ```
---@param key string Registry key
---@param r number Desired red channel value
---@param g number Desired green channel value
---@param b number Desired blue channel value
---@param a? number Desired alpha channel value
function SetColor(key, r, g, b, a) end

--- Returns the color registry key value
---
--- Example:
--- ```lua
--- function init()
--- 	SetColor("red", 1.0, 0.1, 0.1)
--- 	color = GetColor("red")
--- 	DebugPrint("RGBA: " .. color[1] .. " " .. color[2] .. " " .. color[3] .. " " .. color[4])
--- end
--- ```
---@param key string Registry key
---@return number r Desired red channel value
---@return number g Desired green channel value
---@return number b Desired blue channel value
---@return number a Desired alpha channel value
function GetColor(key) return 0, 0, 0, 0 end

--- Returns the translation for the specified key from the translation table. If the key is not found returns the default value
---
--- Example:
--- ```lua
--- function init()
--- 	DebugPrint(GetTranslatedStringByKey("TOOL_CAMERA"))
--- end
--- ```
---@param key string Translation key
---@param default? string Default value
---@return string value Translation
function GetTranslatedStringByKey(key, default) return "" end

--- Checks that translation for specified key exists
---
--- Example:
--- ```lua
--- function init()
--- 	DebugPrint(HasTranslationByKey("TOOL_CAMERA"))
--- end
--- ```
---@param key string Translation key
---@return boolean value True if translation exists
function HasTranslationByKey(key) return false end

--- Loads the language table for specified language id for further localization.
--- Possible id values are:<br>
--- BEGINTABLE Id -- Language
--- 0 -- English
--- 1 -- French
--- 2 -- Spanish
--- 3 -- Italian
--- 4 -- German
--- 5 -- Simplified Chinese
--- 6 -- Japenese
--- 7 -- Russian
--- 8 -- Polish
--- ENDTABLE
---
--- Example:
--- ```lua
--- function init()
--- 	-- loads the english localization table
--- 	LoadLanguageTable(0)
--- end
--- ```
---@param id number Language id (enum)
function LoadLanguageTable(id) end

--- Returns the user nickname with the specified id. If id is not specified, returns nickname for user with id '0'
---
--- Example:
--- ```lua
--- function init()
--- 	DebugPrint(GetUserNickname(0))
--- end
--- ```
---@param id? number User id
---@return string value User nickname
function GetUserNickname(id) return "" end

function HasInputController(...) end

--- Check that game is running on Steam
---
--- Example:
--- ```lua
--- function init()
--- 	DebugPrint(IsRunningOnSteam())
--- end
--- ```
---@return boolean value True if the game is running on Steam
function IsRunningOnSteam() return false end

--- Check that game is running on SteamDeck
---
--- Example:
--- ```lua
--- function init()
--- 	DebugPrint(IsRunningOnSteamDeck())
--- end
--- ```
---@return boolean value True if the game is running on SteamDeck
function IsRunningOnSteamDeck() return false end

--- Check that game is running on EGS
---
--- Example:
--- ```lua
--- function init()
--- 	DebugPrint(IsRunningOnEgs())
--- end
--- ```
---@return boolean value True if the game is running on EGS
function IsRunningOnEgs() return false end

--- Check that game is running on PC
---
--- Example:
--- ```lua
--- function init()
--- 	DebugPrint(IsRunningOnPC())
--- end
--- ```
---@return boolean value True if the game is running on PC
function IsRunningOnPC() return false end

--- Check that game is running on Playstation
---
--- Example:
--- ```lua
--- function init()
--- 	DebugPrint(IsRunningOnPlaystation())
--- end
--- ```
---@return boolean value True if the game is running on Playstation
function IsRunningOnPlaystation() return false end

--- Check that game is running on Playstation 5
---
--- Example:
--- ```lua
--- function init()
--- 	DebugPrint(IsRunningOnPlaystation5())
--- end
--- ```
---@return boolean value True if the game is running on Playstation 5
function IsRunningOnPlaystation5() return false end

--- Check that game is running on Xbox
---
--- Example:
--- ```lua
--- function init()
--- 	DebugPrint(IsRunningOnXbox())
--- end
--- ```
---@return boolean value True if the game is running on Xbox
function IsRunningOnXbox() return false end

--- Check that game is running on Xbox Series X
---
--- Example:
--- ```lua
--- function init()
--- 	DebugPrint(IsRunningOnXboxX())
--- end
--- ```
---@return boolean value True if the game is running on Xbox Series X
function IsRunningOnXboxX() return false end

--- Check that game is running on Xbox Series S
---
--- Example:
--- ```lua
--- function init()
--- 	DebugPrint(IsRunningOnXboxS())
--- end
--- ```
---@return boolean value True if the game is running on Xbox Series S
function IsRunningOnXboxS() return false end

--- Check that game is running on Nintendo Switch
---
--- Example:
--- ```lua
--- function init()
--- 	DebugPrint(IsRunningOnSwitch())
--- end
--- ```
---@return boolean value True if the game is running on Nintendo Switch
function IsRunningOnSwitch() return false end

--- Check that game is running on Apple (macOS or iOS)
---
--- Example:
--- ```lua
--- function init()
---     DebugPrint(IsRunningOnApple())
--- end
--- ```
---@return boolean value True if the game is running on Apple (macOS or iOS)
function IsRunningOnApple() return false end

--- Check that game is running on macOS
---
--- Example:
--- ```lua
--- function init()
---     DebugPrint(IsRunningOnMac())
--- end
--- ```
---@return boolean value True if the game is running on macOS
function IsRunningOnMac() return false end

--- Check that game is running on iOS
---
--- Example:
--- ```lua
--- function init()
---     DebugPrint(IsRunningOnIOS())
--- end
--- ```
---@return boolean value True if the game is running on iOS
function IsRunningOnIOS() return false end

--- Set the used character skin.
---
--- Example:
--- ```lua
--- function init()
---     SetPlayerCharacter("space-suit")
--- end
--- ```
---@param name string Requested character skin
function SetPlayerCharacter(name) end
--- Create new vector and optionally initializes it to the provided values.
--- A Vec is equivalent to a regular lua table with three numbers.
---
--- Example:
--- ```lua
--- function init()
--- 	--These are equivalent
--- 	local a1 = Vec()
--- 	local a2 = {0, 0, 0}
--- 	DebugPrint("a1 == a2: " .. tostring(VecStr(a1) == VecStr(a2)))
--- 
--- 	--These are equivalent
--- 	local b1 = Vec(0, 1, 0)
--- 	local b2 = {0, 1, 0}
--- 	DebugPrint("b1 == b2: " .. tostring(VecStr(b1) == VecStr(b2)))
--- end
--- ```
---@param x? number X value
---@param y? number Y value
---@param z? number Z value
---@return TVec vec New vector
function Vec(x, y, z) return Vec() end

--- Vectors should never be assigned like regular numbers. Since they are
--- implemented with lua tables assignment means two references pointing to
--- the same data. Use this function instead.
---
--- Example:
--- ```lua
--- function init()
--- 	--Do this to assign a vector
--- 	local right1 = Vec(1, 2, 3)
--- 	local right2 = VecCopy(right1)
--- 
--- 	--Never do this unless you REALLY know what you're doing
--- 	local wrong1 = Vec(1, 2, 3)
--- 	local wrong2 = wrong1
--- end
--- ```
---@param org TVec A vector
---@return TVec new Copy of org vector
function VecCopy(org) return Vec() end

--- Returns the string representation of vector
---
--- Example:
--- ```lua
--- function init()
--- 	local v = Vec(0, 10, 0)
--- 	DebugPrint(VecStr(v))
--- end
--- ```
---@param vector TVec Vector
---@return string str String representation
function VecStr(vector) return "" end

---
--- Example:
--- ```lua
--- function init()
--- 	local v = Vec(1,1,0)
--- 	local l = VecLength(v)
--- 	--l now equals 1.4142
--- 	DebugPrint(l)
--- end
--- ```
---@param vec TVec A vector
---@return number length Length (magnitude) of the vector
function VecLength(vec) return 0 end

--- If the input vector is of zero length, the function returns {0,0,1}
---
--- Example:
--- ```lua
--- function init()
--- 	local v = Vec(0,3,0)
--- 	local n = VecNormalize(v)
--- 	--n now equals {0,1,0}
--- 	DebugPrint(VecStr(n))
--- end
--- ```
---@param vec TVec A vector
---@return TVec norm A vector of length 1.0
function VecNormalize(vec) return Vec() end

---
--- Example:
--- ```lua
--- function init()
--- 	local v = Vec(1,2,3)
--- 	local n = VecScale(v, 2)
--- 	--n now equals {2,4,6}
--- 	DebugPrint(VecStr(n))
--- end
--- ```
---@param vec TVec A vector
---@param scale number A scale factor
---@return TVec norm A scaled version of input vector
function VecScale(vec, scale) return Vec() end

---
--- Example:
--- ```lua
--- function init()
--- 	local a = Vec(1,2,3)
--- 	local b = Vec(3,0,0)
--- 	local c = VecAdd(a, b)
--- 	--c now equals {4,2,3}
--- 	DebugPrint(VecStr(c))
--- end
--- ```
---@param a TVec Vector
---@param b TVec Vector
---@return TVec c New vector with sum of a and b
function VecAdd(a, b) return Vec() end

---
--- Example:
--- ```lua
--- function init()
--- 	local a = Vec(1,2,3)
--- 	local b = Vec(3,0,0)
--- 	local c = VecSub(a, b)
--- 	--c now equals {-2,2,3}
--- 	DebugPrint(VecStr(c))
--- end
--- ```
---@param a TVec Vector
---@param b TVec Vector
---@return TVec c New vector representing a-b
function VecSub(a, b) return Vec() end

---
--- Example:
--- ```lua
--- function init()
--- 	local a = Vec(1,2,3)
--- 	local b = Vec(3,1,0)
--- 	local c = VecDot(a, b)
--- 	--c now equals 5
--- 	DebugPrint(c)
--- end
--- ```
---@param a TVec Vector
---@param b TVec Vector
---@return number c Dot product of a and b
function VecDot(a, b) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	local a = Vec(1,0,0)
--- 	local b = Vec(0,1,0)
--- 	local c = VecCross(a, b)
--- 	--c now equals {0,0,1}
--- 	DebugPrint(VecStr(c))
--- end
--- ```
---@param a TVec Vector
---@param b TVec Vector
---@return TVec c Cross product of a and b (also called vector product)
function VecCross(a, b) return Vec() end

---
--- Example:
--- ```lua
--- function init()
--- 	local a = Vec(2,0,0)
--- 	local b = Vec(0,4,2)
--- 	local t = 0.5
--- 
--- 	--These two are equivalent
--- 	local c1 = VecLerp(a, b, t)
--- 	local c2 = VecAdd(VecScale(a, 1-t), VecScale(b, t))
--- 
--- 	--c1 and c2 now equals {1, 2, 1}
--- 	DebugPrint("c1" .. VecStr(c1) .. " == c2" .. VecStr(c2))
--- end
--- ```
---@param a TVec Vector
---@param b TVec Vector
---@param t number fraction (usually between 0.0 and 1.0)
---@return TVec c Linearly interpolated vector between a and b, using t
function VecLerp(a, b, t) return Vec() end

--- Create new quaternion and optionally initializes it to the provided values.
--- Do not attempt to initialize a quaternion with raw values unless you know
--- what you are doing. Use QuatEuler or QuatAxisAngle instead.
--- If no arguments are given, a unit quaternion will be created: {0, 0, 0, 1}.
--- A quaternion is equivalent to a regular lua table with four numbers.
---
--- Example:
--- ```lua
--- function init()
--- 	--These are equivalent
--- 	local a1 = Quat()
--- 	local a2 = {0, 0, 0, 1}
--- 
--- 	DebugPrint(QuatStr(a1) == QuatStr(a2))
--- end
--- ```
---@param x? number X value
---@param y? number Y value
---@param z? number Z value
---@param w? number W value
---@return TQuat quat New quaternion
function Quat(x, y, z, w) return Quat() end

--- Quaternions should never be assigned like regular numbers. Since they are
--- implemented with lua tables assignment means two references pointing to
--- the same data. Use this function instead.
---
--- Example:
--- ```lua
--- function init()
--- 	--Do this to assign a quaternion
--- 	local right1 = QuatEuler(0, 90, 0)
--- 	local right2 = QuatCopy(right1)
--- 
--- 	--Never do this unless you REALLY know what you're doing
--- 	local wrong1 = QuatEuler(0, 90, 0)
--- 	local wrong2 = wrong1
--- end
--- ```
---@param org TQuat Quaternion
---@return TQuat new Copy of org quaternion
function QuatCopy(org) return Quat() end

--- Create a quaternion representing a rotation around a specific axis
---
--- Example:
--- ```lua
--- function init()
--- 	--Create quaternion representing rotation 30 degrees around Y axis
--- 	local q = QuatAxisAngle(Vec(0,1,0), 30)
--- 	DebugPrint(QuatStr(q))
--- end
--- ```
---@param axis TVec Rotation axis, unit vector
---@param angle number Rotation angle in degrees
---@return TQuat quat New quaternion
function QuatAxisAngle(axis, angle) return Quat() end

--- Create a quaternion representing a rotation between the input normals
---
--- Example:
--- ```lua
--- function init()
--- 	--Create quaternion representing a rotation between x-axis and y-axis
--- 	local q = QuatDeltaNormals(Vec(1,0,0), Vec(0,1,0))
--- end
--- ```
---@param normal0 TVec Unit vector
---@param normal1 TVec Unit vector
---@return TQuat quat New quaternion
function QuatDeltaNormals(normal0, normal1) return Quat() end

--- Create a quaternion representing a rotation between the input vectors that doesn't need to be of unit-length
---
--- Example:
--- ```lua
--- function init()
--- 	--Create quaternion representing a rotation between two non-unit vectors aligned along x-axis and y-axis
--- 	local q = QuatDeltaVectors(Vec(10,0,0), Vec(0,5,0))
--- end
--- ```
---@param vector0 TVec Vector
---@param vector1 TVec Vector
---@return TQuat quat New quaternion
function QuatDeltaVectors(vector0, vector1) return Quat() end

--- Create quaternion using euler angle notation. The order of applied rotations uses the
--- "NASA standard aeroplane" model:
--- <ol>
--- <li>Rotation around Y axis (yaw or heading)</li>
--- <li>Rotation around Z axis (pitch or attitude)</li>
--- <li>Rotation around X axis (roll or bank)</li>
--- </ol>
---
--- Example:
--- ```lua
--- function init()
--- 	--Create quaternion representing rotation 30 degrees around Y axis and 25 degrees around Z axis
--- 	local q = QuatEuler(0, 30, 25)
--- end
--- ```
---@param x number Angle around X axis in degrees, sometimes also called roll or bank
---@param y number Angle around Y axis in degrees, sometimes also called yaw or heading
---@param z number Angle around Z axis in degrees, sometimes also called pitch or attitude
---@return TQuat quat New quaternion
function QuatEuler(x, y, z) return Quat() end

--- Return the quaternion aligned to specified axes
---
--- Example:
--- ```lua
--- function update()
--- 	local laserSprite = LoadSprite("gfx/laser.png")
--- 	local origin = Vec(0, 0, 0)
--- 	local dir = Vec(1, 0, 0)
--- 	local length = 10
--- 	local hitPoint = VecAdd(origin, VecScale(dir, length))
--- 	local t = Transform(VecLerp(origin, hitPoint, 0.5))
--- 	local xAxis = VecNormalize(VecSub(hitPoint, origin))
--- 	local zAxis = VecNormalize(VecSub(origin, GetCameraTransform().pos))
--- 	t.rot = QuatAlignXZ(xAxis, zAxis)
--- 	DrawSprite(laserSprite, t, length, 0.05+math.random()*0.01, 8, 4, 4, 1, true, true)
--- 	DrawSprite(laserSprite, t, length, 0.5, 1.0, 0.3, 0.3, 1, true, true)
--- end
--- ```
---@param xAxis TVec X axis
---@param zAxis TVec Z axis
---@return TQuat quat Quaternion
function QuatAlignXZ(xAxis, zAxis) return Quat() end

--- Return euler angles from quaternion. The order of rotations uses the "NASA standard aeroplane" model:
--- <ol>
--- <li>Rotation around Y axis (yaw or heading)</li>
--- <li>Rotation around Z axis (pitch or attitude)</li>
--- <li>Rotation around X axis (roll or bank)</li>
--- </ol>
---
--- Example:
--- ```lua
--- function init()
--- 	--Return euler angles from quaternion q
--- 	q = QuatEuler(30, 45, 0)
--- 	rx, ry, rz = GetQuatEuler(q)
--- 	DebugPrint(rx .. " " .. ry .. " " .. rz)
--- end
--- ```
---@param quat TQuat Quaternion
---@return number x Angle around X axis in degrees, sometimes also called roll or bank
---@return number y Angle around Y axis in degrees, sometimes also called yaw or heading
---@return number z Angle around Z axis in degrees, sometimes also called pitch or attitude
function GetQuatEuler(quat) return 0, 0, 0 end

--- Create a quaternion pointing the negative Z axis (forward) towards
--- a specific point, keeping the Y axis upwards. This is very useful
--- for creating camera transforms.
---
--- Example:
--- ```lua
--- function init()
--- 	local eye = Vec(0, 10, 0)
--- 	local target = Vec(0, 1, 5)
--- 	local rot = QuatLookAt(eye, target)
--- 	SetCameraTransform(Transform(eye, rot))
--- end
--- ```
---@param eye TVec Vector representing the camera location
---@param target TVec Vector representing the point to look at
---@return TQuat quat New quaternion
function QuatLookAt(eye, target) return Quat() end

--- Spherical, linear interpolation between a and b, using t. This is
--- very useful for animating between two rotations.
---
--- Example:
--- ```lua
--- function init()
--- 	local a = QuatEuler(0, 10, 0)
--- 	local b = QuatEuler(0, 0, 45)
--- 
--- 	--Create quaternion half way between a and b
--- 	local q = QuatSlerp(a, b, 0.5)
--- 	DebugPrint(QuatStr(q))
--- end
--- ```
---@param a TQuat Quaternion
---@param b TQuat Quaternion
---@param t number fraction (usually between 0.0 and 1.0)
---@return TQuat c New quaternion
function QuatSlerp(a, b, t) return Quat() end

--- Returns the string representation of quaternion
---
--- Example:
--- ```lua
--- function init()
--- 	local q = QuatEuler(0, 10, 0)
--- 	DebugPrint(QuatStr(q))
--- end
--- ```
---@param quat TQuat Quaternion
---@return string str String representation
function QuatStr(quat) return "" end

--- Rotate one quaternion with another quaternion. This is mathematically
--- equivalent to c = a * b using quaternion multiplication.
---
--- Example:
--- ```lua
--- function init()
--- 	local a = QuatEuler(0, 10, 0)
--- 	local b = QuatEuler(0, 0, 45)
--- 	local q = QuatRotateQuat(a, b)
--- 
--- 	--q now represents a rotation first 10 degrees around
--- 	--the Y axis and then 45 degrees around the Z axis.
--- 	local x, y, z = GetQuatEuler(q)
--- 	DebugPrint(x .. " " .. y .. " " .. z)
--- end
--- 
--- ```
---@param a TQuat Quaternion
---@param b TQuat Quaternion
---@return TQuat c New quaternion
function QuatRotateQuat(a, b) return Quat() end

--- Rotate a vector by a quaternion
---
--- Example:
--- ```lua
--- function init()
--- 	local q = QuatEuler(0, 10, 0)
--- 	local v = Vec(1, 0, 0)
--- 	local r = QuatRotateVec(q, v)
--- 
--- 	--r is now vector a rotated 10 degrees around the Y axis
--- 	DebugPrint(VecStr(r))
--- end
--- ```
---@param a TQuat Quaternion
---@param vec TVec Vector
---@return TVec vec Rotated vector
function QuatRotateVec(a, vec) return Vec() end

--- A transform is a regular lua table with two entries: pos and rot,
--- a vector and quaternion representing transform position and rotation.
---
--- Example:
--- ```lua
--- function init()
--- 	--Create transform located at {0, 0, 0} with no rotation
--- 	local t1 = Transform()
--- 
--- 	--Create transform located at {10, 0, 0} with no rotation
--- 	local t2 = Transform(Vec(10, 0,0))
--- 
--- 	--Create transform located at {10, 0, 0}, rotated 45 degrees around Y axis
--- 	local t3 = Transform(Vec(10, 0,0), QuatEuler(0, 45, 0))
--- 
--- 	DebugPrint(TransformStr(t1))
--- 	DebugPrint(TransformStr(t2))
--- 	DebugPrint(TransformStr(t3))
--- end
--- ```
---@param pos? TVec Vector representing transform position
---@param rot? TQuat Quaternion representing transform rotation
---@return TTransform transform New transform
function Transform(pos, rot) return Transform() end

--- Transforms should never be assigned like regular numbers. Since they are
--- implemented with lua tables assignment means two references pointing to
--- the same data. Use this function instead.
---
--- Example:
--- ```lua
--- function init()
--- 	--Do this to assign a quaternion
--- 	local right1 = Transform(Vec(1,0,0), QuatEuler(0, 90, 0))
--- 	local right2 = TransformCopy(right1)
--- 
--- 	--Never do this unless you REALLY know what you're doing
--- 	local wrong1 = Transform(Vec(1,0,0), QuatEuler(0, 90, 0))
--- 	local wrong2 = wrong1
--- end
--- ```
---@param org TTransform Transform
---@return TTransform new Copy of org transform
function TransformCopy(org) return Transform() end

--- Returns the string representation of transform
---
--- Example:
--- ```lua
--- function init()
--- 	local eye = Vec(0, 10, 0)
--- 	local target = Vec(0, 1, 5)
--- 	local rot = QuatLookAt(eye, target)
--- 	local t = Transform(eye, rot)
--- 	DebugPrint(TransformStr(t))
--- end
--- ```
---@param transform TTransform Transform
---@return string str String representation
function TransformStr(transform) return "" end

--- Transform child transform out of the parent transform.
--- This is the opposite of TransformToLocalTransform.
---
--- Example:
--- ```lua
--- function init()
--- 	local b = GetBodyTransform(body)
--- 	local s = GetShapeLocalTransform(shape)
--- 
--- 	--b represents the location of body in world space
--- 	--s represents the location of shape in body space
--- 
--- 	local w = TransformToParentTransform(b, s)
--- 
--- 	--w now represents the location of shape in world space
--- 	DebugPrint(TransformStr(w))
--- end
--- ```
---@param parent TTransform Transform
---@param child TTransform Transform
---@return TTransform transform New transform
function TransformToParentTransform(parent, child) return Transform() end

--- Transform one transform into the local space of another transform.
--- This is the opposite of TransformToParentTransform.
---
--- Example:
--- ```lua
--- function init()
--- 	local b = GetBodyTransform(body)
--- 	local w = GetShapeWorldTransform(shape)
--- 
--- 	--b represents the location of body in world space
--- 	--w represents the location of shape in world space
--- 
--- 	local s = TransformToLocalTransform(b, w)
--- 
--- 	--s now represents the location of shape in body space.
--- 	DebugPrint(TransformStr(s))
--- end
--- ```
---@param parent TTransform Transform
---@param child TTransform Transform
---@return TTransform transform New transform
function TransformToLocalTransform(parent, child) return Transform() end

--- Transfom vector v out of transform t only considering rotation.
---
--- Example:
--- ```lua
--- function init()
--- 	local t = GetBodyTransform(body)
--- 	local localUp = Vec(0, 1, 0)
--- 	local up = TransformToParentVec(t, localUp)
--- 
--- 	--up now represents the local body up direction in world space
--- 	DebugPrint(VecStr(up))
--- end
--- ```
---@param t TTransform Transform
---@param v TVec Vector
---@return TVec r Transformed vector
function TransformToParentVec(t, v) return Vec() end

--- Transfom vector v into transform t only considering rotation.
---
--- Example:
--- ```lua
--- function init()
--- 	local t = GetBodyTransform(body)
--- 	local localUp = Vec(0, 1, 0)
--- 	local up = TransformToParentVec(t, localUp)
--- 
--- 	--up now represents the local body up direction in world space
--- 	DebugPrint(VecStr(up))
--- end
--- ```
---@param t TTransform Transform
---@param v TVec Vector
---@return TVec r Transformed vector
function TransformToLocalVec(t, v) return Vec() end

--- Transfom position p out of transform t.
---
--- Example:
--- ```lua
--- function init()
--- 	local t = GetBodyTransform(body)
--- 	local bodyPoint = Vec(0, 0, -1)
--- 	local p = TransformToParentPoint(t, bodyPoint)
--- 
--- 	--p now represents the local body point {0, 0, -1 } in world space
--- 	DebugPrint(VecStr(p))
--- end
--- ```
---@param t TTransform Transform
---@param p TVec Vector representing position
---@return TVec r Transformed position
function TransformToParentPoint(t, p) return Vec() end

--- Transfom position p into transform t.
---
--- Example:
--- ```lua
--- function init()
--- 	local t = GetBodyTransform(body)
--- 	local worldOrigo = Vec(0, 0, 0)
--- 	local p = TransformToLocalPoint(t, worldOrigo)
--- 
--- 	--p now represents the position of world origo in local body space
--- 	DebugPrint(VecStr(p))
--- end
--- ```
---@param t TTransform Transform
---@param p TVec Vector representing position
---@return TVec r Transformed position
function TransformToLocalPoint(t, p) return Vec() end
--- Returns an entity with the specified tag and type. This is a universal method that is an alternative to FindBody, FindShape, FindVehicle, etc.
---
--- Example:
--- ```lua
--- function tick()
--- 	--You may use this function in a similar way to other "Find functions" like FindBody, FindShape, FindVehicle, etc.
--- 	local myCar = FindEntity("myCar", false, "vehicle")
--- 
--- 	--If you do not specify the tag, the first element found will be returned
--- 	local joint = FindEntity("", true, "joint")
--- 
--- 	--If the type is not specified, the search will be performed for all types of entity
--- 	local target = FindEntity("target", true)
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@param type? string Entity type ("body", "shape", "light", "location" etc.)
---@return number handle Handle to first entity with specified tag or zero if not found
function FindEntity(tag, global, type) return 0 end

--- Returns a list of entities with the specified tag and type. This is a universal method that is an alternative to FindBody, FindShape, FindVehicle, etc.
---
--- Example:
--- ```lua
--- function tick()
--- 	-- You may use this function in a similar way to other "Find functions" like FindBody, FindShape, FindVehicle, etc.
--- 	local cars = FindEntities("car", false, "vehicle")
--- 
--- 	-- You can get all the entities of the specified type by passing an empty string to the tag
--- 	local allJoints = FindEntities("", true, "joint")
--- 
--- 	-- If the type is not specified, the search will be performed for all types
--- 	local allUnbreakables = FindEntities("unbreakable", true)
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@param type? string Entity type ("body", "shape", "light", "location" etc.)
---@return any list Indexed table with handles to all entities with specified tag
function FindEntities(tag, global, type) return nil end

--- Returns child entities
---
--- Example:
--- ```lua
--- function tick()
--- 	local car = FindEntity("car", true, "vehicle")
--- 	DebugWatch("car", car)
--- 
--- 	local children = GetEntityChildren(entity, "", true, "wheel")
--- 	for i = 1, #children do
--- 		DebugWatch("wheel " .. tostring(i), children[i])
--- 	end
--- end
--- ```
---@param handle number Entity handle
---@param tag? string Tag name
---@param recursive? boolean Search recursively
---@param type? string Entity type ("body", "shape", "light", "location" etc.)
---@return any list Indexed table with child elements of the entity
function GetEntityChildren(handle, tag, recursive, type) return nil end

---
--- Example:
--- ```lua
--- function tick()
--- 	local wheel = FindEntity("", true, "wheel")
--- 	local vehicle = GetEntityParent(wheel,  "", "vehicle")
--- 	DebugWatch("Wheel vehicle", GetEntityType(vehicle) .. " " .. tostring(vehicle))
--- end
--- ```
---@param handle number Entity handle
---@param tag? string Tag name
---@param type? string Entity type ("body", "shape", "light", "location" etc.)
---@return number handle 
function GetEntityParent(handle, tag, type) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	local handle = FindBody("body", true)
--- 	--Add "special" tag to an entity
--- 	SetTag(handle, "special")
--- 	DebugPrint(HasTag(handle, "special"))
--- 
--- 	--Add "team" tag to an entity and give it value "red"
--- 	SetTag(handle, "team", "red")
--- 	DebugPrint(HasTag(handle, "team"))
--- end
--- ```
---@param handle number Entity handle
---@param tag string Tag name
---@param value? string Tag value
function SetTag(handle, tag, value) end

--- Remove tag from an entity. If the tag had a value it is removed too.
---
--- Example:
--- ```lua
--- function init()
--- 	local handle = FindBody("body", true)
--- 	--Add "special" tag to an entity
--- 	SetTag(handle, "special")
--- 	RemoveTag(handle, "special")
--- 	DebugPrint(HasTag(handle, "special"))
--- 
--- 	--Add "team" tag to an entity and give it value "red"
--- 	SetTag(handle, "team", "red")
--- 	DebugPrint(HasTag(handle, "team"))
--- end
--- ```
---@param handle number Entity handle
---@param tag string Tag name
function RemoveTag(handle, tag) end

---
--- Example:
--- ```lua
--- function init()
--- 	local handle = FindBody("body", true)
--- 	--Add "special" tag to an entity
--- 	SetTag(handle, "special")
--- 	DebugPrint(HasTag(handle, "special"))
--- 
--- 	--Add "team" tag to an entity and give it value "red"
--- 	SetTag(handle, "team", "red")
--- 	DebugPrint(HasTag(handle, "team"))
--- end
--- ```
---@param handle number Entity handle
---@param tag string Tag name
---@return boolean exists Returns true if entity has tag
function HasTag(handle, tag) return false end

---
--- Example:
--- ```lua
--- function init()
--- 	local handle = FindBody("body", true)
--- 
--- 	--Add "team" tag to an entity and give it value "red"
--- 	SetTag(handle, "team", "red")
--- 	DebugPrint(GetTagValue(handle, "team"))
--- end
--- ```
---@param handle number Entity handle
---@param tag string Tag name
---@return string value Returns the tag value, if any. Empty string otherwise.
function GetTagValue(handle, tag) return "" end

---
--- Example:
--- ```lua
--- function init()
--- 	local handle = FindBody("body", true)
--- 
--- 	--Add "team" tag to an entity and give it value "red"
--- 	SetTag(handle, "team", "red")
--- 
--- 	--List all tags and their tag values for a particular entity
--- 	local tags = ListTags(handle)
--- 	for i=1, #tags do
--- 		DebugPrint(tags[i] .. " " .. GetTagValue(handle, tags[i]))
--- 	end
--- end
--- ```
---@param handle number Entity handle
---@return any tags Indexed table of tags on entity
function ListTags(handle) return nil end

--- All entities can have an associated description. For bodies and
--- shapes this can be provided through the editor. This function
--- retrieves that description.
---
--- Example:
--- ```lua
--- function init()
--- 	local body = FindBody("body", true)
--- 	DebugPrint(GetDescription(body))
--- end
--- ```
---@param handle number Entity handle
---@return string description The description string
function GetDescription(handle) return "" end

--- All entities can have an associated description. The description for
--- bodies and shapes will show up on the HUD when looking at them.
---
--- Example:
--- ```lua
--- function init()
--- 	local body = FindBody("body", true)
--- 	SetDescription(body, "Target object")
--- 	DebugPrint(GetDescription(body))
--- end
--- ```
---@param handle number Entity handle
---@param description string The description string
function SetDescription(handle, description) end

--- Remove an entity from the scene. All entities owned by this entity
--- will also be removed.
---
--- Example:
--- ```lua
--- function init()
--- 	local body = FindBody("body", true)
--- 	--All shapes associated with body will also be removed
--- 	Delete(body)
--- end
--- ```
---@param handle number Entity handle
function Delete(handle) end

---
--- Example:
--- ```lua
--- function init()
--- 	local body = FindBody("body", true)
--- 
--- 	--valid is true if body still exists
--- 	DebugPrint(IsHandleValid(body))
--- 	Delete(body)
--- 
--- 	--valid will now be false
--- 	DebugPrint(IsHandleValid(body))
--- end
--- ```
---@param handle number Entity handle
---@return boolean exists Returns true if the entity pointed to by handle still exists
function IsHandleValid(handle) return false end

--- Returns the type name of provided entity, for example "body", "shape", "light", etc.
---
--- Example:
--- ```lua
--- function init()
--- 	local body = FindBody("body", true)
--- 	DebugPrint(GetEntityType(body))
--- end
--- ```
---@param handle number Entity handle
---@return string type Type name of the provided entity
function GetEntityType(handle) return "" end

--- BEGINTABLE Entity type -- Available params
--- Body		-- desc (string), dynamic (boolean), mass (number), transform, velocity (vector(x, y, z)), angVelocity (vector(x, y, z)), active (boolean), friction (number), restitution (number), frictionMode (average|minimum|multiply|maximum), restitutionMode (average|minimum|multiply|maximum)
--- Shape		-- density (number), strength (number), size (number), emissiveScale (number), localTransform, worldTransform
--- Light		-- enabled (boolean), color (vector(r, g, b)), intensity (number), transform, active (boolean), type (string), size (number), reach (number), unshadowed (number), fogscale (number), fogiter (number), glare (number)
--- Location	-- transform
--- Water		-- depth (number), wave (number), ripple (number), motion (number), foam (number), color (vector(r, g, b))
--- Joint		-- type (string), size (number), rotstrength (number), rotspring (number);  only for ropes: slack (number), strength (number), maxstretch (number), ropecolor (vector(r, g, b))
--- Vehicle		-- spring (number), damping (number), topspeed (number), acceleration (number), strength (number), antispin (number), antiroll (number), difflock (number), steerassist (number), friction (number), smokeintensity (number), transform, brokenthreshold (number)
--- Wheel		-- drive (number), steer (number), travel (vector(x, y))
--- Screen		-- enabled (boolean), bulge (number), resolution (number, number), script (string), interactive (boolean), emissive (number), fxraster (number), fxca (number), fxnoise (number), fxglitch (number), size (vector(x, y))
--- Trigger		-- transform, type (string), size (vector(x, y, z)/number)
--- ENDTABLE
---
--- Example:
--- ```lua
--- function tick()
--- 	local body = FindBody("testbody", true)
--- 	local isDynamic = GetProperty(body, "dynamic")
--- 	DebugWatch("isDynamic", isDynamic)
--- end
--- ```
---@param handle number Entity handle
---@param property string Property name
---@return any value Property value
function GetProperty(handle, property) return nil end

--- BEGINTABLE Entity type -- Available params
--- Body		-- desc (string), dynamic (boolean), transform, velocity (vector(x, y, z)), angVelocity (vector(x,y,z)), active (boolean), friction (number), restitution (number), frictionMode (average|minimum|multiply|maximum), restitutionMode (average|minimum|multiply|maximum)
--- Shape		-- density (number), strength (number), emissiveScale (number), localTransform
--- Light		-- enabled (boolean), color (vector(r, g, b)), intensity (number), transform, size (number/vector(x,y)), reach (number), unshadowed (number), fogscale (number), fogiter (number), glare (number)
--- Location	-- transform
--- Water		-- type (string), depth (number), wave (number), ripple (number), motion (number), foam (number), color (vector(r, g, b))
--- Joint		-- size (number), rotstrength (number), rotspring (number);  only for ropes: slack (number), strength (number), maxstretch (number), ropecolor (vector(r, g, b))
--- Vehicle		-- spring (number), damping (number), topspeed (number), acceleration (number), strength (number), antispin (number), antiroll (number), difflock (number), steerassist (number), friction (number), smokeintensity (number), transform, brokenthreshold (number)
--- Wheel		-- drive (number), steer (number), travel (vector(x, y))
--- Screen		-- enabled (boolean), interactive (boolean), emissive (number), fxraster (number), fxca (number), fxnoise (number), fxglitch (number)
--- Trigger		-- transform, size (vector(x, y, z)/number)
--- ENDTABLE
---
--- Example:
--- ```lua
--- function tick()
--- 	local light = FindLight("mylight", true)
--- 	SetProperty(light, "intensity", math.abs(math.sin(GetTime())))
--- end
--- ```
---@param handle number Entity handle
---@param property string Property name
---@param value any Property value
function SetProperty(handle, property, value) end

---
--- Example:
--- ```lua
--- function init()
--- 	--Search for a body tagged "target" in script scope
--- 	local target = FindBody("body")
--- 	DebugPrint(target)
--- 
--- 	--Search for a body tagged "escape" in entire scene
--- 	local escape = FindBody("body", true)
--- 	DebugPrint(escape)
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return number handle Handle to first body with specified tag or zero if not found
function FindBody(tag, global) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	--Search for bodies tagged "target" in script scope
--- 	local targets = FindBodies("target", true)
--- 	for i=1, #targets do
--- 		local target = targets[i]
--- 		DebugPrint(target)
--- 	end
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return any list Indexed table with handles to all bodies with specified tag
function FindBodies(tag, global) return nil end

---
--- Example:
--- ```lua
--- function init()
--- 	local handle = FindBody("target", true)
--- 	local t = GetBodyTransform(handle)
--- 	DebugPrint(TransformStr(t))
--- end
--- ```
---@param handle number Body handle
---@return TTransform transform Transform of the body
function GetBodyTransform(handle) return Transform() end

---
--- Example:
--- ```lua
--- function init()
--- 	local handle = FindBody("body", true)
--- 
--- 	--Move a body 1 meter upwards
--- 	local t = GetBodyTransform(handle)
--- 	t.pos = VecAdd(t.pos, Vec(0, 3, 0))
--- 	SetBodyTransform(handle, t)
--- end
--- ```
---@param handle number Body handle
---@param transform TTransform Desired transform
function SetBodyTransform(handle, transform) end

---
--- Example:
--- ```lua
--- function init()
--- 	local handle = FindBody("body", true)
--- 
--- 	--Move a body 1 meter upwards
--- 	local mass = GetBodyMass(handle)
--- 	DebugPrint(mass)
--- end
--- ```
---@param handle number Body handle
---@return number mass Body mass. Static bodies always return zero mass.
function GetBodyMass(handle) return 0 end

--- Check if body is dynamic. Note that something that was created static
--- may become dynamic due to destruction.
---
--- Example:
--- ```lua
--- function init()
--- 	local handle = FindBody("body", true)
--- 	DebugPrint(IsBodyDynamic(handle))
--- end
--- ```
---@param handle number Body handle
---@return boolean dynamic Return true if body is dynamic
function IsBodyDynamic(handle) return false end

--- Change the dynamic state of a body. There is very limited use for this
--- function. In most situations you should leave it up to the engine to decide.
--- Use with caution.
---
--- Example:
--- ```lua
--- function init()
--- 	local handle = FindBody("body", true)
--- 	SetBodyDynamic(handle, false)
--- 	DebugPrint(IsBodyDynamic(handle))
--- end
--- ```
---@param handle number Body handle
---@param dynamic boolean True for dynamic. False for static.
function SetBodyDynamic(handle, dynamic) end

--- This can be used for animating bodies with preserved physical interaction,
--- but in most cases you are better off with a motorized joint instead.
---
--- Example:
--- ```lua
--- function init()
--- 	local handle = FindBody("body", true)
--- 	local vel = Vec(0,10,0)
--- 	SetBodyVelocity(handle, vel)
--- end
--- ```
---@param handle number Body handle (should be a dynamic body)
---@param velocity TVec Vector with linear velocity
function SetBodyVelocity(handle, velocity) end

---
--- Example:
--- ```lua
--- function init()
--- 	handle = FindBody("body", true)
--- 	local vel = Vec(0,10,0)
--- 	SetBodyVelocity(handle, vel)
--- end
--- 
--- function tick()
--- 	DebugPrint(VecStr(GetBodyVelocity(handle)))
--- end
--- ```
---@param handle number Body handle (should be a dynamic body)
---@return TVec velocity Linear velocity as vector
function GetBodyVelocity(handle) return Vec() end

--- Return the velocity on a body taking both linear and angular velocity into account.
---
--- Example:
--- ```lua
--- function init()
--- 	handle = FindBody("body", true)
--- 	local vel = Vec(0,10,0)
--- 	SetBodyVelocity(handle, vel)
--- end
--- 
--- function tick()
--- 	DebugPrint(VecStr(GetBodyVelocityAtPos(handle, Vec(0, 0, 0))))
--- end
--- ```
---@param handle number Body handle (should be a dynamic body)
---@param pos TVec World space point as vector
---@return TVec velocity Linear velocity on body at pos as vector
function GetBodyVelocityAtPos(handle, pos) return Vec() end

--- This can be used for animating bodies with preserved physical interaction,
--- but in most cases you are better off with a motorized joint instead.
---
--- Example:
--- ```lua
--- function init()
--- 	handle = FindBody("body", true)
--- 	local angVel = Vec(0,100,0)
--- 	SetBodyAngularVelocity(handle, angVel)
--- end
--- ```
---@param handle number Body handle (should be a dynamic body)
---@param angVel TVec Vector with angular velocity
function SetBodyAngularVelocity(handle, angVel) end

---
--- Example:
--- ```lua
--- function init()
--- 	handle = FindBody("body", true)
--- 	local angVel = Vec(0,100,0)
--- 	SetBodyAngularVelocity(handle, angVel)
--- end
--- 
--- function tick()
--- 	DebugPrint(VecStr(GetBodyAngularVelocity(handle)))
--- end
--- ```
---@param handle number Body handle (should be a dynamic body)
---@return TVec angVel Angular velocity as vector
function GetBodyAngularVelocity(handle) return Vec() end

--- Check if body is body is currently simulated. For performance reasons,
--- bodies that don't move are taken out of the simulation. This function
--- can be used to query the active state of a specific body. Only dynamic
--- bodies can be active.
---
--- Example:
--- ```lua
--- -- try to break the body to see the logs
--- function tick()
--- 	handle = FindBody("body", true)
--- 	if IsBodyActive(handle) then
--- 		DebugPrint("Body is active")
--- 	end
--- end
--- ```
---@param handle number Body handle
---@return boolean active Return true if body is active
function IsBodyActive(handle) return false end

function IsBodyHitted(...) end

function GetBodyHitsCount(...) end

function GetBodyHit(...) end

--- This function makes it possible to manually activate and deactivate bodies to include or
--- exclude in simulation. The engine normally handles this automatically, so use with care.
---
--- Example:
--- ```lua
--- function tick()
--- 	handle = FindBody("body", true)
--- 
--- 	-- Forces body to "sleep"
--- 	SetBodyActive(handle, false)
--- 	if IsBodyActive(handle) then
--- 		DebugPrint("Body is active")
--- 	end
--- end
--- ```
---@param handle number Body handle
---@param active boolean Set to tru if body should be active (simulated)
function SetBodyActive(handle, active) end

--- Apply impulse to dynamic body at position (give body a push).
---
--- Example:
--- ```lua
--- function tick()
--- 	handle = FindBody("body", true)
--- 
--- 	local pos = Vec(0,1,0)
--- 	local imp = Vec(0,0,10)
--- 	ApplyBodyImpulse(handle, pos, imp)
--- end
--- ```
---@param handle number Body handle (should be a dynamic body)
---@param position TVec World space position as vector
---@param impulse TVec World space impulse as vector
function ApplyBodyImpulse(handle, position, impulse) end

--- Return handles to all shapes owned by a body
---
--- Example:
--- ```lua
--- function init()
--- 	handle = FindBody("body", true)
--- 
--- 	local shapes = GetBodyShapes(handle)
--- 	for i=1,#shapes do
--- 		local shape = shapes[i]
--- 		DebugPrint(shape)
--- 	end
--- end
--- ```
---@param handle number Body handle
---@return any list Indexed table of shape handles
function GetBodyShapes(handle) return nil end

---
--- Example:
--- ```lua
--- function init()
--- 	handle = FindBody("body", true)
--- 
--- 	local vehicle = GetBodyVehicle(handle)
--- 	DebugPrint(vehicle)
--- end
--- ```
---@param body number Body handle
---@return number handle Get parent vehicle for body, or zero if not part of vehicle
function GetBodyVehicle(body) return 0 end

--- Return the world space, axis-aligned bounding box for a body.
---
--- Example:
--- ```lua
--- function init()
--- 	handle = FindBody("body", true)
--- 
--- 	local min, max = GetBodyBounds(handle)
--- 	local boundsSize = VecSub(max, min)
--- 	local center = VecLerp(min, max, 0.5)
--- 	DebugPrint(VecStr(boundsSize) .. " " .. VecStr(center))
--- end
--- ```
---@param handle number Body handle
---@return TVec min Vector representing the AABB lower bound
---@return TVec max Vector representing the AABB upper bound
function GetBodyBounds(handle) return Vec(), Vec() end

---
--- Example:
--- ```lua
--- function init()
--- 	handle = FindBody("body", true)
--- end
--- 
--- function tick()
--- 	--Visualize center of mass on for body
--- 	local com = GetBodyCenterOfMass(handle)
--- 	local worldPoint = TransformToParentPoint(GetBodyTransform(handle), com)
--- 	DebugCross(worldPoint)
--- end
--- ```
---@param handle number Body handle
---@return TVec point Vector representing local center of mass in body space
function GetBodyCenterOfMass(handle) return Vec() end

--- This function does a very rudimetary check and will only return true if the
--- object is visible within 74 degrees of the camera's forward direction, and
--- only tests line-of-sight visibility for the corners and center of the bounding box.
---
--- Example:
--- ```lua
--- local handle = 0
--- function init()
--- 	handle = FindBody("body", true)
--- end
--- 
--- function tick()
--- 	if IsBodyVisible(handle, 25) then
--- 		--Body is within 25 meters visible to the camera
--- 		DebugPrint("visible")
--- 	else
--- 		DebugPrint("not visible")
--- 	end
--- end
--- ```
---@param handle number Body handle
---@param maxDist number Maximum visible distance
---@param rejectTransparent? boolean See through transparent materials. Default false.
---@return boolean visible Return true if body is visible
function IsBodyVisible(handle, maxDist, rejectTransparent) return false end

--- Determine if any shape of a body has been broken.
---
--- Example:
--- ```lua
--- local handle = 0
--- function init()
--- 	handle = FindBody("body", true)
--- end
--- 
--- function tick()
--- 	DebugPrint(IsBodyBroken(handle))
--- end
--- ```
---@param handle number Body handle
---@return boolean broken Return true if body is broken
function IsBodyBroken(handle) return false end

--- Determine if a body is in any way connected to a static object, either by being static itself or
--- be being directly or indirectly jointed to something static.
---
--- Example:
--- ```lua
--- local handle = 0
--- function init()
--- 	handle = FindBody("body", true)
--- end
--- 
--- function tick()
--- 	DebugPrint(IsBodyJointedToStatic(handle))
--- end
--- ```
---@param handle number Body handle
---@return boolean result Return true if body is in any way connected to a static body
function IsBodyJointedToStatic(handle) return false end

--- Render next frame with an outline around specified body.
--- If no color is given, a white outline will be drawn.
---
--- Example:
--- ```lua
--- local handle = 0
--- function init()
--- 	handle = FindBody("body", true)
--- end
--- 
--- function tick()
--- 	if InputDown("interact") then
--- 		--Draw white outline at 50% transparency
--- 		DrawBodyOutline(handle, 0.5)
--- 	else
--- 		--Draw green outline, fully opaque
--- 		DrawBodyOutline(handle, 0, 1, 0, 1)
--- 	end
--- end
--- ```
---@param handle number Body handle
---@param r? number Red
---@param g? number Green
---@param b? number Blue
---@param a? number Alpha
function DrawBodyOutline(handle, r, g, b, a) end

--- Flash the appearance of a body when rendering this frame. This is
--- used for valuables in the game.
---
--- Example:
--- ```lua
--- local handle = 0
--- function init()
--- 	handle = FindBody("body", true)
--- end
--- 
--- function tick()
--- 	if InputDown("interact") then
--- 		DrawBodyHighlight(handle, 0.5)
--- 	end
--- end
--- ```
---@param handle number Body handle
---@param amount number Amount
function DrawBodyHighlight(handle, amount) end

function WatchBodyHit(...) end

--- This will return the closest point of a specific body
---
--- Example:
--- ```lua
--- local handle = 0
--- function init()
--- 	handle = FindBody("body", true)
--- end
--- 
--- function tick()
--- 	DebugCross(Vec(1, 0, 0))
--- 	local hit, p, n, s = GetBodyClosestPoint(handle, Vec(1, 0, 0))
--- 	if hit then
--- 		DebugCross(p)
--- 	end
--- end
--- ```
---@param body number Body handle
---@param origin TVec World space point
---@return boolean hit True if a point was found
---@return TVec point World space closest point
---@return TVec normal World space normal at closest point
---@return number shape Handle to closest shape
function GetBodyClosestPoint(body, origin) return false, Vec(), Vec(), 0 end

--- This will tell the physics solver to constrain the velocity between two bodies. The physics solver
--- will try to reach the desired goal, while not applying an impulse bigger than the min and max values.
--- This function should only be used from the update callback.
---
--- Example:
--- ```lua
--- local handleA = 0
--- local handleB = 0
--- function init()
--- 	handleA = FindBody("body", true)
--- 	handleB = FindBody("target", true)
--- end
--- 
--- function update()
--- 	--Constrain the velocity between bodies A and B so that the relative velocity
--- 	--along the X axis at point (0, 5, 0) is always 3 m/s
--- 	ConstrainVelocity(handleA, handleB, Vec(0, 5, 0), Vec(1, 0, 0), 3)
--- end
--- ```
---@param bodyA number First body handle (zero for static)
---@param bodyB number Second body handle (zero for static)
---@param point TVec World space point
---@param dir TVec World space direction
---@param relVel number Desired relative velocity along the provided direction
---@param min? number Minimum impulse (default: -infinity)
---@param max? number Maximum impulse (default: infinity)
function ConstrainVelocity(bodyA, bodyB, point, dir, relVel, min, max) end

--- This will tell the physics solver to constrain the angular velocity between two bodies. The physics solver
--- will try to reach the desired goal, while not applying an angular impulse bigger than the min and max values.
--- This function should only be used from the update callback.
---
--- Example:
--- ```lua
--- local handleA = 0
--- local handleB = 0
--- function init()
--- 	handleA = FindBody("body", true)
--- 	handleB = FindBody("target", true)
--- end
--- 
--- function update()
--- 	--Constrain the angular velocity between bodies A and B so that the relative angular velocity
--- 	--along the Y axis is always 3 rad/s
--- 	ConstrainAngularVelocity(handleA, handleB, Vec(1, 0, 0), 3)
--- end
--- ```
---@param bodyA number First body handle (zero for static)
---@param bodyB number Second body handle (zero for static)
---@param dir TVec World space direction
---@param relAngVel number Desired relative angular velocity along the provided direction
---@param min? number Minimum angular impulse (default: -infinity)
---@param max? number Maximum angular impulse (default: infinity)
function ConstrainAngularVelocity(bodyA, bodyB, dir, relAngVel, min, max) end

--- This is a helper function that uses ConstrainVelocity to constrain a point on one
--- body to a point on another body while not affecting the bodies more than the provided
--- maximum relative velocity and maximum impulse. In other words: physically push on
--- the bodies so that pointA and pointB are aligned in world space. This is useful for
--- physically animating objects. This function should only be used from the update callback.
---
--- Example:
--- ```lua
--- local handleA = 0
--- local handleB = 0
--- function init()
--- 	handleA = FindBody("body", true)
--- 	handleB = FindBody("target", true)
--- end
--- 
--- function update()
--- 	--Constrain the origo of body a to an animated point in the world
--- 	local worldPos = Vec(0, 3+math.sin(GetTime()), 0)
--- 	ConstrainPosition(handleA, 0, GetBodyTransform(handleA).pos, worldPos)
--- 
--- 	--Constrain the origo of body a to the origo of body b (like a ball joint)
--- 	ConstrainPosition(handleA, handleA, GetBodyTransform(handleA).pos, GetBodyTransform(handleB).pos)
--- end
--- ```
---@param bodyA number First body handle (zero for static)
---@param bodyB number Second body handle (zero for static)
---@param pointA TVec World space point for first body
---@param pointB TVec World space point for second body
---@param maxVel? number Maximum relative velocity (default: infinite)
---@param maxImpulse? number Maximum impulse (default: infinite)
function ConstrainPosition(bodyA, bodyB, pointA, pointB, maxVel, maxImpulse) end

--- This is the angular counterpart to ConstrainPosition, a helper function that uses
--- ConstrainAngularVelocity to constrain the orientation of one body to the orientation
--- on another body while not affecting the bodies more than the provided maximum relative
--- angular velocity and maximum angular impulse. In other words: physically rotate the
--- bodies so that quatA and quatB are aligned in world space. This is useful for
--- physically animating objects. This function should only be used from the update callback.
---
--- Example:
--- ```lua
--- local handleA = 0
--- local handleB = 0
--- function init()
--- 	handleA = FindBody("body", true)
--- 	handleB = FindBody("target", true)
--- end
--- 
--- function update()
--- 	--Constrain the orietation of body a to an upright orientation in the world
--- 	ConstrainOrientation(handleA, 0, GetBodyTransform(handleA).rot, Quat())
--- 
--- 	--Constrain the orientation of body a to the orientation of body b
--- 	ConstrainOrientation(handleA, handleB, GetBodyTransform(handleA).rot, GetBodyTransform(handleB).rot)
--- end
--- ```
---@param bodyA number First body handle (zero for static)
---@param bodyB number Second body handle (zero for static)
---@param quatA TQuat World space orientation for first body
---@param quatB TQuat World space orientation for second body
---@param maxAngVel? number Maximum relative angular velocity (default: infinite)
---@param maxAngImpulse? number Maximum angular impulse (default: infinite)
function ConstrainOrientation(bodyA, bodyB, quatA, quatB, maxAngVel, maxAngImpulse) end

--- Every scene in Teardown has an implicit static world body that contains all shapes that are not explicitly assigned a body in the editor.
---
--- Example:
--- ```lua
--- local handle
--- function init()
--- 	handle = GetWorldBody()
--- end
--- 
--- function tick()
--- 	DebugCross(GetBodyTransform(handle).pos)
--- end
--- ```
---@return number body Handle to the static world body
function GetWorldBody() return 0 end

---
--- Example:
--- ```lua
--- local target = 0
--- local escape = 0
--- function init()
--- 	--Search for a shape tagged "mybox" in script scope
--- 	target = FindShape("mybox")
--- 
--- 	--Search for a shape tagged "laserturret" in entire scene
--- 	escape = FindShape("laserturret", true)
--- end
--- 
--- function tick()
--- 	DebugCross(GetShapeWorldTransform(target).pos)
--- 	DebugCross(GetShapeWorldTransform(escape).pos)
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return number handle Handle to first shape with specified tag or zero if not found
function FindShape(tag, global) return 0 end

---
--- Example:
--- ```lua
--- local shapes = {}
--- function init()
--- 	--Search for shapes tagged "body"
--- 	shapes = FindShapes("body", true)
--- end
--- 
--- function tick()
--- 	for i=1, #shapes do
--- 		local shape = shapes[i]
--- 		DebugCross(GetShapeWorldTransform(shape).pos)
--- 	end
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return any list Indexed table with handles to all shapes with specified tag
function FindShapes(tag, global) return nil end

---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape")
--- end
--- 
--- function tick()
--- 	--Shape transform in body local space
--- 	local shapeTransform = GetShapeLocalTransform(shape)
--- 
--- 	--Body transform in world space
--- 	local bodyTransform = GetBodyTransform(GetShapeBody(shape))
--- 
--- 	--Shape transform in world space
--- 	local worldTranform = TransformToParentTransform(bodyTransform, shapeTransform)
--- 
--- 	DebugCross(worldTranform)
--- end
--- ```
---@param handle number Shape handle
---@return TTransform transform Return shape transform in body space
function GetShapeLocalTransform(handle) return Transform() end

---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape")
--- 	local transform = Transform(Vec(0, 1, 0), QuatEuler(0, 90, 0))
--- 	SetShapeLocalTransform(shape, transform)
--- end
--- 
--- function tick()
--- 	--Shape transform in body local space
--- 	local shapeTransform = GetShapeLocalTransform(shape)
--- 
--- 	--Body transform in world space
--- 	local bodyTransform = GetBodyTransform(GetShapeBody(shape))
--- 
--- 	--Shape transform in world space
--- 	local worldTranform = TransformToParentTransform(bodyTransform, shapeTransform)
--- 
--- 	DebugCross(worldTranform)
--- end
--- ```
---@param handle number Shape handle
---@param transform TTransform Shape transform in body space
function SetShapeLocalTransform(handle, transform) end

--- This is a convenience function, transforming the shape out of body space
---
--- Example:
--- ```lua
--- --GetShapeWorldTransform is equivalent to
--- --local shapeTransform = GetShapeLocalTransform(shape)
--- --local bodyTransform = GetBodyTransform(GetShapeBody(shape))
--- --worldTranform = TransformToParentTransform(bodyTransform, shapeTransform)
--- 
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- end
--- 
--- function tick()
--- 	DebugCross(GetShapeWorldTransform(shape).pos)
--- end
--- ```
---@param handle number Shape handle
---@return TTransform transform Return shape transform in world space
function GetShapeWorldTransform(handle) return Transform() end

--- Get handle to the body this shape is owned by. A shape is always owned by a body,
--- but can be transfered to a new body during destruction.
---
--- Example:
--- ```lua
--- local body = 0
--- function init()
--- 	body = GetShapeBody(FindShape("shape", true), true)
--- end
--- 
--- function tick()
--- 	DebugCross(GetBodyCenterOfMass(body))
--- end
--- ```
---@param handle number Shape handle
---@return number handle Body handle
function GetShapeBody(handle) return 0 end

---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- 
--- 	local hinges = GetShapeJoints(shape)
--- 	for i=1, #hinges do
--- 		local joint = hinges[i]
--- 		DebugPrint(joint)
--- 	end
--- end
--- ```
---@param shape number Shape handle
---@return any list Indexed table with joints connected to shape
function GetShapeJoints(shape) return nil end

---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- 
--- 	local light = GetShapeLights(shape)
--- 	for i=1, #light do
--- 		DebugPrint(light[i])
--- 	end
--- end
--- ```
---@param shape number Shape handle
---@return any list Indexed table of lights owned by shape
function GetShapeLights(shape) return nil end

--- Return the world space, axis-aligned bounding box for a shape.
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- 
--- 	local min, max = GetShapeBounds(shape)
--- 	local boundsSize = VecSub(max, min)
--- 	local center = VecLerp(min, max, 0.5)
--- 
--- 	DebugPrint(VecStr(boundsSize) .. " " .. VecStr(center))
--- end
--- ```
---@param handle number Shape handle
---@return TVec min Vector representing the AABB lower bound
---@return TVec max Vector representing the AABB upper bound
function GetShapeBounds(handle) return Vec(), Vec() end

--- Scale emissiveness for shape. If the shape has light sources attached,
--- their intensity will be scaled by the same amount.
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- 
--- 	--Pulsate emissiveness and light intensity for shape
--- 	local scale = math.sin(GetTime())*0.5 + 0.5
--- 	SetShapeEmissiveScale(shape, scale)
--- end
--- ```
---@param handle number Shape handle
---@param scale number Scale factor for emissiveness
function SetShapeEmissiveScale(handle, scale) end

--- Change the material density of the shape.
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- 
--- 	local density = 10.0
--- 	SetShapeDensity(shape, density)
--- end
--- ```
---@param handle number Shape handle
---@param density number New density for the shape
function SetShapeDensity(handle, density) end

function SetShapeStrength(...) end

function GetShapeStrength(...) end

--- Return material properties for a particular voxel
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- end
--- 
--- function tick()
--- 	local pos = GetCameraTransform().pos
--- 	local dir = Vec(0, 0, 1)
--- 	local hit, dist, normal, shape = QueryRaycast(pos, dir, 10)
--- 	if hit then
--- 		local hitPoint = VecAdd(pos, VecScale(dir, dist))
--- 		local mat = GetShapeMaterialAtPosition(shape, hitPoint)
--- 		DebugPrint("Raycast hit voxel made out of " .. mat)
--- 	end
--- 	DebugLine(pos, VecAdd(pos, VecScale(dir, 10)))
--- end
--- ```
---@param handle number Shape handle
---@param pos TVec Position in world space
---@param includeUnphysical? boolean Include unphysical voxels in the search. Default false.
---@return string type Material type
---@return number r Red
---@return number g Green
---@return number b Blue
---@return number a Alpha
---@return number entry Palette entry for voxel (zero if empty)
function GetShapeMaterialAtPosition(handle, pos, includeUnphysical) return "", 0, 0, 0, 0, 0 end

--- Return material properties for a particular voxel in the voxel grid indexed by integer values.
--- The first index is zero (not one, as opposed to a lot of lua related things)
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- 	local mat = GetShapeMaterialAtIndex(shape, 0, 0, 0)
--- 	DebugPrint("The voxel is of material: " .. mat)
--- end
--- ```
---@param handle number Shape handle
---@param x number X integer coordinate
---@param y number Y integer coordinate
---@param z number Z integer coordinate
---@return string type Material type
---@return number r Red
---@return number g Green
---@return number b Blue
---@return number a Alpha
---@return number entry Palette entry for voxel (zero if empty)
function GetShapeMaterialAtIndex(handle, x, y, z) return "", 0, 0, 0, 0, 0 end

--- Return the size of a shape in voxels
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- 	local x, y, z = GetShapeSize(shape)
--- 	DebugPrint("Shape size: " .. x .. ";" .. y .. ";" .. z)
--- end
--- ```
---@param handle number Shape handle
---@return number xsize Size in voxels along x axis
---@return number ysize Size in voxels along y axis
---@return number zsize Size in voxels along z axis
---@return number scale The size of one voxel in meters (with default scale it is 0.1)
function GetShapeSize(handle) return 0, 0, 0, 0 end

--- Return the number of voxels in a shape, not including empty space
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- 	local voxelCount = GetShapeVoxelCount(shape)
--- 	DebugPrint(voxelCount)
--- end
--- ```
---@param handle number Shape handle
---@return number count Number of voxels in shape
function GetShapeVoxelCount(handle) return 0 end

--- This function does a very rudimetary check and will only return true if the
--- object is visible within 74 degrees of the camera's forward direction, and
--- only tests line-of-sight visibility for the corners and center of the bounding box.
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- end
--- 
--- function tick()
--- 	if IsShapeVisible(shape, 25) then
--- 		DebugPrint("Shape is visible")
--- 	else
--- 		DebugPrint("Shape is not visible")
--- 	end
--- end
--- ```
---@param handle number Shape handle
---@param maxDist number Maximum visible distance
---@param rejectTransparent? boolean See through transparent materials. Default false.
---@return boolean visible Return true if shape is visible
function IsShapeVisible(handle, maxDist, rejectTransparent) return false end

--- Determine if shape has been broken. Note that a shape can be transfered
--- to another body during destruction, but might still not be considered
--- broken if all voxels are intact.
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- end
--- 
--- function tick()
--- 	DebugPrint("Is shape broken: " .. tostring(IsShapeBroken(shape)))
--- end
--- ```
---@param handle number Shape handle
---@return boolean broken Return true if shape is broken
function IsShapeBroken(handle) return false end

--- Render next frame with an outline around specified shape.
--- If no color is given, a white outline will be drawn.
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- end
--- 
--- function tick()
--- 	if InputDown("interact") then
--- 		--Draw white outline at 50% transparency
--- 		DrawShapeOutline(shape, 0.5)
--- 	else
--- 		--Draw green outline, fully opaque
--- 		DrawShapeOutline(shape, 0, 1, 0, 1)
--- 	end
--- end
--- ```
---@param handle number Shape handle
---@param r? number Red
---@param g? number Green
---@param b? number Blue
---@param a number Alpha
function DrawShapeOutline(handle, r, g, b, a) end

--- Flash the appearance of a shape when rendering this frame.
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- end
--- 
--- function tick()
--- 	if InputDown("interact") then
--- 		DrawShapeHighlight(shape, 0.5)
--- 	end
--- end
--- ```
---@param handle number Shape handle
---@param amount number Amount
function DrawShapeHighlight(handle, amount) end

--- This is used to filter out collisions with other shapes. Each shape can be given a layer
--- bitmask (8 bits, 0-255) along with a mask (also 8 bits). The layer of one object must be in
--- the mask of the other object and vice versa for the collision to be valid. The default layer
--- for all objects is 1 and the default mask is 255 (collide with all layers).
---
--- Example:
--- ```lua
--- local shapeA = 0
--- local shapeB = 0
--- local shapeC = 0
--- local shapeD = 0
--- function init()
--- 	shapeA = FindShape("shapeA")
--- 	shapeB = FindShape("shapeB")
--- 	shapeC = FindShape("shapeC")
--- 	shapeD = FindShape("shapeD")
--- 	--This will put shapes a and b in layer 2 and disable collisions with
--- 	--object shapes in layers 2, preventing any collisions between the two.
--- 	SetShapeCollisionFilter(shapeA, 2, 255-2)
--- 	SetShapeCollisionFilter(shapeB, 2, 255-2)
--- 
--- 	--This will put shapes c and d in layer 4 and allow collisions with other
--- 	--shapes in layer 4, but ignore all other collisions with the rest of the world.
--- 	SetShapeCollisionFilter(shapeC, 4, 4)
--- 	SetShapeCollisionFilter(shapeD, 4, 4)
--- end
--- ```
---@param handle number Shape handle
---@param layer number Layer bits (0-255)
---@param mask number Mask bits (0-255)
function SetShapeCollisionFilter(handle, layer, mask) end

--- Returns the current layer/mask settings of the shape
---
--- Example:
--- ```lua
--- function init()
--- 	local shape = FindShape("some_shape")
--- 	local layer, mask = GetShapeCollisionFilter(shape)
--- end
--- ```
---@param handle number Shape handle
---@return number layer Layer bits (0-255)
---@return number mask Mask bits (0-255)
function GetShapeCollisionFilter(handle) return 0, 0 end

--- Create new, empty shape on existing body using the palette of a reference shape.
--- The reference shape can be any existing shape in the scene or an external vox file.
--- The size of the new shape will be 1x1x1.
---
--- Example:
--- ```lua
--- function tick()
--- 	if InputPressed("interact") then
--- 		local t = Transform(Vec(0, 5, 0), QuatEuler(0, 0, 0))
--- 		local handle = CreateShape(FindBody("shape", true), t, FindShape("shape", true))
--- 		DebugPrint(handle)
--- 	end
--- end
--- ```
---@param body number Body handle
---@param transform TTransform Shape transform in body space
---@param refShape any or string) Handle to reference shape or path to vox file
---@return number newShape Handle of new shape
function CreateShape(body, transform, refShape) return 0 end

--- Fill a voxel shape with zeroes, thus removing all voxels.
---
--- Example:
--- ```lua
--- function init()
--- 	ClearShape(FindShape("shape", true))
--- end
--- ```
---@param shape number Shape handle
function ClearShape(shape) end

--- Resize an existing shape. The new coordinates are expressed in the existing shape coordinate frame,
--- so you can provide negative values. The existing content is preserved, but may be cropped if needed.
--- The local shape transform will be moved automatically with an offset vector to preserve the original content in body space.
--- This offset vector is returned in shape local space.
---
--- Example:
--- ```lua
--- function init()
--- 	ResizeShape(FindShape("shape", true), -5, 0, -5, 5, 5, 5)
--- end
--- ```
---@param shape number Shape handle
---@param xmi number Lower X coordinate
---@param ymi number Lower Y coordinate
---@param zmi number Lower Z coordinate
---@param xma number Upper X coordinate
---@param yma number Upper Y coordinate
---@param zma number Upper Z coordinate
---@return boolean resized Resized successfully
---@return TVec offset Offset vector in shape local space
function ResizeShape(shape, xmi, ymi, zmi, xma, yma, zma) return false, Vec() end

--- Move existing shape to a new body, optionally providing a new local transform.
---
--- Example:
--- ```lua
--- function init()
--- 	SetShapeBody(FindShape("shape", true), FindBody("custombody", true), true)
--- end
--- ```
---@param shape number Shape handle
---@param body number Body handle
---@param transform? TTransform New local shape transform. Default is existing local transform.
function SetShapeBody(shape, body, transform) end

--- Copy voxel content from source shape to destination shape. If destination
--- shape has a different size, it will be resized to match the source shape.
---
--- Example:
--- ```lua
--- function init()
--- 	CopyShapeContent(FindShape("shape", true), FindShape("shape2", true))
--- end
--- ```
---@param src number Source shape handle
---@param dst number Destination shape handle
function CopyShapeContent(src, dst) end

--- Copy the palette from source shape to destination shape.
---
--- Example:
--- ```lua
--- function init()
--- 	CopyShapePalette(FindShape("shape", true), FindShape("shape2", true))
--- end
--- ```
---@param src number Source shape handle
---@param dst number Destination shape handle
function CopyShapePalette(src, dst) end

--- Return list of material entries, each entry is a material index that
--- can be provided to GetShapeMaterial or used as brush for populating a
--- shape.
---
--- Example:
--- ```lua
--- function init()
--- 	local palette = GetShapePalette(FindShape("shape2", true))
--- 	for i = 1, #palette do
--- 		DebugPrint(palette[i])
--- 	end
--- end
--- ```
---@param shape number Shape handle
---@return any entries Palette material entries
function GetShapePalette(shape) return nil end

--- Return material properties for specific matirial entry.
---
--- Example:
--- ```lua
--- function init()
--- 	local type, r, g, b, a, reflectivity, shininess, metallic, emissive = GetShapeMaterial(FindShape("shape2", true), 1)
--- 	DebugPrint(type)
--- end
--- ```
---@param shape number Shape handle
---@param entry number Material entry
---@return string type Type
---@return number red Red value
---@return number green Green value
---@return number blue Blue value
---@return number alpha Alpha value
---@return number reflectivity Range 0 to 1
---@return number shininess Range 0 to 1
---@return number metallic Range 0 to 1
---@return number emissive Range 0 to 32
function GetShapeMaterial(shape, entry) return "", 0, 0, 0, 0, 0, 0, 0, 0 end

--- Set material index to be used for following calls to DrawShapeLine and DrawShapeBox and ExtrudeShape.
--- An optional brush vox file and subobject can be used and provided instead of material index,
--- in which case the content of the brush will be used and repeated. Use material index zero
--- to remove of voxels.
---
--- Example:
--- ```lua
--- function init()
--- 	SetBrush("sphere", 3, 3)
--- end
--- ```
---@param type string One of "sphere", "cube" or "noise"
---@param size number Size of brush in voxels (must be in range 1 to 16)
---@param index any path (number or string) Material index or path to brush vox file
---@param object? string Optional object in brush vox file if brush vox file is used
function SetBrush(type, size, index, object) end

--- Draw voxelized line between (x0,y0,z0) and (x1,y1,z1) into shape using the material
--- set up with SetBrush. Paint mode will only change material of existing voxels (where
--- the current material index is non-zero). noOverwrite mode will only fill in voxels if the
--- space isn't already accupied by another shape in the scene.
---
--- Example:
--- ```lua
--- function init()
--- 	SetBrush("sphere", 3, 1)
--- 	DrawShapeLine(FindShape("shape"), 0, 0, 0, 10, 50, 5, false, true)
--- end
--- ```
---@param shape number Handle to shape
---@param x0 number Start X coordinate
---@param y0 number Start Y coordinate
---@param z0 number Start Z coordinate
---@param x1 number End X coordinate
---@param y1 number End Y coordinate
---@param z1 number End Z coordinate
---@param paint? boolean Paint mode. Default is false.
---@param noOverwrite? boolean Only fill in voxels if space isn't already occupied. Default is false.
function DrawShapeLine(shape, x0, y0, z0, x1, y1, z1, paint, noOverwrite) end

--- Draw box between (x0,y0,z0) and (x1,y1,z1) into shape using the material
--- set up with SetBrush.
---
--- Example:
--- ```lua
--- function init()
--- 	SetBrush("sphere", 3, 4)
--- 	DrawShapeBox(FindShape("shape", true), 0, 0, 0, 10, 50, 5)
--- end
--- ```
---@param shape number Handle to shape
---@param x0 number Start X coordinate
---@param y0 number Start Y coordinate
---@param z0 number Start Z coordinate
---@param x1 number End X coordinate
---@param y1 number End Y coordinate
---@param z1 number End Z coordinate
function DrawShapeBox(shape, x0, y0, z0, x1, y1, z1) end

--- Extrude region of shape. The extruded region will be filled in with the material set up with SetBrush.
--- The mode parameter sepcifies how the region is determined.
--- Exact mode selects region of voxels that exactly match the input voxel at input coordinate.
--- Material mode selects region that has the same material type as the input voxel.
--- Geometry mode selects any connected voxel in the same plane as the input voxel.
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	SetBrush("sphere", 3, 4)
--- 	shape = FindShape("shape")
--- 	ExtrudeShape(shape, 0, 5, 0, -1, 0, 0, 50, "exact")
--- end
--- ```
---@param shape number Handle to shape
---@param x number X coordinate to extrude
---@param y number Y coordinate to extrude
---@param z number Z coordinate to extrude
---@param dx number X component of extrude direction, should be -1, 0 or 1
---@param dy number Y component of extrude direction, should be -1, 0 or 1
---@param dz number Z component of extrude direction, should be -1, 0 or 1
---@param steps number Length of extrusion in voxels
---@param mode string Extrusion mode, one of "exact", "material", "geometry". Default is "exact"
function ExtrudeShape(shape, x, y, z, dx, dy, dz, steps, mode) end

--- Trim away empty regions of shape, thus potentially making it smaller.
--- If the size of the shape changes, the shape will be automatically moved
--- to preserve the shape content in body space. The offset vector for this
--- translation is returned in shape local space.
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- 	TrimShape(shape)
--- end
--- ```
---@param shape number Source handle
---@return TVec offset Offset vector in shape local space
function TrimShape(shape) return Vec() end

--- Split up a shape into multiple shapes based on connectivity. If the removeResidual flag
--- is used, small disconnected chunks will be removed during this process to reduce the number
--- of newly created shapes.
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- 	SplitShape(shape, true)
--- end
--- ```
---@param shape number Source handle
---@param removeResidual boolean Remove residual shapes (default false)
---@return any newShapes List of shape handles created
function SplitShape(shape, removeResidual) return nil end

--- Try to merge shape with a nearby, matching shape. For a merge to happen, the
--- shapes need to be aligned to the same rotation and touching. If the
--- provided shape was merged into another shape, that shape may be resized to
--- fit the merged content. If shape was merged, the handle to the other shape is
--- returned, otherwise the input handle is returned.
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- 	DebugPrint(shape)
--- 	shape = MergeShape(shape)
--- 	DebugPrint(shape)
--- end
--- ```
---@param shape number Input shape
---@return number shape Shape handle after merge
function MergeShape(shape) return 0 end

---@param shape number Shape handle
---@param name string Name of shape
---@return boolean success True if shape was saved successfully
---@return string reason Reason for failure: "no_space" if there is not enough space on disk, "invalid_name" if the name contains invalid characters
function SaveShape(shape, name) return false, "" end

function DeleteShape(...) end

---
--- Example:
--- ```lua
--- function tick()
--- 	DebugWatch("IsShapeDisconnected", IsShapeDisconnected(FindShape("shape", true)))
--- end
--- ```
---@param shape number Input shape
---@return boolean disconnected True if shape disconnected (has detached parts)
function IsShapeDisconnected(shape) return false end

---
--- Example:
--- ```lua
--- function tick()
--- 	DebugWatch("IsStaticShapeDetached", IsStaticShapeDetached(FindShape("shape_glass", true)))
--- end
--- ```
---@param shape number Input shape
---@return boolean disconnected True if static shape has detached parts
function IsStaticShapeDetached(shape) return false end

--- This will return the closest point of a specific shape
---
--- Example:
--- ```lua
--- local shape = 0
--- function init()
--- 	shape = FindShape("shape", true)
--- end
--- 
--- function tick()
--- 	DebugCross(Vec(1, 0, 0))
--- 	local hit, p, n, s = GetShapeClosestPoint(shape, Vec(1, 0, 0))
--- 	if hit then
--- 		DebugCross(p)
--- 	end
--- end
--- ```
---@param shape number Shape handle
---@param origin TVec World space point
---@return boolean hit True if a point was found
---@return TVec point World space closest point
---@return TVec normal World space normal at closest point
function GetShapeClosestPoint(shape, origin) return false, Vec(), Vec() end

--- This will check if two shapes has physical overlap
---
--- Example:
--- ```lua
--- local shapeA = 0
--- local shapeB = 0
--- function init()
--- 	shapeA = FindShape("shape")
--- 	shapeB = FindShape("shape2")
--- end
--- 
--- function tick()
--- 	DebugPrint(IsShapeTouching(shapeA, shapeB))
--- end
--- ```
---@param a number Handle to first shape
---@param b number Handle to second shape
---@return boolean touching True is shapes a and b are touching each other
function IsShapeTouching(a, b) return false end

---
--- Example:
--- ```lua
--- local loc = 0
--- function init()
--- 	loc = FindLocation("loc1")
--- end
--- 
--- function tick()
--- 	DebugCross(GetLocationTransform(loc).pos)
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return number handle Handle to first location with specified tag or zero if not found
function FindLocation(tag, global) return 0 end

---
--- Example:
--- ```lua
--- local locations
--- function init()
--- 	locations = FindLocations("loc1")
--- 
--- 	for i=1, #locations do
--- 		local loc = locations[i]
--- 		DebugPrint(DebugPrint(loc))
--- 	end
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return any list Indexed table with handles to all locations with specified tag
function FindLocations(tag, global) return nil end

---
--- Example:
--- ```lua
--- local location = 0
--- function init()
--- 	location = FindLocation("loc1")
--- 	DebugPrint(VecStr(GetLocationTransform(location).pos))
--- end
--- ```
---@param handle number Location handle
---@return TTransform transform Transform of the location
function GetLocationTransform(handle) return Transform() end

---
--- Example:
--- ```lua
--- function init()
--- 	local joint = FindJoint("doorhinge")
--- 	DebugPrint(joint)
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return number handle Handle to first joint with specified tag or zero if not found
function FindJoint(tag, global) return 0 end

---
--- Example:
--- ```lua
--- --Search for locations tagged "doorhinge" in script scope
--- function init()
--- 	local hinges = FindJoints("doorhinge")
--- 	for i=1, #hinges do
--- 		local joint = hinges[i]
--- 		DebugPrint(joint)
--- 	end
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return any list Indexed table with handles to all joints with specified tag
function FindJoints(tag, global) return nil end

---
--- Example:
--- ```lua
--- function init()
--- 	local broken = IsJointBroken(FindJoint("joint"))
--- 	DebugPrint(broken)
--- end
--- ```
---@param joint number Joint handle
---@return boolean broken True if joint is broken
function IsJointBroken(joint) return false end

--- Joint type is one of the following: "ball", "hinge", "prismatic" or "rope".
--- An empty string is returned if joint handle is invalid.
---
--- Example:
--- ```lua
--- function init()
--- 	local joint = FindJoint("joint")
--- 	if GetJointType(joint) == "rope" then
--- 		DebugPrint("Joint is rope")
--- 	end
--- end
--- ```
---@param joint number Joint handle
---@return string type Joint type
function GetJointType(joint) return "" end

function SetRopeSlack(...) end

--- A joint is always connected to two shapes. Use this function if you know
--- one shape and want to find the other one.
---
--- Example:
--- ```lua
--- function init()
--- 	local joint = FindJoint("joint")
--- 	--joint is connected to A and B
--- 
--- 	otherShape = GetJointOtherShape(joint, FindShape("shapeA"))
--- 	--otherShape is now B
--- 
--- 	otherShape = GetJointOtherShape(joint, FindShape("shapeB"))
--- 	--otherShape is now A
--- end
--- ```
---@param joint number Joint handle
---@param shape number Shape handle
---@return number other Other shape handle
function GetJointOtherShape(joint, shape) return 0 end

--- 
--- Get shapes connected to the joint.
--- 
---
--- Example:
--- ```lua
--- local mainBody
--- local shapes
--- local joint
--- function init()
--- 	joint = FindJoint("joint")
--- 	mainBody = GetVehicleBody(FindVehicle("vehicle"))
--- 	shapes = GetJointShapes(joint)
--- end
--- 
--- function tick()
--- 	-- Check to see if joint chain is still connected to vehicle main body
--- 	-- If not then disable motors
--- 
--- 	local connected = false
--- 	for i=1,#shapes do
--- 
--- 		local body = GetShapeBody(shapes[i])
--- 
--- 		if body == mainBody then
--- 			connected = true
--- 		end
--- 
--- 	end
--- 
--- 	if connected then
--- 		SetJointMotor(joint, 0.5)
--- 	else
--- 		SetJointMotor(joint, 0.0)
--- 	end
--- end
--- ```
---@param joint number Joint handle
---@return number shapes Shape handles
function GetJointShapes(joint) return 0 end

--- Set joint motor target velocity. If joint is of type hinge, velocity is
--- given in radians per second angular velocity. If joint type is prismatic joint
--- velocity is given in meters per second. Calling this function will override and
--- void any previous call to SetJointMotorTarget.
---
--- Example:
--- ```lua
--- function init()
--- 	--Set motor speed to 0.5 radians per second
--- 	SetJointMotor(FindJoint("hinge"), 0.5)
--- end
--- ```
---@param joint number Joint handle
---@param velocity number Desired velocity
---@param strength? number Desired strength. Default is infinite. Zero to disable.
function SetJointMotor(joint, velocity, strength) end

--- If a joint has a motor target, it will try to maintain its relative movement. This
--- is very useful for elevators or other animated, jointed mechanisms.
--- If joint is of type hinge, target is an angle in degrees (-180 to 180) and velocity
--- is given in radians per second. If joint type is prismatic, target is given
--- in meters and velocity is given in meters per second. Setting a motor target will
--- override any previous call to SetJointMotor.
---
--- Example:
--- ```lua
--- function init()
--- 	--Make joint reach a 45 degree angle, going at a maximum of 3 radians per second
--- 	SetJointMotorTarget(FindJoint("hinge"), 45, 3)
--- end
--- ```
---@param joint number Joint handle
---@param target number Desired movement target
---@param maxVel? number Maximum velocity to reach target. Default is infinite.
---@param strength? number Desired strength. Default is infinite. Zero to disable.
function SetJointMotorTarget(joint, target, maxVel, strength) end

--- Return joint limits for hinge or prismatic joint. Returns angle or distance
--- depending on joint type.
---
--- Example:
--- ```lua
--- function init()
--- 	local min, max = GetJointLimits(FindJoint("hinge"))
--- 	DebugPrint(min .. "-" .. max)
--- end
--- ```
---@param joint number Joint handle
---@return number min Minimum joint limit (angle or distance)
---@return number max Maximum joint limit (angle or distance)
function GetJointLimits(joint) return 0, 0 end

--- Return the current position or angle or the joint, measured in same way
--- as joint limits.
---
--- Example:
--- ```lua
--- function init()
--- 	local current = GetJointMovement(FindJoint("hinge"))
--- 	DebugPrint(current)
--- end
--- ```
---@param joint number Joint handle
---@return number movement Current joint position or angle
function GetJointMovement(joint) return 0 end

---
--- Example:
--- ```lua
--- local body = 0
--- function init()
--- 	body = FindBody("body")
--- end
--- 
--- function tick()
--- 	--Draw outline for all bodies in jointed structure
--- 	local all = GetJointedBodies(body)
--- 	for i=1,#all do
--- 		DrawBodyOutline(all[i], 0.5)
--- 	end
--- end
--- ```
---@param body number Body handle (must be dynamic)
---@return any bodies Handles to all dynamic bodies in the jointed structure. The input handle will also be included.
function GetJointedBodies(body) return nil end

--- Detach joint from shape. If joint is not connected to shape, nothing happens.
---
--- Example:
--- ```lua
--- function init()
--- 	DetachJointFromShape(FindJoint("joint"), FindShape("door"))
--- end
--- ```
---@param joint number Joint handle
---@param shape number Shape handle
function DetachJointFromShape(joint, shape) end

--- Returns the number of points in the rope given its handle.
--- Will return zero if the handle is not a rope
---
--- Example:
--- ```lua
--- function init()
--- 	local joint = FindJoint("joint")
--- 	local numberPoints = GetRopeNumberOfPoints(joint)
--- end
--- ```
---@param joint number Joint handle
---@return number amount Number of points in a rope or zero if invalid
function GetRopeNumberOfPoints(joint) return 0 end

--- Returns the world position of the rope's point.
--- Will return nil if the handle is not a rope or the index is not valid
---
--- Example:
--- ```lua
--- function init()
--- 	local joint = FindJoint("joint")
--- 	numberPoints = GetRopeNumberOfPoints(joint)
--- 
--- 	for pointIndex = 1, numberPoints do
--- 		DebugCross(GetRopePointPosition(joint, pointIndex))
--- 	end
--- end
--- ```
---@param joint number Joint handle
---@param index number The point index, starting at 1
---@return TVec pos World position of the point, or nil, if invalid
function GetRopePointPosition(joint, index) return Vec() end

--- Returns the bounds of the rope.
--- Will return nil if the handle is not a rope
---
--- Example:
--- ```lua
--- function init()
--- 	local joint = FindJoint("joint")
--- 	local mi, ma = GetRopeBounds(joint)
--- 
--- 	DebugCross(mi)
--- 	DebugCross(ma)
--- end
--- ```
---@param joint number Joint handle
---@return TVec min Lower point of rope bounds in world space
---@return TVec max Upper point of rope bounds in world space
function GetRopeBounds(joint) return Vec(), Vec() end

--- Breaks the rope at the specified point.
---
--- Example:
--- ```lua
--- function tick()
--- 	local playerCameraTransform = GetPlayerCameraTransform()
--- 	local dir = TransformToParentVec(playerCameraTransform, Vec(0, 0, -1))
--- 
--- 	local hit, dist, joint = QueryRaycastRope(playerCameraTransform.pos, dir, 5)
--- 	if hit then
--- 		local breakPoint = VecAdd(playerCameraTransform.pos, VecScale(dir, dist))
--- 		BreakRope(joint, breakPoint)
--- 	end
--- end
--- ```
---@param joint number Rope type joint handle
---@param point TVec Point of break as world space vector
function BreakRope(joint, point) end

---
--- Example:
--- ```lua
--- SetAnimatorPositionIK(animator, "shoulder_l", "hand_l", Vec(10, 0, 0), 1.0, 0.9, true)
--- ```
---@param handle number Animator handle
---@param begname string Name of the start-bone of the chain
---@param endname string Name of the end-bone of the chain
---@param target TVec World target position that the "endname" bone should reach
---@param weight? number Weight [0,1] of this animation, default is 1.0
---@param history? number How much of the previous frames result [0,1] that should be used when start the IK search, default is 0.0
---@param flag? boolean TRUE if constraints should be used, default is TRUE
function SetAnimatorPositionIK(handle, begname, endname, target, weight, history, flag) end

---
--- Example:
--- ```lua
--- SetAnimatorTransformIK(animator, "shoulder_l", "hand_l", Transform(10, 0, 0), 1.0, 0.9, false, true)
--- ```
---@param handle number Animator handle
---@param begname string Name of the start-bone of the chain
---@param endname string Name of the end-bone of the chain
---@param transform TTransform World target transform that the "endname" bone should reach
---@param weight? number Weight [0,1] of this animation, default is 1.0
---@param history? number How much of the previous frames result [0,1] that should be used when start the IK search, default is 0.0
---@param locktarget? boolean TRUE if the end-bone should be fixed to the target-transform, FALSE if IK solution is used
---@param useconstraints? boolean TRUE if constraints should be used, default is TRUE
function SetAnimatorTransformIK(handle, begname, endname, transform, weight, history, locktarget, useconstraints) end

--- This will calculate the length of the bone-chain between the endpoints.
--- If the skeleton have a chain like this (shoulder_l -> upper_arm_l -> lower_arm_l -> hand_l) it will return the length of the upper_arm_l+lower_arm_l
---
--- Example:
--- ```lua
--- local length = GetBoneChainLength(animator, "shoulder_l", "hand_l")
--- ```
---@param handle number Animator handle
---@param begname string Name of the start-bone of the chain
---@param endname string Name of the end-bone of the chain
---@return number length Length of the bone chain between "start-bone" and "end-bone"
function GetBoneChainLength(handle, begname, endname) return 0 end

---
--- Example:
--- ```lua
--- --Search for the first animator in script scope
--- local animator = FindAnimator()
--- 
--- --Search for an animator tagged "anim" in script scope
--- local animator = FindAnimator("anim")
--- 
--- --Search for an animator tagged "anim2" in entire scene
--- local anim2 = FindAnimator("anim2", true)
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return number handle Handle to first animator with specified tag or zero if not found
function FindAnimator(tag, global) return 0 end

---
--- Example:
--- ```lua
--- --Search for animators tagged "target" in script scope
--- local targets = FindAnimators("target")
--- for i=1, #targets do
--- 	local target = targets[i]
--- 	...
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return any list Indexed table with handles to all animators with specified tag
function FindAnimators(tag, global) return nil end

---
--- Example:
--- ```lua
--- local pos = GetAnimatorTransform(animator).pos
--- ```
---@param handle number Animator handle
---@return TTransform transform World space transform of the animator
function GetAnimatorTransform(handle) return Transform() end

--- When using IK for a character you can use ik-helpers to define where the
---
--- Example:
--- ```lua
--- --This will adjust the target transform so that the grip defined by a location node in editor called "ik_hand_l" will reach the target
--- local target = Transform(Vec(10, 0, 0), QuatEuler(0, 90, 0))
--- local adj = GetAnimatorAdjustTransformIK(animator, "ik_hand_l")
--- if adj ~= nil then
---     target = TransformToParentTransform(target, adj)
--- end
--- SetAnimatorTransformIK(animator, "shoulder_l", "hand_l", target, 1.0, 0.9)
--- ```
---@param handle number Animator handle
---@param name string Name of the location node
---@return TTransform transform World space transform of the animator
function GetAnimatorAdjustTransformIK(handle, name) return Transform() end

---
--- Example:
--- ```lua
--- local t = Transform(Vec(10, 0, 0), QuatEuler(0, 90, 0))
--- SetAnimatorTransform(animator, t)
--- ```
---@param handle number Animator handle
---@param transform TTransform Desired transform
function SetAnimatorTransform(handle, transform) end

--- Make all prefab bodies physical and leave control to physics system
---
--- Example:
--- ```lua
--- MakeRagdoll(animator)
--- ```
---@param handle number Animator handle
function MakeRagdoll(handle) end

--- Take control if the prefab bodies and do an optional blend between the current ragdoll state and current animation state
---
--- Example:
--- ```lua
--- --Take control of bodies and do a blend during one sec between the animation state and last physics state
--- UnRagdoll(animator, 1.0)
--- ```
---@param handle number Animator handle
---@param time? number Transition time
function UnRagdoll(handle, time) end

--- Single animations, one-shot, will be processed after looping animations.
---
--- Example:
--- ```lua
--- --This will play a single animation "Shooting" with a 80% influence but only on the skeleton starting at bone "Spine"
--- PlayAnimation(animator, "Shooting", 0.8, "Spine")
--- ```
---@param handle number Animator handle
---@param name string Animation name
---@param weight? number Weight [0,1] of this animation, default is 1.0
---@param filter? string Name of the bone and its subtree that will be affected
---@return number handle Handle to the instance that can be used with PlayAnimationInstance, zero if clip reached its end
function PlayAnimation(handle, name, weight, filter) return 0 end

---
--- Example:
--- ```lua
--- --This will play an animation loop "Walking" with a 100% influence on the whole skeleton
--- PlayAnimationLoop(animator, "Walking")
--- ```
---@param handle number Animator handle
---@param name string Animation name
---@param weight? number Weight [0,1] of this animation, default is 1.0
---@param filter? string Name of the bone and its subtree that will be affected
function PlayAnimationLoop(handle, name, weight, filter) end

--- Single animations, one-shot, will be processed after looping animations.
---
--- Example:
--- ```lua
--- --This will play a single animation "Shooting" with a 80% influence but only on the skeleton starting at bone "Spine"
--- PlayAnimation(animator, "Shooting", 0.8, "Spine")
--- ```
---@param handle number Animator handle
---@param instance number Instance handle
---@param weight? number Weight [0,1] of this animation, default is 1.0
---@param speed? number Weight [0,1] of this animation, default is 1.0
---@return number handle Handle to the instance that can be used with PlayAnimationInstance, zero if clip reached its end
function PlayAnimationInstance(handle, instance, weight, speed) return 0 end

--- This will stop the playing anim-instance
---@param handle number Animator handle
---@param instance number Instance handle
function StopAnimationInstance(handle, instance) end

---
--- Example:
--- ```lua
--- --This will play an animation "Walking" at a specific time of 1.5s with a 80% influence on the whole skeleton
--- PlayAnimationFrame(animator, "Walking", 1.5, 0.8)
--- ```
---@param handle number Animator handle
---@param name string Animation name
---@param time number Time in the animation
---@param weight? number Weight [0,1] of this animation, default is 1.0
---@param filter? string Name of the bone and its subtree that will be affected
function PlayAnimationFrame(handle, name, time, weight, filter) end

--- You can group looping animations together and use the result of those to blend to target.
--- PlayAnimation will not work here since they are processed last separately from blendgroups.
---
--- Example:
--- ```lua
--- --This will blend an entire group with 50% influence
--- BeginAnimationGroup(animator, 0.5)
--- 	PlayAnimationLoop(...)
--- 	PlayAnimationLoop(...)
--- EndAnimationGroup(animator)
--- 
--- --You can also create a tree of groups, blending is performed in a depth-first order
--- BeginAnimationGroup(animator, 0.5)
--- 	PlayAnimationLoop(animator, "anim_a", 1.0)
--- 	PlayAnimationLoop(animator, "anim_b", 0.2)
--- 	BeginAnimationGroup(animator, 0.75)
--- 		PlayAnimationLoop(animator, "anim_c", 1.0)
--- 		PlayAnimationLoop(animator, "anim_d", 0.25)
--- 	EndAnimationGroup(animator)
--- EndAnimationGroup(animator)
--- ```
---@param handle number Animator handle
---@param weight? number Weight [0,1] of this group, default is 1.0
---@param filter? string Name of the bone and its subtree that will be affected
function BeginAnimationGroup(handle, weight, filter) end

--- Ends the group created by BeginAnimationGroup
---@param handle number Animator handle
function EndAnimationGroup(handle) end

--- Single animations, one-shot, will be processed after looping animations.
--- By calling PlayAnimationInstances you can force it to be processed earlier and be able to "overwrite" the result of it if you want
---
--- Example:
--- ```lua
--- --First we play a single jump animation affecting the whole skeleton
--- --Then we play an aiming animation on the upper-body, filter="Spine1", keeping the lower-body unaffected
--- --Then we force the single-animations to be processed, this will force the "jump" to be processed.
--- --Then we overwrite just the spine-bone with a mouse controlled rotation("rot")
--- --Result will be a jump animation with the upperbody playing an aiming animation but the pitch of the spine controlled by the mouse("rot")
--- 
--- if InputPressed("jump") then
--- 	PlayAnimation(animator, "Jump")
--- end
--- PlayAnimationLoop(animator, "Pistol Idle", aimWeight, "Spine1")
--- PlayAnimationInstances(animator)
--- SetBoneRotation(animator, "Spine1", rot, 1)
--- ```
---@param handle number Animator handle
function PlayAnimationInstances(handle) end

---
--- Example:
--- ```lua
--- local list = GetAnimationClipNames(animator)
--- for i=1, #list do
--- 	local name = list[i]
--- 	..
--- end
--- ```
---@param handle number Animator handle
---@return any list Indexed table with animation names
function GetAnimationClipNames(handle) return nil end

---@param handle number Animator handle
---@param name string Animation name
---@return number time Total duration of the animation
function GetAnimationClipDuration(handle, name) return 0 end

---
--- Example:
--- ```lua
--- SetAnimationClipFade(animator, "fire", 0.5, 0.5)
--- ```
---@param handle number Animator handle
---@param name string Animation name
---@param fadein number Fadein time of the animation
---@param fadeout number Fadeout time of the animation
function SetAnimationClipFade(handle, name, fadein, fadeout) end

---
--- Example:
--- ```lua
--- --This will make the clip run 2x as normal speed
--- SetAnimationClipSpeed(animator, "walking", 2)
--- ```
---@param handle number Animator handle
---@param name string Animation name
---@param speed number Sets the speed factor of the animation
function SetAnimationClipSpeed(handle, name, speed) end

---
--- Example:
--- ```lua
--- --This will "remove" 1s from the beginning and 2s from the end.
--- TrimAnimationClip(animator, "walking", 1, -2)
--- ```
---@param handle number Animator handle
---@param name string Animation name
---@param begoffset number Time offset from the beginning of the animation
---@param endoffset? number Time offset, positive value means from the beginning and negative value means from the end, zero(default) means at end
function TrimAnimationClip(handle, name, begoffset, endoffset) end

---@param handle number Animator handle
---@param name string Animation name
---@return number time Time of the current playposition in the animation
function GetAnimationClipLoopPosition(handle, name) return 0 end

---@param handle number Animator handle
---@param instance number Instance handle
---@return number time Time of the current playposition in the animation
function GetAnimationInstancePosition(handle, instance) return 0 end

---
--- Example:
--- ```lua
--- --This will set the current playposition to one second
--- SetAnimationClipLoopPosition(animator, "walking", 1)
--- ```
---@param handle number Animator handle
---@param name string Animation name
---@param time number Time in the animation
function SetAnimationClipLoopPosition(handle, name, time) end

---
--- Example:
--- ```lua
--- --This will set the existing rotation by QuatEuler(...)
--- SetBoneRotation(animator, "spine", QuatEuler(0, 180, 0), 1.0)
--- ```
---@param handle number Animator handle
---@param name string Bone name
---@param quat TQuat Orientation of the bone
---@param weight? number Weight [0,1] default is 1.0
function SetBoneRotation(handle, name, quat, weight) end

---
--- Example:
--- ```lua
--- --This will set the existing local-rotation to point to world space point
--- SetBoneLookAt(animator, "upper_arm_l", Vec(10, 20, 30), 1.0)
--- ```
---@param handle number Animator handle
---@param name string Bone name
---@param point any World space point as vector
---@param weight? number Weight [0,1] default is 1.0
function SetBoneLookAt(handle, name, point, weight) end

---
--- Example:
--- ```lua
--- --This will offset the existing rotation by QuatEuler(...)
--- RotateBone(animator, "spine", QuatEuler(0, 5, 0), 1.0)
--- ```
---@param handle number Animator handle
---@param name string Bone name
---@param quat TQuat Additive orientation
---@param weight? number Weight [0,1] default is 1.0
function RotateBone(handle, name, quat, weight) end

---
--- Example:
--- ```lua
--- local list = GetBoneNames(animator)
--- for i=1, #list do
--- 	local name = list[i]
--- 	..
--- end
--- ```
---@param handle number Animator handle
---@return any list Indexed table with bone-names
function GetBoneNames(handle) return nil end

---
--- Example:
--- ```lua
--- local body = GetBoneBody(animator, "head")
--- end
--- ```
---@param handle number Animator handle
---@param name string Bone name
---@return number handle Handle to the bone's body, or zero if no bone is present.
function GetBoneBody(handle, name) return 0 end

---
--- Example:
--- ```lua
---     local animator = GetPlayerAnimator()
---     local bones = GetBoneNames(animator)
---     for i=1, #bones do
---         local bone = bones[i]
---         local t = GetBoneWorldTransform(animator,bone)
---         DebugCross(t.pos)
---     end
--- ```
---@param handle number Animator handle
---@param name string Bone name
---@return TTransform transform World space transform of the bone
function GetBoneWorldTransform(handle, name) return Transform() end

---
--- Example:
--- ```lua
--- local lt = getBindPoseTransform(animator, "lefthand")
--- ```
---@param handle number Animator handle
---@param name string Bone name
---@return TTransform transform Local space transform of the bone in bindpose
function GetBoneBindPoseTransform(handle, name) return Transform() end

---
--- Example:
--- ```lua
--- function init()
--- 	local light = FindLight("main")
--- 	DebugPrint(light)
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return number handle Handle to first light with specified tag or zero if not found
function FindLight(tag, global) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	--Search for lights tagged "main" in script scope
--- 	local lights = FindLights("main")
--- 	for i=1, #lights do
--- 		local light = lights[i]
--- 		DebugPrint(light)
--- 	end
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return any list Indexed table with handles to all lights with specified tag
function FindLights(tag, global) return nil end

--- If light is owned by a shape, the emissive scale of that shape will be set
--- to 0.0 when light is disabled and 1.0 when light is enabled.
---
--- Example:
--- ```lua
--- function init()
--- 	SetLightEnabled(FindLight("main"), false)
--- end
--- ```
---@param handle number Light handle
---@param enabled boolean Set to true if light should be enabled
function SetLightEnabled(handle, enabled) end

--- This will only set the color tint of the light. Use SetLightIntensity for brightness.
--- Setting the light color will not affect the emissive color of a parent shape.
---
--- Example:
--- ```lua
--- function init()
--- 	--Set light color to yellow
--- 	SetLightColor(FindLight("main"), 1, 1, 0)
--- end
--- ```
---@param handle number Light handle
---@param r number Red value
---@param g number Green value
---@param b number Blue value
function SetLightColor(handle, r, g, b) end

--- If the shape is owned by a shape you most likely want to use
--- SetShapeEmissiveScale instead, which will affect both the emissiveness
--- of the shape and the brightness of the light at the same time.
---
--- Example:
--- ```lua
--- function init()
--- 	--Pulsate light
--- 	SetLightIntensity(FindLight("main"), math.sin(GetTime())*0.5 + 1.0)
--- end
--- ```
---@param handle number Light handle
---@param intensity number Desired intensity of the light
function SetLightIntensity(handle, intensity) end

--- Lights that are owned by a dynamic shape are automatcially moved with that shape
---
--- Example:
--- ```lua
--- local light = 0
--- function init()
--- 	light = FindLight("main")
--- 	local t = GetLightTransform(light)
--- 	DebugPrint(VecStr(t.pos))
--- end
--- ```
---@param handle number Light handle
---@return TTransform transform World space light transform
function GetLightTransform(handle) return Transform() end

---
--- Example:
--- ```lua
--- local light = 0
--- function init()
--- 	light = FindLight("main")
--- 	local shape = GetLightShape(light)
--- 	DebugPrint(shape)
--- end
--- ```
---@param handle number Light handle
---@return number handle Shape handle or zero if not attached to shape
function GetLightShape(handle) return 0 end

---
--- Example:
--- ```lua
--- local light = 0
--- function init()
--- 	light = FindLight("main")
--- 	if IsLightActive(light) then
--- 		DebugPrint("Light is active")
--- 	end
--- end
--- ```
---@param handle number Light handle
---@return boolean active True if light is currently emitting light
function IsLightActive(handle) return false end

---
--- Example:
--- ```lua
--- local light = 0
--- function init()
--- 	light = FindLight("main")
--- 	local point = Vec(0, 10, 0)
--- 	local affected = IsPointAffectedByLight(light, point)
--- 	DebugPrint(affected)
--- end
--- ```
---@param handle number Light handle
---@param point TVec World space point as vector
---@return boolean affected Return true if point is in light cone and range
function IsPointAffectedByLight(handle, point) return false end

--- DEPRECATED_ALERT
--- Disable all lights sources on the scene
---
--- Example:
--- ```lua
--- function init()
--- 	DisableAllLights()
--- end
--- ```
function DisableAllLights() end

--- Returns the handle of the player's flashlight. You can work with it as with an entity of the Light type.
---
--- Example:
--- ```lua
--- function tick()
--- 	local flashlight = GetFlashlight()
--- 	SetProperty(flashlight, "color", Vec(0.5, 0, 1))
--- end
--- ```
---@return number handle Handle of the player's flashlight
function GetFlashlight() return 0 end

--- Sets a new entity of the Light type as a flashlight.
---
--- Example:
--- ```lua
--- local oldLight = 0
--- function tick()
--- 	-- in order not to lose the original flashlight, it is better to save it's handle
--- 	oldLight = GetFlashlight()
--- 	SetFlashlight(FindEntity("mylight", true))
--- end
--- ```
---@param handle number Handle of the light
function SetFlashlight(handle) end

---
--- Example:
--- ```lua
--- function init()
--- 	local goal = FindTrigger("goal")
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return number handle Handle to first trigger with specified tag or zero if not found
function FindTrigger(tag, global) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	--Find triggers tagged "toxic" in script scope
--- 	local triggers = FindTriggers("toxic")
--- 	for i=1, #triggers do
--- 		local trigger = triggers[i]
--- 		DebugPrint(trigger)
--- 	end
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return any list Indexed table with handles to all triggers with specified tag
function FindTriggers(tag, global) return nil end

---
--- Example:
--- ```lua
--- function init()
--- 	local trigger = FindTrigger("toxic")
--- 	local t = GetTriggerTransform(trigger)
--- 	DebugPrint(t.pos)
--- end
--- ```
---@param handle number Trigger handle
---@return TTransform transform Current trigger transform in world space
function GetTriggerTransform(handle) return Transform() end

---
--- Example:
--- ```lua
--- function init()
--- 	local trigger = FindTrigger("toxic")
--- 	local t = Transform(Vec(0, 1, 0), QuatEuler(0, 90, 0))
--- 	SetTriggerTransform(trigger, t)
--- end
--- ```
---@param handle number Trigger handle
---@param transform TTransform Desired trigger transform in world space
function SetTriggerTransform(handle, transform) end

--- Return the lower and upper points in world space of the trigger axis aligned bounding box
---
--- Example:
--- ```lua
--- function init()
--- 	local trigger = FindTrigger("toxic")
--- 	local mi, ma = GetTriggerBounds(trigger)
--- 
--- 	local list = QueryAabbShapes(mi, ma)
--- 	for i = 1, #list do
--- 		DebugPrint(list[i])
--- 	end
--- end
--- ```
---@param handle number Trigger handle
---@return TVec min Lower point of trigger bounds in world space
---@return TVec max Upper point of trigger bounds in world space
function GetTriggerBounds(handle) return Vec(), Vec() end

--- This function will only check the center point of the body
---
--- Example:
--- ```lua
--- local trigger = 0
--- local body = 0
--- function init()
--- 	trigger = FindTrigger("toxic")
--- 	body = FindBody("body")
--- end
--- 
--- function tick()
--- 	if IsBodyInTrigger(trigger, body) then
--- 		DebugPrint("In trigger!")
--- 	end
--- end
--- ```
---@param trigger number Trigger handle
---@param body number Body handle
---@return boolean inside True if body is in trigger volume
function IsBodyInTrigger(trigger, body) return false end

--- This function will only check origo of vehicle
---
--- Example:
--- ```lua
--- local trigger = 0
--- local vehicle = 0
--- function init()
--- 	trigger = FindTrigger("toxic")
--- 	vehicle = FindVehicle("vehicle")
--- end
--- 
--- function tick()
--- 	if IsVehicleInTrigger(trigger, vehicle) then
--- 		DebugPrint("In trigger!")
--- 	end
--- end
--- ```
---@param trigger number Trigger handle
---@param vehicle number Vehicle handle
---@return boolean inside True if vehicle is in trigger volume
function IsVehicleInTrigger(trigger, vehicle) return false end

--- This function will only check the center point of the shape
---
--- Example:
--- ```lua
--- local trigger = 0
--- local shape = 0
--- function init()
--- 	trigger = FindTrigger("toxic")
--- 	shape = FindShape("shape")
--- end
--- 
--- function tick()
--- 	if IsShapeInTrigger(trigger, shape) then
--- 		DebugPrint("In trigger!")
--- 	end
--- end
--- ```
---@param trigger number Trigger handle
---@param shape number Shape handle
---@return boolean inside True if shape is in trigger volume
function IsShapeInTrigger(trigger, shape) return false end

---
--- Example:
--- ```lua
--- local trigger = 0
--- local point = {}
--- function init()
--- 	trigger = FindTrigger("toxic", true)
--- 	point = Vec(0, 0, 0)
--- end
--- 
--- function tick()
--- 	if IsPointInTrigger(trigger, point) then
--- 		DebugPrint("In trigger!")
--- 	end
--- end
--- ```
---@param trigger number Trigger handle
---@param point TVec Word space point as vector
---@return boolean inside True if point is in trigger volume
function IsPointInTrigger(trigger, point) return false end

--- Checks whether the point is within the scene boundaries.
--- If there are no boundaries on the scene, the function returns True.
---
--- Example:
--- ```lua
--- function tick()
--- 	local p = Vec(1.5, 3, 2.5)
--- 	DebugWatch("In boundaries", IsPointInBoundaries(p))
--- end
--- ```
---@param point TVec Point
---@return boolean value True if point is inside scene boundaries
function IsPointInBoundaries(point) return false end

--- This function will check if trigger is empty. If trigger contains any part of a body
--- it will return false and the highest point as second return value.
---
--- Example:
--- ```lua
--- local trigger = 0
--- function init()
--- 	trigger = FindTrigger("toxic")
--- end
--- 
--- function tick()
--- 	local empty, highPoint = IsTriggerEmpty(trigger)
--- 	if not empty then
--- 		--highPoint[2] is the tallest point in trigger
--- 		DebugPrint("Is not empty")
--- 	end
--- end
--- ```
---@param handle number Trigger handle
---@param demolision? boolean If true, small debris and vehicles are ignored
---@return boolean empty True if trigger is empty
---@return TVec maxpoint World space point of highest point (largest Y coordinate) if not empty
function IsTriggerEmpty(handle, demolision) return false, Vec() end

--- Get distance to the surface of trigger volume. Will return negative distance if inside.
---
--- Example:
--- ```lua
--- local trigger = 0
--- function init()
--- 	trigger = FindTrigger("toxic")
--- 	local p = Vec(0, 10, 0)
--- 	local dist = GetTriggerDistance(trigger, p)
--- 	DebugPrint(dist)
--- end
--- ```
---@param trigger number Trigger handle
---@param point TVec Word space point as vector
---@return number distance Positive if point is outside, negative if inside
function GetTriggerDistance(trigger, point) return 0 end

--- Return closest point in trigger volume. Will return the input point itself if inside trigger
--- or closest point on surface of trigger if outside.
---
--- Example:
--- ```lua
--- local trigger = 0
--- function init()
--- 	trigger = FindTrigger("toxic")
--- 	local p = Vec(0, 10, 0)
--- 	local closest = GetTriggerClosestPoint(trigger, p)
--- 	DebugPrint(closest)
--- end
--- ```
---@param trigger number Trigger handle
---@param point TVec Word space point as vector
---@return TVec closest Closest point in trigger as vector
function GetTriggerClosestPoint(trigger, point) return Vec() end

---
--- Example:
--- ```lua
--- function init()
--- 	local screen = FindScreen("tv")
--- 	DebugPrint(screen)
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return number handle Handle to first screen with specified tag or zero if not found
function FindScreen(tag, global) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	--Find screens tagged "tv" in script scope
--- 	local screens = FindScreens("tv")
--- 	for i=1, #screens do
--- 		local screen = screens[i]
--- 		DebugPrint(screen)
--- 	end
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return any list Indexed table with handles to all screens with specified tag
function FindScreens(tag, global) return nil end

--- Enable or disable screen
---
--- Example:
--- ```lua
--- function init()
--- 	SetScreenEnabled(FindScreen("tv"), true)
--- end
--- ```
---@param screen number Screen handle
---@param enabled boolean True if screen should be enabled
function SetScreenEnabled(screen, enabled) end

---
--- Example:
--- ```lua
--- function init()
--- 	local b = IsScreenEnabled(FindScreen("tv"))
--- 	DebugPrint(b)
--- end
--- ```
---@param screen number Screen handle
---@return boolean enabled True if screen is enabled
function IsScreenEnabled(screen) return false end

--- Return handle to the parent shape of a screen
---
--- Example:
--- ```lua
--- local screen = 0
--- function init()
--- 	screen = FindScreen("tv")
--- 	local shape = GetScreenShape(screen)
--- 	DebugPrint(shape)
--- end
--- ```
---@param screen number Screen handle
---@return number shape Shape handle or zero if none
function GetScreenShape(screen) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	local vehicle = FindVehicle("mycar")
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return number handle Handle to first vehicle with specified tag or zero if not found
function FindVehicle(tag, global) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	--Find all vehicles in level tagged "boat"
--- 	local boats = FindVehicles("boat")
--- 	for i=1, #boats do
--- 		local boat = boats[i]
--- 		DebugPrint(boat)
--- 	end
--- end
--- ```
---@param tag? string Tag name
---@param global? boolean Search in entire scene
---@return any list Indexed table with handles to all vehicles with specified tag
function FindVehicles(tag, global) return nil end

---
--- Example:
--- ```lua
--- function init()
--- 	local vehicle = FindVehicle("vehicle")
--- 	local t = GetVehicleTransform(vehicle)
--- end
--- ```
---@param vehicle number Vehicle handle
---@return TTransform transform Transform of vehicle
function GetVehicleTransform(vehicle) return Transform() end

--- Returns the exhausts transforms in local space of the vehicle.
---
--- Example:
--- ```lua
--- function tick()
--- 	local vehicle = FindVehicle("car", true)
--- 	local t = GetVehicleExhaustTransforms(vehicle)
--- 	for i = 1, #t do
--- 		DebugWatch(tostring(i), t[i])
--- 	end
--- end
--- ```
---@param vehicle number Vehicle handle
---@return any transforms Transforms of vehicle exhausts
function GetVehicleExhaustTransforms(vehicle) return nil end

--- Returns the vitals transforms in local space of the vehicle.
---
--- Example:
--- ```lua
--- function tick()
--- 	local vehicle = FindVehicle("car", true)
--- 	local t = GetVehicleVitalTransforms(vehicle)
--- 	for i = 1, #t do
--- 		DebugWatch(tostring(i), t[i])
--- 	end
--- end
--- ```
---@param vehicle number Vehicle handle
---@return any transforms Transforms of vehicle vitals
function GetVehicleVitalTransforms(vehicle) return nil end

---
--- Example:
--- ```lua
--- function tick()
--- 	local vehicle = FindVehicle("car", true)
--- 	local t = GetVehicleBodies(vehicle)
--- 	for i = 1, #t do
--- 		DebugWatch(tostring(i), t[i])
--- 	end
--- end
--- ```
---@param vehicle number Vehicle handle
---@return any transforms Vehicle bodies handles
function GetVehicleBodies(vehicle) return nil end

---
--- Example:
--- ```lua
--- function init()
--- 	local vehicle = FindVehicle("vehicle")
--- 	local body = GetVehicleBody(vehicle)
--- 	if IsBodyBroken(body) then
--- 		DebugPrint("Is broken")
--- 	end
--- end
--- ```
---@param vehicle number Vehicle handle
---@return number body Main body of vehicle
function GetVehicleBody(vehicle) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	local vehicle = FindVehicle("vehicle")
--- 	local health = GetVehicleHealth(vehicle)
--- 	DebugPrint(health)
--- end
--- ```
---@param vehicle number Vehicle handle
---@return number health Vehicle health (zero to one)
function GetVehicleHealth(vehicle) return 0 end

function SetVehicleEngineHealth(...) end

---
--- Example:
--- ```lua
--- function tick()
--- 	local params = GetVehicleParams(FindVehicle("car", true))
--- 	for key, value in pairs(params) do
--- 		DebugWatch(key, value)
--- 	end
--- end
--- ```
---@param vehicle number Vehicle handle
---@return any params Vehicle params
function GetVehicleParams(vehicle) return nil end

--- Available parameters: spring, damping, topspeed, acceleration, strength, antispin, antiroll, difflock, steerassist, friction
---
--- Example:
--- ```lua
--- function init()
--- 	SetVehicleParam(FindVehicle("car", true), "topspeed", 200)
--- end
--- ```
---@param handle number Vehicle handler
---@param param string Param name
---@param value number Param value
function SetVehicleParam(handle, param, value) end

---
--- Example:
--- ```lua
--- function init()
--- 	local vehicle = FindVehicle("vehicle")
--- 	local driverPos = GetVehicleDriverPos(vehicle)
--- 	local t = GetVehicleTransform(vehicle)
--- 	local worldPos = TransformToParentPoint(t, driverPos)
--- 	DebugPrint(worldPos)
--- end
--- ```
---@param vehicle number Vehicle handle
---@return TVec pos Driver position as vector in vehicle space
function GetVehicleDriverPos(vehicle) return Vec() end

function GetVehicleLocationWorldTransform(...) end

---
--- Example:
--- ```lua
--- local steering = GetVehicleSteering(vehicle)
--- ```
---@param vehicle number Vehicle handle
---@return number steering Driver steering value -1 to 1
function GetVehicleSteering(vehicle) return 0 end

---
--- Example:
--- ```lua
--- local drive = GetVehicleDrive(vehicle)
--- ```
---@param vehicle number Vehicle handle
---@return number drive Driver drive value -1 to 1
function GetVehicleDrive(vehicle) return 0 end

--- This function applies input to vehicles, allowing for autonomous driving. The vehicle
--- will be turned on automatically and turned off when no longer called. Call this from
--- the tick function, not update.
---
--- Example:
--- ```lua
--- function tick()
--- 	--Drive mycar forwards
--- 	local v = FindVehicle("mycar")
--- 	DriveVehicle(v, 1, 0, false)
--- end
--- ```
---@param vehicle number Vehicle handle
---@param drive number Reverse/forward control -1 to 1
---@param steering number Left/right control -1 to 1
---@param handbrake boolean Handbrake control
function DriveVehicle(vehicle, drive, steering, handbrake) end

--- Return center point of player. This function is deprecated.
--- Use GetPlayerTransform instead.
---
--- Example:
--- ```lua
--- function init()
--- 	local p = GetPlayerPos()
--- 	DebugPrint(p)
--- 
--- 	--This is equivalent to
--- 	p = VecAdd(GetPlayerTransform().pos, Vec(0,1,0))
--- 	DebugPrint(p)
--- end
--- ```
---@return TVec position Player center position
function GetPlayerPos() return Vec() end

function DisableCrouch(...) end

---
--- Example:
--- ```lua
--- local muzzle = GetToolLocationWorldTransform("muzzle")
--- local _, pos, _, dir = GetPlayerAimInfo(muzzle.pos)
--- Shoot(pos, dir)
--- ```
---@param position TVec Start position of the search
---@param maxdist? number Max search distance
---@return boolean hit TRUE if hit, FALSE otherwise.
---@return TVec startpos Player can modify start position when close to walls etc
---@return TVec endpos Hit position
---@return TVec direction Direction from start position to end position
---@return TVec hitnormal Normal of the hitpoint
---@return number hitdist Distance of the hit
---@return any hitentity Handle of the entitiy being hit
---@return any hitmaterial Name of the material being hit
function GetPlayerAimInfo(position, maxdist) return false, Vec(), Vec(), Vec(), Vec(), 0, nil, nil end

function GetPlayerToolRecoil(...) end

--- The player pitch angle is applied to the player camera transform. This value can be used to animate tool pitch movement when using SetToolTransformOverride.
---
--- Example:
--- ```lua
--- function init()
--- 	local pitchRotation = Quat(Vec(1,0,0), GetPlayerPitch())
--- end
--- ```
---@return number pitch Current player pitch angle
function GetPlayerPitch() return 0 end

--- The player yaw angle is applied to the player camera transform. It represents the top-down angle of rotation of the player.
---
--- Example:
--- ```lua
--- function init()
--- 	local compassBearing = GetPlayerYaw()
--- end
--- ```
---@return number yaw Current player yaw angle
function GetPlayerYaw() return 0 end

--- Sets the player pitch.
---
--- Example:
--- ```lua
--- function tick()
--- 	-- look straight ahead
--- 	SetPlayerPitch(0.0)
--- end
--- ```
---@param pitch number Pitch.
function SetPlayerPitch(pitch) end

---
--- Example:
--- ```lua
--- function tick()
---     local crouch = GetPlayerCrouch()
---     if crouch > 0.0 then
---         ...
---     end
--- end
--- ```
---@return number recoil Current player crouch
function GetPlayerCrouch() return 0 end

--- The player transform is located at the bottom of the player. The player transform
--- considers heading (looking left and right). Forward is along negative Z axis.
--- Player pitch (looking up and down) does not affect player transform unless includePitch
--- is set to true. If you want the transform of the eye, use GetPlayerCameraTransform() instead.
---
--- Example:
--- ```lua
--- function init()
--- 	local t = GetPlayerTransform()
--- 	DebugPrint(TransformStr(t))
--- end
--- ```
---@param includePitch? boolean Include the player pitch (look up/down) in transform
---@return TTransform transform Current player transform
function GetPlayerTransform(includePitch) return Transform() end

--- Instantly teleport the player to desired transform. Unless includePitch is
--- set to true, up/down look angle will be set to zero during this process.
--- Player velocity will be reset to zero.
---
--- Example:
--- ```lua
--- function tick()
--- 	if InputPressed("jump") then
--- 		local t = Transform(Vec(50, 0, 0), QuatEuler(0, 90, 0))
--- 		SetPlayerTransform(t)
--- 	end
--- end
--- ```
---@param transform TTransform Desired player transform
---@param includePitch? boolean Set player pitch (look up/down) as well
function SetPlayerTransform(transform, includePitch) end

---
--- Example:
--- ```lua
---     --Clear specific rig
---     ClearPlayerRig(someId)
--- 
---     --Clear all rigs
---     ClearPlayerRig(-1)
--- ```
---@param rig-id number Unique rig-id, -1 means all rigs
function ClearPlayerRig(rig_id) end

---
--- Example:
--- ```lua
---     local someBody = FindBody("bodyname")
---     SetPlayerRigLocationLocalTransform(someBody, "ik_foot_l", TransformToLocalTransform(GetBodyTransform(someBody), GetLocationTransform(FindLocation("ik_foot_l"))))
--- ```
---@param rig-id number Unique id
---@param name string Name of location
---@param location any Rig Local transform of the location
function SetPlayerRigLocationLocalTransform(rig_id, name, location) end

--- This will both update the rig identified by the 'id' and make it active
---
--- Example:
--- ```lua
---     local someBody = FindBody("bodyname")
---     SetPlayerRigTransform(someBody, GetBodyTransform(someBody))
--- ```
---@param rig-id number Unique id
---@param location any New world transform
function SetPlayerRigTransform(rig_id, location) end

---@return any location Transform of the current active player-rig, nil otherwise
function GetPlayerRigTransform() return nil end

---
--- Example:
--- ```lua
--- local t = GetPlayerRigLocationWorldTransform("ik_hand_l")
--- ```
---@param name string Name of location
---@return any location Transform of a location in world space
function GetPlayerRigLocationWorldTransform(name) return nil end

---@param tag string Tag name
---@param value? string Tag value
function SetPlayerRigTags(tag, value) end

---@param tag string Tag name
---@return boolean exists Returns true if entity has tag
function GetPlayerRigHasTag(tag) return false end

---@param tag string Tag name
---@return string value Returns the tag value, if any. Empty string otherwise.
function GetPlayerRigTagValue(tag) return "" end

--- Make the ground act as a conveyor belt, pushing the player even if ground shape is static.
---
--- Example:
--- ```lua
--- function tick()
--- 	SetPlayerGroundVelocity(Vec(2,0,0))
--- end
--- ```
---@param vel TVec Desired ground velocity
function SetPlayerGroundVelocity(vel) end

--- The player eye transform is the same as what you get from GetCameraTransform when playing in first-person,
--- but if you have set a camera transform manually with SetCameraTransform or playing in third-person, you can retrieve
--- the player eye transform with this function.
---
--- Example:
--- ```lua
--- function init()
--- 	local t = GetPlayerEyeTransform()
--- 	DebugPrint(TransformStr(t))
--- end
--- ```
---@return TTransform transform Current player eye transform
function GetPlayerEyeTransform() return Transform() end

--- The player camera transform is usually the same as what you get from GetCameraTransform,
--- but if you have set a camera transform manually with SetCameraTransform, you can retrieve
--- the standard player camera transform with this function.
---
--- Example:
--- ```lua
--- function init()
--- 	local t = GetPlayerCameraTransform()
--- 	DebugPrint(TransformStr(t))
--- end
--- ```
---@return TTransform transform Current player camera transform
function GetPlayerCameraTransform() return Transform() end

--- Call this function continously to apply a camera offset. Can be used for camera effects
--- such as shake and wobble.
---
--- Example:
--- ```lua
--- function tick()
--- 	local t = Transform(Vec(), QuatAxisAngle(Vec(1, 0, 0), math.sin(GetTime()*3.0) * 3.0))
--- 	SetPlayerCameraOffsetTransform(t)
--- end
--- ```
---@param transform TTransform Desired player camera offset transform
---@param stackable? boolean True if eye offset should summ up with multiple calls per tick
function SetPlayerCameraOffsetTransform(transform, stackable) end

--- Call this function during init to alter the player spawn transform.
---
--- Example:
--- ```lua
--- function init()
--- 	local t = Transform(Vec(10, 0, 0), QuatEuler(0, 90, 0))
--- 	SetPlayerSpawnTransform(t)
--- end
--- ```
---@param transform TTransform Desired player spawn transform
function SetPlayerSpawnTransform(transform) end

--- Call this function during init to alter the player spawn health amount.
---
--- Example:
--- ```lua
--- function init()
--- 	SetPlayerSpawnHealth(0.5)
--- end
--- ```
---@param health number Desired player spawn health (between zero and one)
function SetPlayerSpawnHealth(health) end

--- Call this function during init to alter the player spawn active tool.
---
--- Example:
--- ```lua
--- function init()
--- 	SetPlayerSpawnTool("pistol")
--- end
--- ```
---@param id string Tool unique identifier
function SetPlayerSpawnTool(id) end

---
--- Example:
--- ```lua
--- function tick()
--- 	local vel = GetPlayerVelocity()
--- 	DebugPrint(VecStr(vel))
--- end
--- ```
---@return TVec velocity Player velocity in world space as vector
function GetPlayerVelocity() return Vec() end

--- Drive specified vehicle.
---
--- Example:
--- ```lua
--- function tick()
--- 	if InputPressed("interact") then
--- 		local car = FindVehicle("mycar")
--- 		SetPlayerVehicle(car)
--- 	end
--- end
--- ```
---@param vehicle number Handle to vehicle or zero to not drive.
function SetPlayerVehicle(vehicle) end

---@param animator number Handle to animator or zero for no animator
function SetPlayerAnimator(animator) end

---@return number animator Handle to animator or zero for no animator
function GetPlayerAnimator() return 0 end

---
--- Example:
--- ```lua
--- function tick()
--- 	if InputPressed("jump") then
--- 		SetPlayerVelocity(Vec(0, 5, 0))
--- 	end
--- end
--- ```
---@param velocity TVec Player velocity in world space as vector
function SetPlayerVelocity(velocity) end

---
--- Example:
--- ```lua
--- function tick()
--- 	local vehicle = GetPlayerVehicle()
--- 	if vehicle ~= 0 then
--- 		DebugPrint("Player drives the vehicle")
--- 	end
--- end
--- ```
---@return number handle Current vehicle handle, or zero if not in vehicle
function GetPlayerVehicle() return 0 end

---
--- Example:
--- ```lua
--- local isGrounded = IsPlayerGrounded()
--- ```
---@return boolean isGrounded Whether the player is grounded
function IsPlayerGrounded() return false end

function IsPlayerJumping(...) end

--- 
--- Get information about player ground contact. If the output boolean (contact) is false then
--- the rest of the output is invalid.
--- 
---
--- Example:
--- ```lua
--- function tick()
--- 	hasGroundContact, shape, point, normal = GetPlayerGroundContact()
--- 
--- 	if hasGroundContact then
--- 		-- print ground contact data
--- 		DebugPrint(VecStr(point).." : "..VecStr(normal))
--- 	end
--- end
--- ```
---@return boolean contact Whether the player is grounded
---@return number shape Handle to shape
---@return any point Point of contact
---@return any normal Normal of contact
function GetPlayerGroundContact() return false, 0, nil, nil end

---
--- Example:
--- ```lua
--- function tick()
--- 	local shape = GetPlayerGrabShape()
--- 	if shape ~= 0 then
--- 		DebugPrint("Player is grabbing a shape")
--- 	end
--- end
--- ```
---@return number handle Handle to grabbed shape or zero if not grabbing.
function GetPlayerGrabShape() return 0 end

---
--- Example:
--- ```lua
--- function tick()
--- 	local body = GetPlayerGrabBody()
--- 	if body ~= 0 then
--- 		DebugPrint("Player is grabbing a body")
--- 	end
--- end
--- ```
---@return number handle Handle to grabbed body or zero if not grabbing.
function GetPlayerGrabBody() return 0 end

--- Release what the player is currently holding
---
--- Example:
--- ```lua
--- function tick()
--- 	if InputPressed("jump") then
--- 		ReleasePlayerGrab()
--- 	end
--- end
--- ```
function ReleasePlayerGrab() end

---
--- Example:
--- ```lua
--- local body = GetPlayerGrabBody()
--- if body ~= 0 then
--- 	local pos = GetPlayerGrabPoint()
--- end
--- ```
---@return TVec pos The world space grab point.
function GetPlayerGrabPoint() return Vec() end

---
--- Example:
--- ```lua
--- function tick()
--- 	local shape = GetPlayerPickShape()
--- 	if shape ~= 0 then
--- 		DebugPrint("Picked shape " .. shape)
--- 	end
--- end
--- ```
---@return number handle Handle to picked shape or zero if nothing is picked
function GetPlayerPickShape() return 0 end

---
--- Example:
--- ```lua
--- function tick()
--- 	local body = GetPlayerPickBody()
--- 	if body ~= 0 then
--- 		DebugWatch("Pick body ", body)
--- 	end
--- end
--- ```
---@return number handle Handle to picked body or zero if nothing is picked
function GetPlayerPickBody() return 0 end

--- Interactable shapes has to be tagged with "interact". The engine
--- determines which interactable shape is currently interactable.
---
--- Example:
--- ```lua
--- function tick()
--- 	local shape = GetPlayerInteractShape()
--- 	if shape ~= 0 then
--- 		DebugPrint("Interact shape " .. shape)
--- 	end
--- end
--- ```
---@return number handle Handle to interactable shape or zero
function GetPlayerInteractShape() return 0 end

--- Interactable shapes has to be tagged with "interact". The engine
--- determines which interactable body is currently interactable.
---
--- Example:
--- ```lua
--- function tick()
--- 	local body = GetPlayerInteractBody()
--- 	if body ~= 0 then
--- 		DebugPrint("Interact body " .. body)
--- 	end
--- end
--- ```
---@return number handle Handle to interactable body or zero
function GetPlayerInteractBody() return 0 end

--- Set the screen the player should interact with. For the screen
--- to feature a mouse pointer and receieve input, the screen also
--- needs to have interactive property.
---
--- Example:
--- ```lua
--- function tick()
--- 	if InputPressed("interact") then
--- 		if GetPlayerScreen() ~= 0 then
--- 			SetPlayerScreen(0)
--- 		else
--- 			SetPlayerScreen(screen)
--- 		end
--- 
--- 	end
--- end
--- ```
---@param handle number Handle to screen or zero for no screen
function SetPlayerScreen(handle) end

---
--- Example:
--- ```lua
--- function tick()
--- 	if InputPressed("interact") then
--- 		if GetPlayerScreen() ~= 0 then
--- 			SetPlayerScreen(0)
--- 		else
--- 			SetPlayerScreen(screen)
--- 		end
--- 
--- 	end
--- end
--- ```
---@return number handle Handle to interacted screen or zero if none
function GetPlayerScreen() return 0 end

---
--- Example:
--- ```lua
--- function tick()
--- 	if InputPressed("interact") then
--- 		if GetPlayerHealth() < 0.75 then
--- 			SetPlayerHealth(1.0)
--- 		else
--- 			SetPlayerHealth(0.5)
--- 		end
--- 	end
--- end
--- ```
---@param health number Set player health (between zero and one)
function SetPlayerHealth(health) end

---
--- Example:
--- ```lua
--- function tick()
--- 	if InputPressed("interact") then
--- 		if GetPlayerHealth() < 0.75 then
--- 			SetPlayerHealth(1.0)
--- 		else
--- 			SetPlayerHealth(0.5)
--- 		end
--- 	end
--- end
--- ```
---@return number health Current player health
function GetPlayerHealth() return 0 end

--- Enable or disable regeneration for player
---
--- Example:
--- ```lua
--- function init()
--- 	-- disable regeneration for player
--- 	SetPlayerRegenerationState(false)
--- end
--- ```
---@param state boolean State of player regeneration
function SetPlayerRegenerationState(state) end

--- Respawn player at spawn position without modifying the scene
---
--- Example:
--- ```lua
--- function tick()
--- 	if InputPressed("interact") then
--- 		RespawnPlayer()
--- 	end
--- end
--- ```
function RespawnPlayer() end

--- This function gets base speed, but real player speed depends on many
--- factors such as health, crouch, water, grabbing objects.
---
--- Example:
--- ```lua
--- function tick()
--- 	DebugPrint(GetPlayerWalkingSpeed())
--- end
--- ```
---@return number speed Current player base walking speed
function GetPlayerWalkingSpeed() return 0 end

--- This function sets base speed, but real player speed depends on many
--- factors such as health, crouch, water, grabbing objects.
---
--- Example:
--- ```lua
--- function tick()
--- 	if InputDown("shift") then
--- 		SetPlayerWalkingSpeed(15.0)
--- 	else
--- 		SetPlayerWalkingSpeed(7.0)
--- 	end
--- end
--- ```
---@param speed number Set player base walking speed
function SetPlayerWalkingSpeed(speed) end

--- BEGINTABLE Param name	-- Type				-- Description
--- health					-- float			-- Current value of the player's health.
--- healthRegeneration  	-- boolean &nbsp	-- Is the player's health regeneration enabled.
--- walkingSpeed			-- float			-- The player's walking speed.
--- jumpSpeed				-- float			-- The player's jump speed.
--- godMode					-- boolean &nbsp	-- If the value is True, the player does not lose health
--- friction				-- float			-- Player body friction
--- frictionMode			-- string			-- Player friction combine mode
--- flyMode					-- boolean &nbsp	-- If the value is True, the player will fly
--- ENDTABLE
---
--- Example:
--- ```lua
--- function tick()
--- 	-- The parameter names are case-insensitive, so any of the specified writing styles will be correct:
--- 	-- "GodMode", "godmode", "godMode"
--- 	local paramName = "GodMode"
--- 	local param = GetPlayerParam(paramName)
--- 	DebugWatch(paramName, param)
--- 
--- 	if InputPressed("g") then
--- 		SetPlayerParam(paramName, not param)
--- 	end
--- end
--- ```
---@param parameter string Parameter name
---@return any value Parameter value
function GetPlayerParam(parameter) return nil end

--- BEGINTABLE Param name	-- Type				-- Description
--- health					-- float			-- Current value of the player's health.
--- healthRegeneration  	-- boolean &nbsp	-- Is the player's health regeneration enabled.
--- walkingSpeed			-- float			-- The player's walking speed. <b> This value is applied for 1 frame! </b>
--- jumpSpeed				-- float			-- The player's jump speed. The height of the jump depends non-linearly on the jump speed. <b> This value is applied for 1 frame! </b>
--- godMode					-- boolean &nbsp	-- If the value is True, the player does not lose health
--- friction				-- float			-- Player body friction. Default is 0.8
--- frictionMode			-- string			-- Player friction combine mode. Can be (average|minimum|multiply|maximum)
--- flyMode					-- boolean &nbsp	-- If the value is True, the player will fly
--- ENDTABLE
---
--- Example:
--- ```lua
--- function tick()
--- 	-- The parameter names are case-insensitive, so any of the specified writing styles will be correct:
--- 	-- "JumpSpeed", "jumpspeed", "jumpSpeed"
--- 	local paramName = "JumpSpeed"
--- 	local param = GetPlayerParam(paramName)
--- 	DebugWatch(paramName, param)
--- 
--- 	if InputDown("shift") then
--- 		-- JumpSpeed sets for 1 frame
--- 		SetPlayerParam(paramName, 10)
--- 	end
--- end
--- ```
---@param parameter string Parameter name
---@param value any Parameter value
function SetPlayerParam(parameter, value) end

--- 
--- Use this function to hide the player character.
--- 
---
--- Example:
--- ```lua
--- 
--- function tick()
--- 	...
--- 	SetCameraTransform(t)
--- 	SetPlayerHidden()
--- end
--- ```
function SetPlayerHidden() end

--- Register a custom tool that will show up in the player inventory and
--- can be selected with scroll wheel. Do this only once per tool.
--- You also need to enable the tool in the registry before it can be used.
---
--- Example:
--- ```lua
--- function init()
--- 	RegisterTool("lasergun", "Laser Gun", "MOD/vox/lasergun.vox")
--- 	SetBool("game.tool.lasergun.enabled", true)
--- end
--- 
--- function tick()
--- 	if GetString("game.player.tool") == "lasergun" then
--- 		--Tool is selected. Tool logic goes here.
--- 	end
--- end
--- ```
---@param id string Tool unique identifier
---@param name string Tool name to show in hud
---@param file string Path to vox file or prefab xml
---@param group? number Tool group for this tool (1-6) Default is 6.
function RegisterTool(id, name, file, group) end

--- Return body handle of the visible tool. You can use this to retrieve tool shapes
--- and animate them, change emissiveness, etc. Do not attempt to set the tool body
--- transform, since it is controlled by the engine. Use SetToolTranform for that.
---
--- Example:
--- ```lua
--- function tick()
--- 	local toolBody = GetToolBody()
--- 	if toolBody~=0 then
--- 		DebugPrint("Tool body: " .. toolBody)
--- 	end
--- end
--- ```
---@return number handle Handle to currently visible tool body or zero if none
function GetToolBody() return 0 end

---
--- Example:
--- ```lua
--- local right, left = GetToolHandPoseLocalTransform()
--- ```
---@return TTransform right Transform of right hand relative to the tool body origin, or nil if the right hand is not used
---@return TTransform left Transform of left hand, or nil if left hand is not used
function GetToolHandPoseLocalTransform() return Transform(), Transform() end

---
--- Example:
--- ```lua
--- local right, left = GetToolHandPoseWorldTransform()
--- ```
---@return TTransform right Transform of right hand in world space, or nil if the right hand is not used
---@return TTransform left Transform of left hand, or nil if left hand is not used
function GetToolHandPoseWorldTransform() return Transform(), Transform() end

--- Use this function to position the character's hands on the currently equipped tool. This function must be called every frame from the tick function.
--- In third-person view, failing to call this function can lead to different outcomes depending on how the tool is animated:
--- <ul>
--- <li>If the tool's transform is not explicitly set or is set using SetToolTransform, not calling this function will trigger a fallback solution where the right hand is automatically positioned.</li>
--- <li>If the tool is animated using the SetToolTransformOverride function, not calling this function will result in the character's animation taking control of the hand movement</li>
--- </ul>
--- 
---
--- Example:
--- ```lua
--- if GetBool("game.thirdperson") then
--- 	if aiming then
--- 		SetToolHandPoseLocalTransform(Transform(Vec(0.2,0.0,0.0), QuatAxisAngle(Vec(0,1,0), 90.0)), Transform(Vec(-0.1, 0.0, -0.4)))
--- 	else
--- 		SetToolHandPoseLocalTransform(Transform(Vec(0.2,0.0,0.0), QuatAxisAngle(Vec(0,1,0), 90.0)), nil)
--- 	end
--- end
--- ```
---@param right TTransform Transform of right hand relative to the tool body origin, or nil if right hand is not used
---@param left TTransform Transform of left hand, or nil if left hand is not used
function SetToolHandPoseLocalTransform(right, left) end

--- Return transform of a tool location in tool space. Locations can be defined using the tool prefab editor.
---
--- Example:
--- ```lua
--- local right  = GetToolLocationLocalTransform("righthand")
--- SetToolHandPoseLocalTransform(right, nil)
--- ```
---@param name string Name of location
---@return TTransform location Transform of a tool location in tool space or nil if location is not found.
function GetToolLocationLocalTransform(name) return Transform() end

--- Return transform of a tool location in world space. Locations can be defined using the tool prefab editor. A tool location is defined in tool space and to get the world space transform a tool body is required.
--- If a tool body does not exist this function will return nil.
---
--- Example:
--- ```lua
--- local muzzle = GetToolLocationWorldTransform("muzzle")
--- Shoot(muzzle, direction)
--- ```
---@param name string Name of location
---@return TTransform location Transform of a tool location in world space or nil if the location is not found or if there is no visible tool body.
function GetToolLocationWorldTransform(name) return Transform() end

--- Apply an additional transform on the visible tool body. This can be used to
--- create tool animations. You need to set this every frame from the tick function.
--- The optional sway parameter control the amount of tool swaying when walking.
--- Set to zero to disable completely.
---
--- Example:
--- ```lua
--- function init()
--- 	--Offset the tool half a meter to the right
--- 	local offset = Transform(Vec(0.5, 0, 0))
--- 	SetToolTransform(offset)
--- end
--- ```
---@param transform TTransform Tool body transform
---@param sway? number Tool sway amount. Default is 1.0.
function SetToolTransform(transform, sway) end

--- Set the allowed zoom for a registered tool. The zoom sensitivity will be factored
--- with the user options for sensitivity.
---
--- Example:
--- ```lua
--- function tick()
--- 	-- allow our scoped tool to zoom by factor 4.
--- 	SetToolAllowedZoom(4.0, 0.5)
--- end
--- ```
---@param zoom number Zoom factor
---@param [zoom any (number) Input sensitivity when zoomed in. Default is 1.0.
function SetToolAllowedZoom(zoom, _zoom) end

--- This function serves as an alternative to SetToolTransform, providing full control over tool animation by disabling all internal tool animations.
--- When using this function, you must manually include pitch, sway, and crouch movements in the transform. To maintain this control, call the function every frame from the tick function.
--- 
---
--- Example:
--- ```lua
--- function init()
--- 
--- 	if GetBool("game.thirdperson") then
--- 		local toolTransform = Transform(Vec(0.3, -0.3, -0.2), Quat(0.0, 0.0, 15.0))
--- 
--- 		-- Rotate around point
--- 		local pivotPoint = Vec(-0.01, -0.2, 0.04)
--- 		toolTransform.pos = VecSub(toolTransform.pos, pivotPoint)
--- 		local rotation = Transform(Vec(), QuatAxisAngle(Vec(0,0,1), GetPlayerPitch()))
--- 		toolTransform = TransformToParentTransform(rotation, toolTransform)
--- 		toolTransform.pos = VecAdd(toolTransform.pos, pivotPoint)
--- 
--- 		SetToolTransformOverride(toolTransform)
--- 	else
--- 		local toolTransform = Transform(Vec(0.3, -0.3, -0.2), Quat(0.0, 0.0, 15.0))
--- 		SetToolTransform(toolTransform)
--- 	end
--- end
--- ```
---@param transform TTransform Tool body transform
function SetToolTransformOverride(transform) end

--- Apply an additional offset on the visible tool body. This can be used to
--- tweak tool placement for different characters. You need to set this every frame from the tick function.
---
--- Example:
--- ```lua
--- function tick()
--- 	--Offset the tool depending on character height
--- 	local defaultEyeY = 1.7
--- 	local offsetY = characterHeight - defaultEyeY
--- 	local offset = Vec(0, offsetY, 0)
--- 	SetToolOffset(offset)
--- end
--- ```
---@param offset TVec Tool body offset
function SetToolOffset(offset) end

---
--- Example:
--- ```lua
--- function init()
--- 	local snd = LoadSound("warning-beep.ogg")
--- end
--- ```
---@param path string Path to ogg sound file
---@param nominalDistance? number The distance in meters this sound is recorded at. Affects attenuation, default is 10.0
---@return number handle Sound handle
function LoadSound(path, nominalDistance) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	local snd = LoadSound("warning-beep.ogg")
--- 	UnloadSound(snd)
--- end
--- ```
---@param handle number Sound handle
function UnloadSound(handle) end

---
--- Example:
--- ```lua
--- local loop
--- function init()
--- 	loop = LoadLoop("radio/jazz.ogg")
--- end
--- 
--- function tick()
--- 	local pos = Vec(0, 0, 0)
--- 	PlayLoop(loop, pos, 1.0)
--- end
--- ```
---@param path string Path to ogg sound file
---@param nominalDistance? number The distance in meters this sound is recorded at. Affects attenuation, default is 10.0
---@return number handle Loop handle
function LoadLoop(path, nominalDistance) return 0 end

---
--- Example:
--- ```lua
--- local loop = -1
--- function init()
--- 	loop = LoadLoop("radio/jazz.ogg")
--- end
--- 
--- function tick()
--- 	if loop ~= -1 then
--- 		local pos = Vec(0, 0, 0)
--- 		PlayLoop(loop, pos, 1.0)
--- 	end
--- 
--- 	if InputPressed("space") then
--- 		UnloadLoop(loop)
--- 		loop = -1
--- 	end
--- end
--- ```
---@param handle number Loop handle
function UnloadLoop(handle) end

---
--- Example:
--- ```lua
--- function init()
--- 	local loop = LoadLoop("radio/jazz.ogg")
--- 	SetSoundLoopUser(loop, 0)
--- end
--- --This function will move (if possible) sound to gamepad of appropriate user
--- ```
---@param handle number Loop handle
---@param nominalDistance number User index
---@return boolean flag TRUE if sound applied to gamepad speaker, FALSE otherwise.
function SetSoundLoopUser(handle, nominalDistance) return false end

---
--- Example:
--- ```lua
--- local snd
--- function init()
--- 	snd = LoadSound("warning-beep.ogg")
--- end
--- 
--- function tick()
--- 	if InputPressed("interact") then
--- 		local pos = Vec(0, 0, 0)
--- 		PlaySound(snd, pos, 0.5)
--- 	end
--- end
--- 
--- -- If you have a list of sound files and you add a sequence number, starting from zero, at the end of each filename like below,
--- -- then each time you call PlaySound it will pick a random sound from that list and play that sound.
--- 
--- -- "example-sound0.ogg"
--- -- "example-sound1.ogg"
--- -- "example-sound2.ogg"
--- -- "example-sound3.ogg"
--- -- ...
--- --[[
--- 	local snd
--- 	function init()
--- 		snd = LoadSound("example-sound0.ogg")
--- 	end
--- 
--- 	-- Plays a random sound from the loaded sound series
--- 	function tick()
--- 		if trigSound then
--- 			local pos = Vec(100, 0, 0)
--- 			PlaySound(snd, pos, 0.5)
--- 		end
--- 	end
--- ]]
--- ```
---@param handle number Sound handle
---@param pos? TVec World position as vector. Default is player position.
---@param volume? number Playback volume. Default is 1.0
---@param registerVolume? boolean Register position and volume of this sound for GetLastSound. Default is true
---@param pitch? number Playback pitch. Default 1.0
---@return number handle Sound play handle
function PlaySound(handle, pos, volume, registerVolume, pitch) return 0 end

---
--- Example:
--- ```lua
--- local snd
--- function init()
--- 	snd = LoadSound("warning-beep.ogg")
--- end
--- 
--- function tick()
--- 	if InputPressed("interact") then
--- 		PlaySoundForUser(snd, 0)
--- 	end
--- end
--- 
--- -- If you have a list of sound files and you add a sequence number, starting from zero, at the end of each filename like below,
--- -- then each time you call PlaySoundForUser it will pick a random sound from that list and play that sound.
--- 
--- -- "example-sound0.ogg"
--- -- "example-sound1.ogg"
--- -- "example-sound2.ogg"
--- -- "example-sound3.ogg"
--- -- ...
--- 
--- --[[
--- 	local snd
--- 	function init()
--- 		snd = LoadSound("example-sound0.ogg")
--- 	end
--- 
--- 	-- Plays a random sound from the loaded sound series
--- 	function tick()
--- 		if trigSound then
--- 			local pos = Vec(100, 0, 0)
--- 			PlaySoundForUser(snd, 0, pos, 0.5)
--- 		end
--- 	end
--- ]]
--- ```
---@param handle number Sound handle
---@param user number Index of user to play.
---@param pos? TVec World position as vector. Default is player position.
---@param volume? number Playback volume. Default is 1.0
---@param registerVolume? boolean Register position and volume of this sound for GetLastSound. Default is true
---@param pitch? number Playback pitch. Default 1.0
---@return number handle Sound play handle
function PlaySoundForUser(handle, user, pos, volume, registerVolume, pitch) return 0 end

---
--- Example:
--- ```lua
--- local snd
--- function init()
--- 	snd = LoadSound("radio/jazz.ogg")
--- end
--- 
--- local sndPlay
--- function tick()
--- 	if InputPressed("interact") then
--- 		if not IsSoundPlaying(sndPlay) then
--- 			local pos = Vec(0, 0, 0)
--- 			sndPlay = PlaySound(snd, pos, 0.5)
--- 		else
--- 			StopSound(sndPlay)
--- 		end
--- 	end
--- end
--- ```
---@param handle number Sound play handle
function StopSound(handle) end

---
--- Example:
--- ```lua
--- local snd
--- function init()
--- 	snd = LoadSound("radio/jazz.ogg")
--- end
--- 
--- local sndPlay
--- function tick()
--- 	if InputPressed("interact") then
--- 		if not IsSoundPlaying(sndPlay) then
--- 			local pos = Vec(0, 0, 0)
--- 			sndPlay = PlaySound(snd, pos, 0.5)
--- 		else
--- 			StopSound(sndPlay)
--- 		end
--- 	end
--- end
--- ```
---@param handle number Sound play handle
---@return boolean playing True if sound is playing, false otherwise.
function IsSoundPlaying(handle) return false end

---
--- Example:
--- ```lua
--- local snd
--- function init()
--- 	snd = LoadSound("radio/jazz.ogg")
--- end
--- 
--- local sndPlay
--- function tick()
--- 	if InputPressed("interact") then
--- 		if not IsSoundPlaying(sndPlay) then
--- 			local pos = Vec(0, 0, 0)
--- 			sndPlay = PlaySound(snd, pos, 0.5)
--- 		else
--- 			SetSoundProgress(sndPlay, GetSoundProgress(sndPlay) - 1.0)
--- 		end
--- 	end
--- end
--- ```
---@param handle number Sound play handle
---@return number progress Current sound progress in seconds.
function GetSoundProgress(handle) return 0 end

---
--- Example:
--- ```lua
--- local snd
--- function init()
--- 	snd = LoadSound("radio/jazz.ogg")
--- end
--- 
--- local sndPlay
--- function tick()
--- 	if InputPressed("interact") then
--- 		if not IsSoundPlaying(sndPlay) then
--- 			local pos = Vec(0, 0, 0)
--- 			sndPlay = PlaySound(snd, pos, 0.5)
--- 		else
--- 			SetSoundProgress(sndPlay, GetSoundProgress(sndPlay) - 1.0)
--- 		end
--- 	end
--- end
--- ```
---@param handle number Sound play handle
---@param progress number Progress in seconds
function SetSoundProgress(handle, progress) end

--- Call this function continuously to play loop
---
--- Example:
--- ```lua
--- local loop
--- function init()
--- 	loop = LoadLoop("radio/jazz.ogg")
--- end
--- 
--- function tick()
--- 	local pos = Vec(0, 0, 0)
--- 	PlayLoop(loop, pos, 1.0)
--- end
--- ```
---@param handle number Loop handle
---@param pos? TVec World position as vector. Default is player position.
---@param volume? number Playback volume. Default is 1.0
---@param registerVolume? boolean Register position and volume of this sound for GetLastSound. Default is true
---@param pitch? number Playback pitch. Default 1.0
function PlayLoop(handle, pos, volume, registerVolume, pitch) end

---
--- Example:
--- ```lua
--- function init()
--- 	loop = LoadLoop("radio/jazz.ogg")
--- end
--- 
--- function tick()
--- 	local pos = Vec(0, 0, 0)
--- 	PlayLoop(loop, pos, 1.0)
--- 	if InputPressed("interact") then
--- 		SetSoundLoopProgress(loop, GetSoundLoopProgress(loop) - 1.0)
--- 	end
--- end
--- ```
---@param handle number Loop handle
---@return number progress Current music progress in seconds.
function GetSoundLoopProgress(handle) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	loop = LoadLoop("radio/jazz.ogg")
--- end
--- 
--- function tick()
--- 	local pos = Vec(0, 0, 0)
--- 	PlayLoop(loop, pos, 1.0)
--- 	if InputPressed("interact") then
--- 		SetSoundLoopProgress(loop, GetSoundLoopProgress(loop) - 1.0)
--- 	end
--- end
--- ```
---@param handle number Loop handle
---@param progress? number Progress in seconds. Default 0.0.
function SetSoundLoopProgress(handle, progress) end

---
--- Example:
--- ```lua
--- function init()
--- 	PlayMusic("about.ogg")
--- end
--- ```
---@param path string Music path
function PlayMusic(path) end

---
--- Example:
--- ```lua
--- function init()
--- 	PlayMusic("about.ogg")
--- end
--- 
--- function tick()
--- 	if InputDown("interact") then
--- 		StopMusic()
--- 	end
--- end
--- ```
function StopMusic() end

---
--- Example:
--- ```lua
--- function init()
--- 	PlayMusic("about.ogg")
--- end
--- 
--- function tick()
--- 	if InputPressed("interact") and IsMusicPlaying() then
--- 		DebugPrint("music is playing")
--- 	end
--- end
--- ```
---@return boolean playing True if music is playing, false otherwise.
function IsMusicPlaying() return false end

---
--- Example:
--- ```lua
--- function init()
--- 	PlayMusic("about.ogg")
--- end
--- 
--- function tick()
--- 	if InputPressed("interact") then
--- 		SetMusicPaused(IsMusicPlaying())
--- 	end
--- end
--- ```
---@param paused boolean True to pause, false to resume.
function SetMusicPaused(paused) end

---
--- Example:
--- ```lua
--- function init()
--- 	PlayMusic("about.ogg")
--- end
--- 
--- function tick()
--- 	if InputPressed("interact") then
--- 		DebugPrint(GetMusicProgress())
--- 	end
--- end
--- ```
---@return number progress Current music progress in seconds.
function GetMusicProgress() return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	PlayMusic("about.ogg")
--- end
--- 
--- function tick()
--- 	if InputPressed("interact") then
---  		SetMusicProgress(GetMusicProgress() - 1.0)
--- 	end
--- end
--- ```
---@param progress? number Progress in seconds. Default 0.0.
function SetMusicProgress(progress) end

--- Override current music volume for this frame. Call continuously to keep overriding.
---
--- Example:
--- ```lua
--- function init()
--- 	PlayMusic("about.ogg")
--- end
--- 
--- function tick()
--- 	if InputDown("interact") then
---  		SetMusicVolume(0.3)
--- 	end
--- end
--- ```
---@param volume number Music volume.
function SetMusicVolume(volume) end

--- Override current music low pass filter for this frame. Call continuously to keep overriding.
---
--- Example:
--- ```lua
--- function init()
--- 	PlayMusic("about.ogg")
--- end
--- 
--- function tick()
--- 	if InputDown("interact") then
---  		SetMusicLowPass(0.6)
--- 	end
--- end
--- ```
---@param wet number Music low pass filter 0.0 - 1.0.
function SetMusicLowPass(wet) end

---
--- Example:
--- ```lua
--- function init()
--- 	arrow = LoadSprite("gfx/arrowdown.png")
--- end
--- ```
---@param path string Path to sprite. Must be PNG or JPG format.
---@return number handle Sprite handle
function LoadSprite(path) return 0 end

--- Draw sprite in world at next frame. Call this function from the tick callback.
---
--- Example:
--- ```lua
--- function init()
--- 	arrow = LoadSprite("gfx/arrowdown.png")
--- end
--- 
--- function tick()
--- 	--Draw sprite using transform
--- 	--Size is two meters in width and height
--- 	--Color is white, fully opaue
--- 	local t = Transform(Vec(0, 10, 0), QuatEuler(0, GetTime(), 0))
--- 	DrawSprite(arrow, t, 2, 2, 1, 1, 1, 1)
--- end
--- ```
---@param handle number Sprite handle
---@param transform TTransform Transform
---@param width number Width in meters
---@param height number Height in meters
---@param r? number Red color. Default 1.0.
---@param g? number Green color. Default 1.0.
---@param b? number Blue color. Default 1.0.
---@param a? number Alpha. Default 1.0.
---@param depthTest? boolean Depth test enabled. Default false.
---@param additive? boolean Additive blending enabled. Default false.
---@param fogAffected? boolean Enable distance fog effect. Default false.
function DrawSprite(handle, transform, width, height, r, g, b, a, depthTest, additive, fogAffected) end

--- Set required layers for next query. Available layers are:
--- BEGINTABLE Layer -- Description
--- physical	-- have a physical representation
--- dynamic		-- part of a dynamic body
--- static		-- part of a static body
--- large		-- above debris threshold
--- small		-- below debris threshold
--- visible		-- only hit visible shapes
--- animator    -- part of an animator hierachy
--- player      -- part of an player animator hierachy
--- tool        -- part of a tool
--- ENDTABLE
---
--- Example:
--- ```lua
--- --Raycast dynamic, physical objects above debris threshold, but not specific vehicle
--- function tick()
--- 	local vehicle = FindVehicle("vehicle")
--- 	QueryRequire("physical dynamic large")
--- 	QueryRejectVehicle(vehicle)
--- 	local hit, dist = QueryRaycast(Vec(0, 0, 0), Vec(1, 0, 0), 10)
--- 	if hit then
--- 		DebugPrint(dist)
--- 	end
--- end
--- ```
---@param layers string Space separate list of layers
function QueryRequire(layers) end

--- Set included layers for next query. Queries include all layers except tool and player per default. Available layers are:
--- BEGINTABLE Layer -- Description
--- physical	-- have a physical representation
--- dynamic		-- part of a dynamic body
--- static		-- part of a static body
--- large		-- above debris threshold
--- small		-- below debris threshold
--- visible		-- only hit visible shapes
--- animator    -- part of an animator hierachy
--- player      -- part of an player
--- tool        -- part of a tool
--- ENDTABLE
---
--- Example:
--- ```lua
--- --Raycast all the default layers and include the player layer.
--- function tick()
--- 	QueryInclude("player")
--- 	local hit, dist = QueryRaycast(Vec(0, 0, 0), Vec(1, 0, 0), 10)
--- 	if hit then
--- 		DebugPrint(dist)
--- 	end
--- end
--- ```
---@param layers string Space separate list of layers
function QueryInclude(layers) end

function QueryLayerFilter(...) end

--- Exclude animator from the next query
---@param handle number Animator handle
function QueryRejectAnimator(handle) end

--- Exclude vehicle from the next query
---
--- Example:
--- ```lua
--- function tick()
--- 	local vehicle = FindVehicle("vehicle")
--- 	QueryRequire("physical dynamic large")
--- 	--Do not include vehicle in next raycast
--- 	QueryRejectVehicle(vehicle)
--- 	local hit, dist = QueryRaycast(Vec(0, 0, 0), Vec(1, 0, 0), 10)
--- 	if hit then
--- 		DebugPrint(dist)
--- 	end
--- end
--- 
--- 
--- ```
---@param vehicle number Vehicle handle
function QueryRejectVehicle(vehicle) end

--- Exclude body from the next query
---
--- Example:
--- ```lua
--- function tick()
--- 	local body = FindBody("body")
--- 	QueryRequire("physical dynamic large")
--- 	--Do not include body in next raycast
--- 	QueryRejectBody(body)
--- 	local hit, dist = QueryRaycast(Vec(0, 0, 0), Vec(1, 0, 0), 10)
--- 	if hit then
--- 		DebugPrint(dist)
--- 	end
--- end
--- ```
---@param body number Body handle
function QueryRejectBody(body) end

--- Exclude bodies from the next query
---
--- Example:
--- ```lua
--- function tick()
--- 	local body = FindBody("body")
--- 	QueryRequire("physical dynamic large")
--- 	local bodies = {body}
--- 	--Do not include body in next raycast
--- 	QueryRejectBodies(bodies)
--- 	local hit, dist = QueryRaycast(Vec(0, 0, 0), Vec(1, 0, 0), 10)
--- 	if hit then
--- 		DebugPrint(dist)
--- 	end
--- end
--- ```
---@param bodies any Array with bodies handles
function QueryRejectBodies(bodies) end

--- Exclude shape from the next query
---
--- Example:
--- ```lua
--- function tick()
--- 	local shape = FindShape("shape")
--- 	QueryRequire("physical dynamic large")
--- 	--Do not include shape in next raycast
--- 	QueryRejectShape(shape)
--- 	local hit, dist = QueryRaycast(Vec(0, 0, 0), Vec(1, 0, 0), 10)
--- 	if hit then
--- 		DebugPrint(dist)
--- 	end
--- end
--- ```
---@param shape number Shape handle
function QueryRejectShape(shape) end

--- Exclude shapes from the next query
---
--- Example:
--- ```lua
--- function tick()
--- 	local shape = FindShape("shape")
--- 	QueryRequire("physical dynamic large")
--- 	local shapes = {shape}
--- 	--Do not include shape in next raycast
--- 	QueryRejectShapes(shapes)
--- 	local hit, dist = QueryRaycast(Vec(0, 0, 0), Vec(1, 0, 0), 10)
--- 	if hit then
--- 		DebugPrint(dist)
--- 	end
--- end
--- ```
---@param shapes any Array with shapes handles
function QueryRejectShapes(shapes) end

--- This will perform a raycast or spherecast (if radius is more than zero) query.
--- If you want to set up a filter for the query you need to do so before every call
--- to this function.
---
--- Example:
--- ```lua
--- function init()
--- 	local vehicle = FindVehicle("vehicle")
--- 	QueryRejectVehicle(vehicle)
--- 	--Raycast from a high point straight downwards, excluding a specific vehicle
--- 	local hit, d = QueryRaycast(Vec(0, 100, 0), Vec(0, -1, 0), 100)
--- 	if hit then
--- 		DebugPrint(d)
--- 	end
--- end
--- ```
---@param origin TVec Raycast origin as world space vector
---@param direction TVec Unit length raycast direction as world space vector
---@param maxDist number Raycast maximum distance. Keep this as low as possible for good performance.
---@param radius? number Raycast thickness. Default zero.
---@param rejectTransparent? boolean Raycast through transparent materials. Default false.
---@return boolean hit True if raycast hit something
---@return number dist Hit distance from origin
---@return TVec normal World space normal at hit point
---@return number shape Handle to hit shape
function QueryRaycast(origin, direction, maxDist, radius, rejectTransparent) return false, 0, Vec(), 0 end

--- This will perform a raycast query that returns the handle of the joint of rope type when if collides with it.
--- There are no filters for this type of raycast.
---
--- Example:
--- ```lua
--- function tick()
--- 	local playerCameraTransform = GetPlayerCameraTransform()
--- 	local dir = TransformToParentVec(playerCameraTransform, Vec(0, 0, -1))
--- 
--- 	local hit, dist, joint = QueryRaycastRope(playerCameraTransform.pos, dir, 10)
--- 	if hit then
--- 		DebugWatch("distance", dist)
--- 		DebugWatch("joint", joint)
--- 	end
--- end
--- ```
---@param origin TVec Raycast origin as world space vector
---@param direction TVec Unit length raycast direction as world space vector
---@param maxDist number Raycast maximum distance. Keep this as low as possible for good performance.
---@param radius? number Raycast thickness. Default zero.
---@return boolean hit True if raycast hit something
---@return number dist Hit distance from origin
---@return number joint Handle to hit joint of rope type
function QueryRaycastRope(origin, direction, maxDist, radius) return false, 0, 0 end

--- This will query the closest point to all shapes in the world. If you
--- want to set up a filter for the query you need to do so before every call
--- to this function.
---
--- Example:
--- ```lua
--- function tick()
--- 	local vehicle = FindVehicle("vehicle")
--- 	--Find closest point within 10 meters of {0, 5, 0}, excluding any point on myVehicle
--- 	QueryRejectVehicle(vehicle)
--- 	local hit, p, n, s = QueryClosestPoint(Vec(0, 5, 0), 10)
--- 	if hit then
--- 		DebugPrint(p)
--- 	end
--- end
--- ```
---@param origin TVec World space point
---@param maxDist number Maximum distance. Keep this as low as possible for good performance.
---@return boolean hit True if a point was found
---@return TVec point World space closest point
---@return TVec normal World space normal at closest point
---@return number shape Handle to closest shape
function QueryClosestPoint(origin, maxDist) return false, Vec(), Vec(), 0 end

--- Return all shapes within the provided world space, axis-aligned bounding box
---
--- Example:
--- ```lua
--- function tick()
--- 	local list = QueryAabbShapes(Vec(0, 0, 0), Vec(10, 10, 10))
--- 	for i=1, #list do
--- 		local shape = list[i]
--- 		DebugPrint(shape)
--- 	end
--- end
--- ```
---@param min TVec Aabb minimum point
---@param max TVec Aabb maximum point
---@return any list Indexed table with handles to all shapes in the aabb
function QueryAabbShapes(min, max) return nil end

--- Return all bodies within the provided world space, axis-aligned bounding box
---
--- Example:
--- ```lua
--- function tick()
--- 	local list = QueryAabbBodies(Vec(0, 0, 0), Vec(10, 10, 10))
--- 	for i=1, #list do
--- 		local body = list[i]
--- 		DebugPrint(body)
--- 	end
--- end
--- ```
---@param min TVec Aabb minimum point
---@param max TVec Aabb maximum point
---@return any list Indexed table with handles to all bodies in the aabb
function QueryAabbBodies(min, max) return nil end

--- Initiate path planning query. The result will run asynchronously as long as GetPathState
--- returns "busy". An ongoing path query can be aborted with AbortPath. The path planning query
--- will use the currently set up query filter, just like the other query functions.
--- Using the 'water' type allows you to build a path within the water.
--- The 'flying' type builds a path in the entire three-dimensional space.
---
--- Example:
--- ```lua
--- function init()
--- 	QueryPath(Vec(-10, 0, 0), Vec(10, 0, 0))
--- end
--- ```
---@param start TVec World space start point
---@param _end TVec World space target point
---@param maxDist? number Maximum path length before giving up. Default is infinite.
---@param targetRadius? number Maximum allowed distance to target in meters. Default is 2.0
---@param type? string Type of path. Can be "low", "standart", "water", "flying". Default is "standart"
function QueryPath(start, _end, maxDist, targetRadius, type) end

--- Creates a new path planner that can be used to calculate multiple paths in parallel.
--- It is supposed to be used together with PathPlannerQuery.
--- Returns created path planner id/handler.
--- It is recommended to reuse previously created path planners, because they exist throughout the lifetime of the script.
---
--- Example:
--- ```lua
--- local paths = {}
--- 
--- function init()
--- 	paths[1] = {
--- 		id = CreatePathPlanner(),
--- 		location = GetProperty(FindEntity("loc1", true), "transform").pos,
--- 	}
--- 
--- 	paths[2] = {
--- 		id = CreatePathPlanner(),
--- 		location = GetProperty(FindEntity("loc2", true), "transform").pos,
--- 	}
--- 
--- 	for i = 1, #paths do
--- 		PathPlannerQuery(paths[i].id, GetPlayerTransform().pos, paths[i].location)
--- 	end
--- end
--- ```
---@return number [id] Path planner id
function CreatePathPlanner() return 0 end

--- Deletes the path planner with the specified id which can be used to save some memory.
--- Calling CreatePathPlanner again can initialize a new path planner with the id previously deleted.
---
--- Example:
--- ```lua
--- local paths = {}
--- 
--- function init()
--- 	local id = CreatePathPlanner()
--- 	DeletePathPlanner(id)
--- 	-- now calling PathPlannerQuery for 'id' will result in an error
--- end
--- ```
---@param id number Path planner id
function DeletePathPlanner(id) end

--- It works similarly to QueryPath but several paths can be built simultaneously within the same script.
--- The QueryPath automatically creates a path planner with an index of 0 and only works with it.
---
--- Example:
--- ```lua
--- local paths = {}
--- 
--- function init()
--- 	paths[1] = {
--- 		id = CreatePathPlanner(),
--- 		location = GetProperty(FindEntity("loc1", true), "transform").pos,
--- 	}
--- 
--- 	paths[2] = {
--- 		id = CreatePathPlanner(),
--- 		location = GetProperty(FindEntity("loc2", true), "transform").pos,
--- 	}
--- 
--- 	for i = 1, #paths do
--- 		PathPlannerQuery(paths[i].id, GetPlayerTransform().pos, paths[i].location)
--- 	end
--- end
--- ```
---@param id number Path planner id
---@param start TVec World space start point
---@param _end TVec World space target point
---@param maxDist? number Maximum path length before giving up. Default is infinite.
---@param targetRadius? number Maximum allowed distance to target in meters. Default is 2.0
---@param type? string Type of path. Can be "low", "standart", "water", "flying". Default is "standart"
function PathPlannerQuery(id, start, _end, maxDist, targetRadius, type) end

--- Abort current path query, regardless of what state it is currently in. This is a way to
--- save computing resources if the result of the current query is no longer of interest.
---
--- Example:
--- ```lua
--- function init()
--- 	QueryPath(Vec(-10, 0, 0), Vec(10, 0, 0))
--- 	AbortPath()
--- end
--- ```
---@param id? number Path planner id. Default value is 0.
function AbortPath(id) end

--- Return the current state of the last path planning query.
--- BEGINTABLE State -- Description
--- idle	-- No recent query
--- busy	-- Busy computing. No path found yet.
--- fail	-- Failed to find path. You can still get the resulting path (even though it won't reach the target).
--- done	-- Path planning completed and a path was found. Get it with GetPathLength and GetPathPoint)
--- ENDTABLE
---
--- Example:
--- ```lua
--- function init()
--- 	QueryPath(Vec(-10, 0, 0), Vec(10, 0, 0))
--- end
--- 
--- function tick()
--- 	local s = GetPathState()
--- 	if s == "done" then
--- 		DebugPrint("done")
--- 	end
--- end
--- ```
---@param id? number Path planner id. Default value is 0.
---@return string state Current path planning state
function GetPathState(id) return "" end

--- Return the path length of the most recently computed path query. Note that the result can often be retrieved even
--- if the path query failed. If the target point couldn't be reached, the path endpoint will be the point closest
--- to the target.
---
--- Example:
--- ```lua
--- function init()
--- 	QueryPath(Vec(-10, 0, 0), Vec(10, 0, 0))
--- end
--- 
--- function tick()
--- 	local s = GetPathState()
--- 	if s == "done" then
--- 		DebugPrint("done " .. GetPathLength())
--- 	end
--- end
--- ```
---@param id? number Path planner id. Default value is 0.
---@return number length Length of last path planning result (in meters)
function GetPathLength(id) return 0 end

--- Return a point along the path for the most recently computed path query. Note that the result can often be retrieved even
--- if the path query failed. If the target point couldn't be reached, the path endpoint will be the point closest
--- to the target.
---
--- Example:
--- ```lua
--- function init()
--- 	QueryPath(Vec(-10, 0, 0), Vec(10, 0, 0))
--- end
--- 
--- function tick()
--- 	local d = 0
--- 	local l = GetPathLength()
--- 	while d < l do
--- 		DebugCross(GetPathPoint(d))
--- 		d = d + 0.5
--- 	end
--- end
--- ```
---@param dist number The distance along path. Should be between zero and result from GetPathLength()
---@param id? number Path planner id. Default value is 0.
---@return TVec point The path point dist meters along the path
function GetPathPoint(dist, id) return Vec() end

---
--- Example:
--- ```lua
--- function tick()
--- 	local vol, pos = GetLastSound()
--- 	if vol > 0 then
--- 		DebugPrint(vol .. " " .. VecStr(pos))
--- 	end
--- end
--- ```
---@return number volume Volume of loudest sound played last frame
---@return TVec position World position of loudest sound played last frame
function GetLastSound() return 0, Vec() end

---
--- Example:
--- ```lua
--- function tick()
--- 	local wet, d = IsPointInWater(Vec(10, 0, 0))
--- 	if wet then
--- 		DebugPrint("point" .. d .. " meters into water")
--- 	end
--- end
--- ```
---@param point TVec World point as vector
---@return boolean inWater True if point is in water
---@return number depth Depth of point into water, or zero if not in water
function IsPointInWater(point) return false, 0 end

--- Get the wind velocity at provided point. The wind will be determined by wind property of
--- the environment, but it varies with position procedurally.
---
--- Example:
--- ```lua
--- function tick()
--- 	local v = GetWindVelocity(Vec(0, 10, 0))
--- 	DebugPrint(VecStr(v))
--- end
--- ```
---@param point TVec World point as vector
---@return TVec vel Wind at provided position
function GetWindVelocity(point) return Vec() end

--- Reset to default particle state, which is a plain, white particle of radius 0.5.
--- Collision is enabled and it alpha animates from 1 to 0.
---
--- Example:
--- ```lua
--- function init()
--- 	ParticleReset()
--- end
--- ```
function ParticleReset() end

--- Set type of particle
---
--- Example:
--- ```lua
--- function init()
--- 	ParticleType("smoke")
--- end
--- ```
---@param type string Type of particle. Can be "smoke" or "plain".
function ParticleType(type) end

---
--- Example:
--- ```lua
--- function init()
--- 	--Smoke particle
--- 	ParticleTile(0)
--- 
--- 	--Fire particle
--- 	ParticleTile(5)
--- end
--- ```
---@param type number Tile in the particle texture atlas (0-15)
function ParticleTile(type) end

--- Set particle color to either constant (three arguments) or linear interpolation (six arguments)
---
--- Example:
--- ```lua
--- function init()
--- 	--Constant red
--- 	ParticleColor(1,0,0)
--- 
--- 	--Animating from yellow to red
--- 	ParticleColor(1,1,0, 1,0,0)
--- end
--- ```
---@param r0 number Red value
---@param g0 number Green value
---@param b0 number Blue value
---@param r1? number Red value at end
---@param g1? number Green value at end
---@param b1? number Blue value at end
function ParticleColor(r0, g0, b0, r1, g1, b1) end

--- Set the particle radius. Max radius for smoke particles is 1.0.
---
--- Example:
--- ```lua
--- function init()
--- 	--Constant radius 0.4 meters
--- 	ParticleRadius(0.4)
--- 
--- 	--Interpolate from small to large
--- 	ParticleRadius(0.1, 0.7)
--- end
--- ```
---@param r0 number Radius
---@param r1? number End radius
---@param interpolation? string Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein? number Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout? number Fade out between t=fadeout and t=1. Default is one.
function ParticleRadius(r0, r1, interpolation, fadein, fadeout) end

--- Set the particle alpha (opacity).
---
--- Example:
--- ```lua
--- function init()
--- 	--Interpolate from opaque to transparent
--- 	ParticleAlpha(1.0, 0.0)
--- end
--- ```
---@param a0 number Alpha (0.0 - 1.0)
---@param a1? number End alpha (0.0 - 1.0)
---@param interpolation? string Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein? number Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout? number Fade out between t=fadeout and t=1. Default is one.
function ParticleAlpha(a0, a1, interpolation, fadein, fadeout) end

--- Set particle gravity. It will be applied along the world Y axis. A negative value will move the particle downwards.
---
--- Example:
--- ```lua
--- function init()
--- 	--Move particles slowly upwards
--- 	ParticleGravity(2)
--- end
--- ```
---@param g0 number Gravity
---@param g1? number End gravity
---@param interpolation? string Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein? number Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout? number Fade out between t=fadeout and t=1. Default is one.
function ParticleGravity(g0, g1, interpolation, fadein, fadeout) end

--- Particle drag will slow down fast moving particles. It's implemented slightly different for
--- smoke and plain particles. Drag must be positive, and usually look good between zero and one.
---
--- Example:
--- ```lua
--- function init()
--- 	--Slow down fast moving particles
--- 	ParticleDrag(0.5)
--- end
--- ```
---@param d0 number Drag
---@param d1? number End drag
---@param interpolation? string Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein? number Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout? number Fade out between t=fadeout and t=1. Default is one.
function ParticleDrag(d0, d1, interpolation, fadein, fadeout) end

--- Draw particle as emissive (glow in the dark). This is useful for fire and embers.
---
--- Example:
--- ```lua
--- function init()
--- 	--Highly emissive at start, not emissive at end
--- 	ParticleEmissive(5, 0)
--- end
--- ```
---@param d0 number Emissive
---@param d1? number End emissive
---@param interpolation? string Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein? number Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout? number Fade out between t=fadeout and t=1. Default is one.
function ParticleEmissive(d0, d1, interpolation, fadein, fadeout) end

--- Makes the particle rotate. Positive values is counter-clockwise rotation.
---
--- Example:
--- ```lua
--- function init()
--- 	--Rotate fast at start and slow at end
--- 	ParticleRotation(10, 1)
--- end
--- ```
---@param r0 number Rotation speed in radians per second.
---@param r1? number End rotation speed in radians per second.
---@param interpolation? string Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein? number Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout? number Fade out between t=fadeout and t=1. Default is one.
function ParticleRotation(r0, r1, interpolation, fadein, fadeout) end

--- Stretch particle along with velocity. 0.0 means no stretching. 1.0 stretches with the particle motion over
--- one frame. Larger values stretches the particle even more.
---
--- Example:
--- ```lua
--- function init()
--- 	--Stretch particle along direction of motion
--- 	ParticleStretch(1.0)
--- end
--- ```
---@param s0 number Stretch
---@param s1? number End stretch
---@param interpolation? string Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein? number Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout? number Fade out between t=fadeout and t=1. Default is one.
function ParticleStretch(s0, s1, interpolation, fadein, fadeout) end

--- Make particle stick when in contact with objects. This can be used for friction.
---
--- Example:
--- ```lua
--- function init()
--- 	--Make particles stick to objects
--- 	ParticleSticky(0.5)
--- end
--- ```
---@param s0 number Sticky (0.0 - 1.0)
---@param s1? number End sticky (0.0 - 1.0)
---@param interpolation? string Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein? number Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout? number Fade out between t=fadeout and t=1. Default is one.
function ParticleSticky(s0, s1, interpolation, fadein, fadeout) end

--- Control particle collisions. A value of zero means that collisions are ignored. One means full collision.
--- It is sometimes useful to animate this value from zero to one in order to not collide with objects around
--- the emitter.
---
--- Example:
--- ```lua
--- function init()
--- 	--Disable collisions
--- 	ParticleCollide(0)
--- 
--- 	--Enable collisions over time
--- 	ParticleCollide(0, 1)
--- 
--- 	--Ramp up collisions very quickly, only skipping the first 5% of lifetime
--- 	ParticleCollide(1, 1, "constant", 0.05)
--- end
--- ```
---@param c0 number Collide (0.0 - 1.0)
---@param c1? number End collide (0.0 - 1.0)
---@param interpolation? string Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein? number Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout? number Fade out between t=fadeout and t=1. Default is one.
function ParticleCollide(c0, c1, interpolation, fadein, fadeout) end

--- Set particle bitmask. The value 256 means fire extinguishing particles and is currently the only
--- flag in use. There might be support for custom flags and queries in the future.
---
--- Example:
--- ```lua
--- function tick()
--- 	--Fire extinguishing particle
--- 	ParticleFlags(256)
--- 	SpawnParticle(Vec(0, 10, 0), -0.1, math.random() + 1)
--- end
--- ```
---@param bitmask number Particle flags (bitmask 0-65535)
function ParticleFlags(bitmask) end

--- DEPRECATED_ALERT
--- Orients the particle according to specified flags
---
--- Example:
--- ```lua
--- local q = 1.0
--- local w = 1.0
--- 
--- function tick()
--- 	ParticleRadius(0.02+q*0.05, 0.01, "linear", 0.02, 0.1)
--- 	ParticleStretch(2)
--- 	ParticleSticky(0.02)
--- 	ParticleColor(0.6*w, 0.55*w, 0.35*w)
--- 	ParticleType("plain")
--- 	ParticleOrientation("normalup flat")
--- 	ParticleGravity(-8)
--- 	SpawnParticle(Vec(0, 10, 0), -0.1, math.random() + 1)
--- end
--- ```
---@param flags string List of flags separated by spaces (known flags: normalup, flat)
function ParticleOrientation(flags) end

--- Spawn particle using the previously set up particle state. You can call this multiple times
--- using the same particle state, but with different position, velocity and lifetime. You can
--- also modify individual properties in the particle state in between calls to to this function.
---
--- Example:
--- ```lua
--- function tick()
--- 	ParticleReset()
--- 	ParticleType("smoke")
--- 	ParticleColor(0.7, 0.6, 0.5)
--- 	--Spawn particle at world origo with upwards velocity and a lifetime of ten seconds
--- 	SpawnParticle(Vec(0, 5, 0), Vec(0, 1, 0), 10.0)
--- end
--- ```
---@param pos TVec World space point as vector
---@param velocity TVec World space velocity as vector
---@param lifetime number Particle lifetime in seconds
function SpawnParticle(pos, velocity, lifetime) end

--- The first argument can be either a prefab XML file in your mod folder or a string with XML content. It is also
--- possible to spawn prefabs from other mods, by using the mod id followed by colon, followed by the prefab path.
--- Spawning prefabs from other mods should be used with causion since the referenced mod might not be installed.
---
--- Example:
--- ```lua
--- function init()
--- 	Spawn("MOD/prefab/mycar.xml", Transform(Vec(0, 5, 0)))
--- 	Spawn("&lt;voxbox size='10 10 10' prop='true' material='wood'/&gt;", Transform(Vec(0, 10, 0)))
--- end
--- ```
---@param xml string File name or xml string
---@param transform TTransform Spawn transform
---@param allowStatic? boolean Allow spawning static shapes and bodies (default false)
---@param jointExisting? boolean Allow joints to connect to existing scene geometry (default false)
---@return any entities Indexed table with handles to all spawned entities
function Spawn(xml, transform, allowStatic, jointExisting) return nil end

--- Same functionality as Spawn(), except using a specific layer in the vox-file
---
--- Example:
--- ```lua
--- function init()
--- 	Spawn("MOD/prefab/mycar.xml", "some_vox_layer", Transform(Vec(0, 5, 0)))
--- 	Spawn("&lt;voxbox size='10 10 10' prop='true' material='wood'/&gt;", "some_vox_layer", Transform(Vec(0, 10, 0)))
--- end
--- ```
---@param xml string File name or xml string
---@param layer string Vox layer name
---@param transform TTransform Spawn transform
---@param allowStatic? boolean Allow spawning static shapes and bodies (default false)
---@param jointExisting? boolean Allow joints to connect to existing scene geometry (default false)
---@return any entities Indexed table with handles to all spawned entities
function SpawnLayer(xml, layer, transform, allowStatic, jointExisting) return nil end

--- Fire projectile. Type can be one of "bullet", "rocket", "gun" or "shotgun".
--- For backwards compatilbility, type also accept a number, where 1 is same as "rocket" and anything else "bullet"
--- Note that this function will only spawn the projectile, not make any sound
--- Also note that "bullet" and "rocket" are the only projectiles that can hurt the player.
---
--- Example:
--- ```lua
--- function tick()
--- 	Shoot(Vec(0, 10, 0), Vec(0, -1, 0), "shotgun")
--- end
--- ```
---@param origin TVec Origin in world space as vector
---@param direction TVec Unit length direction as world space vector
---@param type? string Shot type, see description, default is "bullet"
---@param strength? number Strength scaling, default is 1.0
---@param maxDist? number Maximum distance, default is 100.0
function Shoot(origin, direction, type, strength, maxDist) end

--- Tint the color of objects within radius to either black or yellow.
---
--- Example:
--- ```lua
--- function tick()
--- 	Paint(Vec(0, 2, 0), 5.0, "spraycan")
--- end
--- ```
---@param origin TVec Origin in world space as vector
---@param radius number Affected radius, in range 0.0 to 5.0
---@param type? string Paint type. Can be "explosion" or "spraycan". Default is spraycan.
---@param probability? number Dithering probability between zero and one, default is 1.0
function Paint(origin, radius, type, probability) end

--- Tint the color of objects within radius to custom RGBA color.
---
--- Example:
--- ```lua
--- function tick()
--- 	PaintRGBA(Vec(0, 5, 0), 5.5, 1.0, 0.0, 0.0)
--- end
--- ```
---@param origin TVec Origin in world space as vector
---@param radius number Affected radius, in range 0.0 to 5.0
---@param red number red color value, in range 0.0 to 1.0
---@param green number green color value, in range 0.0 to 1.0
---@param blue number blue color value, in range 0.0 to 1.0
---@param alpha? number alpha channel value, in range 0.0 to 1.0
---@param probability? number Dithering probability between zero and one, default is 1.0
function PaintRGBA(origin, radius, red, green, blue, alpha, probability) end

--- DEPRECATED_ALERT
--- Adds snow particle on specified location
---
--- Example:
--- ```lua
--- function update()
--- 	local body = FindBody("body")
--- 	local pos = GetBodyTransform(body).pos
--- 	local hit, point, normal, shape = QueryClosestPoint(pos, 0.3)
--- 	AddSnow(shape, point, 0.22)
--- end
--- ```
---@param shape number Shape index
---@param point TVec Spawn location
---@param size number Radius of snow particle
---@return boolean r 
function AddSnow(shape, point, size) return false end

--- Make a hole in the environment. Radius is given in meters.
--- Soft materials: glass, foliage, dirt, wood, plaster and plastic.
--- Medium materials: concrete, brick and weak metal.
--- Hard materials: hard metal and hard masonry.
---
--- Example:
--- ```lua
--- function init()
--- 	MakeHole(Vec(0, 0, 0), 5.0, 1.0)
--- end
--- ```
---@param position TVec Hole center point
---@param r0 number Hole radius for soft materials
---@param r1? number Hole radius for medium materials. May not be bigger than r0. Default zero.
---@param r2? number Hole radius for hard materials. May not be bigger than r1. Default zero.
---@param silent? boolean Make hole without playing any break sounds.
---@return number count Number of voxels that was cut out. This will be zero if there were no changes to any shape.
function MakeHole(position, r0, r1, r2, silent) return 0 end

---
--- Example:
--- ```lua
--- function init()
--- 	Explosion(Vec(0, 5, 0), 1)
--- end
--- ```
---@param pos TVec Position in world space as vector
---@param size number Explosion size from 0.5 to 4.0
function Explosion(pos, size) end

---
--- Example:
--- ```lua
--- function tick()
--- 	SpawnFire(Vec(0, 2, 0))
--- end
--- ```
---@param pos TVec Position in world space as vector
function SpawnFire(pos) end

---
--- Example:
--- ```lua
--- function tick()
--- 	local c = GetFireCount()
--- 	DebugPrint("Fire count " .. c)
--- end
--- ```
---@return number count Number of active fires in level
function GetFireCount() return 0 end

---
--- Example:
--- ```lua
--- function tick()
--- 	local hit, pos = QueryClosestFire(GetPlayerTransform().pos, 5.0)
--- 	if hit then
--- 		--There is a fire within 5 meters to the player. Mark it with a debug cross.
--- 		DebugCross(pos)
--- 	end
--- end
--- ```
---@param origin TVec World space position as vector
---@param maxDist number Maximum search distance
---@return boolean hit A fire was found within search distance
---@return TVec pos Position of closest fire
function QueryClosestFire(origin, maxDist) return false, Vec() end

---
--- Example:
--- ```lua
--- function tick()
--- 	local count = QueryAabbFireCount(Vec(0,0,0), Vec(10,10,10))
--- 	DebugPrint(count)
--- end
--- ```
---@param min TVec Aabb minimum point
---@param max TVec Aabb maximum point
---@return number count Number of active fires in bounding box
function QueryAabbFireCount(min, max) return 0 end

---
--- Example:
--- ```lua
--- function tick()
--- 	local removedCount= RemoveAabbFires(Vec(0,0,0), Vec(10,10,10))
--- 	DebugPrint(removedCount)
--- end
--- ```
---@param min TVec Aabb minimum point
---@param max TVec Aabb maximum point
---@return number count Number of fires removed
function RemoveAabbFires(min, max) return 0 end

---
--- Example:
--- ```lua
--- function tick()
--- 	local t = GetCameraTransform()
--- 	DebugPrint(TransformStr(t))
--- end
--- ```
---@return TTransform transform Current camera transform
function GetCameraTransform() return Transform() end

--- Override current camera transform for this frame. Call continuously to keep overriding.
--- When transform of some shape or body used to calculate camera transform, consider use of AttachCameraTo,
--- because you might be using transform from previous physics update
--- (that was on previous frame or even earlier depending on fps and timescale).
---
--- Example:
--- ```lua
--- function tick()
--- 	SetCameraTransform(Transform(Vec(0, 10, 0), QuatEuler(0, 90, 0)))
--- end
--- ```
---@param transform TTransform Desired camera transform
---@param fov? number Optional horizontal field of view in degrees (default: 90)
function SetCameraTransform(transform, fov) end

--- Use this function to switch to first-person view, overriding the player's selected third-person view.
--- This is particularly useful for scenarios like looking through a camera viewfinder or a rifle scope.
--- Call the function continuously to maintain the override.
---
--- Example:
--- ```lua
--- function tick()
--- 	if useViewFinder then
--- 		RequestFirstPerson(true)
--- 	end
--- end
--- 
--- function draw()
--- 	if useViewFinder and !GetBool("game.thirdperson") then
--- 		-- Draw view finder overlay
--- 	end
--- end
--- ```
---@param transition boolean Use transition
function RequestFirstPerson(transition) end

--- Use this function to switch to third-person view, overriding the player's selected first-person view.
--- Call the function continuously to maintain the override.
---
--- Example:
--- ```lua
--- function tick()
--- 	if useThirdPerson then
--- 		RequestThirdPerson(true)
--- 	end
--- end
--- ```
---@param transition boolean Use transition
function RequestThirdPerson(transition) end

--- Saves the camera override transform after exiting override mode.
--- Can be used for smoother transition between camera mods. For example MODE_OVERRIDE -> MODE_FOLLOW
function SaveCameraOverrideTransform() end

--- Call this function continously to apply a camera offset. Can be used for camera effects
--- such as shake and wobble.
---
--- Example:
--- ```lua
--- function tick()
--- 	local tPosX = Transform(Vec(math.sin(GetTime()*3.0) * 0.2, 0, 0))
--- 	local tPosY = Transform(Vec(0, math.cos(GetTime()*3.0) * 0.2, 0), QuatAxisAngle(Vec(0, 0, 0)))
--- 
--- 	SetCameraOffsetTransform(tPosX, true)
--- 	SetCameraOffsetTransform(tPosY, true)
--- end
--- ```
---@param transform TTransform Desired camera offset transform
---@param stackable? boolean True if camera offset should summ up with multiple calls per tick
function SetCameraOffsetTransform(transform, stackable) end

--- Attach current camera transform for this frame to body or shape. Call continuously to keep overriding.
--- In tick function we have coordinates of bodies and shapes that are not yet updated by physics,
--- that's why camera can not be in sync with it using SetCameraTransform,
--- instead use this function and SetCameraOffsetTransform to place camera around any body or shape without lag.
---
--- Example:
--- ```lua
--- function tick()
--- 	local vehicle = GetPlayerVehicle()
--- 	if vehicle ~= 0 then
--- 		AttachCameraTo(GetVehicleBody(vehicle))
--- 		SetCameraOffsetTransform(Transform(Vec(1, 2, 3)))
--- 	end
--- end
--- ```
---@param handle number Body or shape handle
---@param ignoreRotation? boolean True to ignore rotation and use position only, false to use full transform
function AttachCameraTo(handle, ignoreRotation) end

--- treated as pivots when clipping
--- body's shapes which is used to calculate clipping parameters
--- (default: -1)
--- Enforce camera clipping for this frame and mark the given body as a
--- pivot for clipping. Call continuously to keep overriding.
---
--- Example:
--- ```lua
--- local body_1 = 0
--- local body_2 = 0
--- function init()
--- 	body_1 = FindBody("body_1")
--- 	body_2 = FindBody("body_2")
--- end
--- 
--- function tick()
--- 	SetPivotClipBody(body_1, 0) -- this overload should be called once and
--- 	-- only once per frame to take effect
--- 	SetPivotClipBody(body_2)
--- end
--- ```
---@param bodyHandle number Handle of a body, shapes of which should be
---@param mainShapeIdx number Optional index of a shape among the given
function SetPivotClipBody(bodyHandle, mainShapeIdx) end

--- Shakes the player camera
---
--- Example:
--- ```lua
--- function tick()
--- 	ShakeCamera(0.5)
--- end
--- ```
---@param strength number Normalized strength of shaking
function ShakeCamera(strength) end

--- Override field of view for the next frame for all camera modes, except when explicitly set in SetCameraTransform
---
--- Example:
--- ```lua
--- function tick()
--- 	SetCameraFov(60)
--- end
--- ```
---@param degrees number Horizontal field of view in degrees (10-170)
function SetCameraFov(degrees) end

--- Override depth of field for the next frame for all camera modes. Depth of field will be used even if turned off in options.
---
--- Example:
--- ```lua
--- function tick()
--- 	--Set depth of field to 10 meters
--- 	SetCameraDof(10)
--- end
--- ```
---@param distance number Depth of field distance
---@param amount? number Optional amount of blur (default 1.0)
function SetCameraDof(distance, amount) end

--- Add a temporary point light to the world for this frame. Call continuously
--- for a steady light.
---
--- Example:
--- ```lua
--- function tick()
--- 	--Pulsating, yellow light above world origo
--- 	local intensity = 3 + math.sin(GetTime())
--- 	PointLight(Vec(0, 5, 0), 1, 1, 0, intensity)
--- end
--- ```
---@param pos TVec World space light position
---@param r number Red
---@param g number Green
---@param b number Blue
---@param intensity? number Intensity. Default is 1.0.
function PointLight(pos, r, g, b, intensity) end

--- Experimental. Scale time in order to make a slow-motion or acceleration effect. Audio will also be affected.
--- (v1.4 and below: this function will affect physics behavior and is not intended for gameplay purposes.)
--- Starting from v1.5 this function does not affect physics behavior and rely on rendering interpolation.
--- Scaling time up may decrease performance, and is not recommended for gameplay purposes.
--- Calling this function will change time scale for the next frame only.
--- Call every frame from tick function to get steady slow-motion.
---
--- Example:
--- ```lua
--- function tick()
--- 	--Slow down time when holding down a key
--- 	if InputDown('t') then
--- 		SetTimeScale(0.2)
--- 	end
--- end
--- ```
---@param scale number Time scale 0.0 to 2.0
function SetTimeScale(scale) end

--- Reset the environment properties to default. This is often useful before
--- setting up a custom environment.
---
--- Example:
--- ```lua
--- function init()
--- 	SetEnvironmentDefault()
--- end
--- ```
function SetEnvironmentDefault() end

--- This function is used for manipulating the environment properties. The available properties are
--- exactly the same as in the editor, except for "snowonground" which is not currently supported.
---
--- Example:
--- ```lua
--- function init()
--- 	SetEnvironmentDefault()
--- 	SetEnvironmentProperty("skybox", "cloudy.dds")
--- 	SetEnvironmentProperty("rain", 0.7)
--- 	SetEnvironmentProperty("fogcolor", 0.5, 0.5, 0.8)
--- 	SetEnvironmentProperty("nightlight", false)
--- end
--- ```
---@param name string Property name
---@param value0 any Property value (type depends on property)
---@param value1? any Extra property value (only some properties)
---@param value2? any Extra property value (only some properties)
---@param value3? any Extra property value (only some properties)
function SetEnvironmentProperty(name, value0, value1, value2, value3) end

--- This function is used for querying the current environment properties. The available properties are
--- exactly the same as in the editor.
---
--- Example:
--- ```lua
--- function init()
--- 	local skyboxPath = GetEnvironmentProperty("skybox")
--- 	local rainValue = GetEnvironmentProperty("rain")
--- 	local r,g,b = GetEnvironmentProperty("fogcolor")
--- 	local enabled = GetEnvironmentProperty("nightlight")
--- 	DebugPrint(skyboxPath)
--- 	DebugPrint(rainValue)
--- 	DebugPrint(r .. " " .. g .. " " .. b)
--- 	DebugPrint(enabled)
--- end
--- ```
---@param name string Property name
---@return any value0 Property value (type depends on property)
---@return any [value1] Property value (only some properties)
---@return any [value2] Property value (only some properties)
---@return any [value3] Property value (only some properties)
---@return any [value4] Property value (only some properties)
function GetEnvironmentProperty(name) return nil, nil, nil, nil, nil end

--- Reset the post processing properties to default.
---
--- Example:
--- ```lua
--- function tick()
--- 	SetPostProcessingProperty("saturation", 0.4)
--- 	SetPostProcessingProperty("colorbalance", 1.3, 1.0, 0.7)
--- 	SetPostProcessingDefault()
--- end
--- ```
function SetPostProcessingDefault() end

--- This function is used for manipulating the post processing properties. The available properties are
--- exactly the same as in the editor.
---
--- Example:
--- ```lua
--- --Sepia post processing
--- function tick()
--- 	SetPostProcessingProperty("saturation", 0.4)
--- 	SetPostProcessingProperty("colorbalance", 1.3, 1.0, 0.7)
--- end
--- ```
---@param name string Property name
---@param value0 number Property value
---@param value1? number Extra property value (only some properties)
---@param value2? number Extra property value (only some properties)
function SetPostProcessingProperty(name, value0, value1, value2) end

--- This function is used for querying the current post processing properties.
--- The available properties are exactly the same as in the editor.
---
--- Example:
--- ```lua
--- function tick()
--- 	SetPostProcessingProperty("saturation", 0.4)
--- 	SetPostProcessingProperty("colorbalance", 1.3, 1.0, 0.7)
--- 	local saturation = GetPostProcessingProperty("saturation")
--- 	local r,g,b = GetPostProcessingProperty("colorbalance")
--- 	DebugPrint("saturation " .. saturation)
--- 	DebugPrint("colorbalance " .. r .. " " .. g .. " " .. b)
--- end
--- ```
---@param name string Property name
---@return number value0 Property value
---@return number [value1] Property value (only some properties)
---@return number [value2] Property value (only some properties)
function GetPostProcessingProperty(name) return 0, 0, 0 end

--- Draw a 3D line. In contrast to DebugLine, it will not show behind objects. Default color is white.
---
--- Example:
--- ```lua
--- function tick()
--- 	--Draw white debug line
--- 	DrawLine(Vec(0, 0, 0), Vec(-10, 5, -10))
--- 
--- 	--Draw red debug line
--- 	DrawLine(Vec(0, 0, 0), Vec(10, 5, 10), 1, 0, 0)
--- end
--- ```
---@param p0 TVec World space point as vector
---@param p1 TVec World space point as vector
---@param r? number Red
---@param g? number Green
---@param b? number Blue
---@param a? number Alpha
function DrawLine(p0, p1, r, g, b, a) end

--- Draw a 3D debug overlay line in the world. Default color is white.
---
--- Example:
--- ```lua
--- function tick()
--- 	--Draw white debug line
--- 	DebugLine(Vec(0, 0, 0), Vec(-10, 5, -10))
--- 
--- 	--Draw red debug line
--- 	DebugLine(Vec(0, 0, 0), Vec(10, 5, 10), 1, 0, 0)
--- end
--- ```
---@param p0 TVec World space point as vector
---@param p1 TVec World space point as vector
---@param r? number Red
---@param g? number Green
---@param b? number Blue
---@param a? number Alpha
function DebugLine(p0, p1, r, g, b, a) end

--- Draw a debug cross in the world to highlight a location. Default color is white.
---
--- Example:
--- ```lua
--- function tick()
--- 	DebugCross(Vec(10, 5, 5))
--- end
--- ```
---@param p0 TVec World space point as vector
---@param r? number Red
---@param g? number Green
---@param b? number Blue
---@param a? number Alpha
function DebugCross(p0, r, g, b, a) end

--- Draw the axis of the transform
---
--- Example:
--- ```lua
--- function tick()
--- 	DebugTransform(GetPlayerCameraTransform(), 0.5)
--- end
--- ```
---@param transform TTransform The transform
---@param scale? number Length of the axis
function DebugTransform(transform, scale) end

--- Show a named valued on screen for debug purposes.
--- Up to 32 values can be shown simultaneously. Values updated the current
--- frame are drawn opaque. Old values are drawn transparent in white.
--- 
--- The function will also recognize tables and convert them to strings automatically.
---
--- Example:
--- ```lua
--- function tick()
--- 	DebugWatch("Player camera transform", GetPlayerCameraTransform())
--- 
--- 	local anyTable = {
--- 		"teardown",
--- 		{
--- 			name = "Alex",
--- 			age = 25,
--- 			child = { name = "Lena" }
--- 		},
--- 		nil,
--- 		version = "1.6.0",
--- 		true
--- 	}
--- 	DebugWatch("table", anyTable);
--- end
--- ```
---@param name string Name
---@param value string Value
---@param lineWrapping? boolean True if you need to wrap Table lines. Works only with tables.
function DebugWatch(name, value, lineWrapping) end

--- Display message on screen. The last 20 lines are displayed.
--- The function will also recognize tables and convert them to strings automatically.
---
--- Example:
--- ```lua
--- function init()
--- 	DebugPrint("time")
--- 
--- 	DebugPrint(GetPlayerCameraTransform())
--- 
--- 	local anyTable = {
--- 		"teardown",
--- 		{
--- 			name = "Alex",
--- 			age = 25,
--- 			child = { name = "Lena" }
--- 		},
--- 		nil,
--- 		version = "1.6.0",
--- 		true,
--- 	}
--- 	DebugPrint(anyTable)
--- end
--- ```
---@param message string Message to display
---@param lineWrapping? boolean True if you need to wrap Table lines. Works only with tables.
function DebugPrint(message, lineWrapping) end

--- Binds the callback function on the event
---
--- Example:
--- ```lua
--- function onLangauageChanged()
--- 	DebugPrint("langauageChanged")
--- end
--- 
--- function init()
--- 	RegisterListenerTo("LanguageChanged", "onLangauageChanged")
--- 	TriggerEvent("LanguageChanged")
--- end
--- ```
---@param eventName string Event name
---@param listenerFunction string Listener function name
function RegisterListenerTo(eventName, listenerFunction) end

--- Unbinds the callback function from the event
---
--- Example:
--- ```lua
--- function onLangauageChanged()
--- 	DebugPrint("langauageChanged")
--- end
--- 
--- function init()
--- 	RegisterListenerTo("LanguageChanged", "onLangauageChanged")
--- 	UnregisterListener("LanguageChanged", "onLangauageChanged")
--- 	TriggerEvent("LanguageChanged")
--- end
--- ```
---@param eventName string Event name
---@param listenerFunction string Listener function name
function UnregisterListener(eventName, listenerFunction) end

--- Triggers an event for all registered listeners
---
--- Example:
--- ```lua
--- function onLangauageChanged()
--- 	DebugPrint("langauageChanged")
--- end
--- 
--- function init()
--- 	RegisterListenerTo("LanguageChanged", "onLangauageChanged")
--- 	UnregisterListener("LanguageChanged", "onLangauageChanged")
--- 	TriggerEvent("LanguageChanged")
--- end
--- ```
---@param eventName string Event name
---@param args? string Event parameters
function TriggerEvent(eventName, args) end

---
--- Example:
--- ```lua
--- -- Rumble with gun Haptic effect
--- function init()
--- 	haptic_effect = LoadHaptic("haptic/gun_fire.xml")
--- end
--- 
--- function tick()
--- 	if trigHaptic then
--- 		PlayHaptic(haptic_effect, 1)
--- 	end
--- end
--- ```
---@param filepath string Path to Haptic effect to play
---@return string handle Haptic effect handle
function LoadHaptic(filepath) return "" end

---
--- Example:
--- ```lua
--- -- Rumble with gun Haptic effect
--- function init()
--- 	haptic_effect = CreateHaptic(1, 1, 0, 0)
--- end
--- 
--- function tick()
--- 	if trigHaptic then
--- 		PlayHaptic(haptic_effect, 1)
--- 	end
--- end
--- ```
---@param leftMotorRumble number Amount of rumble for left motor
---@param rightMotorRumble number Amount of rumble for right motor
---@param leftTriggerRumble number Amount of rumble for left trigger
---@param rightTriggerRumble number Amount of rumble for right trigger
---@return string handle Haptic effect handle
function CreateHaptic(leftMotorRumble, rightMotorRumble, leftTriggerRumble, rightTriggerRumble) return "" end

--- If Haptic already playing, restarts it.
---
--- Example:
--- ```lua
--- -- Rumble with gun Haptic effect
--- function init()
--- 	haptic_effect = LoadHaptic("haptic/gun_fire.xml")
--- end
--- 
--- function tick()
--- 	if trigHaptic then
--- 		PlayHaptic(haptic_effect, 1)
--- 	end
--- end
--- ```
---@param handle string Handle of haptic effect
---@param amplitude number Amplidute used for calculation of Haptic effect.
function PlayHaptic(handle, amplitude) end

--- If Haptic already playing, restarts it.
---
--- Example:
--- ```lua
--- -- Rumble with gun Haptic effect
--- local haptic_effect
--- function init()
--- 	haptic_effect = LoadHaptic("haptic/gun_fire.xml")
--- end
--- 
--- function tick()
--- 	if InputPressed("interact") then
--- 		PlayHapticDirectional(haptic_effect, Vec(-1, 0, 0), 1)
--- 	end
--- end
--- ```
---@param handle string Handle of haptic effect
---@param direction TVec Direction in which effect must be played
---@param amplitude number Amplidute used for calculation of Haptic effect.
function PlayHapticDirectional(handle, direction, amplitude) end

---
--- Example:
--- ```lua
--- -- Rumble infinitely
--- local haptic_effect
--- function init()
--- 	haptic_effect = LoadHaptic("haptic/gun_fire.xml")
--- end
--- 
--- function tick()
--- 	if not HapticIsPlaying(haptic_effect) then
--- 		PlayHaptic(haptic_effect, 1)
--- 	end
--- end
--- ```
---@param handle string Handle of haptic effect
---@return boolean flag is current Haptic playing or not
function HapticIsPlaying(handle) return false end

--- Register haptic as a "Tool haptic" for custom tools.
--- "Tool haptic" will be played on repeat while this tool is active.
--- Also it can be used for Active Triggers of DualSense controller
---
--- Example:
--- ```lua
--- function init()
--- 	RegisterTool("minigun", "loc@MINIGUN", "MOD/vox/minigun.vox")
--- 	toolHaptic = LoadHaptic("MOD/haptic/tool.xml")
--- 	SetToolHaptic("minigun", toolHaptic)
--- end
--- ```
---@param id string Tool unique identifier
---@param handle string Handle of haptic effect
---@param amplitude? number Amplitude multiplier. Default (1.0)
function SetToolHaptic(id, handle, amplitude) end

---
--- Example:
--- ```lua
--- -- Rumble infinitely
--- local haptic_effect
--- function init()
--- 	haptic_effect = LoadHaptic("haptic/gun_fire.xml")
--- end
--- 
--- function tick()
---     if InputDown("interact") then
---         StopHaptic(haptic_effect)
---     elseif not HapticIsPlaying(haptic_effect) then
--- 		PlayHaptic(haptic_effect, 1)
---     end
--- end
--- ```
---@param handle string Handle of haptic effect
function StopHaptic(handle) end

function GetScriptId(...) end

--- Works only for vehicles with 'customhealth' tag. 'customhealth' disables the common vehicles damage system.
--- So this function needed for custom vehicle damage systems.
---
--- Example:
--- ```lua
--- function tick()
--- 	if InputPressed("usetool") then
--- 		SetVehicleHealth(FindVehicle("car", true), 0.0)
--- 	end
--- end
--- ```
---@param vehicle number Vehicle handle
---@param health number Set vehicle health (between zero and one)
function SetVehicleHealth(vehicle, health) end

---@param trail any trail structure
---@param dt number delta time
---@return any (boolean) if trail is still dead, false otherwise
function trailUpdateCPP(trail, dt) return nil end

---@param smoke any smoke structure
---@param pos TVec position vector
---@param dt number delta time
function smokeUpdateCPP(smoke, pos, dt) end

---@param fire any fire structure
---@param pos TVec position vector
---@param dt number delta time
function fireUpdateCPP(fire, pos, dt) end

---@param explosionPos TVec explosion position
---@param count number amount
---@param vel number velocity
function explosionSparksCPP(explosionPos, count, vel) end

---@param explosionPos TVec explosion position
---@param count number amount
---@param vel number velocity
function explosionDebrisCPP(explosionPos, count, vel) end

function GetLayoutActions(...) end

function GetActionByButton(...) end

function GetButtonsByAction(...) end

function GetKeyByAction(...) end

--- This will perform a raycast query looking for water.
---
--- Example:
--- ```lua
--- function init()
--- 	--Raycast from a high point straight downwards, looking for water
--- 	local hit, d = QueryRaycast(Vec(0, 100, 0), Vec(0, -1, 0), 100)
--- 	if hit then
--- 		DebugPrint(d)
--- 	end
--- end
--- ```
---@param origin TVec Raycast origin as world space vector
---@param direction TVec Unit length raycast direction as world space vector
---@param maxDist number Raycast maximum distance. Keep this as low as possible for good performance.
---@return boolean hit True if raycast hit something
---@return number dist Hit distance from origin
---@return TVec hitPos Hit point as world space vector
function QueryRaycastWater(origin, direction, maxDist) return false, 0, Vec() end

function TornadoSpawnParticlesCPP(...) end

function TornadoBodiesSuctionCPP(...) end

function WinddustSpawnParticlesCPP(...) end

function RobotRejectAllBodiesCPP(...) end

function RobotRemoveTaggedJointsCPP(...) end

function RobotSetBodyCollisionFilterCPP(...) end

function RobotProcessSamplesCPP(...) end

function RobotFootStepCPP(...) end

function RobotSetFootConstraintsCPP(...) end

function RobotSensorGetBlockedCPP(...) end

function RobotAimUpdateCPP(...) end

function RobotHoverUprightCPP(...) end

function RobotHoverGetUpCPP(...) end

function RobotGetTransformAndAxesCPP(...) end

function RobotGetBodyParametersCPP(...) end

function RadiolinkCheckConnectionCPP(...) end

function RadiolinkDrawLinesCPP(...) end

function FxEmitSmokeCPP(...) end

--- Adds heat to shape. It works similar to blowtorch.
--- As soon as the heat of the voxel reaches a critical value, it destroys and can ignite the surrounding voxels.
---
--- Example:
--- ```lua
--- function tick(dt)
--- 	if InputDown("usetool") then
--- 		local playerCameraTransform = GetPlayerCameraTransform()
--- 		local dir = TransformToParentVec(playerCameraTransform, Vec(0, 0, -1))
--- 
--- 		-- Cast ray out of player camera and add heat to shape if we can find one
--- 		local hit, dist, normal, shape = QueryRaycast(playerCameraTransform.pos, dir, 50)
--- 
--- 		if hit then
--- 			local hitPos = VecAdd(playerCameraTransform.pos, VecScale(dir, dist))
--- 			AddHeat(shape, hitPos, 2 * dt)
--- 		end
--- 
--- 		DrawLine(VecAdd(playerCameraTransform.pos, Vec(0.5, 0, 0)), VecAdd(playerCameraTransform.pos, VecScale(dir, dist)), 1, 0, 0, 1)
--- 	end
--- end
--- ```
---@param shape number Shape handle
---@param pos TVec World space point as vector
---@param amount number amount of heat
function AddHeat(shape, pos, amount) end

--- Returns the gravity value on the scene.
---
--- Example:
--- ```lua
--- function tick()
--- 	DebugPrint(VecStr(GetGravity()))
--- end
--- ```
---@return TVec vector Gravity vector
function GetGravity() return Vec() end

--- Sets the gravity value on the scene.
--- When the scene restarts, it resets to the default value (0, -10, 0).
---
--- Example:
--- ```lua
--- local isMoonGravityEnabled = false
--- 
--- function tick()
--- 	if InputPressed("g") then
--- 		isMoonGravityEnabled = not isMoonGravityEnabled
--- 		if isMoonGravityEnabled then
--- 			SetGravity(Vec(0, -1.6, 0))
--- 		else
--- 			SetGravity(Vec(0, -10.0, 0))
--- 		end
--- 	end
--- end
--- ```
---@param vec TVec Gravity vector
function SetGravity(vec) end

--- Sets the base orientation when gravity is disabled with SetGravity.
--- This will determine what direction is "up", "right" and "forward" as
--- gravity is completely turned off.
---
--- Example:
--- ```lua
--- function tick()
--- 	SetGravity(Vec(0, 0, 0))
--- 
--- 	-- Turn player upside-down.
--- 	local base = QuatAxisAngle(Vec(1,0,0), 180)
--- 	SetPlayerOrientation(base)
--- end
--- ```
---@param orientation any Base orientation
function SetPlayerOrientation(orientation) end

--- Gets the base orientation of the player.
--- This can be used to retrieve the base orientation of the player when using a custom gravity vector.
---
--- Example:
--- ```lua
--- function tick(dt)
--- 	SetGravity(Vec(0, 0, 0))
--- 	-- Spin the player if using zero gravity
--- 	local base = QuatRotateQuat(GetPlayerOrientation(), QuatAxisAngle(Vec(1,0,0), dt))
--- 	SetPlayerOrientation(base)
--- end
--- ```
---@return TQuat orientation Player base orientation
function GetPlayerOrientation() return Quat() end

function SetMapOrientation(...) end

--- Returns the current "up" vector derived from the player's base orientation.
--- This can be used to retrieve the player's up vector when using a custom gravity vector.
---
--- Example:
--- ```lua
--- function tick(dt)
--- 	local up = GetPlayerUp()
--- end
--- ```
---@return TVec up Player up vector
function GetPlayerUp() return Vec() end

--- Returns the fps value based on general game timestep.
--- It doesn't depend on whether it is called from tick or update.
---
--- Example:
--- ```lua
--- function tick()
--- 	DebugWatch("fps", GetFps())
--- end
--- ```
---@return number fps Frames per second
function GetFps() return 0 end
--- Calling this function will disable game input, bring up the mouse pointer
--- and allow Ui interaction with the calling script without pausing the game.
--- This can be useful to make interactive user interfaces from scripts while
--- the game is running. Call this continuously every frame as long as Ui
--- interaction is desired.
---
--- Example:
--- ```lua
--- UiMakeInteractive()
--- ```
function UiMakeInteractive() end

--- Push state onto stack. This is used in combination with UiPop to
--- remember a state and restore to that state later.
---
--- Example:
--- ```lua
--- UiColor(1,0,0)
--- UiText("Red")
--- UiPush()
--- 	UiColor(0,1,0)
--- 	UiText("Green")
--- UiPop()
--- UiText("Red")
--- ```
function UiPush() end

--- Pop state from stack and make it the current one. This is used in
--- combination with UiPush to remember a previous state and go back to
--- it later.
---
--- Example:
--- ```lua
--- UiColor(1,0,0)
--- UiText("Red")
--- UiPush()
--- 	UiColor(0,1,0)
--- 	UiText("Green")
--- UiPop()
--- UiText("Red")
--- ```
function UiPop() end

---
--- Example:
--- ```lua
--- local w = UiWidth()
--- ```
---@return number width Width of draw context
function UiWidth() return 0 end

---
--- Example:
--- ```lua
--- local h = UiHeight()
--- ```
---@return number height Height of draw context
function UiHeight() return 0 end

---
--- Example:
--- ```lua
--- local c = UiCenter()
--- --Same as
--- local c = UiWidth()/2
--- ```
---@return number center Half width of draw context
function UiCenter() return 0 end

---
--- Example:
--- ```lua
--- local m = UiMiddle()
--- --Same as
--- local m = UiHeight()/2
--- ```
---@return number middle Half height of draw context
function UiMiddle() return 0 end

---
--- Example:
--- ```lua
--- --Set color yellow
--- UiColor(1,1,0)
--- ```
---@param r number Red channel
---@param g number Green channel
---@param b number Blue channel
---@param a? number Alpha channel. Default 1.0
function UiColor(r, g, b, a) end

function UiTextUnderline(...) end

--- Color filter, multiplied to all future colors in this scope
---
--- Example:
--- ```lua
--- UiPush()
--- 	--Draw menu in transparent, yellow color tint
--- 	UiColorFilter(1, 1, 0, 0.5)
--- 	drawMenu()
--- UiPop()
--- ```
---@param r number Red channel
---@param g number Green channel
---@param b number Blue channel
---@param a? number Alpha channel. Default 1.0
function UiColorFilter(r, g, b, a) end

--- Resets the ui context's color, outline color, shadow color, color filter to default values. <br>
--- Remarkable that if some component, lets call it "parent", wants to hide everyting in it's scope, <br>
--- it is possible that a child which uses UiResetColor would ignore the hide logic, if its implemented via changing opacity.
---
--- Example:
--- ```lua
--- function draw()
--- 	UiPush()
---         UiFont("bold.ttf", 44)
--- 		UiTranslate(100, 100)
--- 		UiColor(1, 0, 0)
--- 		UiText("A")
--- 		UiTranslate(100, 0)
--- 		UiResetColor()
--- 		UiText("B")
--- 	UiPop()
--- end
--- ```
function UiResetColor() end

--- Translate cursor
---
--- Example:
--- ```lua
--- UiPush()
--- 	UiTranslate(100, 0)
--- 	UiText("Indented")
--- UiPop()
--- ```
---@param x number X component
---@param y number Y component
function UiTranslate(x, y) end

--- Rotate cursor
---
--- Example:
--- ```lua
--- UiPush()
--- 	UiRotate(45)
--- 	UiText("Rotated")
--- UiPop()
--- ```
---@param angle number Angle in degrees, counter clockwise
function UiRotate(angle) end

--- Scale cursor either uniformly (one argument) or non-uniformly (two arguments)
---
--- Example:
--- ```lua
--- UiPush()
--- 	UiScale(2)
--- 	UiText("Double size")
--- UiPop()
--- ```
---@param x number X component
---@param y? number Y component. Default value is x.
function UiScale(x, y) end

--- Returns the ui context's scale
---
--- Example:
--- ```lua
--- function draw()
--- 	UiPush()
--- 		UiScale(2)
--- 		x, y = UiGetScale()
--- 		DebugPrint(x .. " " .. y)
--- 	UiPop()
--- end
--- ```
---@return number x X scale
---@return number y Y scale
function UiGetScale() return 0, 0 end

--- Specifies the area beyond which ui is cut off and not drawn.<br>
--- If inherit is true the resulting rect clip will be equal to the overlapped area of both rects
---
--- Example:
--- ```lua
--- function draw()
---     UiTranslate(200, 200)
---     UiPush()
---         UiClipRect(100, 50)
---         UiTranslate(5, 15)
---         UiFont("regular.ttf", 50)
---         UiText("Text")
---     UiPop()
--- end
--- 
--- ```
---@param width number Rect width
---@param height number Rect height
---@param inherit? boolean True if must include the parent's clip rect
function UiClipRect(width, height, inherit) end

--- Set up new bounds. Calls to UiWidth, UiHeight, UiCenter and UiMiddle
--- will operate in the context of the window size.
--- If clip is set to true, contents of window will be clipped to
--- bounds (only works properly for non-rotated windows).
---
--- Example:
--- ```lua
--- UiPush()
--- 	UiWindow(400, 200)
--- 	local w = UiWidth()
--- 	--w is now 400
--- UiPop()
--- ```
---@param width number Window width
---@param height number Window height
---@param clip? boolean Clip content outside window. Default is false.
---@param inherit? boolean Inherit current clip region (for nested clip regions)
function UiWindow(width, height, clip, inherit) end

--- Returns the top left & bottom right points of the current window
---
--- Example:
--- ```lua
--- function draw()
--- 	UiPush()
--- 		UiWindow(400, 200)
--- 		tl_x, tl_y, br_x, br_y = UiGetCurrentWindow()
--- 		-- do something
--- 	UiPop()
--- end
--- ```
---@return number tl_x Top left x
---@return number tl_y Top left y
---@return number br_x Bottom right x
---@return number br_y Bottom right y
function UiGetCurrentWindow() return 0, 0, 0, 0 end

--- True if the specified point is within the boundaries of the current window
---
--- Example:
--- ```lua
--- function draw()
--- 	UiPush()
--- 		UiWindow(400, 200)
--- 		DebugPrint("point 1: " .. tostring(UiIsInCurrentWindow(200, 100)))
---         DebugPrint("point 2: " .. tostring(UiIsInCurrentWindow(450, 100)))
--- 	UiPop()
--- end
--- ```
---@param x number X
---@param y number Y
---@return boolean val True if
function UiIsInCurrentWindow(x, y) return false end

--- Checks whether a rectangle with width w and height h is completely clipped
---
--- Example:
--- ```lua
--- function draw()
---     UiTranslate(200, 200)
---     UiPush()
---         UiClipRect(150, 150)
---         UiColor(1.0, 1.0, 1.0, 0.15)
---         UiRect(150, 150)
---         UiRect(w, h)
---         UiTranslate(-50, 30)
---         UiColor(1, 0, 0)
---         local w, h = 100, 100
---         UiRect(w, h)
---         DebugPrint(UiIsRectFullyClipped(w, h))
---     UiPop()
--- end
--- ```
---@param w number Width
---@param h number Height
---@return boolean value True if rect is fully clipped
function UiIsRectFullyClipped(w, h) return false end

--- Checks whether a point is inside the clip region
---
--- Example:
--- ```lua
--- function draw()
---     UiPush()
---         UiTranslate(200, 200)
---         UiClipRect(150, 150)
---         UiColor(1.0, 1.0, 1.0, 0.15)
---         UiRect(150, 150)
---         UiRect(w, h)
--- 
---         DebugPrint("point 1: " .. tostring(UiIsInClipRegion(250, 250)))
---         DebugPrint("point 2: " .. tostring(UiIsInClipRegion(350, 250)))
---     UiPop()
--- end
--- ```
---@param x number X
---@param y number Y
---@return boolean value True if point is in clip region
function UiIsInClipRegion(x, y) return false end

--- Checks whether a rect is overlap the clip region
---
--- Example:
--- ```lua
--- function draw()
---     UiPush()
---         UiTranslate(200, 200)
---         UiClipRect(150, 150)
---         UiColor(1.0, 1.0, 1.0, 0.15)
---         UiRect(150, 150)
---         UiRect(w, h)
--- 
---         DebugPrint("rect 1: " .. tostring(UiIsFullyClipped(200, 200)))
---         UiTranslate(200, 0)
---         DebugPrint("rect 2: " .. tostring(UiIsFullyClipped(200, 200)))
---     UiPop()
--- end
--- ```
---@param w number Width
---@param h number Height
---@return boolean value True if rect is not overlapping clip region
function UiIsFullyClipped(w, h) return false end

--- Return a safe drawing area that will always be visible regardless of
--- display aspect ratio. The safe drawing area will always be 1920 by 1080
--- in size. This is useful for setting up a fixed size UI.
---
--- Example:
--- ```lua
--- function draw()
--- 	local x0, y0, x1, y1 = UiSafeMargins()
--- 	UiTranslate(x0, y0)
--- 	UiWindow(x1-x0, y1-y0, true)
--- 	--The drawing area is now 1920 by 1080 in the center of screen
--- 	drawMenu()
--- end
--- ```
---@return number x0 Left
---@return number y0 Top
---@return number x1 Right
---@return number y1 Bottom
function UiSafeMargins() return 0, 0, 0, 0 end

--- Returns the canvas size. "Canvas" means a coordinate space in which UI is drawn
---
--- Example:
--- ```lua
--- function draw()
--- 	UiPush()
---         local canvas = UiCanvasSize()
---         UiWindow(canvas.w, canvas.h)
---         --[[
---             ...
---         ]]
--- 	UiPop()
--- end
--- ```
---@return any value Canvas width and height
function UiCanvasSize() return nil end

--- The alignment determines how content is aligned with respect to the
--- cursor.
--- BEGINTABLE Alignment -- Description
--- left	-- Horizontally align to the left
--- right	-- Horizontally align to the right
--- center	-- Horizontally align to the center
--- top		-- Vertically align to the top
--- bottom	-- Veritcally align to the bottom
--- middle	-- Vertically align to the middle
--- ENDTABLE
--- Alignment can contain combinations of these, for instance:
--- "center middle", "left top", "center top", etc. If horizontal
--- or vertical alginment is omitted it will depend on the element drawn.
--- Text, for instance has default vertical alignment at baseline.
--- 
---
--- Example:
--- ```lua
--- UiAlign("left")
--- UiText("Aligned left at baseline")
--- 
--- UiAlign("center middle")
--- UiText("Fully centered")
--- ```
---@param alignment string Alignment keywords
function UiAlign(alignment) end

--- The alignment determines how text is aligned with respect to the
--- cursor and wrap width.
--- BEGINTABLE Alignment -- Description
--- left	-- Horizontally align to the left
--- right	-- Horizontally align to the right
--- center	-- Horizontally align to the center
--- ENDTABLE
--- Alignment can contain either "center", "left", or "right"
--- 
---
--- Example:
--- ```lua
--- UiTextAlignment("left")
--- UiText("Aligned left at baseline")
--- 
--- UiTextAlignment("center")
--- UiText("Centered")
--- ```
---@param alignment string Alignment keyword
function UiTextAlignment(alignment) end

--- Disable input for everything, except what's between UiModalBegin and UiModalEnd
--- (or if modal state is popped)
---
--- Example:
--- ```lua
--- UiModalBegin()
--- if UiTextButton("Okay") then
--- 	--All other interactive ui elements except this one are disabled
--- end
--- UiModalEnd()
--- 
--- --This is also okay
--- UiPush()
--- 	UiModalBegin()
--- 	if UiTextButton("Okay") then
--- 		--All other interactive ui elements except this one are disabled
--- 	end
--- UiPop()
--- --No longer modal
--- ```
---@param force? boolean Pass true if you need to increase the priority of this modal in the context
function UiModalBegin(force) end

--- Disable input for everything, except what's between UiModalBegin and UiModalEnd
--- Calling this function is optional. Modality is part of the current state and will
--- be lost if modal state is popped.
---
--- Example:
--- ```lua
--- UiModalBegin()
--- if UiTextButton("Okay") then
--- 	--All other interactive ui elements except this one are disabled
--- end
--- UiModalEnd()
--- ```
function UiModalEnd() end

--- Disable input
---
--- Example:
--- ```lua
--- UiPush()
--- 	UiDisableInput()
--- 	if UiTextButton("Okay") then
--- 		--Will never happen
--- 	end
--- UiPop()
--- ```
function UiDisableInput() end

--- Enable input that has been previously disabled
---
--- Example:
--- ```lua
--- UiDisableInput()
--- if UiTextButton("Okay") then
--- 	--Will never happen
--- end
--- 
--- UiEnableInput()
--- if UiTextButton("Okay") then
--- 	--This can happen
--- end
--- ```
function UiEnableInput() end

--- This function will check current state receives input. This is the case
--- if input is not explicitly disabled with (with UiDisableInput) and no other
--- state is currently modal (with UiModalBegin). Input functions and UI
--- elements already do this check internally, but it can sometimes be useful
--- to read the input state manually to trigger things in the UI.
---
--- Example:
--- ```lua
--- if UiReceivesInput() then
--- 	highlightItemAtMousePointer()
--- end
--- ```
---@return boolean receives True if current context receives input
function UiReceivesInput() return false end

--- Get mouse pointer position relative to the cursor
---
--- Example:
--- ```lua
--- local x, y = UiGetMousePos()
--- ```
---@return number x X coordinate
---@return number y Y coordinate
function UiGetMousePos() return 0, 0 end

--- Returns position of mouse cursor in UI canvas space.<br>
--- The size of the canvas depends on the aspect ratio. For example, for 16:9, the maximum value will be 1920x1080, and for 16:10, it will be 1920x1200
---
--- Example:
--- ```lua
--- function draw()
--- 	local x, y = UiGetCanvasMousePos()
--- 	DebugPrint("x :" .. x .. " y:" .. y)
--- end
--- ```
---@return number x X coordinate
---@return number y Y coordinate
function UiGetCanvasMousePos() return 0, 0 end

--- Check if mouse pointer is within rectangle. Note that this function respects
--- alignment.
---
--- Example:
--- ```lua
--- if UiIsMouseInRect(100, 100) then
--- 	-- mouse pointer is in rectangle
--- end
--- ```
---@param w number Width
---@param h number Height
---@return boolean inside True if mouse pointer is within rectangle
function UiIsMouseInRect(w, h) return false end

--- Convert world space position to user interface X and Y coordinate relative
--- to the cursor. The distance is in meters and positive if in front of camera,
--- negative otherwise.
---
--- Example:
--- ```lua
--- local x, y, dist = UiWorldToPixel(point)
--- if dist > 0 then
--- UiTranslate(x, y)
--- UiText("Label")
--- end
--- ```
---@param point TVec 3D world position as vector
---@return number x X coordinate
---@return number y Y coordinate
---@return number distance Distance to point
function UiWorldToPixel(point) return 0, 0, 0 end

--- Convert X and Y UI coordinate to a world direction, as seen from current camera.
--- This can be used to raycast into the scene from the mouse pointer position.
---
--- Example:
--- ```lua
--- UiMakeInteractive()
--- local x, y = UiGetMousePos()
--- local dir = UiPixelToWorld(x, y)
--- local pos = GetCameraTransform().pos
--- local hit, dist = QueryRaycast(pos, dir, 100)
--- if hit then
--- 	DebugPrint("hit distance: " .. dist)
--- end
--- ```
---@param x number X coordinate
---@param y number Y coordinate
---@return TVec direction 3D world direction as vector
function UiPixelToWorld(x, y) return Vec() end

function UiGetRelativePos(...) end

--- Returns the ui cursor's postion
---
--- Example:
--- ```lua
--- function draw()
---     UiTranslate(100, 50)
---     x, y = UiGetCursorPos()
---     DebugPrint("x: " .. x .. "; y: " .. y)
--- end
--- ```
function UiGetCursorPos() end

--- Perform a gaussian blur on current screen content
---
--- Example:
--- ```lua
--- UiBlur(1.0)
--- drawMenu()
--- ```
---@param amount number Blur amount (0.0 to 1.0)
function UiBlur(amount) end

---
--- Example:
--- ```lua
--- UiFont("bold.ttf", 24)
--- UiText("Hello")
--- ```
---@param path string Path to TTF font file
---@param size number Font size (10 to 100)
function UiFont(path, size) end

---
--- Example:
--- ```lua
--- local h = UiFontHeight()
--- ```
---@return number size Font size
function UiFontHeight() return 0 end

---
--- Example:
--- ```lua
--- UiFont("bold.ttf", 24)
--- UiText("Hello")
--- 
--- ...
--- 
--- --Automatically advance cursor
--- UiText("First line", true)
--- UiText("Second line", true)
--- 
--- 
--- 
--- --Using links
--- UiFont("bold.ttf", 26)
--- UiTranslate(100,100)
--- --Using virtual links
--- link = "[[link;label=loc@UI_TEXT_FREE_ROAM_OPTIONS_LINK_NAME;id=options/game;color=#DDDD7FDD;underline=true]]"
--- someText = "Some text with a link: " .. link .. " and some more text"
--- 
--- w, h, x, y, linkId = UiText(someText)
--- if linkId:len() ~= 0 then
--- 	if linkId == "options/game" then
--- 		DebugPrint(linkId.." link clicked")
--- 	elseif linkId == "options/sound" then
--- 		--Do something else
--- 	end
--- end
--- UiTranslate(0,50)
--- 
--- --Using game links, id attribute is required, color is optional, same as virtual links
--- link = "[[game://options;label=loc@UI_TEXT_FREE_ROAM_OPTIONS_LINK_NAME;id=game;color=#DDDD7FDD;underline=false]]"
--- someText = "Some text with a link: " .. link .. " and some more text"
--- w, h, x, y, linkId = UiText(someText)
--- if linkId:len() ~= 0 then
--- 	DebugPrint(linkId.." link clicked")
--- end
--- UiTranslate(0,50)
--- 
--- --Using http/s links is also possible, link will be opened in the default browser
--- link = "[[http://www.example.com;label=loc@SOME_KEY;]]"
--- someText = "Goto: " .. link
--- UiText(someText)
--- 
--- ```
---@param text string Print text at cursor location
---@param move? boolean Automatically move cursor vertically. Default false.
---@param maxChars? number Maximum amount of characters. Default 100000.
---@return number w Width of text
---@return number h Height of text
---@return number x End x-position of text.
---@return number y End y-position of text.
---@return string linkId Link id of clicked link
function UiText(text, move, maxChars) return 0, 0, 0, 0, "" end

--- 
---
--- Example:
--- ```lua
--- 
--- UiFont("regular.ttf", 30)
--- UiPush()
--- 	UiTextDisableWildcards(true)
--- 	-- icon won't be embedded here, text will be left as is
--- 	UiText("Text with embedded icon image [[menu:menu_accept;iconsize=42,42]]")
--- UiPop()
--- 
--- -- embedding works as expected
--- UiText("Text with embedded icon image [[menu:menu_accept;iconsize=42,42]]")
--- ```
---@param disable boolean Enable or disable wildcard [[...]] substitution support in UiText
function UiTextDisableWildcards(disable) end

--- This function toggles the use of a fixed line height for text rendering.
--- When enabled (true), the line height is set to a constant value determined by
--- the current font metrics, ensuring uniform spacing between lines of text.
--- This mode is useful for maintaining consistent line spacing across different
--- text elements, regardless of the specific characters displayed.
--- When disabled (false), the line height adjusts dynamically to accommodate
--- the tallest character in each line of text.
--- 
---
--- Example:
--- ```lua
--- #include "script/common.lua"
--- enabled = false
--- group = 1
--- local desc = {
---     {
---         {"A mod desc without descenders"},
---         {"Author: Abcd"},
---         {"Tags: map, spawnable"},
---     },
---     {
---         {"A mod with descenders, like g, j, p, q, y"},
---         {"Author: Ggjyq"},
---         {"Tags: map, spawnable"},
---     },
--- }
--- -- Function to draw text with or without uniform line height
--- local function drawDescriptions()
---     UiAlign("top")
---     for _, text in ipairs(desc[group]) do
---         UiTextUniformHeight(enabled)
---         UiText(text[1], true)
---     end
--- end
--- 
--- function draw()
---     UiFont("regular.ttf", 22)
---     UiTranslate(100, 100)
--- 
---     UiPush()
---         local r,g,b
---         if enabled then
---             r,g,b = 0,1,0
---         else
---             r,g,b = 1,0,0
---         end
---         UiColor(0,0,0)
---         UiButtonImageBox("ui/common/box-solid-6.png", 6, 6, r,g,b)
---         if UiTextButton("Uniform height "..(enabled and "enabled" or "disabled")) then
---             enabled = not enabled
---         end
---         UiTranslate(0,35)
---         if UiTextButton(">") then
---             group = clamp(group + 1, 1, #desc)
---         end
---         UiTranslate(0,35)
---         if UiTextButton("<") then
---             group = clamp(group - 1, 1, #desc)
---         end
---     UiPop()
---     UiTranslate(0,80)
---     drawDescriptions()
--- end
--- 
--- ```
---@param uniform boolean Enable or disable fixed line height for text rendering
function UiTextUniformHeight(uniform) end

---
--- Example:
--- ```lua
--- 
--- local w, h = UiGetTextSize("Some text")
--- ```
---@param text string A text string
---@return number w Width of text
---@return number h Height of text
---@return number x Offset x-component of text AABB
---@return number y Offset y-component of text AABB
function UiGetTextSize(text) return 0, 0, 0, 0 end

---
--- Example:
--- ```lua
--- 
--- local w, h = UiMeasureText(0, "Some text", "loc@key")
--- ```
---@param space number Space between lines
---@param text/locale any ... A text strings
---@return number w Width of biggest line
---@return number h Height of all lines combined with interval
function UiMeasureText(space, text_locale) return 0, 0 end

--- Returns the symbols count in the specified text.<br>
--- This function is intended to property count symbols in UTF 8 encoded string
---
--- Example:
--- ```lua
--- function draw()
---     DebugPrint(UiGetSymbolsCount("Hello world!"))
--- end
--- ```
---@param text string Text
---@return number count Symbols count
function UiGetSymbolsCount(text) return 0 end

--- Returns the substring. This function is intended to properly work with UTF8 encoded strings
---
--- Example:
--- ```lua
--- function draw()
---     DebugPrint(UiTextSymbolsSub("Hello world", 1, 5))
--- end
--- ```
---@param text string Text
---@param from number From element index
---@param to number To element index
---@return string substring Substring
function UiTextSymbolsSub(text, from, to) return "" end

function UiTextToLower(...) end

function UiTextToUpper(...) end

---@param text string 
---@return any words 
function UiRichTextSplitByWords(text) return nil end

---
--- Example:
--- ```lua
--- UiWordWrap(200)
--- UiText("Some really long text that will get wrapped into several lines")
--- ```
---@param width number Maximum width of text
function UiWordWrap(width) end

--- Sets the context's linespacing value of the text which is drawn using UiText
---
--- Example:
--- ```lua
--- function draw()
---     UiTextLineSpacing(10)
--- 	UiWordWrap(200)
--- 	UiText("TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT")
--- end
--- ```
---@param value number Text linespacing
function UiTextLineSpacing(value) end

---
--- Example:
--- ```lua
--- --Black outline, standard thickness
--- UiTextOutline(0,0,0,1)
--- UiText("Text with outline")
--- ```
---@param r number Red channel
---@param g number Green channel
---@param b number Blue channel
---@param a number Alpha channel
---@param thickness? number Outline thickness. Default is 0.1
function UiTextOutline(r, g, b, a, thickness) end

---
--- Example:
--- ```lua
--- --Black drop shadow, 50% transparent, distance 2
--- UiTextShadow(0, 0, 0, 0.5, 2.0)
--- UiText("Text with drop shadow")
--- ```
---@param r number Red channel
---@param g number Green channel
---@param b number Blue channel
---@param a number Alpha channel
---@param distance? number Shadow distance. Default is 1.0
---@param blur? number Shadow blur. Default is 0.5
function UiTextShadow(r, g, b, a, distance, blur) end

--- Draw solid rectangle at cursor position
---
--- Example:
--- ```lua
--- --Draw full-screen black rectangle
--- UiColor(0, 0, 0)
--- UiRect(UiWidth(), UiHeight())
--- 
--- --Draw smaller, red, rotating rectangle in center of screen
--- UiPush()
--- 	UiColor(1, 0, 0)
--- 	UiTranslate(UiCenter(), UiMiddle())
--- 	UiRotate(GetTime())
--- 	UiAlign("center middle")
--- 	UiRect(100, 100)
--- UiPop()
--- ```
---@param w number Width
---@param h number Height
function UiRect(w, h) end

--- Draw rectangle outline at cursor position
---
--- Example:
--- ```lua
--- --Draw a red rotating rectangle outline in center of screen
--- UiPush()
--- 	UiColor(1, 0, 0)
--- 	UiTranslate(UiCenter(), UiMiddle())
--- 	UiRotate(GetTime())
--- 	UiAlign("center middle")
--- 	UiRectOutline(100, 100, 5)
--- UiPop()
--- ```
---@param width number Rectangle width
---@param height number Rectangle height
---@param thickness number Rectangle outline thickness
function UiRectOutline(width, height, thickness) end

--- Draw a solid rectangle with round corners of specified radius
---
--- Example:
--- ```lua
--- UiPush()
--- 	UiColor(1, 0, 0)
--- 	UiTranslate(UiCenter(), UiMiddle())
--- 	UiRotate(GetTime())
--- 	UiAlign("center middle")
--- 	UiRoundedRect(100, 100, 8)
--- UiPop()
--- ```
---@param width number Rectangle width
---@param height number Rectangle height
---@param roundingRadius number Round corners radius
function UiRoundedRect(width, height, roundingRadius) end

--- Draw rectangle outline with round corners at cursor position
---
--- Example:
--- ```lua
--- UiPush()
--- 	UiColor(1, 0, 0)
--- 	UiTranslate(UiCenter(), UiMiddle())
--- 	UiRotate(GetTime())
--- 	UiAlign("center middle")
--- 	UiRoundedRectOutline(100, 100, 20, 5)
--- UiPop()
--- ```
---@param width number Rectangle width
---@param height number Rectangle height
---@param roundingRadius number Round corners radius
---@param thickness number Rectangle outline thickness
function UiRoundedRectOutline(width, height, roundingRadius, thickness) end

--- Draw a solid circle at cursor position
---
--- Example:
--- ```lua
--- UiPush()
--- 	UiColor(1, 0, 0)
--- 	UiTranslate(UiCenter(), UiMiddle())
--- 	UiAlign("center middle")
--- 	UiCircle(100)
--- UiPop()
--- ```
---@param radius number Circle radius
function UiCircle(radius) end

--- Draw a circle outline at cursor position
---
--- Example:
--- ```lua
--- --Draw a red rotating rectangle outline in center of screen
--- UiPush()
--- 	UiColor(1, 0, 0)
--- 	UiTranslate(UiCenter(), UiMiddle())
--- 	UiAlign("center middle")
--- 	UiCircleOutline(100, 8)
--- UiPop()
--- ```
---@param radius number Circle radius
---@param thickness number Circle outline thickness
function UiCircleOutline(radius, thickness) end

--- Image to fill for UiRoundedRect, UiCircle
---
--- Example:
--- ```lua
--- UiPush()
--- 	UiFillImage("ui/hud/tutorial/plank-lift.jpg")
--- 	UiTranslate(UiCenter(), UiMiddle())
--- 	UiRotate(GetTime())
--- 	UiAlign("center middle")
--- 	UiRoundedRect(100, 100, 8)
--- UiPop()
--- ```
---@param path string Path to image (PNG or JPG format)
function UiFillImage(path) end

function UiRectBgBlur(...) end

--- Draw image at cursor position. If x0, y0, x1, y1 is provided a cropped version
--- will be drawn in that coordinate range.
---
--- Example:
--- ```lua
--- --Draw image in center of screen
--- UiPush()
--- 	UiTranslate(UiCenter(), UiMiddle())
--- 	UiAlign("center middle")
--- 	UiImage("test.png")
--- UiPop()
--- ```
---@param path string Path to image (PNG or JPG format)
---@param x0? number Lower x coordinate (default is 0)
---@param y0? number Lower y coordinate (default is 0)
---@param x1? number Upper x coordinate (default is image width)
---@param y1? number Upper y coordinate (default is image height)
---@return number w Width of drawn image
---@return number h Height of drawn image
function UiImage(path, x0, y0, x1, y1) return 0, 0 end

function UiImageAlpha(...) end

function UiImageOverlayAlpha(...) end

--- Unloads a texture from the memory
---
--- Example:
--- ```lua
--- local image = "gfx/cursor.png"
--- 
--- function draw()
---     UiTranslate(300, 300)
--- 	if UiHasImage(image) then
--- 		if InputDown("interact") then
--- 			UiUnloadImage("img/background.jpg")
--- 		else
--- 			UiImage(image)
--- 		end
--- 	end
--- end
--- ```
---@param path string Path to image (PNG or JPG format)
function UiUnloadImage(path) end

---
--- Example:
--- ```lua
--- local image = "gfx/circle.png"
--- 
--- function draw()
--- 	if UiHasImage(image) then
--- 		DebugPrint("image " .. image .. " exists")
--- 	end
--- end
--- ```
---@param path string Path to image (PNG or JPG format)
---@return boolean exists Does the image exists at the specified path
function UiHasImage(path) return false end

--- Get image size
---
--- Example:
--- ```lua
--- local w,h = UiGetImageSize("test.png")
--- ```
---@param path string Path to image (PNG or JPG format)
---@return number w Image width
---@return number h Image height
function UiGetImageSize(path) return 0, 0 end

--- Draw 9-slice image at cursor position. Width should be at least 2*borderWidth.
--- Height should be at least 2*borderHeight.
---
--- Example:
--- ```lua
--- UiImageBox("menu-frame.png", 200, 200, 10, 10)
--- ```
---@param path string Path to image (PNG or JPG format)
---@param width number Width
---@param height number Height
---@param borderWidth? number Border width. Default 0
---@param borderHeight? number Border height. Default 0
function UiImageBox(path, width, height, borderWidth, borderHeight) end

--- UI sounds are not affected by acoustics simulation. Use LoadSound / PlaySound for that.
---
--- Example:
--- ```lua
--- UiSound("click.ogg")
--- ```
---@param path string Path to sound file (OGG format)
---@param volume? number Playback volume. Default 1.0
---@param pitch? number Playback pitch. Default 1.0
---@param panAzimuth? number Playback stereo panning azimuth (-PI to PI). Default 0.0.
---@param panDepth? number Playback stereo panning depth (0.0 to 1.0). Default 1.0.
function UiSound(path, volume, pitch, panAzimuth, panDepth) end

--- Call this continuously to keep playing loop.
--- UI sounds are not affected by acoustics simulation. Use LoadLoop / PlayLoop for that.
---
--- Example:
--- ```lua
--- if animating then
--- 	UiSoundLoop("screech.ogg")
--- end
--- ```
---@param path string Path to looping sound file (OGG format)
---@param volume? number Playback volume. Default 1.0
---@param pitch? number Playback pitch. Default 1.0
function UiSoundLoop(path, volume, pitch) end

--- Mute game audio and optionally music for the next frame. Call
--- continuously to stay muted.
---
--- Example:
--- ```lua
--- if menuOpen then
--- 	UiMute(1.0)
--- end
--- ```
---@param amount number Mute by this amount (0.0 to 1.0)
---@param music? boolean Mute music as well
function UiMute(amount, music) end

--- Set up 9-slice image to be used as background for buttons.
---
--- Example:
--- ```lua
--- UiButtonImageBox("button-9slice.png", 10, 10)
--- if UiTextButton("Test") then
--- 	...
--- end
--- ```
---@param path string Path to image (PNG or JPG format)
---@param borderWidth number Border width
---@param borderHeight number Border height
---@param r? number Red multiply. Default 1.0
---@param g? number Green multiply. Default 1.0
---@param b? number Blue multiply. Default 1.0
---@param a? number Alpha channel. Default 1.0
function UiButtonImageBox(path, borderWidth, borderHeight, r, g, b, a) end

--- Link color.
---
--- Example:
--- ```lua
--- UiLinkColor(1, 0, 0)
--- w,h,linkId = UiText("[[link;href=Click me;id=myId]]")
--- if linkId == "myId"
--- 	...
--- end
--- ```
---@param r number Red multiply
---@param g number Green multiply
---@param b number Blue multiply
---@param a? number Alpha channel. Default 1.0
function UiLinkColor(r, g, b, a) end

--- Button color filter when hovering mouse pointer.
---
--- Example:
--- ```lua
--- UiButtonHoverColor(1, 0, 0)
--- if UiTextButton("Test") then
--- 	...
--- end
--- ```
---@param r number Red multiply
---@param g number Green multiply
---@param b number Blue multiply
---@param a? number Alpha channel. Default 1.0
function UiButtonHoverColor(r, g, b, a) end

--- Button color filter when pressing down.
---
--- Example:
--- ```lua
--- UiButtonPressColor(0, 1, 0)
--- if UiTextButton("Test") then
--- 	...
--- end
--- ```
---@param r number Red multiply
---@param g number Green multiply
---@param b number Blue multiply
---@param a? number Alpha channel. Default 1.0
function UiButtonPressColor(r, g, b, a) end

--- The button offset when being pressed
---
--- Example:
--- ```lua
--- UiButtonPressDistance(4, 4)
--- if UiTextButton("Test") then
--- 	...
--- end
--- ```
---@param distX number Press distance along X axis
---@param distY number Press distance along Y axis
function UiButtonPressDist(distX, distY) end

--- indicating how to handle text overflow.
--- Possible values are:
--- 0 - AsIs,
--- 1 - Slide,
--- 2 - Truncate,
--- 3 - Fade,
--- 4 - Resize (Default)
---
--- Example:
--- ```lua
--- UiButtonTextHandling(1)
--- if UiTextButton("Test") then
--- 	...
--- end
--- ```
---@param type number One of the enum value
function UiButtonTextHandling(type) end

---
--- Example:
--- ```lua
--- if UiTextButton("Test") then
--- 	...
--- end
--- ```
---@param text string Text on button
---@param w? number Button width
---@param h? number Button height
---@return boolean pressed True if user clicked button
function UiTextButton(text, w, h) return false end

---
--- Example:
--- ```lua
--- if UiImageButton("image.png") then
--- 	...
--- end
--- ```
---@param path string Image path (PNG or JPG file)
---@return boolean pressed True if user clicked button
function UiImageButton(path) return false end

---
--- Example:
--- ```lua
--- if UiBlankButton(30, 30) then
--- 	...
--- end
--- ```
---@param w number Button width
---@param h number Button height
---@return boolean pressed True if user clicked button
function UiBlankButton(w, h) return false end

---
--- Example:
--- ```lua
--- value = UiSlider("dot.png", "x", value, 0, 100)
--- ```
---@param path string Image path (PNG or JPG file)
---@param axis string Drag axis, must be "x" or "y"
---@param current number Current value
---@param min number Minimum value
---@param max number Maximum value
---@return number value New value, same as current if not changed
---@return boolean done True if user is finished changing (released slider)
function UiSlider(path, axis, current, min, max) return 0, false end

--- Sets the slider hover color filter
---
--- Example:
--- ```lua
--- local slider = 0
--- 
--- function draw()
---     local thumbPath = "common/thumb_I218_249_2430_49029.png"
---     UiTranslate(200, 200)
---     UiPush()
---         UiMakeInteractive()
---         UiPush()
---             UiAlign("top right")
---             UiTranslate(40, 3.4)
---             UiColor(0.5291666388511658, 0.5291666388511658, 0.5291666388511658, 1)
---             UiFont("regular.ttf", 27)
---             UiText("slider")
---         UiPop()
---         UiTranslate(45.0, 3.0)
---         UiPush()
---             UiTranslate(0, 4.0)
---             UiImageBox("common/rect_c#ffffff_o0.10_cr3.png", 301.0, 12.0, 4, 4)
---         UiPop()
---         UiTranslate(2, 0)
---         UiSliderHoverColorFilter(1.0, 0.2, 0.2)
---         UiSliderThumbSize(8, 20)
---         slider = UiSlider(thumbPath, "x", slider * 295, 0, 295) / 295
---     UiPop()
--- end
--- ```
---@param r number Red channel
---@param g number Green channel
---@param b number Blue channel
---@param a number Alpha channel
function UiSliderHoverColorFilter(r, g, b, a) end

--- Sets the slider thumb size
---
--- Example:
--- ```lua
--- local slider = 0
--- 
--- function draw()
---     local thumbPath = "common/thumb_I218_249_2430_49029.png"
---     UiTranslate(200, 200)
---     UiPush()
---         UiMakeInteractive()
---         UiPush()
---             UiAlign("top right")
---             UiTranslate(40, 3.4)
---             UiColor(0.5291666388511658, 0.5291666388511658, 0.5291666388511658, 1)
---             UiFont("regular.ttf", 27)
---             UiText("slider")
---         UiPop()
---         UiTranslate(45.0, 3.0)
---         UiPush()
---             UiTranslate(0, 4.0)
---             UiImageBox("common/rect_c#ffffff_o0.10_cr3.png", 301.0, 12.0, 4, 4)
---         UiPop()
---         UiTranslate(2, 0)
---         UiSliderHoverColorFilter(1.0, 0.2, 0.2)
---         UiSliderThumbSize(8, 20)
---         slider = UiSlider(thumbPath, "x", slider * 295, 0, 295) / 295
---     UiPop()
--- end
--- ```
---@param width number Thumb width
---@param height number Thumb height
function UiSliderThumbSize(width, height) end

--- DEPRECATED_ALERT
--- Implements a field for entering text from the keyboard or on-screen keyboard for consoles
---
--- Example:
--- ```lua
--- function draw()
---     UiMakeInteractive()
--- 	UiPush()
---         local tw = 500
---         local th = 42
---         UiTranslate(100, 100)
---         UiColor(1,1,1, 0.8)
---         UiImageBox("ui/common/box-outline-4.png", tw, th, 12, 12)
---         UiColor(1,1,1)
---         UiFont("regular.ttf", 26)
---         local newText = UiTextInput(gFilterText, tw, th, gFocusText)
---         if string.len(newText) > 20 then
---             newText = string.sub(newText, 1, 20)
---         end
---         gFocusText = false
---         if gFilterText == "" then
---             UiColor(1,1,1,0.5)
---             UiTranslate(10, 30)
---             UiText("loc@UI_TEXT_SEARCH")
---         else
---             UiTranslate(tw-32, 10)
---             UiColor(1,1,1)
---             if not isGamepad then
---                 if UiImageButton("ui/common/close.png") then
---                     newText = ""
---                     gFocusText = true
---                 end
---             end
---         end
---         if newText ~= gFilterText then
---             gFilterText = newText
---         end
--- 	UiPop()
--- end
--- ```
---@param str string Text inside input field
---@param width number Input field width
---@param height number Input field height
---@param focus boolean Usage in game code suggests this parameter should be set to true for 1 frame to request focus
---@param hideCursor? boolean Hide the blinking cursor even if the field is in focus
---@return string value Potentially altered text
---@return boolean active Does the field active
function UiTextInput(str, width, height, focus, hideCursor) return "", false end

function UiTextInputKeyBoardShortCutKey(...) end

---
--- Example:
--- ```lua
--- --Turn off screen running current script
--- screen = UiGetScreen()
--- SetScreenEnabled(screen, false)
--- ```
---@return number handle Handle to the screen running this script or zero if none.
function UiGetScreen() return 0 end

function GetDisplayCount(...) end

function GetDisplayName(...) end

--- DEPRECATED_ALERT
---
--- Example:
--- ```lua
--- function draw()
--- 	DebugWatch("val", GetDisplayResolutionCount(0, 0))
--- end
--- ```
---@param display number Number of display
---@param mode number 0 - fullscreen, 1 - windowed, 2 - borderless, 3 - count
---@return number val Display resolution count
function GetDisplayResolutionCount(display, mode) return 0 end

function GetDisplayResolution(...) end

function UiDrawLater(...) end

function UiAddDrawObject(...) end

function UiRemoveDrawObject(...) end

--- Declares a navigation component which participates in navigation using dpad buttons of a gamepad.
--- It's an abstract entity which can be focused. It has it's own size and position on screen accroding to
--- UI cursor and passed arguments, but it won't be drawn on the screen.
--- Note that all navigation components which are located outside of UiWindow borders won't participate
--- in the navigation and will be considered as inactive
---
--- Example:
--- ```lua
--- function draw()
---     -- window declaration is necessary for navigation to work
---     UiWindow(1920, 1080)
---     if LastInputDevice() == UI_DEVICE_GAMEPAD then
--- 		-- active mouse cursor has higher priority over the gamepad control
--- 		-- so it will reset focused components if the mouse moves
---         UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
---     end
---     UiTranslate(960, 540)
---     local id = UiNavComponent(100, 20)
---     local isInFocus = UiIsComponentInFocus(id)
---     if isInFocus then
---         local rect = UiFocusedComponentRect()
---         DebugPrint("Position: (" .. tostring(rect.x) .. ", " .. tostring(rect.y) .. "), Size: (" .. tostring(rect.w) .. ", " .. tostring(rect.h) .. ")")
---     end
--- end
--- ```
---@param w number Width of the component
---@param h number Height of the component
---@return string id Generated ID of the component which can be used to get an info about the component state
function UiNavComponent(w, h) return "" end

--- Sets a flag to ingore the navgation in a current UI scope or not. By default, if argument isn't
--- specified, the function sets the flag to true. If ignore is set to true, all components after the function call
--- won't participate in navigation as if they didn't exist on a scene. Flag resets back to false
--- after leaving the UI scope in which the function was called.
---
--- Example:
--- ```lua
--- function draw()
---     -- window declaration is necessary for navigation to work
---     UiWindow(1920, 1080)
---     if LastInputDevice() == UI_DEVICE_GAMEPAD then
--- 		-- active mouse cursor has higher priority over the gamepad control
--- 		-- so it will reset focused components if the mouse moves
---         UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
---     end
---     UiTranslate(960, 540)
---     UiNavComponent(100, 20)
--- 
--- 	UiTranslate(150, 40)
--- 	UiPush()
--- 		UiIgnoreNavigation(true)
--- 		local id = UiNavComponent(100, 20)
--- 		local isInFocus = UiIsComponentInFocus(id)
--- 		-- will be always "false"
--- 		DebugPrint(isInFocus)
--- 	UiPop()
--- end
--- ```
---@param ignore? boolean Whether ignore the navigation in a current UI scope or not.
function UiIgnoreNavigation(ignore) end

--- Resets navigation state as if none componets before the function call were declared
---
--- Example:
--- ```lua
--- function draw()
---     -- window declaration is necessary for navigation to work
---     UiWindow(1920, 1080)
---     if LastInputDevice() == UI_DEVICE_GAMEPAD then
--- 		-- active mouse cursor has higher priority over the gamepad control
--- 		-- so it will reset focused components if the mouse moves
---         UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
---     end
---     UiTranslate(960, 540)
---     local id = UiNavComponent(100, 20)
--- 
--- 	UiResetNavigation()
--- 	UiTranslate(150, 40)
--- 	UiNavComponent(100, 20)
--- 
--- 	local isInFocus = UiIsComponentInFocus(id)
--- 	-- will be always "false"
--- 	DebugPrint(isInFocus)
--- end
--- ```
function UiResetNavigation() end

--- Skip update of the whole navigation state in a current draw. Could be used to override
--- behaviour of navigation in some cases. See an example.
---
--- Example:
--- ```lua
--- function draw()
---     -- window declaration is necessary for navigation to work
---     UiWindow(1920, 1080)
---     if LastInputDevice() == UI_DEVICE_GAMEPAD then
--- 		-- active mouse cursor has higher priority over the gamepad control
--- 		-- so it will reset focused components if the mouse moves
---         UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
---     end
---     UiTranslate(960, 540)
--- 	UiNavComponent(100, 20)
--- 
--- 	UiTranslate(0, 50)
---     local id = UiNavComponent(100, 20)
--- 	local isInFocus = UiIsComponentInFocus(id)
--- 
--- 	if isInFocus and InputPressed("menu_up") then
--- 		-- don't let navigation to update and if component in focus
--- 		-- and do different action
--- 		UiNavSkipUpdate()
--- 		DebugPrint("Navigation action UP is overrided")
--- 	end
--- end
--- ```
function UiNavSkipUpdate() end

--- Returns the flag whether the component with specified id is in focus or not
---
--- Example:
--- ```lua
--- function draw()
---     -- window declaration is necessary for navigation to work
---     UiWindow(1920, 1080)
---     if LastInputDevice() == UI_DEVICE_GAMEPAD then
--- 		-- active mouse cursor has higher priority over the gamepad control
--- 		-- so it will reset focused components if the mouse moves
---         UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
---     end
--- 
---     UiTranslate(960, 540)
--- 
--- 	local gId = UiNavGroupBegin()
--- 
--- 	UiNavComponent(100, 20)
--- 	UiTranslate(0, 50)
---     local id = UiNavComponent(100, 20)
--- 	local isInFocus = UiIsComponentInFocus(id)
--- 
--- 	UiNavGroupEnd()
--- 
--- 	local groupInFocus = UiIsComponentInFocus(gId)
--- 
--- 
--- 	if isInFocus then
--- 		DebugPrint(groupInFocus)
--- 	end
--- end
--- ```
---@param id string Navigation id of the component
---@return boolean focus Flag whether the component in focus on not
function UiIsComponentInFocus(id) return false end

--- Begins a scope of a new navigation group. Navigation group is an entity which aggregates
--- all navigation components which was declared in it's scope. The group becomes a parent entity
--- for all aggregated components including inner group declarations. During the navigation update process
--- the game engine first checks the focused componet for proximity to components in the same group,
--- and then if none neighbour was found the engine starts to search for the closest group and the
--- closest component inside that group.
--- Navigation group has the same properties as navigation component, that is id, width and height.
--- Group size depends on its children common bounding box or it can be set explicitly.
--- Group is considered in focus if any of its child is in focus.
---
--- Example:
--- ```lua
--- function draw()
---     -- window declaration is necessary for navigation to work
---     UiWindow(1920, 1080)
---     if LastInputDevice() == UI_DEVICE_GAMEPAD then
--- 		-- active mouse cursor has higher priority over the gamepad control
--- 		-- so it will reset focused components if the mouse moves
---         UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
---     end
--- 
---     UiTranslate(960, 540)
--- 
--- 	local gId = UiNavGroupBegin()
--- 
--- 	UiNavComponent(100, 20)
--- 	UiTranslate(0, 50)
---     local id = UiNavComponent(100, 20)
--- 	local isInFocus = UiIsComponentInFocus(id)
--- 
--- 	UiNavGroupEnd()
--- 
--- 	local groupInFocus = UiIsComponentInFocus(gId)
--- 
--- 
--- 	if isInFocus then
--- 		DebugPrint(groupInFocus)
--- 	end
--- end
--- ```
---@param id? string Name of navigation group. If not presented, will be generated automatically.
---@return string id Generated ID of the group which can be used to get an info about the group state
function UiNavGroupBegin(id) return "" end

--- Ends a scope of a new navigation group. All components before that call become
--- children of that navigation group.
---
--- Example:
--- ```lua
--- function draw()
---     -- window declaration is necessary for navigation to work
---     UiWindow(1920, 1080)
---     if LastInputDevice() == UI_DEVICE_GAMEPAD then
--- 		-- active mouse cursor has higher priority over the gamepad control
--- 		-- so it will reset focused components if the mouse moves
---         UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
---     end
--- 
---     UiTranslate(960, 540)
--- 
--- 	local gId = UiNavGroupBegin()
--- 
--- 	UiNavComponent(100, 20)
--- 	UiTranslate(0, 50)
---     local id = UiNavComponent(100, 20)
--- 	local isInFocus = UiIsComponentInFocus(id)
--- 
--- 	UiNavGroupEnd()
--- 
--- 	local groupInFocus = UiIsComponentInFocus(gId)
--- 
--- 
--- 	if isInFocus then
--- 		DebugPrint(groupInFocus)
--- 	end
--- end
--- ```
function UiNavGroupEnd() end

--- Set a size of current navigation group explicitly. Can be used in cases when it's needed
--- to limit area occupied by the group or make it bigger than total occupied area by children
--- in order to catch focus from near neighbours.
---
--- Example:
--- ```lua
--- function draw()
---     -- window declaration is necessary for navigation to work
---     UiWindow(1920, 1080)
---     if LastInputDevice() == UI_DEVICE_GAMEPAD then
--- 		-- active mouse cursor has higher priority over the gamepad control
--- 		-- so it will reset focused components if the mouse moves
---         UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
---     end
--- 
--- 	UiTranslate(960, 540)
--- 
--- 	local gId = UiNavGroupBegin()
--- 	UiNavGroupSize(500, 300)
--- 
--- 	UiNavComponent(100, 20)
--- 	UiTranslate(0, 50)
---     local id = UiNavComponent(100, 20)
--- 	local isInFocus = UiIsComponentInFocus(id)
--- 
--- 	UiNavGroupEnd()
--- 
--- 	local groupInFocus = UiIsComponentInFocus(gId)
--- 
---     if groupInFocus then
--- 		-- get a rect of the focused component parent
---         local rect = UiFocusedComponentRect(1)
---         DebugPrint("Position: (" .. tostring(rect.x) .. ", " .. tostring(rect.y) .. "), Size: (" .. tostring(rect.w) .. ", " .. tostring(rect.h) .. ")")
---     end
--- end
--- ```
---@param w number Width of the component
---@param h number Height of the component
function UiNavGroupSize(w, h) end

--- Force focus to the component with specified id.
---
--- Example:
--- ```lua
--- function draw()
---     -- window declaration is necessary for navigation to work
---     UiWindow(1920, 1080)
---     if LastInputDevice() == UI_DEVICE_GAMEPAD then
---         -- active mouse cursor has higher priority over the gamepad control
---         -- so it will reset focused components if the mouse moves
---         UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
---     end
--- 
--- 	UiPush()
--- 
---     UiTranslate(960, 540)
--- 
---     local id1 = UiNavComponent(100, 20)
---     UiTranslate(0, 50)
---     local id2 = UiNavComponent(100, 20)
--- 
--- 	UiPop()
--- 
---     local f1 = UiIsComponentInFocus(id1)
---     local f2 = UiIsComponentInFocus(id2)
--- 
---     local rect = UiFocusedComponentRect()
---     UiPush()
---         UiColor(1, 0, 0)
---         UiTranslate(rect.x, rect.y)
---         UiRect(rect.w, rect.h)
---     UiPop()
--- 
---     if InputPressed("menu_accept") then
---         UiForceFocus(id2)
---     end
--- end
--- ```
---@param id string Id of the component
function UiForceFocus(id) end

--- Returns an id of the currently focused component
---
--- Example:
--- ```lua
--- function draw()
---     -- window declaration is necessary for navigation to work
---     UiWindow(1920, 1080)
---     if LastInputDevice() == UI_DEVICE_GAMEPAD then
---         -- active mouse cursor has higher priority over the gamepad control
---         -- so it will reset focused components if the mouse moves
---         UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
---     end
--- 
--- 	UiPush()
--- 
---     UiTranslate(960, 540)
--- 
---     local id1 = UiNavComponent(100, 20)
---     UiTranslate(0, 50)
---     local id2 = UiNavComponent(100, 20)
--- 
--- 	UiPop()
--- 
---     local f1 = UiIsComponentInFocus(id1)
---     local f2 = UiIsComponentInFocus(id2)
--- 
---     local rect = UiFocusedComponentRect()
---     UiPush()
---         UiColor(1, 0, 0)
---         UiTranslate(rect.x, rect.y)
---         UiRect(rect.w, rect.h)
---     UiPop()
--- 
---     DebugPrint(UiFocusedComponentId())
--- end
--- ```
---@return string id Id of the focused component
function UiFocusedComponentId() return "" end

--- Returns a bounding rect of the currently focused component. If the arg "n" is specified
--- the function return a rect of the n-th parent group of the component.
--- The rect contains the following fields:
--- w - width of the component
--- h - height of the component
--- x - x position of the component on the canvas
--- y - y position of the component on the canvas
---
--- Example:
--- ```lua
--- function draw()
---     -- window declaration is necessary for navigation to work
---     UiWindow(1920, 1080)
---     if LastInputDevice() == UI_DEVICE_GAMEPAD then
---         -- active mouse cursor has higher priority over the gamepad control
---         -- so it will reset focused components if the mouse moves
---         UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
---     end
--- 
---     UiPush()
--- 
---     UiTranslate(960, 540)
--- 
---     local id1 = UiNavComponent(100, 20)
---     UiTranslate(0, 50)
---     local id2 = UiNavComponent(100, 20)
--- 
---     UiPop()
--- 
---     local f1 = UiIsComponentInFocus(id1)
---     local f2 = UiIsComponentInFocus(id2)
--- 
---     local rect = UiFocusedComponentRect()
---     UiPush()
---         UiColor(1, 0, 0)
---         UiTranslate(rect.x, rect.y)
---         UiRect(rect.w, rect.h)
---     UiPop()
--- end
--- ```
---@param n? number Take n-th parent of the focused component insetad of the component itself
---@return any rect Rect object with info about the component bounding rectangle
function UiFocusedComponentRect(n) return nil end

function ProsHasActiveQRCode(...) end

function ProsRequestQRCode(...) end

function ProsIsAccountLinked(...) end

function ProsBrowseToQRLink(...) end

function ProhibitScreenRecord(...) end

function PermitScreenRecord(...) end

--- Returns the last ui item size
---
--- Example:
--- ```lua
--- function draw()
---     UiTranslate(200, 200)
---     UiPush()
---         UiBeginFrame()
---             UiFont("regular.ttf", 30)
---             UiText("Text")
---         UiEndFrame()
---         w, h = UiGetItemSize()
---         DebugPrint(w .. " " .. h)
---     UiPop()
--- end
--- ```
---@return number x Width
---@return number y Height
function UiGetItemSize() return 0, 0 end

--- Enables/disables auto autotranslate function when measuring the item size
---
--- Example:
--- ```lua
--- function draw()
---     UiPush()
---         UiBeginFrame()
---             if InputDown("interact") then
---                 UiAutoTranslate(false)
---             else
---                 UiAutoTranslate(true)
---             end
--- 
---             UiRect(50, 50)
---             local w, h = UiGetItemSize()
---             DebugPrint(math.ceil(w) .. "x" .. math.ceil(h))
---         UiEndFrame()
---     UiPop()
--- end
--- ```
---@param value boolean 
function UiAutoTranslate(value) end

--- Call to start measuring the content size. After drawing part of the
--- interface, call UiEndFrame to get its size. Useful when you want the
--- size of the image box to match the size of the content.
---
--- Example:
--- ```lua
--- function draw()
--- 	UiPush()
---         UiBeginFrame()
---             UiColor(1.0, 1.0, 0.8)
---             UiTranslate(UiCenter(), 300)
---             UiFont("bold.ttf", 40)
---             UiText("Hello")
---         local panelWidth, panelHeight = UiEndFrame()
---         DebugPrint(math.ceil(panelWidth) .. "x" .. math.ceil(panelHeight))
---     UiPop()
--- end
--- ```
function UiBeginFrame() end

--- Resets the current frame measured values
---
--- Example:
--- ```lua
--- function draw()
---     UiPush()
---         UiTranslate(UiCenter(), 300)
---         UiFont("bold.ttf", 40)
---         UiBeginFrame()
---             UiTextButton("Button1")
---             UiTranslate(200, 0)
---             UiTextButton("Button2")
---         UiResetFrame()
---         local panelWidth, panelHeight = UiEndFrame()
---         DebugPrint("w: " .. panelWidth .. "; h:" .. panelHeight)
---     UiPop()
--- end
--- ```
function UiResetFrame() end

--- Occupies some space for current frame (between UiBeginFrame and UiEndFrame)
---
--- Example:
--- ```lua
--- function draw()
--- 	UiPush()
---         UiBeginFrame()
---             UiColor(1.0, 1.0, 0.8)
---             UiRect(200, 200)
---             UiRect(300, 200)
---             UiFrameOccupy(500, 500)
---         local panelWidth, panelHeight = UiEndFrame()
---         DebugPrint(math.ceil(panelWidth) .. "x" .. math.ceil(panelHeight))
---     UiPop()
--- end
--- ```
---@param width number Width
---@param height number Height
function UiFrameOccupy(width, height) end

---
--- Example:
--- ```lua
--- function draw()
--- 	UiPush()
---         UiBeginFrame()
---             UiColor(1.0, 1.0, 0.8)
---             UiRect(200, 200)
---             UiRect(300, 200)
---         local panelWidth, panelHeight = UiEndFrame()
---         DebugPrint(math.ceil(panelWidth) .. "x" .. math.ceil(panelHeight))
---     UiPop()
--- end
--- ```
---@return number width Width of content drawn between since UiBeginFrame was called
---@return number height Height of content drawn between since UiBeginFrame was called
function UiEndFrame() return 0, 0 end

--- Sets whether to skip items in current ui scope for current ui frame. This items won't affect on the frame size
---
--- Example:
--- ```lua
--- function draw()
--- 	UiPush()
--- 		UiBeginFrame()
--- 			UiFrameSkipItem(true)
--- 			--[[
--- 				...
--- 			]]
--- 		UiEndFrame()
--- 	UiPop()
--- end
--- ```
---@param skip boolean Should skip item
function UiFrameSkipItem(skip) end

---
--- Example:
--- ```lua
--- function draw()
--- 	local fNo = GetFrame()
--- 	DebugPrint(fNo)
--- end
--- ```
---@return number frameNo Frame number since the level start
function UiGetFrameNo() return 0 end

---
--- Example:
--- ```lua
--- local n = UiGetLanguage()
--- ```
---@return number index Language index
function UiGetLanguage() return 0 end

function UiSetProsModFilter(...) end

function UiGetProsModNumber(...) end

function UiGetModsNumber(...) end

function UiGetProsModAt(...) end

function UiGetModsList(...) end

function UiGetProsModRange(...) end

function UiGetModById(...) end

function UiSelectProsMod(...) end

function UiSelectedProsModInfo(...) end

function UiProsIsPreviewReady(...) end

function UiSubscribeToProsMod(...) end

function UiUnsubscribeFromProsMod(...) end

function UiLikeProsMod(...) end

function UiDislikeProsMod(...) end

--- Possible values are: <br> 0 - show cursor (UI_CURSOR_SHOW) <br> 1 - hide cursor (UI_CURSOR_HIDE) <br> 2 - hide & lock cursor (UI_CURSOR_HIDE_AND_LOCK)<br><br>
--- Allows you to force visibilty of cursor for next frame. If the cursor is hidden, gamepad navigation methods are used.<br>
--- By default, in case of entering interactive UI state with gamepad, cursor will be shown and will be controlled using gamepad.<br>
--- Thus, if you need to implement navigation using the gamepad's D-pad, you should call this function.
---
--- Example:
--- ```lua
--- #include "ui/ui_helpers.lua"
--- 
--- function draw()
--- 	UiPush()
--- 		-- If the last input device was a gamepad, hide the cursor and proceed to control through D-pad navigation
--- 		if LastInputDevice() == UI_DEVICE_GAMEPAD then
--- 			UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
--- 		end
--- 
---         UiMakeInteractive()
---         UiAlign("center")
---         UiColor(1.0, 1.0, 1.0)
--- 		UiButtonHoverColor(1.0, 0.5, 0.5)
---         UiFont("regular.ttf", 50)
---         UiTranslate(UiCenter(), 200)
--- 
---         UiTranslate(0, 100)
---         if UiTextButton("1") then
---             DebugPrint(1)
---         end
---         UiTranslate(0, 100)
---         if UiTextButton("2") then
---             DebugPrint(2)
---         end
--- 	UiPop()
--- end
--- ```
---@param state number 
function UiSetCursorState(state) end

--- Possible values are: <br>
--- 0 - show cursor (UI_MOUSE_SHOW / UI_CURSOR_SHOW) <br>
--- 1 - hide cursor (UI_MOUSE_HIDE / UI_CURSOR_HIDE) <br>
--- 2 - hide & lock cursor (UI_MOUSE_HIDE_AND_LOCK / UI_CURSOR_HIDE_AND_LOCK)<br><br>
--- Allows you to force visibilty of cursor for next frame. If the cursor is hidden, gamepad navigation methods are used.<br>
--- By default, in case of entering interactive UI state with gamepad, cursor will be shown and will be controlled using gamepad.<br>
--- Thus, if you need to implement navigation using the gamepad's D-pad, you should call this function.
---
--- Example:
--- ```lua
--- #include "ui/ui_helpers.lua"
--- 
--- function draw()
--- 	UiPush()
--- 		-- If the last input device was a gamepad, hide the cursor and proceed to control through D-pad navigation
--- 		if LastInputDevice() == UI_DEVICE_GAMEPAD then
--- 			UiForceMouse(UI_MOUSE_HIDE_AND_LOCK)
--- 		end
--- 
--- 		UiMakeInteractive()
--- 		UiAlign("center")
--- 		UiColor(1.0, 1.0, 1.0)
--- 		UiButtonHoverColor(1.0, 0.5, 0.5)
--- 		UiFont("regular.ttf", 50)
--- 		UiTranslate(UiCenter(), 200)
--- 
--- 		UiTranslate(0, 100)
--- 		if UiTextButton("1") then
--- 			DebugPrint(1)
--- 		end
--- 		UiTranslate(0, 100)
--- 		if UiTextButton("2") then
--- 			DebugPrint(2)
--- 		end
--- 	UiPop()
--- end
--- ```
---@param state number 
function UiForceMouse(state) end

--- Send input action with given value and actionId produced from given touchId.
---
--- Example:
--- ```lua
--- local touchId = UiGetScreenTouchIdStartedInRect(100, 100)
--- if touchId ~= 0 then
--- 	UiSetScreenTouchIdHandled(touchId)
--- 	UiSendInputScreenTouchAction("down", touchId, 1)
--- end
--- ```
---@param actionId string Input action identifier
---@param touchId number Touch identifier
---@param value number Input action value
function UiSendInputScreenTouchAction(actionId, touchId, value) end

--- Check if touch input action with given actionId is active.
---
--- Example:
--- ```lua
--- if UiHasInputScreenTouchAction("down") then
--- 	DebugPrint("Down is active")
--- end
--- ```
---@param actionId string Input action identifier
---@return boolean value True if touch input action with given actionId is active
function UiHasInputScreenTouchAction(actionId) return false end

--- Get touchId and value for action with given actionId.
---
--- Example:
--- ```lua
--- local touchId, value = UiGetInputScreenTouchAction("down")
--- if touchId ~= 0 then
--- 	DebugPrint("Value is " .. value)
--- end
--- ```
---@param actionId string Input action identifier
---@return number touchId Touch identifier
---@return number value Input action value
function UiGetInputScreenTouchAction(actionId) return 0, 0 end

--- Mark touch with specified touchId as handled by UI. This touch will not be used on camera movement and other operations.
---
--- Example:
--- ```lua
--- local touchId = UiGetScreenTouchIdStartedAndContinuedInCircle(100)
--- if touchId ~= 0 then
--- 	-- touch was pressed, apply yellow color filter and mark touch as handled
--- 	UiColorFilter(1, 1, 0, 1)
--- 	UiSetScreenTouchIdHandled(touchId)
--- elseif UiWasScreenTouchCompletedWithoutLeavingCircle(100) then
--- 	-- touch was released, send action which should be sent on touch release
--- 	UiSendInputScreenTouchAction("jump", touchId, 1)
--- end
--- ```
---@param touchId number Touch identifier
---@param value? boolean Value to set, use false to clean handled mark. Default is true
function UiSetScreenTouchIdHandled(touchId, value) end

--- Check if touch was marked as handled by UI.
---
--- Example:
--- ```lua
--- local touchId = UiGetScreenTouchIdStartedAndContinuedInCircle(100)
--- if touchId ~= 0 and not UiIsScreenTouchIdHandled(touchId) then
--- 	-- touch was pressed and not marked as handled earlier, apply red color filter and mark touch as handled
--- 	UiColorFilter(1, 0, 0, 1)
--- 	UiSetScreenTouchIdHandled(touchId)
--- end
--- ```
---@param touchId number Touch identifier
---@return boolean value True if touch was marked as handled by UI
function UiIsScreenTouchIdHandled(touchId) return false end

--- Check if touch is within rectangle.
---
--- Example:
--- ```lua
--- local touchId = UiGetScreenTouchIdInRect(100, 100)
--- if touchId ~= 0 then
--- 	-- touch with touchId is within rectangle
--- end
--- ```
---@param w number Width
---@param h number Height
---@param unhandled? boolean Get only unhandled touches if true. Default is false
---@return number touchId Touch identifier if touch is within rectangle, 0 otherwise
function UiGetScreenTouchIdInRect(w, h, unhandled) return 0 end

--- Check if touch was started within rectangle.
---
--- Example:
--- ```lua
--- local touchId = UiGetScreenTouchIdStartedInRect(100, 100)
--- if touchId ~= 0 then
--- 	-- touch with touchId was started within rectangle
--- end
--- ```
---@param w number Width
---@param h number Height
---@param unhandled? boolean Get only unhandled touches if true. Default is false
---@return number touchId Touch identifier if touch was started within rectangle, 0 otherwise
function UiGetScreenTouchIdStartedInRect(w, h, unhandled) return 0 end

--- Check if touch was started and still is within rectangle.
---
--- Example:
--- ```lua
--- local touchId = UiGetScreenTouchIdStartedAndContinuedInRect(100, 100)
--- if touchId ~= 0 then
--- 	-- touch with touchId was started and still is within rectangle
--- end
--- ```
---@param w number Width
---@param h number Height
---@param unhandled? boolean Get only unhandled touches if true. Default is false
---@return number touchId Touch identifier if touch was started and still is within rectangle, 0 otherwise
function UiGetScreenTouchIdStartedAndContinuedInRect(w, h, unhandled) return 0 end

--- Check if touch was started and finished within rectangle.
---
--- Example:
--- ```lua
--- if UiWasScreenTouchCompletedWithoutLeavingRect(100, 100) then
--- 	-- touch was started and finished within rectangle
--- end
--- ```
---@param w number Width
---@param h number Height
---@return boolean value True if touch was started and finished within rectangle
function UiWasScreenTouchCompletedWithoutLeavingRect(w, h) return false end

--- Check if touch is within circle.
---
--- Example:
--- ```lua
--- local touchId = UiGetScreenTouchIdInCircle(100)
--- if touchId ~= 0 then
--- 	-- touch with touchId is within circle
--- end
--- ```
---@param radius number Radius
---@param unhandled? boolean Get only unhandled touches if true. Default is false
---@return number touchId Touch identifier if touch is within circle, 0 otherwise
function UiGetScreenTouchIdInCircle(radius, unhandled) return 0 end

--- Check if touch was started within circle.
---
--- Example:
--- ```lua
--- local touchId = UiGetScreenTouchIdStartedInCircle(100)
--- if touchId ~= 0 then
--- 	-- touch with touchId was started within circle
--- end
--- ```
---@param radius number Radius
---@param unhandled? boolean Get only unhandled touches if true. Default is false
---@return number touchId Touch identifier if touch was started within circle, 0 otherwise
function UiGetScreenTouchIdStartedInCircle(radius, unhandled) return 0 end

--- Check if touch was started and still is within circle.
---
--- Example:
--- ```lua
--- local touchId = UiGetScreenTouchIdStartedAndContinuedInCircle(100)
--- if touchId ~= 0 then
--- 	-- touch with touchId was started and still is within circle
--- end
--- ```
---@param radius number Radius
---@param unhandled? boolean Get only unhandled touches if true. Default is false
---@return number touchId Touch identifier if touch was started and still is within circle, 0 otherwise
function UiGetScreenTouchIdStartedAndContinuedInCircle(radius, unhandled) return 0 end

--- Check if touch was started and finished within circle.
---
--- Example:
--- ```lua
--- if UiWasScreenTouchCompletedWithoutLeavingCircle(100) then
--- 	-- touch was started and finished within circle
--- end
--- ```
---@param radius number Radius
---@return boolean value True if touch was started and finished within circle
function UiWasScreenTouchCompletedWithoutLeavingCircle(radius) return false end

--- Check if touch with given touchId is valid.
---
--- Example:
--- ```lua
--- if UiIsScreenTouchValid(previousTouchId) then
--- 	-- Touch with previousTouchId is still valid
--- end
--- ```
---@param touchId number Touch identifier
---@return boolean value True if touch with given touchId is valid
function UiIsScreenTouchValid(touchId) return false end

--- Get touch position for given touchId.
---
--- Example:
--- ```lua
--- local touchId = UiGetScreenTouchIdInCircle(100)
--- local x, y = UiGetScreenTouchPos(touchId)
--- ```
---@param touchId number Touch identifier
---@return number x X coordinate
---@return number y Y coordinate
function UiGetScreenTouchPos(touchId) return 0, 0 end

--- Get initial touch position for given touchId.
---
--- Example:
--- ```lua
--- local touchId = UiGetScreenTouchIdInCircle(100)
--- local x, y = UiGetScreenInitialTouchPos(touchId)
--- ```
---@param touchId number Touch identifier
---@return number x X coordinate
---@return number y Y coordinate
function UiGetScreenInitialTouchPos(touchId) return 0, 0 end

--- Get difference betwen current and previous positions for given touchId.
---
--- Example:
--- ```lua
--- local touchId = UiGetScreenTouchIdInCircle(100)
--- local dx, dy = UiGetScreenTouchDiff(touchId)
--- ```
---@param touchId number Touch identifier
---@return number x X coordinate
---@return number y Y coordinate
function UiGetScreenTouchDiff(touchId) return 0, 0 end

--- Get difference betwen current and initial positions for given touchId.
---
--- Example:
--- ```lua
--- local touchId = UiGetScreenTouchIdInCircle(100)
--- local dx, dy = UiGetScreenTouchDrag(touchId)
--- ```
---@param touchId number Touch identifier
---@return number x X coordinate
---@return number y Y coordinate
function UiGetScreenTouchDrag(touchId) return 0, 0 end

--- Get zoom factor between two touches in pinch gesture.
---
--- Example:
--- ```lua
--- local touch1 = UiGetScreenTouchIdInRect(UiHeight(), UiWidth(), true)
--- if touch1 ~= 0 then
--- 	UiSetScreenTouchIdHandled(touch1, true)
--- 	local touch2 = UiGetScreenTouchIdInRect(UiHeight(), UiWidth(), true)
--- 	if touch2 ~= 0 then
--- 		local zoom = UiGetScreenTouchDiffZoom(touch1, touch2)
--- 		if zoom > 1.0 then
--- 			DebugPrint("Zoom in: " .. zoom)
--- 		elseif zoom < 1.0 then
--- 			DebugPrint("Zoom out: " .. zoom)
--- 		end
--- 	end
--- 	UiSetScreenTouchIdHandled(touch1, false)
--- end
--- ```
---@param touchId1 number Touch identifier for first touch
---@param touchId2 number Touch identifier for second touch
---@return number value Zoom factor between two touches in pinch gesture
function UiGetScreenTouchDiffZoom(touchId1, touchId2) return 0 end
