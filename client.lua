--[[
	* Magic Tool+ (MTP) by chris1384 @2024 (youtube.com/chris1384)
	* Original idea by Mirage (Mirage's Magic Tool - MMT)
	* This script was made from scratch.
	* Do not redistribute this (under other names) without my permission, do not edit & upload without my permission or take any credit from it.
	* For any questions, bug reports or any suggestions, send a message to @chris1384 on Discord.

	* Have fun mapping! - chris1384 <3
]]

local positionData = {}
local editorControls = {}
local savedDirections = {}

-- // do not edit
local toolEnabled = false -- yk
local previewModel = 1 -- object model that will spawn
local previewDirection = 1 -- spawn direction
local selectedElement = nil -- main event
local previewElements = {} -- all preview elements
local selectedShader = nil -- shader lol
local blockedBinds = false -- fix for freecam > cursor
local editorForceCancel = false -- disable the tool on editor suspend/test
local selectedBlip = nil
--local guiFocusCancel = false -- don't do any keypress when a gui is shown
local guiFocusCooldown = nil
local bindCreateTimer = nil -- to avoid selection conflict (drop/clone/create)

local moveLocalElementTimer = nil
local keyboardBlockEventTimer = nil

local screenW, screenH = guiGetScreenSize()
local debugLevel = 0

local defaultControls = {
	{name = "mtp_toggle", friendlyName = "Toggle tool", key = "x"},
	{name = "mtp_toggle_lrot", friendlyName = "Toggle local rotation", key = "rshift"},
	{name = "mtp_toggle_lpos", friendlyName = "Toggle local positioning", key = "lctrl"},
	{name = "mtp_toggle_lpos_s", friendlyName = "Toggle slow local positioning", key = "lalt"},
	{name = "mtp_direction_spawn", friendlyName = "Direction quick spawn", key = "ralt"},
	{name = "mtp_direction_u", friendlyName = "Change direction +1", key = "mouse2", alt = "]"},
	{name = "mtp_direction_d", friendlyName = "Change direction -1", key = "["},
	{name = "mtp_model_u", friendlyName = "Change model +1", key = "mouse_wheel_down", alt = "."},
	{name = "mtp_model_d", friendlyName = "Change model -1", key = "mouse_wheel_up", alt = ","},
	{name = "mtp_quick_front", friendlyName = "Quick spawn front / Local +X", key = "w"},
	{name = "mtp_quick_back", friendlyName = "Quick spawn back / Local -X", key = "s"},
	{name = "mtp_quick_right", friendlyName = "Quick spawn right / Local +Z", key = "d"},
	{name = "mtp_quick_left", friendlyName = "Quick spawn left / Local -Z", key = "a"},
	{name = "mtp_quick_up", friendlyName = "Local +Y", key = "num_add"},
	{name = "mtp_quick_down", friendlyName = "Local -Y", key = "num_sub"},
	{name = "mtp_move_right", friendlyName = "Move local +X", key = "num_6"},
	{name = "mtp_move_left", friendlyName = "Move local -X", key = "num_4"},
	{name = "mtp_move_front", friendlyName = "Move local +Y", key = "num_8"},
	{name = "mtp_move_back", friendlyName = "Move local -Y", key = "num_2"},
	{name = "mtp_move_up", friendlyName = "Move local +Z", key = "num_add"},
	{name = "mtp_move_down", friendlyName = "Move local -Z", key = "num_sub"},
	{name = "mtp_features", friendlyName = "Spawn build features", key = "num_mul"},
}

local keyBindings = {
	["mtp_toggle"] = {friendlyName = "Toggle tool", key = "x"},
	["mtp_toggle_lrot"] = {friendlyName = "Toggle local rotation", key = "rshift"},
	["mtp_toggle_lpos"] = {friendlyName = "Toggle local positioning", key = "lctrl"},
	["mtp_toggle_lpos_s"] = {friendlyName = "Toggle slow local positioning", key = "lalt"},
	["mtp_direction_spawn"] = {friendlyName = "Direction quick spawn", key = "ralt"},
	["mtp_direction_u"] = {friendlyName = "Change direction +1", key = "mouse2", alt = "]"},
	["mtp_direction_d"] = {friendlyName = "Change direction -1", key = "["},
	["mtp_model_u"] = {friendlyName = "Change model +1", key = "mouse_wheel_down", alt = "."},
	["mtp_model_d"] = {friendlyName = "Change model -1", key = "mouse_wheel_up", alt = ","},
	["mtp_quick_front"] = {friendlyName = "Quick spawn front / Local +X", key = "w"},
	["mtp_quick_back"] = {friendlyName = "Quick spawn back / Local -X", key = "s"},
	["mtp_quick_right"] = {friendlyName = "Quick spawn right / Local +Z", key = "d"},
	["mtp_quick_left"] = {friendlyName = "Quick spawn left / Local -Z", key = "a"},
	["mtp_quick_up"] = {friendlyName = "Local +Y", key = "num_add"},
	["mtp_quick_down"] = {friendlyName = "Local -Y", key = "num_sub"},
	["mtp_move_right"] = {friendlyName = "Move local +X", key = "num_6"},
	["mtp_move_left"] = {friendlyName = "Move local -X", key = "num_4"},
	["mtp_move_front"] = {friendlyName = "Move local +Y", key = "num_8"},
	["mtp_move_back"] = {friendlyName = "Move local -Y", key = "num_2"},
	["mtp_move_up"] = {friendlyName = "Move local +Z", key = "num_add"},
	["mtp_move_down"] = {friendlyName = "Move local -Z", key = "num_sub"},
	["mtp_features"] = {friendlyName = "Spawn build features", key = "num_mul"},
}

addEventHandler("onClientResourceStart", root, function(started)

	if started == getThisResource() then

		prompt("Magic Tool$$+ v1.4.2 ##by #FFAAFFchris1384 ##has $$started##!")
		prompt("Use $$/mtphelp ##to see commands!")

		-- // Load offsets.lua
		if mtpData and type(mtpData) == "table" then
			for model, data in pairs(mtpData) do
				for k, v in ipairs(data) do
					if #v[2] == 1 then
						local firstData = v[2][1]
						for i=1, 4 do
							mtpData[model][k][2][i] = firstData
						end
					end
				end

			end
			positionData = mtpData
		end

		-- // Load secret userconfig.lua (debug only)
		--[[

			* Want to add your own userconfig? create the userconfig.lua in your mods folder (NOT SERVER) and add the contents as such (same as offset.lua):

				return {
					[3458] = {
						{3458, {{0, 0, 2}, {0, 0, -2}}},
						{8558, {{0, 0, 2}, {0, 0, -2}}},
						{8553, {{0, 0, 2}, {0, 0, -2}}},
					},
					-- models.. models.. offsets.. etc..
				}

		]]
		local userConfigData = nil

		if fileExists("userconfig.lua") then
			local file = fileOpen("userconfig.lua")
			if file then
				userConfigData = fileRead(file, fileGetSize(file))
				fileClose(file)
			end

			-- // Import new offsets
			local func, err = loadstring(userConfigData)
			local success, result = pcall(func)
			if success then
				local userOffsets = type(result) == "table" and result
				if userOffsets then
					for model,modelData in pairs(userOffsets) do
						for modelIndex,modelOffsets in ipairs(modelData) do
							for offsetIndex, offsetData in ipairs(modelOffsets[2]) do
								if not positionData[model] then
									positionData[model] = {}
								else
									local targetModel = getModelOffsetPosition(model, modelOffsets[1])
									if not positionData[model][targetModel] then
										positionData[model][targetModel] = {modelOffsets[1], {}}
									end
									table.insert(positionData[model][targetModel][2], offsetData)
								end
							end
						end
					end
				end
			end
		end


		for commandName, commandData in pairs(defaultControls) do
			bindKey(commandData.key or "", "down", commandData.friendlyName)
			bindKey(commandData.alt or "", "down", commandData.friendlyName)
			bindKey(commandData.alt2 or "", "down", commandData.friendlyName)
			bindKey(commandData.alt3 or "", "down", commandData.friendlyName)
		end

		if not toggleDebug then
			function outputDebugString() -- XD
			end
		end


	elseif getResourceName(started) == "editor_main" then
		prompt("Magic Tool$$+ ##is now #64FF64ready ##to be activated!")
		--editorControls = exports["editor_main"]:getControls()
	end

end)

addEventHandler("onClientResourceStop", root, function(stopped)
	if stopped == getThisResource() then
		--prompt("Magic Tool$$+ ##resource has been $$stopped##!")

		local lockedElement = getElementData(localPlayer, "mtp:selectedElement")
		if lockedElement then
			triggerServerEvent("doUnlockElement", lockedElement)
			setElementData(localPlayer, "mtp:selectedElement", nil, false)
		end

	elseif getResourceName(stopped) == "editor_main" then
		prompt("Magic Tool$$+ ##has been $$disabled ##due to editor stopping!")
		toolEnabled = false
		destroyPreviews()
		mainElementShader()
	end
end)

addCommandHandler("mtphelp", function(cmd, pageArg)

	local wasdOutput = string.format("%s | %s | %s | %s", getControlBindings("mtp_quick_front", true), getControlBindings("mtp_quick_left", true), getControlBindings("mtp_quick_back", true), getControlBindings("mtp_quick_right", true))
	local numpadOutputs = string.format("%s | %s | %s | %s | %s | %s", getControlBindings("mtp_move_front", true), getControlBindings("mtp_move_left", true), getControlBindings("mtp_move_back", true), getControlBindings("mtp_move_right", true), getControlBindings("mtp_move_up", true), getControlBindings("mtp_move_down", true))
	local updownOutput = string.format("%s | %s", getControlBindings("mtp_quick_up", true), getControlBindings("mtp_quick_down", true))
	local scrollupdownOutput = string.format("%s | %s", getControlBindings("mtp_model_u", true), getControlBindings("mtp_model_d", true))

	local all_commands = {
		"$$/mtphelp ##[page number] $$- ##show commands from a page",
		"",
		"'$$"..getControlBindings("mtp_toggle", true).."##' $$- ##enable/disable the tool",
		"After selecting $$main element##:",
		"#AAAAFFLEFT CLICK $$(ghost object) - ##spawn the object",
		"#FFBB55RIGHT CLICK $$- ##toggle spawn direction",
		"#FFAAFF"..scrollupdownOutput.." $$- ##cycle between different models $$(LIMITED)",
		"#64FF64"..wasdOutput.." $$- ##quickly clone the object in a certain direction",
		"#FFFF00"..getControlBindings("mtp_toggle_lrot", true).." ##+ #64FF64"..wasdOutput.." $$- ##rotate object on local axis $$(TAP)",
		"#FFFF00"..getControlBindings("mtp_toggle_lrot", true).." ##+ #64FF64"..updownOutput.." $$- ##rotate object on local #00FF00Y ##axis $$(TAP)",
		"#FFFF00"..getControlBindings("mtp_toggle_lrot", true).." ##+ '#FFAA00".. getControlBindings("mtp_features", true) .."##' $$- ##add building features $$(LIMITED)",
		"#FF0080"..getControlBindings("mtp_toggle_lpos", true).." ##| #FF0020"..getControlBindings("mtp_toggle_lpos_s", true).." $$- ##toggle local normal / slow positioning",
		"#64FFFF"..numpadOutputs.." $$- ##local movement",
		"For anything else, contact $$@chris1384 ##on Discord!",
	}

	local page_setting_elements = 5
	local page_count = math.ceil(#all_commands/page_setting_elements)
	local page_target = math.max(0, math.min(tonumber(pageArg) or 1, page_count))
	local page_rows = page_setting_elements*(page_target-1)

	prompt("")
	prompt("Commands List $$(page "..tostring(page_target).."/"..tostring(page_count)..")##:", 255, 100, 100)
	for i=1+page_rows,page_setting_elements+page_rows do
		prompt(all_commands[i], 255, 100, 100)
	end

	all_commands = nil

end)

function toolToggle()

	if toolEnabled then

		toolEnabled = false
		destroyPreviews()
		mainElementShader()

		if bindCreateTimer then if isTimer(bindCreateTimer) then killTimer(bindCreateTimer) end bindCreateTimer = nil end
		blockedBinds = false

		guiFocusCancel = false

		if isTimer(keyboardBlockEventTimer) then
			killTimer(keyboardBlockEventTimer)
			keyboardBlockEventTimer = nil
		end
		removeDebugHook("preFunction", cancelKeyboardEvents)

		elementHasBeenMoved = false
		if isTimer(moveLocalElementTimer) then
			killTimer(moveLocalElementTimer)
			moveLocalElementTimer = nil
		end

		if not exports["editor_main"]:getSelectedElement() then
			local lockedElement = getElementData(localPlayer, "mtp:selectedElement")
			if lockedElement then
				triggerServerEvent("doUnlockElement", lockedElement)
				setElementData(localPlayer, "mtp:selectedElement", nil, false)
			end
		end

	else
		if not getResourceFromName("editor_main") then
			prompt("Magic Tool$$+ ##was $$unable ##to start: $$editor_main ##is not activated!")
			return false
		end
		if editorForceCancel then
			prompt("Failed to enable the tool, $$'onEditorSuspended' ##got triggered.")
			return
		end
		toolEnabled = true
		destroyPreviews()

		while true do

			if spawnMode == "none" then break end

			local editorSelected = exports["editor_main"]:getSelectedElement()
			if editorSelected and getElementType(editorSelected) == "object" then
				selectedElement = editorSelected
			end

			if selectedElement and isElement(selectedElement) and getElementDimension(selectedElement) == exports["editor_main"]:getWorkingDimension() then
				mainElementShader(selectedElement, true)

				if freecamShowPreviews then
					createPreviewElements()
				end
			else
				selectedElement = nil
			end

			break

		end

	end
	prompt("The tool has been " .. (toolEnabled == true and "#00CC00ENABLED" or "#CC0000DISABLED") .. "##!")
	outputDebugString("[MT+] Tool " .. (toolEnabled == true and "enabled" or "disabled") .. ".", debugLevel, 0, 255, 0)
end

function editorEvents()

	if eventName == "onFreecamMode" and freecamDrop then
		selectedElement = nil
		outputDebugString("[MT+] Dropped element on 'freecamDrop'.", debugLevel, 0, 255, 0)

	elseif eventName == "onCursorMode" then
		if getKeyState("w") or getKeyState("a") or getKeyState("s") or getKeyState("d") then
			blockedBinds = true
		end

		if toolEnabled then
			if (selectedElement and isElement(selectedElement) and getElementDimension(selectedElement) == exports["editor_main"]:getWorkingDimension()) then
				destroyPreviews()
				createPreviewElements()
				mainElementShader(selectedElement, true)
				outputDebugString("[MT+] Reselecting main element on 'onCursorMode'.", debugLevel, 0, 255, 0)
			end
		end

		return

	elseif eventName == "onEditorSuspended" then
		editorForceCancel = true
		outputDebugString("[MT+] 'onEditorSuspended' triggered.", debugLevel, 0, 255, 0)

		destroyPreviews()
		mainElementShader()

		if bindCreateTimer then if isTimer(bindCreateTimer) then killTimer(bindCreateTimer) end bindCreateTimer = nil end
		blockedBinds = false

		if isTimer(keyboardBlockEventTimer) then
			killTimer(keyboardBlockEventTimer)
			keyboardBlockEventTimer = nil
		end
		removeDebugHook("preFunction", cancelKeyboardEvents)

		elementHasBeenMoved = false
		if isTimer(moveLocalElementTimer) then
			killTimer(moveLocalElementTimer)
			moveLocalElementTimer = nil
		end

	elseif eventName == "onEditorResumed" then
		editorForceCancel = false
		guiFocusCancel = false
		outputDebugString("[MT+] 'onEditorResumed' triggered.", debugLevel, 0, 255, 0)

		if toolEnabled then
			if (selectedElement and isElement(selectedElement) and getElementDimension(selectedElement) == exports["editor_main"]:getWorkingDimension()) then
				destroyPreviews()
				createPreviewElements()
				mainElementShader(selectedElement, true)
				if bindCreateTimer then if isTimer(bindCreateTimer) then killTimer(bindCreateTimer) end bindCreateTimer = nil end
				blockedBinds = false
				return
			end
		end
	end

	if allowDropping and not freecamShowPreviews then
		mainElementShader()

	elseif not freecamShowPreviews then
		destroyPreviews()

	end

end
for _,editorEventsList in ipairs({"onCursorMode", "onFreecamMode", "onEditorSuspended", "onEditorResumed"}) do
	addEvent(editorEventsList)
	addEventHandler(editorEventsList, root, editorEvents)
end

function onKey(button, state)

	if guiGetInputMode() == "no_binds" or isMTAWindowActive() then return end

	if button == isControlPressed(button, "mtp_toggle") and state then
		toolToggle()
		return
	end

	if not toolEnabled then return end
	if editorForceCancel then outputDebugString("[MT+] 'editorForceCancel' blocked the bind.", debugLevel, 0, 255, 0) return end

	-- // MOUSE KEYS

	if button == "mouse1" or button == "mouse2" then

		if spawnMode == "none" then return end

		if exports["editor_main"]:getMode() == 2 then

			if not hoverGhostDirection then return end

			if state then
				destroyPreviews()
				if freecamShowPreviews then
					createPreviewElements()
				end
				return
			end

			local cameraData = {exports["editor_main"]:processCameraLineOfSight()}

			if button == "mouse2" then

				if (selectedElement and isElement(selectedElement) and getElementDimension(selectedElement) == exports["editor_main"]:getWorkingDimension()) then
					if not exports["move_freecam"]:getAttachedElement() and getPreviewCount() > 0 then
						onClick("right", "up", false, false, cameraData[1], cameraData[2], cameraData[3], nil)
					end
					destroyPreviews()
					if freecamShowPreviews then
						createPreviewElements()
					end
				end

			end


		elseif exports["editor_main"]:getMode() == 1 then

			if state then
				destroyPreviews()
				if freecamShowPreviews then
					createPreviewElements()
				end
				return
			end

			local cameraData = {exports["editor_main"]:processCameraLineOfSight()}

			-- // LEFT KEY

			if button == "mouse1" then

				if cameraData[4] then
					if cameraData[4] and getElementType(cameraData[4]) == "object" then
						if previewElements[cameraData[4]] then
							cancelEvent(true)
						else
							exports["editor_main"]:selectElement(cameraData[4], 2)
						end
						onClick("left", "up", false, false, cameraData[1], cameraData[2], cameraData[3], cameraData[4], {doNotCancel = true})
						return
					end

				else

					if allowDropping then
						--cancelEvent(true)
						selectedElement = nil
						destroyPreviews()
						mainElementShader()
						outputDebugString("[MT+] Dropped main element.", debugLevel, 0, 255, 0)
						return
					end

				end

			-- // RIGHT KEY

			else

				if (selectedElement and isElement(selectedElement) and getElementDimension(selectedElement) == exports["editor_main"]:getWorkingDimension()) then
					if not exports["move_freecam"]:getAttachedElement() and getPreviewCount() > 0 then
						onClick("right", "up", false, false, cameraData[1], cameraData[2], cameraData[3], nil)
					end
					destroyPreviews()
					if freecamShowPreviews then
						createPreviewElements()
					end
				end
			end

		end

	-- // QUICK DIRECTION spawn

	elseif button == isControlPressed(button, "mtp_direction_spawn") then

	--[[
		if exports["editor_main"]:getMode() == 1 then
			return
		end
	]]
		if bindsFarClip and not (isElement(selectedElement) and isElementStreamedIn(selectedElement)) then
			return
		end

		if state then
			destroyPreviews()
			if freecamShowPreviews then
				createPreviewElements()
			end
			return
		end

		exports["editor_main"]:dropElement(true, true)

		local cameraData = {exports["editor_main"]:processCameraLineOfSight()}

		for k,v in pairs(previewElements) do
			onClick("left", "up", false, false, cameraData[1], cameraData[2], cameraData[3], k, {doNotCancel = true})
			return true
		end


	-- // SCROLL WHEEL

	elseif button == isControlPressed(button, "mtp_model_u") or button == isControlPressed(button, "mtp_model_d") then

		if button == "mouse_wheel_down" or button == "mouse_wheel_up" then
			if not state then return end
		else
			if state then return end
		end

		if spawnMode == "none" then return end

		if not (selectedElement and isElement(selectedElement) and getElementDimension(selectedElement) == exports["editor_main"]:getWorkingDimension()) then return end

		cancelEvent(true)

		local model = getElementModel(selectedElement)
		local data = positionData[model]

		if data then

			local scrollWheelButton = (invertScrollWheel == true and isControlPressed(button, "mtp_model_d")) or isControlPressed(button, "mtp_model_u")

			if isControlPressed(button, "mtp_model_d") then
				previewModel = previewModel - 1
				if previewModel < 1 then
					previewModel = #data
				end
			else
				previewModel = previewModel + 1
				if previewModel > #data then
					previewModel = 1
				end
			end

			if not data[previewModel] then previewModel = 1 end
			if not data[previewModel][2][previewDirection] then previewDirection = 1 end

			if not savedDirections[model] then savedDirections[model] = {} end
			savedDirections[model].previewModel = previewModel
			savedDirections[model].previewDirection = previewDirection

			destroyPreviews()
			createPreviewElements()

			outputDebugString("[MT+] Selected preview model: "..tostring(previewModel), debugLevel, 0, 255, 0)

			return true

		end

	-- // LOCAL POSITIONING

	elseif toggleLocalPositioning and (isControlPressed("mtp_toggle_lpos") or isControlPressed("mtp_toggle_lpos_s")) then

		if not (selectedElement and isElement(selectedElement)) then
			mainElementShader()
			selectedElement = nil

			keyboardBlockEventTimer = setTimer(function()
				removeDebugHook("preFunction", cancelKeyboardEvents)
			end, 500, 1)

			if isTimer(moveLocalElementTimer) then
				killTimer(moveLocalElementTimer)
				moveLocalElementTimer = nil
			end

			return
		end

		if state then

			-- // ON PRESS

			if (spawnMode == "none") then
				selectedElement = exports["editor_main"]:getSelectedElement()
				if selectedElement and isElement(selectedElement) and getElementDimension(selectedElement) == exports["editor_main"]:getWorkingDimension() then
					mainElementShader(selectedElement, true)
				end
			end

			destroyPreviews()

			local positioningColor = (isControlPressed("mtp_toggle_lpos") and highlightPositionColor) or (isControlPressed("mtp_toggle_lpos_s") and highlightPositionSlowColor) or {1, 1, 1, 1}

			if selectedShader then
				dxSetShaderValue(selectedShader, "color", positioningColor)
			end
			if selectedBlip then
				setBlipColor(selectedBlip, positioningColor[1]*255, positioningColor[2]*255, positioningColor[3]*255, positioningColor[4]*255)
			end

			if isTimer(keyboardBlockEventTimer) then
				killTimer(keyboardBlockEventTimer)
				keyboardBlockEventTimer = nil
			end
			removeDebugHook("preFunction", cancelKeyboardEvents)

			if ((button == isControlPressed(button, "mtp_move_right")) or
				(button == isControlPressed(button, "mtp_move_left")) or
				(button == isControlPressed(button, "mtp_move_front")) or
				(button == isControlPressed(button, "mtp_move_back")) or
				(button == isControlPressed(button, "mtp_move_up")) or
				(button == isControlPressed(button, "mtp_move_down"))) then
				if exports["editor_main"]:getMode() == 2 then

					addDebugHook("preFunction", cancelKeyboardEvents, {"triggerServerEvent", "setElementPosition"})

					exports["editor_main"]:dropElement(true)
					elementHasBeenMoved = true

					if not isElementLocal(selectedElement) then
						setElementData(localPlayer, "mtp:selectedElement", selectedElement, false)
						triggerServerEvent("doLockElement", selectedElement)
					end

				end
			end

			keyboardBlockEventTimer = setTimer(function()
				removeDebugHook("preFunction", cancelKeyboardEvents)
			end, 500, 1)

			if isTimer(moveLocalElementTimer) then
				killTimer(moveLocalElementTimer)
				moveLocalElementTimer = nil
			end

			if exports["editor_main"]:getMode() == 1 then
				return
			end

			local set_slow, set_norm, set_fast = exports["move_keyboard"].getMoveSpeeds()
			local movementSpeed = (isControlPressed("mtp_toggle_lpos") and (set_norm or 0.5)) or (isControlPressed("mtp_toggle_lpos_s") and (set_slow or 0.02)) or 1
			movementSpeed = movementSpeed * localPositionSpeed

			setElementData(selectedElement, "mtp:move_origin", getElementMatrix(selectedElement), false)
			setElementData(selectedElement, "mtp:move_offset", {0, 0, 0}, false)

			local xSpeed = (isControlPressed("mtp_move_right") and movementSpeed) or (isControlPressed("mtp_move_left") and -movementSpeed) or 0
			local ySpeed = (isControlPressed("mtp_move_front") and movementSpeed) or (isControlPressed("mtp_move_back") and -movementSpeed) or 0
			local zSpeed = (isControlPressed("mtp_move_up") and movementSpeed) or (isControlPressed("mtp_move_down") and -movementSpeed) or 0

			moveLocalElementTimer = setTimer(function()
				if not selectedElement then
					if isTimer(moveLocalElementTimer) then
						killTimer(moveLocalElementTimer)
						moveLocalElementTimer = nil
					end
					selectedElement = nil
					return
				end
				local origin = getElementData(selectedElement, "mtp:move_origin")
				local offsets = getElementData(selectedElement, "mtp:move_offset")
				local newX, newY, newZ = offsets[1] + xSpeed, offsets[2] + ySpeed, offsets[3] + zSpeed
				local offsetX, offsetY, offsetZ = getPositionFromElementOffset(origin, newX, newY, newZ)
				setElementPosition(selectedElement, offsetX, offsetY, offsetZ)
				setElementData(selectedElement, "mtp:move_offset", {newX, newY, newZ}, false)
			end, getFPSLimit()/1000, 0)

		else

			-- // ON RELEASE

			if isTimer(moveLocalElementTimer) then
				killTimer(moveLocalElementTimer)
				moveLocalElementTimer = nil
			end

			if not ((isControlPressed("mtp_move_right")) or
				(isControlPressed("mtp_move_left")) or
				(isControlPressed("mtp_move_front")) or
				(isControlPressed("mtp_move_back")) or
				(isControlPressed("mtp_move_up")) or
				(isControlPressed("mtp_move_down"))) then

				--[[
				local lockedElement = getElementData(localPlayer, "mtp:selectedElement")
				if lockedElement then
					triggerServerEvent("doUnlockElement", lockedElement)
					setElementData(localPlayer, "mtp:selectedElement", nil, false)
				end]]

				return
			end

			if isTimer(keyboardBlockEventTimer) then
				killTimer(keyboardBlockEventTimer)
				keyboardBlockEventTimer = nil
			end
			removeDebugHook("preFunction", cancelKeyboardEvents)

			if exports["editor_main"]:getMode() == 2 then
				addDebugHook("preFunction", cancelKeyboardEvents, {"triggerServerEvent", "setElementPosition"})
				exports["editor_main"]:dropElement(true)
				if not isElementLocal(selectedElement) then
					setElementData(localPlayer, "mtp:selectedElement", selectedElement, false)
					triggerServerEvent("doLockElement", selectedElement)
				end
			end

			keyboardBlockEventTimer = setTimer(function()
				removeDebugHook("preFunction", cancelKeyboardEvents)
			end, 500, 1)

			local currentX, currentY, currentZ = getElementPosition(selectedElement)
			triggerServerEvent("mtp:applyProperty", selectedElement, {position = {currentX, currentY, currentZ}})

			if exports["editor_main"]:getMode() == 1 then
				return
			end

			elementHasBeenMoved = true

			setElementData(selectedElement, "mtp:move_origin", getElementMatrix(selectedElement), false)
			setElementData(selectedElement, "mtp:move_offset", {0, 0, 0}, false)

			local set_slow, set_norm, set_fast = exports["move_keyboard"].getMoveSpeeds()
			local movementSpeed = (isControlPressed("mtp_toggle_lpos") and (set_norm or 0.5)) or (isControlPressed("mtp_toggle_lpos_s") and (set_slow or 0.02)) or 1
			movementSpeed = movementSpeed * localPositionSpeed

			local xSpeed = (isControlPressed("mtp_move_right") and movementSpeed) or (isControlPressed("mtp_move_left") and -movementSpeed) or 0
			local ySpeed = (isControlPressed("mtp_move_front") and movementSpeed) or (isControlPressed("mtp_move_back") and -movementSpeed) or 0
			local zSpeed = (isControlPressed("mtp_move_up") and movementSpeed) or (isControlPressed("mtp_move_down") and -movementSpeed) or 0

			moveLocalElementTimer = setTimer(function()
				if not selectedElement then
					if isTimer(moveLocalElementTimer) then
						killTimer(moveLocalElementTimer)
						moveLocalElementTimer = nil
					end
					return
				end
				local origin = getElementData(selectedElement, "mtp:move_origin")
				local offsets = getElementData(selectedElement, "mtp:move_offset")
				local newX, newY, newZ = offsets[1] + xSpeed, offsets[2] + ySpeed, offsets[3] + zSpeed
				local offsetX, offsetY, offsetZ = getPositionFromElementOffset(origin, newX, newY, newZ)
				setElementPosition(selectedElement, offsetX, offsetY, offsetZ)
				setElementData(selectedElement, "mtp:move_offset", {newX, newY, newZ}, false)
			end, getFPSLimit()/1000, 0)

		end

	elseif button == (isControlPressed(button, "mtp_toggle_lpos") or isControlPressed(button, "mtp_toggle_lpos_s")) then

		destroyPreviews()

		if not state then
			if spawnMode == "none" then
				selectedElement = nil
				mainElementShader()
			end
			if selectedShader then
				dxSetShaderValue(selectedShader, "color", highlightColor)
			end
			if selectedBlip then
				setBlipColor(selectedBlip, highlightColor[1]*255, highlightColor[2]*255, highlightColor[3]*255, highlightColor[4]*255)
			end
		end

		if isTimer(moveLocalElementTimer) then
			killTimer(moveLocalElementTimer)
			moveLocalElementTimer = nil
		end

		if selectedElement then

			if elementHasBeenMoved then
				exports["editor_gui"]:outputMessage("Applied local positioning.", highlightPositionColor[1]*255, highlightPositionColor[2]*255, highlightPositionColor[3]*255, 4000)
				elementHasBeenMoved = false

				local lockedElement = getElementData(localPlayer, "mtp:selectedElement")
				if lockedElement then
					triggerServerEvent("doUnlockElement", lockedElement)
					setElementData(localPlayer, "mtp:selectedElement", nil, false)
				end

			end

			if not exports["move_freecam"]:getAttachedElement() then
				exports["editor_main"]:dropElement(true)
				exports["editor_main"]:selectElement(selectedElement, 2)
			end

			createPreviewElements()
		end


	elseif toggleLocalRotation and isControlPressed("mtp_toggle_lrot") then

		if state then
			if (spawnMode == "none") then
				selectedElement = exports["editor_main"]:getSelectedElement()
				if selectedElement and isElement(selectedElement) and getElementDimension(selectedElement) == exports["editor_main"]:getWorkingDimension() then
					mainElementShader(selectedElement, true)
				end
			end

			destroyPreviews()

			if selectedShader then
				dxSetShaderValue(selectedShader, "color", highlightRotationColor)
			end
			if selectedBlip then
				setBlipColor(selectedBlip, highlightRotationColor[1]*255, highlightRotationColor[2]*255, highlightRotationColor[3]*255, highlightRotationColor[4]*255)
			end


			if selectedElement then
				local x, y, z = getElementPosition(selectedElement)
				local rx, ry, rz = getElementRotation(selectedElement)

				triggerServerEvent("mtp:applyProperty", selectedElement, {position = {x, y, z}})
			else
				outputDebugString("[MT+] Local rotation failed, 'selectedElement' is invalid.", debugLevel, 0, 255, 0)
			end

			return
		end

		if (button == isControlPressed(button, "mtp_quick_front") or button == isControlPressed(button, "mtp_quick_back") or button == isControlPressed(button, "mtp_quick_left") or button == isControlPressed(button, "mtp_quick_right") or button == isControlPressed(button, "mtp_quick_up") or button == isControlPressed(button, "mtp_quick_down")) then

			if exports["editor_main"]:getMode() == 2 then

				if (spawnMode == "none") then
					selectedElement = exports["editor_main"]:getSelectedElement()
				end

				if selectedElement and isElement(selectedElement) and getElementDimension(selectedElement) == exports["editor_main"]:getWorkingDimension() then

					if isElementLocal(selectedElement) then outputDebugString("[MT+] Local rotation failed, not editor element.", debugLevel, 0, 255, 0) return end

					cancelEvent(true)

					local rx, ry, rz = getElementRotation(selectedElement)

					local rotationZ = (button == isControlPressed(button, "mtp_quick_left") and localRotationAngle) or (button == isControlPressed(button, "mtp_quick_right") and -localRotationAngle) or 0
					local rotationX = (button == isControlPressed(button, "mtp_quick_front") and -localRotationAngle) or (button == isControlPressed(button, "mtp_quick_back") and localRotationAngle) or 0
					local rotationY = (button == isControlPressed(button, "mtp_quick_up") and localRotationAngle) or (button == isControlPressed(button, "mtp_quick_down") and -localRotationAngle) or 0

					rx, ry, rz = rotateZ(rx, ry, rz, rotationZ)
					rx, ry, rz = rotateX(rx, ry, rz, rotationX)
					rx, ry, rz = rotateY(rx, ry, rz, rotationY)

					exports.edf:edfSetElementRotation(selectedElement, rx, ry, rz, "ZXY")

					triggerServerEvent("mtp:applyProperty", selectedElement, {rotation = {rx, ry, rz}})

					exports["editor_gui"]:outputMessage("Applied local rotation.", 50, 50, 255, 4000)
					outputDebugString("[MT+] Rotated locally | X: "..tostring(rotationX).." | Y: "..tostring(rotationY).." | Z: "..tostring(rotationZ)..")", debugLevel, 0, 255, 0)

					if (spawnMode == "none") then
						selectedElement = nil
					end

					return true

				end

			else

				outputDebugString("[MT+] Local rotation failed, 'cursorMode' needed.", debugLevel, 0, 255, 0)

			end

		elseif (button == isControlPressed(button, "mtp_features")) then

			if spawnMode == "none" then return end

			if exports["editor_main"]:getMode() == 2 then

				if selectedElement and isElement(selectedElement) and getElementDimension(selectedElement) == exports["editor_main"]:getWorkingDimension() then

					local totalSpawns = 0
					local totalFails = 0

					local model = getElementModel(selectedElement)
					local x, y, z = getElementPosition(selectedElement)
					local _rx, _ry, _rz = getElementRotation(selectedElement)
					local scale = getObjectScale(selectedElement)
					local doublesided = isElementDoubleSided(selectedElement)
					local collisions = getEditorElementCollisions(selectedElement)

					local data = positionData[model]
					if data then

						if #data < 2 then
							prompt("Spawning features $$failed##, object unallowed (offsets entries less than 2)!")
							return
						end

						for k,v in ipairs(data) do

							local rx, ry, rz = _rx, _ry, _rz

							while true do

								if k == 1 then break end

								if k >= 3 then
									if buildFeaturesWindowsOnly then
										break
									end
								end

								local dataX, dataY, dataZ, dataRX, dataRY, dataRZ, additions = unpack(v[2][1])
								dataX, dataY, dataZ = dataX * scale, dataY * scale, dataZ * scale

								if additions and type(additions) == "table" then
									if additions.is2DFX and ignoreRotated2DFX then
										if _rx > 16.26 or _rx < -16.26 or _ry > 16.26 or _ry < -16.26 then
											totalFails = totalFails + 1
											break
										end
									end
								end

								local offX, offY, offZ = getPositionFromElementOffset(getElementMatrix(selectedElement), dataX, dataY, dataZ)

								if overlapThreshold and overlapThreshold > 0 then

									local existing = getElementsWithinRange(offX, offY, offZ, overlapThreshold, "object", getElementInterior(localPlayer), exports["editor_main"]:getWorkingDimension())
									local existingFail = false

									if #existing > 0 then
										for i=1, #existing do
											local existingObject = existing[i]
											if getElementModel(existingObject) == v[1] and getElementAlpha(existingObject) == 255 and getElementDimension(existingObject) == exports["editor_main"]:getWorkingDimension() then
												outputDebugString("[MT+] Spawning feature "..tostring(k-1).." canceled, it already exists in that spot!", debugLevel, 0, 255, 0)
												existingFail = true
												totalFails = totalFails + 1
												break
											end
										end
									end

									if existingFail then
										break
									end

								end

								local rxAdditional = dataRX ~= nil and dataRX or 0
								local ryAdditional = dataRY ~= nil and dataRY or 0
								local rzAdditional = dataRZ ~= nil and dataRZ or 0

								rx, ry, rz = rotateZ(rx, ry, rz, rzAdditional)
								rx, ry, rz = rotateX(rx, ry, rz, rxAdditional)
								rx, ry, rz = rotateY(rx, ry, rz, ryAdditional)

								if additions and type(additions) == "table" then
									if additions.scale ~= nil and type(additions.scale) == "number" then
										scale = scale * additions.scale
									end
									if additions.doublesided ~= nil and type(additions.doublesided) == "boolean" then
										doublesided = additions.doublesided
									end
									if additions.collisions ~= nil and type(additions.collisions) == "boolean" then
										collisions = additions.collisions
									end
								end

								triggerServerEvent("mtp:adjacentAccept", localPlayer, {rotation = {rx, ry, rz}, scale = scale, doublesided = doublesided, collisions = collisions, player = localPlayer, mode = "bind"})
								triggerServerEvent("doCreateElement", localPlayer, "object", "editor_main", {position = {offX, offY, offZ}, rotation = {rx, ry, rz}, model = v[1]}, false, false)

								totalSpawns = totalSpawns + 1

								break
							end

						end

					else
						prompt("Spawning features $$failed##, object invalid (no offsets)!")
						return
					end

					if totalSpawns == 0 then
						prompt("Spawning features $$failed##, no features have been created.")
						outputDebugString("[MT+] No features created.", debugLevel, 0, 255, 0)
						return
					end

					triggerServerEvent("mtp:applyProperty", selectedElement, {rotation = {rx, ry, rz}, position = {x, y, z}})

					selectedElement = nil
					destroyPreviews()
					mainElementShader()

					if totalFails == 0 then
						prompt("Spawning all features #00D000succeeded##!")
					else
						prompt("Spawning features ("..tostring(totalSpawns).." of "..tostring(totalSpawns + totalFails)..") #00D000succeeded##!")
					end

					outputDebugString("[MT+] Added building features.", debugLevel, 0, 255, 0)

					return true

				end

			else

				prompt("Spawning features failed, $$'cursorMode' ##needed!")
				outputDebugString("[MT+] Adding building features failed, 'cursorMode' needed.", debugLevel, 0, 255, 0)

			end

		end

	elseif button == isControlPressed(button, "mtp_toggle_lrot") then

		destroyPreviews()

		if not state then
			if spawnMode == "none" then
				selectedElement = nil
				mainElementShader()
			end
			if selectedShader then
				dxSetShaderValue(selectedShader, "color", highlightColor)
			end
			if selectedBlip then
				setBlipColor(selectedBlip, highlightColor[1]*255, highlightColor[2]*255, highlightColor[3]*255, highlightColor[4]*255)
			end
			exports["editor_main"]:dropElement(true)
			exports["editor_main"]:selectElement(selectedElement, 2)
		end

		createPreviewElements()

		outputDebugString("[MT+] Local rotation ended.", debugLevel, 0, 255, 0)

	elseif (spawnMode == "both" or spawnMode == "binds") and (button == isControlPressed(button, "mtp_quick_front") or button == isControlPressed(button, "mtp_quick_back") or button == isControlPressed(button, "mtp_quick_left") or button == isControlPressed(button, "mtp_quick_right")) then

		if state then return end

		if blockedBinds then
			blockedBinds = false
			outputDebugString("[MT+] Blocked accidental object creation with binds.", debugLevel, 0, 255, 0)
			return
		end

		if isCursorOnGUI() then
			outputDebugString("[MT+] Spawning with binds canceled because the cursor is hovering over a GUI.", debugLevel, 0, 255, 0)
			return
		end

		if exports["editor_main"]:getMode() == 2 then

			if selectedElement and isElement(selectedElement) and getElementDimension(selectedElement) == exports["editor_main"]:getWorkingDimension() then

				cancelEvent(true)

				local x, y, z = getElementPosition(selectedElement)

				if bindsFarClip and getDistanceBetweenPoints3D(x, y, z, getElementPosition(localPlayer)) > getFarClipDistance() then
					return
				end

				local spawningTargetModel = 1

				local model = getElementModel(selectedElement)
				local scale = getObjectScale(selectedElement)
				local doublesided = isElementDoubleSided(selectedElement)
				local collisions = getEditorElementCollisions(selectedElement)
				local rx, ry, rz = exports.edf:edfGetElementRotation(selectedElement)
				local selectedMatrix = getElementMatrix(selectedElement)

				local data = positionData[model]

				local keyOffset = nil

				if data then
					if bindUseSelectedModel then
						spawningTargetModel = previewModel
					end
					if data[spawningTargetModel][2] and type(data[spawningTargetModel][2]) == "table" then
						keyOffset = (button == isControlPressed(button, "mtp_quick_front") and data[spawningTargetModel][2][3]) or (button == isControlPressed(button, "mtp_quick_back") and data[spawningTargetModel][2][4]) or (button == isControlPressed(button, "mtp_quick_right") and data[spawningTargetModel][2][1]) or (button == isControlPressed(button, "mtp_quick_left") and data[spawningTargetModel][2][2]) or nil
					end
				end

				if keyOffset then
					keyOffset = {keyOffset[1] * scale, keyOffset[2] * scale, keyOffset[3] * scale, keyOffset[4], keyOffset[5], keyOffset[6], keyOffset[7]}
				else
					if bindUseSelectedModel then
						spawningTargetModel = 1
					end
					local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(selectedElement)
					local offsetX = (button == isControlPressed(button, "mtp_quick_left") and (minX * 2) + 0.03) or (button == isControlPressed(button, "mtp_quick_right") and (maxX * 2) - 0.03) or 0
					local offsetY = (button == isControlPressed(button, "mtp_quick_front") and (maxY * 2) - 0.03) or (button == isControlPressed(button, "mtp_quick_back") and (minY * 2) + 0.03) or 0
					keyOffset = {offsetX * scale, offsetY * scale, 0}
				end

				local creatorModel = (spawningTargetModel == 1 and model) or data[spawningTargetModel][1]

				x, y, z = getPositionFromElementOffset(selectedMatrix, unpack(keyOffset))

				local rxAdditional = keyOffset[4] ~= nil and keyOffset[4] or 0
				local ryAdditional = keyOffset[5] ~= nil and keyOffset[5] or 0
				local rzAdditional = keyOffset[6] ~= nil and keyOffset[6] or 0

				rx, ry, rz = rotateZ(rx, ry, rz, rzAdditional)
				rx, ry, rz = rotateX(rx, ry, rz, rxAdditional)
				rx, ry, rz = rotateY(rx, ry, rz, ryAdditional)

				if overlapThreshold and overlapThreshold > 0 then
					local existing = getElementsWithinRange(x, y, z, overlapThreshold, "object", getElementInterior(localPlayer), exports["editor_main"]:getWorkingDimension())

					if #existing > 0 then
						for i=1, #existing do
							local existingObject = existing[i]
							if getElementModel(existingObject) == creatorModel and getElementAlpha(existingObject) == 255 and getElementDimension(existingObject) == exports["editor_main"]:getWorkingDimension() then
								local eRx, eRy, eRz = getElementRotation(existingObject)
								if (math.floor(eRx) == math.floor(rx) or math.floor(eRy) == math.floor(ry) or math.floor(eRz) == math.floor(rz)) then
									prompt("Spawning $$canceled ##to prevent overlapping!")
									return
								end
							end
						end
					end
				end

				destroyPreviews()

				local additions = keyOffset[7]
				if additions and type(additions) == "table" then
					if additions.scale ~= nil and type(additions.scale) == "number" then
						scale = scale * additions.scale
					end
					if additions.doublesided ~= nil and type(additions.doublesided) == "boolean" then
						doublesided = additions.doublesided
					end
					if additions.collisions ~= nil and type(additions.collisions) == "boolean" then
						collisions = additions.collisions
					end
				end

				exports["editor_main"]:dropElement(true)

				previewDirection = (button == isControlPressed(button, "mtp_quick_front") and 3) or (button == isControlPressed(button, "mtp_quick_back") and 4) or (button == isControlPressed(button, "mtp_quick_right") and 1) or (button == isControlPressed(button, "mtp_quick_left") and 2) or 1

				if not savedDirections[model] then savedDirections[model] = {} end
				savedDirections[model].previewModel = spawningTargetModel
				savedDirections[model].previewDirection = previewDirection

				triggerServerEvent("mtp:adjacentAccept", localPlayer, {rotation = {rx, ry, rz}, scale = scale, doublesided = doublesided, collisions = collisions, player = localPlayer, mode = "bind"})
				triggerServerEvent("doCreateElement", localPlayer, "object", "editor_main", {position = {x, y, z}, rotation = {rx, ry, rz}, model = creatorModel}, false, false)

				exports["editor_gui"]:outputMessage("Quickly spawned adjacent element.", 255, 100, 0, 4000)

				return true

			end

		end

	elseif button == isControlPressed(button, "mtp_direction_u") or button == isControlPressed(button, "mtp_direction_d") then

		if not state then return end

		local cameraData = {getCameraMatrix()}

		--if guiFocusCancel then outputDebugString("[MT+] Canceled bind, 'guiFocusCancel' got triggered.", debugLevel, 0, 255, 0) return end

		local increment = (button == isControlPressed(button, "mtp_direction_u") and 1) or -1
		onClick("right", "up", false, false, cameraData[1], cameraData[2], cameraData[3], nil, {directionIncrement = increment, usedBinds = true})

	end
end
addEventHandler("onClientKey", root, onKey, false, "low-1384")

function onClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement, extras)

	if not toolEnabled then return end
	if spawnMode == "none" then return end
	if editorForceCancel then return end
	if guiGetInputMode() == "no_binds" or isMTAWindowActive() then return end


	-- // LEFT CLICK

	if button == "left" and state == "up" then

		if spawnMode == "click" or spawnMode == "both" then
			if previewElements[clickedElement] then

				if isCursorOnGUI() then
					outputDebugString("[MT+] Spawning was canceled because the cursor is hovering over a GUI.", debugLevel, 0, 255, 0)
					return
				end

				local cameraX, cameraY, cameraZ = getCameraMatrix()
				if obeyEditorDistanceLimit == true and getDistanceBetweenPoints3D(cameraX, cameraY, cameraZ, worldX, worldY, worldZ) > exports["editor_main"]:getMaxSelectDistance() then
					outputDebugString("[MT+] Spawning was canceled by the 'obeyEditorDistanceLimit' cvar.", debugLevel, 0, 255, 0)
					return
				end

				local model = getElementModel(previewElements[clickedElement])
				local scale = getObjectScale(previewElements[clickedElement])
				local doublesided = isElementDoubleSided(previewElements[clickedElement])
				local collisions = getEditorElementCollisions(selectedElement)
				local x, y, z = getElementPosition(previewElements[clickedElement])

				local rx, ry, rz = exports.edf:edfGetElementRotation(selectedElement)

				local offX, offY, offZ, offRX, offRY, offRZ = getElementAttachedOffsets(clickedElement)

				rx, ry, rz = rotateZ(rx, ry, rz, offRZ)
				rx, ry, rz = rotateX(rx, ry, rz, offRX)
				rx, ry, rz = rotateY(rx, ry, rz, offRY)

				if overlapThreshold and overlapThreshold > 0 then
					local existing = getElementsWithinRange(x, y, z, overlapThreshold, "object", getElementInterior(localPlayer), exports["editor_main"]:getWorkingDimension())

					if #existing > 0 then
						for i=1, #existing do
							local existingObject = existing[i]
							if getElementModel(existingObject) == model and getElementAlpha(existingObject) == 255 and getElementDimension(existingObject) == exports["editor_main"]:getWorkingDimension() then
								local eRx, eRy, eRz = getElementRotation(existingObject)
								if (math.floor(eRx) == math.floor(rx) or math.floor(eRy) == math.floor(ry) or math.floor(eRz) == math.floor(rz)) then
									prompt("Spawning $$canceled ##to prevent overlapping!")
									destroyPreviews()
									cancelEvent(true)
									return
								end
							end
						end
					end
				end

				destroyPreviews()

				local lockedElement = getElementData(localPlayer, "mtp:selectedElement")
				if lockedElement then
					triggerServerEvent("doUnlockElement", lockedElement)
					setElementData(localPlayer, "mtp:selectedElement", nil, false)
				end

				local data = positionData[getElementModel(selectedElement)]
				if data then
					local additions = data[previewModel][2][previewDirection][7]
					if additions and type(additions) == "table" then
						-- if additions.scale ~= nil and type(additions.scale) == "number" then
							-- scale = scale * additions.scale
						-- end
						if additions.doublesided ~= nil and type(additions.doublesided) == "boolean" then
							doublesided = additions.doublesided
						end
						if additions.collisions ~= nil and type(additions.collisions) == "boolean" then
							collisions = additions.collisions
						end
					end
				end

				triggerServerEvent("mtp:adjacentAccept", localPlayer, {rotation = {rx, ry, rz}, scale = scale, doublesided = doublesided, collisions = collisions, player = localPlayer, mode = "click"})
				triggerServerEvent("doCreateElement", localPlayer, "object", "editor_main", {position = {x, y, z}, rotation = {rx, ry, rz}, model = model}, false, false)

				exports["editor_gui"]:outputMessage("Spawned adjacent element.", 255, 100, 0, 4000)

				mainElementShader()

				if type(extras) == "table" and extras.doNotCancel == true then
					-- indeed do not cancel
				else
					cancelEvent(true)
				end

				return
			end
		end

		selectedElement = (isElement(clickedElement) == true and clickedElement) or selectedElement

		if allowDropping and not clickedElement then
			selectedElement = nil
			destroyPreviews()
			mainElementShader()
			outputDebugString("[MT+] Dropped main element.", debugLevel, 0, 255, 0)
			return
		end

		if (selectedElement and isElement(selectedElement) and getElementDimension(selectedElement) == exports["editor_main"]:getWorkingDimension()) then

			outputDebugString("[MT+] Selected main element.", debugLevel, 0, 255, 0)

			mainElementShader(selectedElement, true)

			local model = getElementModel(selectedElement)

			if type(extras) == "table" and extras.doNotCancel == true then
				-- indeed do not cancel
			else
				cancelEvent(true)
			end

			if getElementType(selectedElement) == "object" then

				destroyPreviews()

				if positionData[model] then
					if savedDirections[model] then
						previewModel = savedDirections[model].previewModel
						previewDirection = savedDirections[model].previewDirection
					else
						if not positionData[model][previewModel] then previewModel = 1 end
						if not positionData[model][previewModel][2][previewDirection] then previewDirection = 1 end
					end
				else
					previewModel = 1
					if previewDirection > 6 then previewDirection = 1 end
				end

				if freecamShowPreviews and not exports["move_freecam"]:getAttachedElement() then
					createPreviewElements()
				end
			end

		end



	-- // RIGHT CLICK

	elseif button == "right" and state == "up" then

		local directionIncrement, usedBinds
		if type(extras) == "table" then
			if extras.directionIncrement ~= nil then
				directionIncrement = extras.directionIncrement
			end
			if extras.usedBinds ~= nil then
				usedBinds = extras.usedBinds
			end
		else
			directionIncrement = 1
		end

		if previewElements[clickedElement] then

			cancelEvent(true)

			local cameraX, cameraY, cameraZ = getCameraMatrix()
			if obeyEditorDistanceLimit == true and worldX and getDistanceBetweenPoints3D(cameraX, cameraY, cameraZ, worldX, worldY, worldZ) > 155 then
				outputDebugString("[MT+] Switching model was canceled by the 'obeyEditorDistanceLimit' cvar", debugLevel, 0, 255, 0)
				return
			end

			destroyPreviews()
			createPreviewElements()

		end

		local cameraData = {exports["editor_main"]:processCameraLineOfSight()}

		if usedBinds or not (not hoverGhostDirection and exports["editor_main"]:getMode() == 1 and cameraData[4]) then
		else
			outputDebugString("[MT+] Denied selecting direction.", debugLevel, 0, 255, 0)
			return
		end

		if (selectedElement and isElement(selectedElement) and getElementDimension(selectedElement) == exports["editor_main"]:getWorkingDimension()) and not clickedElement then

			local model = getElementModel(selectedElement)

			if positionData[model] then
				local data = positionData[model][previewModel][2]
				if data then
					previewDirection = previewDirection + (type(directionIncrement) == "number" and directionIncrement) or 1
					if previewDirection > #data then
						previewDirection = 1
					elseif previewDirection < 1 then
						previewDirection = #data
					end
				end
			else
				previewDirection = previewDirection + (type(directionIncrement) == "number" and directionIncrement) or 1
				if previewDirection > 6 then
					previewDirection = 1
				elseif previewDirection < 1 then
					previewDirection = 6
				end

			end

			if not savedDirections[model] then savedDirections[model] = {} end
			savedDirections[model].previewModel = previewModel
			savedDirections[model].previewDirection = previewDirection

			outputDebugString("[MT+] Selected direction: "..tostring(previewDirection), debugLevel, 0, 255, 0)

			destroyPreviews()
			createPreviewElements()

		end
	end
end
addEventHandler("onClientClick", root, onClick, true, "high+1384")

function createPreviewElements()

	destroyPreviews()

	if not toolEnabled then return end
	if spawnMode == "none" then return end
	if editorForceCancel then return end
	if not (spawnMode == "click" or spawnMode == "both" or bindPreview) then return end

	if selectedElement and isElement(selectedElement) and getElementDimension(selectedElement) == exports["editor_main"]:getWorkingDimension() then

		local preview

		local selectedMatrix = getElementMatrix(selectedElement)
		local model = getElementModel(selectedElement)
		local doublesided = isElementDoubleSided(selectedElement)
		local scale = getObjectScale(selectedElement)
		local additional_scale = 1
		local rx, ry, rz = getElementRotation(selectedElement)
		local data = positionData[model]

		if savedDirections[model] then
			previewModel = savedDirections[model].previewModel
			previewDirection = savedDirections[model].previewDirection
		end

		if data then

			if not data[previewModel] then
				previewModel = 1
				previewDirection = 1
			end

			local x, y, z = getPositionFromElementOffset(selectedMatrix, data[previewModel][2][previewDirection][1]*scale, data[previewModel][2][previewDirection][2]*scale, data[previewModel][2][previewDirection][3]*scale)

			local rxAdditional = data[previewModel][2][previewDirection][4] ~= nil and data[previewModel][2][previewDirection][4] or 0
			local ryAdditional = data[previewModel][2][previewDirection][5] ~= nil and data[previewModel][2][previewDirection][5] or 0
			local rzAdditional = data[previewModel][2][previewDirection][6] ~= nil and data[previewModel][2][previewDirection][6] or 0

			preview = createObject(data[previewModel][1], x, y, z, rx, ry, rz)

			rx, ry, rz = rotateZ(rx, ry, rz, rzAdditional)
			rx, ry, rz = rotateX(rx, ry, rz, rxAdditional)
			rx, ry, rz = rotateY(rx, ry, rz, ryAdditional)

			setElementDimension(preview, exports["editor_main"]:getWorkingDimension())

			local additions = data[previewModel][2][previewDirection][7]
			local additions = data[previewModel][2][previewDirection][7]
			if additions and type(additions) == "table" then
				if additions.scale ~= nil and type(additions.scale) == "number" then
					additional_scale = additions.scale
				end
				if additions.doublesided ~= nil and type(additions.doublesided) == "boolean" then
					doublesided = additions.doublesided
				end
				if additions.collisions ~= nil and type(additions.collisions) == "boolean" then
					collisions = additions.collisions
				end
			end

			attachElements(preview, selectedElement, data[previewModel][2][previewDirection][1]*scale, data[previewModel][2][previewDirection][2]*scale, data[previewModel][2][previewDirection][3]*scale, rxAdditional, ryAdditional, rzAdditional)

		else

			local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(selectedElement)
			local offsetX = (previewDirection == 1 and maxX * 2 - 0.03) or (previewDirection == 2 and minX * 2 + 0.03) or 0
			local offsetY = (previewDirection == 3 and maxY * 2 - 0.03) or (previewDirection == 4 and minY * 2 + 0.03) or 0
			local offsetZ = (previewDirection == 5 and maxZ * 2 - 0.03) or (previewDirection == 6 and minZ * 2 + 0.03) or 0
			local x, y, z = getPositionFromElementOffset(selectedMatrix, offsetX*scale, offsetY*scale, offsetZ*scale)

			preview = createObject(model, x, y, z, rx, ry, rz)

			setElementDimension(preview, exports["editor_main"]:getWorkingDimension())

			attachElements(preview, selectedElement, offsetX*scale, offsetY*scale, offsetZ*scale)

		end

		if preview then

			setElementAlpha(preview, 150)
			setObjectScale(preview, scale*additional_scale)
			setElementDoubleSided(preview, doublesided)
			previewElements[preview] = preview
			setElementID(preview, "[preview]")

		end

	end
end

addEvent("onClientElementCreate", true)
addEventHandler("onClientElementCreate", root, function()

	if not toolEnabled then return end
	if spawnMode == "none" then return end
	if editorForceCancel then return end
	if not selectNewOnClone then return end
	if bindCreateTimer then return end

	local newObject = source

	setTimer(function()

		local newType = getElementType(newObject)

		if exports["editor_main"]:getSelectedElement() == newObject and newType == "object" then
			selectedElement = newObject
			mainElementShader(selectedElement, true)
			destroyPreviews()

			outputDebugString("[MT+] Selected cloned element: "..tostring(selectedElement), debugLevel, 0, 255, 0)

			if (freecamShowPreviews and exports["editor_main"]:getMode() == 1) or exports["editor_main"]:getMode() == 2 then
				createPreviewElements()
			end
		end
	end, selectNewOnCloneDelay, 1)

end)

addEvent("onClientElementDestroyed", true)
addEventHandler("onClientElementDestroyed", root, function()
	local destroyedObject = source
	if selectedElement == destroyedObject then
		selectedElement = nil
		mainElementShader()
		destroyPreviews()
	end
end)

addEvent("mtp:response", true)
addEventHandler("mtp:response", root, function(newElement, mode)

	if mode == "newMap" then
		selectedElement = nil
		mainElementShader()
		destroyPreviews()
		return
	end

	if not toolEnabled then return end
	if spawnMode == "none" then return end
	if editorForceCancel then return end

	if mode == "click" then
		if selectNewClick then
			selectedElement = newElement
		elseif incrementClickDirection then
			onClick("right", "up", false, false, false, false, false, nil)
		end
		mainElementShader(selectedElement, true)
		if exports["editor_main"]:getMode() == 1 then
			exports["editor_main"]:selectElement(selectedElement, 2)
		end
		outputDebugString("[MT+] Spawned element: "..tostring(newElement), debugLevel, 0, 255, 0)
		destroyPreviews()
		createPreviewElements()

	elseif mode == "bind" then
		if selectNewBind then
			if not selectedElement then
				selectedElement = nil
				destroyPreviews()
				mainElementShader()
				return
			end
			selectedElement = newElement
			mainElementShader(selectedElement, true)
			if bindCreateTimer then if isTimer(bindCreateTimer) then killTimer(bindCreateTimer) end bindCreateTimer = nil end
			bindCreateTimer = setTimer(function() bindCreateTimer = nil end, 50, 1)
			if bindPreview then
				destroyPreviews()
				createPreviewElements()
			end
		end
		outputDebugString("[MT+] Spawned element with binds: "..tostring(newElement), debugLevel, 0, 255, 0)
	end

end)

function renderList()

	if not toolEnabled then return end
	if spawnMode == "none" then return end
	if editorForceCancel then return end
	if not renderPreviewList then return end

	if selectedElement and isElement(selectedElement) then
		local model = getElementModel(selectedElement)
		dxText("#FFAA00"..tostring(model) .. " ("..engineGetModelNameFromID(model)..")", previewListOffsets.x, previewListOffsets.y, 1)
		local elementData = positionData[model]
		if elementData then
			for i=1,#elementData do
				local x_offset = math.floor(i/16)
				local modelData = elementData[i]
				local previewRenderDirection = ""
				if previewModel == i then
					if savedDirections[model] then
						if savedDirections[model].previewDirection then
							previewRenderDirection = "#FFAA00"..tostring(savedDirections[model].previewDirection).." #FFFFFFof #22AAFF#"..tostring(#modelData[2])
						end
					else
						previewRenderDirection = "#FFAA00"..tostring(previewDirection).." #FFFFFFof #22AAFF#"..tostring(#modelData[2])
					end
				else
					previewRenderDirection = "#22AAFF#"..tostring(#modelData[2])
				end
				local row_offset = i%16
				dxText(((previewModel == i and "#64FF64") or "#A0A0A0") .. tostring(modelData[1]) .. ": "..previewRenderDirection, previewListOffsets.x + 10 + x_offset*100, previewListOffsets.y + 18 * row_offset + 18*x_offset, 1)
			end
		else
			dxText("#64FF64" .. tostring(model) .. ": #FFAA00"..tostring(previewDirection).." #FFFFFFof #22AAFF#6", 50, 340 + 18, 1)
		end
	end

end
addEventHandler("onClientRender", root, renderList)

local shaderCode = [[
float4 color = float4(1, 0.5, 0, 1);

technique TexReplace
{
    pass P0
    {
        MaterialAmbient = color;
        MaterialDiffuse = color;
        MaterialEmissive = color;
        MaterialSpecular = color;
        Lighting = true;
    }
}
]]

function mainElementShader(element, isSelected)
	if selectedShader then destroyElement(selectedShader) selectedShader = nil end
	if selectedBlip then destroyElement(selectedBlip) selectedBlip = nil end
	if editorForceCancel then return end
	if not enableSelectedShader then return end
	if not (element and isElement(element)) or not isSelected then return end
	selectedShader = dxCreateShader(shaderCode)
	if selectedShader then
		engineApplyShaderToWorldTexture(selectedShader, "*", element, true)
		if highlightColor and type(highlightColor) == "table" and #highlightColor == 4 then
			dxSetShaderValue(selectedShader, "color", highlightColor)
		end
	end
	selectedBlip = createBlipAttachedTo(element, 0, 2, highlightColor[1]*255, highlightColor[2]*255, highlightColor[3]*255, 255, 1384)
end

function destroyPreviews()
	for k,v in pairs(previewElements) do
		destroyElement(k)
	end
	previewElements = {}
end

-- // check for element collisions, can be element data or the mta function
function getEditorElementCollisions(element)
	local collisions = true
	local edfCollision = exports.edf:edfGetElementProperty(element, "collisions")
	if edfCollision == "true" then
		return true
	elseif edfCollision == "false" then
		return false
	else
		return getElementCollisionsEnabled(element)
	end
end

-- // check if our cursor is on a window
function isCursorOnGUI()
	if not isCursorShowing() then return false end

	local cX, cY = getCursorPosition()
	cX, cY = cX*screenW, cY*screenH

	local allGUIs = getElementsByType("gui-window")
	if #allGUIs > 0 then
		for i=1, #allGUIs do
			local guiElement = allGUIs[i]
			if guiGetVisible(guiElement) then
				local x, y = guiGetPosition(guiElement)
				local sx, sy = guiGetSize(guiElement)
				if cX > x and cX < x + sx and cY > y and cY < y + sy then
					return true, guiElement
				end
			end
		end
	end
end

function cancelKeyboardEvents(sourceRes, functionName, allowedACL, fileName, lineNumber, ...)
	if sourceRes == getResourceFromName("move_keyboard") then
		return "skip"
	end
end

-- // unused
function getPreviewCount()
	local count = 0
	for k,v in pairs(previewElements) do
		count = count + 1
	end
	return count
end

function getPositionFromElementOffset(m,offX,offY,offZ)
    local m = m  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

function rotateX(rx, ry, rz, add)
	rx, ry, rz = convertRotationFromMTA(rx, ry, rz)
	rx = rx + add
	rx, ry, rz = convertRotationToMTA(rx, ry, rz)
	return rx, ry, rz
end

function rotateY(rx, ry, rz, add)
	return rx, ry + add, rz
end

function rotateZ(rx, ry, rz, add)
	ry = ry + 90
	rx, ry, rz = convertRotationFromMTA(rx, ry, rz)
	rx = rx - add
	rx, ry, rz = convertRotationToMTA(rx, ry, rz)
	ry = ry - 90
	return rx, ry, rz
end

function convertRotationToMTA(rotX, rotY, rotZ)
	rotX, rotY, rotZ = math.rad(rotX), math.rad(rotY), math.rad(rotZ)
	local sinX = math.sin(rotX)
	local cosX = math.cos(rotX)
	local sinY = math.sin(rotY)
	local cosY = math.cos(rotY)
	local sinZ = math.sin(rotZ)
	local cosZ = math.cos(rotZ)
	local newRotX = math.asin(cosY * sinX)
	local newRotY = math.atan2(sinY, cosX * cosY)
	local newRotZ = math.atan2(cosX * sinZ - cosZ * sinX * sinY, cosX * cosZ + sinX * sinY * sinZ)
	return math.deg(newRotX), math.deg(newRotY), math.deg(newRotZ)
end

function convertRotationFromMTA(rotX, rotY, rotZ)
	rotX = math.rad(rotX)
	rotY = math.rad(rotY)
	rotZ = math.rad(rotZ)
	local sinX = math.sin(rotX)
	local cosX = math.cos(rotX)
	local sinY = math.sin(rotY)
	local cosY = math.cos(rotY)
	local sinZ = math.sin(rotZ)
	local cosZ = math.cos(rotZ)
	return math.deg(math.atan2(sinX, cosX * cosY)), math.deg(math.asin(cosX * sinY)), math.deg(math.atan2(cosZ * sinX * sinY + cosY * sinZ, cosY * cosZ - sinX * sinY * sinZ))
end

-- // CUSTOM KEYBINDS
function isControlPressed(key, cmd_name)
	if not cmd_name then
		local keys = getBoundKeys(keyBindings[key].friendlyName)
		for k, v in pairs(keys) do
			if getKeyState(k) then
				return true
			end
		end
		return false
	else
		local keys = getBoundKeys(keyBindings[cmd_name].friendlyName)
		if keys[key] then
			return key
		end
	end
	return false
end

function getControlBindings(cmd_name, formatted)
	if formatted then
		local output
		local keys = getBoundKeys(keyBindings[cmd_name].friendlyName)
		for k, v in pairs(keys) do
			while true do
				if not output then output = string.upper(k) break end
				output = output .. " / " .. string.upper(k)
				break
			end
		end
		return output
	else
		-- idk
	end
end

-- // Returns model offset index position (fuck knows)
function getModelOffsetPosition(baseModel, offsetModel)
	for k,v in ipairs(positionData[baseModel]) do
		if v[1] == offsetModel then
			return k
		end
	end
end


-- // CHATBOX MESSAGE
function prompt(text, r, g, b)
	if type(text) ~= "string" then return end
	local r, g, b = r or 255, g or 100, b or 100
	local prefix = (text ~= "" and "[MT+] ") or ""
	return outputChatBox(prefix.."#FFFFFF"..string.gsub(string.gsub(text, "%#%#", "#FFFFFF"), "%$%$", string.format("#%.2X%.2X%.2X", r, g, b)), r, g, b, true)
end

-- // Cute dxText
function dxText(text, x, y, size)
	dxDrawText(string.gsub(text, "#%x%x%x%x%x%x", ""), x+1, y+1, x+1, y+1, tocolor(0,0,0,255), size, "default", "left", "top", false, false, false, true)
	dxDrawText(text, x, y, x, y, tocolor(255,255,255,255), size, "default", "left", "top", false, false, false, true)
end

-- // Used for efficient saving
function float(number)
	return math.floor( number * 1000 ) * 0.001
end