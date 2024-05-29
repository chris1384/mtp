--[[
	* Magic Tool+ (MTP) by chris1384 @2024 (youtube.com/chris1384)
	* Original idea by Mirage (Mirage's Magic Tool - MMT)
	* This script was made from scratch. 
	* Do not redistribute this (under other names) without my permission, do not edit & upload without my permission or take any credit from it.
	* For any questions, bug reports or any suggestions, send a message to @chris1384 on Discord.
	
	* Have fun mapping! - chris1384 <3
]]

-- // edit to your liking

toggleBind = "x" -- toggle tool bind
alternativeModelChangeBind = nil -- set a bind to change model list, use "key" (ex: "n") to enable this. set to nil to disable
 
allowDropping = true -- if you don't press any editor object, just deselect the main element
freecamDrop = false -- drop selected element after switching to freecam
freecamShowPreviews = true -- show previews during freecam, you can get buggy behaviour (zooming objects)
spawnMode = "both" -- select spawn mode, this can be: "click", "binds", "both", "none" (use only local rotations feature)
invertScrollWheel = true -- invert scroll wheel for model change (useful for touchpads)

overlapThreshold = 0.3 -- overlap radius, preventing objects being stuck to one another. set to 0 to disable (NOT RECOMMENDED)

obeyEditorDistanceLimit = true 
--[[ 	
	prevents the player from creating objects (using CLICKS) that are too far. (over 155 units)
	setting to true limits the distance to which objects are created, but can not appeal to player gameplay.
	setting to false allows to create objects far beyond this limit, but can create editor errors.
]]

selectNewClick = true -- select new element after it spawned using click
incrementClickDirection = true -- change direction on spawn click. 'selectNewClick' needs to be false for this to work

bindsFarClip = true -- limit the spawning of objects using binds to the weathers far clip (safer but annoying sometimes)
bindUseSelectedModel = true -- if you want to spawn something, use the model loaded on preview, instead of spawning the original model
selectNewBind = true -- select new element after it spawned using binds
selectNewOnClone = true -- select the new main element on editor clone
selectNewOnCloneDelay = 150 -- delay in ms until the new object is getting selected (needed, recommended over 100ms)
bindPreview = true -- show click previews on objects spawning with binds

renderPreviewList = true -- show the count of custom offsets
previewListOffsets = {x = 40, y = 340} -- list offset

toggleLocalRotation = true -- rotate selected object to a specified angle on an axis. usage: RIGHT SHIFT + W/A/S/D
localRotationY = true -- enable local rotations on the Y axis. usage: RIGHT SHIFT + NUMPAD+ / NUMPAD-
localRotationAngle = 30 -- rotation angle duuh

buildingFeaturesKey = nil
--[[
	add building features like windows, shadows, meshes or any extra object. 
	this is not being filtered from track objects, so be careful on how you use this.
	to enable this, use "key" (ex: "h"). my preference:   "num_mul"   (NUMPAD *)
	to disable, set this to nil
]]
buildFeaturesWindowsOnly = false 
--[[
	create building features using only the second offset entry (should be nighttime windows, offsets do vary a lot)
	this is recommended on parts where there are a lot of objects and you don't want to cram useless features.
	this boils down to mappers preference, either optimization or vanity.
]]

enableSelectedShader = true -- highlight the selected element
highlightColor = {1, 0.3, 0, 1} -- shader color (float4 RGBA values)
highlightRotationColor = {0, 0, 1, 1} -- shader color (float4 RGBA values)

toggleDebug = false -- spam debugscript

-- //