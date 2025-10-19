--[[
	* Magic Tool+ (MTP) by chris1384 @2024 (youtube.com/chris1384)
	* Original idea by Mirage (Mirage's Magic Tool - MMT)
	* This script was made from scratch.
	* Do not redistribute this (under other names) without my permission, do not edit & upload without my permission or take any credit from it.
	* For any questions, bug reports or any suggestions, send a message to @chris1384 on Discord.

	* Have fun mapping! - chris1384 <3
]]

-- // edit to your liking

--[[
	// NOTICE!!!
	// KEY BINDINGS have been moved to MTA:SA Settings > Binds
]]

allowDropping = true -- if you don't press any editor object, just deselect the main element
freecamDrop = false -- drop selected element after switching to freecam
freecamShowPreviews = true -- show previews during freecam, you can get buggy behaviour (zooming objects)
spawnMode = "both" -- select spawn mode, this can be: "click", "binds", "both", "none" (use only local rotations feature)
invertScrollWheel = false -- invert scroll wheel for model change (useful for touchpads)

overlapThreshold = 0.1 -- overlap radius, preventing objects being stuck to one another. set to 0 to disable (NOT RECOMMENDED)

obeyEditorDistanceLimit = true
--[[
	prevents the player from creating objects (using CLICKS) that are too far. (over 155 units)
	setting to true limits the distance to which objects are created, but can not appeal to player gameplay.
	setting to false allows to create objects far beyond this limit, but can create editor errors.
	UPDATE: it has been fixed in this commit https://github.com/multitheftauto/mtasa-resources/pull/495
]]

hoverGhostDirection = false
--[[
	by default, do not let the player change the offset direction if their cursor is already on a ghost element
	due to players using the older editor, this can affect their mapping session by picking up elements by mistake using RIGHT CLICK
	it's recommended to let this as false if that's the case, otherwise, set it to true if that appeals more to you
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

toggleLocalRotation = true -- rotate selected object to a specified angle on an axis.
localRotationY = true -- enable local rotations on the Y axis.
localRotationAngle = 15 -- rotation angle duuh

toggleLocalPositioning = true -- toggle local movement
localPositionSpeed = 1 -- position scaling, it's multiplying the users editor config (not recommended to edit)

ignoreRotated2DFX = true
--[[
	certain buildings have custom corona effects assigned to an object which can be spawned automatically using the features bind
	most of the time this object may be unnecessary to be spawned since these effects do not appear if the object is rotated on X/Y axis (~ 16.26 corona threshold)
	if you want to save some resources and not fill up your object stream pool on a particular area, please keep this setting enabled to avoid these oversights
]]

buildFeaturesWindowsOnly = false
--[[
	*potentially unwanted setting*
	create building features using only the second offset entry (should be nighttime windows, offsets do vary a lot)
	this is recommended on parts where there are a lot of objects and you don't want to cram useless features.
	this boils down to mappers preference, either optimization or vanity.
]]

enableSelectedShader = true -- highlight the selected element
highlightColor = {1, 0.3, 0, 1} -- shader color (float4 RGBA values)
highlightRotationColor = {0, 0, 1, 1} -- shader color (float4 RGBA values)
highlightPositionColor = {1, 0, 0.25, 1} -- shader color (float4 RGBA values)
highlightPositionSlowColor = {1, 0, 0, 1} -- shader color (float4 RGBA values)

toggleDebug = false -- spam debugscript

-- //