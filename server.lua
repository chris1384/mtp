--[[
	* Magic Tool+ (MTP) by chris1384 @2024 (youtube.com/chris1384)
	* Original idea by Mirage (Mirage's Magic Tool - MMT)
	* This script was made from scratch.
	* Do not redistribute this (under other names) without my permission, do not edit & upload without my permission or take any credit from it.
	* For any questions, bug reports or any suggestions, send a message to @chris1384 on Discord.

	* Have fun mapping! - chris1384 <3
]]

local creatorArgs = {override = false}

addEvent("mtp:adjacentAccept", true)
addEventHandler("mtp:adjacentAccept", root, function(args)
	if client then
		creatorArgs = {override = true, optional = args}
	end
end)

addEvent("mtp:applyProperty", true)
addEventHandler("mtp:applyProperty", root, function(tbl)
	if client then

		local object = source

		if not (object and isElement(object)) then return end
		if not (type(tbl) == "table") then return end

		local addedUndo = false

		local oldX, oldY, oldZ = getElementPosition(source)
		local oldRX, oldRY, oldRZ = getElementRotation(source)

		if tbl.position then
			local x, y, z = unpack(tbl.position)
			local distance = getDistanceBetweenPoints3D(oldX, oldY, oldZ, x, y, z)

			if distance > 1 then
				if not addedUndo then
					triggerEvent("onElementMove_undoredo", source, oldX, oldY, oldZ, oldRX, oldRY, oldRZ)
					addedUndo = true
				end
			end
			exports.edf:edfSetElementPosition(source, x, y, z)
		end

		if tbl.rotation then
			if not addedUndo then
				triggerEvent("onElementMove_undoredo", source, oldX, oldY, oldZ, oldRX, oldRY, oldRZ)
				addedUndo = true
			end
			local rx, ry, rz = unpack(tbl.rotation)
			exports.edf:edfSetElementRotation(source, rx, ry, rz, "ZXY")
		end

	end
end)

addEvent("onElementCreate", true)
addEventHandler("onElementCreate", root, function()

	if not creatorArgs.optional then return end
	if not creatorArgs.optional.player then return end
	if creatorArgs.override == false then return end

	-- // Set custom ID, fuckin override everything idc
	local testID = 1
	while getElementByID("MT+ ("..tostring(testID)..")") do
		testID = testID + 1
	end
	local newID = "MT+ ("..tostring(testID)..")"
	setElementID(source, newID)
	setElementData(source, "id", newID)
	setElementData(source, "me:ID", newID)
	setElementData(source, "me:autoID", true)
	exports.edf:edfSetElementProperty(source, "id", newID)

	exports.edf:edfSetElementProperty(source, "scale", creatorArgs.optional.scale)
	exports.edf:edfSetElementProperty(source, "doublesided", tostring(creatorArgs.optional.doublesided))
	exports.edf:edfSetElementProperty(source, "collisions", tostring(creatorArgs.optional.collisions))

	local rx, ry, rz = unpack(creatorArgs.optional.rotation)
	exports.edf:edfSetElementRotation(source, rx, ry, rz, "ZXY")

	triggerEvent("doUnlockElement", source)

	triggerClientEvent(creatorArgs.optional.player, "mtp:response", creatorArgs.optional.player, source, creatorArgs.optional.mode)

	creatorArgs = {override = false}
end)

--[[
addEvent("onElementDrop", true)
addEventHandler("onElementDrop", root, function()
	if not client then return end
	triggerClientEvent(client, "mtp:response", client, source, "drop")
end)
]]

function onMapChange()
	triggerClientEvent(root, "mtp:response", resourceRoot, false, "newMap")
end
for _,mapEvents in ipairs({"onNewMap", "onMapOpened"}) do
	addEvent(mapEvents)
	addEventHandler(mapEvents, root, onMapChange)
end