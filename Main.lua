local BlizzButtons = { "MiniMapWorldMapButton", "QueueStatusMinimapButton", "MinimapZoomIn", "MinimapZoomOut",  
					   "MiniMapBattlefieldFrame", "GameTimeFrame", "FeedbackUIButton" , "MinimapBackdrop", "TimeManagerClockButton",
					   "GarrisonLandingPageMinimapButton"};

local parent = CreateFrame('Frame',"Mine",UIParent)
parent:RegisterEvent("ADDON_LOADED")
parent:SetSize(32, 32)
parent.t = parent:CreateTexture()
parent.t:SetColorTexture(0.5,0.5,0.5,0.5)
parent.t:SetAllPoints(parent)
parent:SetPoint("TOPRIGHT", MinimapCluster, "TOPLEFT", 25, 0)
parent:Show()

local movedButtonNames = {}
local movedButtons = {}

function isInTable(tbl, buttonName)
	if buttonName == nil then return false end
	for k,v in ipairs(tbl) do
		if (strlower(v) == strlower(buttonName))  then
			return true;
		end
	end
	return false;
end

function printParentChildName(button)
	local parentName = button:GetParent():GetName()	
	local childName = button:GetName()
	
	print(parentName .. "-->" .. childName)			
end

function addButton(button)	
	if button:GetName() == nil then return end
	if isInTable(BlizzButtons, button:GetName()) then return end	
	if button:GetParent():GetName() == "Mine" then return end
	
	--printParentChildName(button)
	
	table.insert(movedButtonNames, button:GetName())
	table.insert(movedButtons, button)
	
	local offsetX = table.getn(movedButtonNames)
	
	parent:SetSize(32 * offsetX, 32)	
	
	button:SetParent(parent)	
	button:SetPoint('TOPLEFT', 32 * (offsetX - 1), 0 )		
end

function findButtons(frame)
	for i, child in ipairs({frame:GetChildren()}) do					
		addButton(child);	
	end
end

function printMyButtons()
	print("------------------------------------")
	for key, value in ipairs(movedButtons) do
		printParentChildName(value)
	end
end

function squareMiniMap()
    MinimapBorderTop:Hide()
    MinimapBorder:Hide()
    Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')
	MiniMapWorldMapButton:Hide()
end

local function refreshAll()	
	addButton(MiniMapTracking)		
	findButtons(Minimap)			
	squareMiniMap()	
end

local function eventHandler(self, event, ...)
	local arg1 = ...	
	if event == "ADDON_LOADED" then			
		refreshAll()					
	end	
end

local lastHasNewMail = nil

local function watchMailBoxIcon()
	--DisableAddOn("SexyMap")
	BuffFrame:SetPoint("TOPRIGHT", MinimapCluster, "TOPLEFT", 25, -40)		
	local point, relativeTo, relativePoint, offset_x, offset_y = BuffFrame:GetPoint()
	--print(offset_y)
	MiniMapMailFrame:Show()			
	if MiniMapMailFrame == nil then return end
	if lastHasNewMail ~= HasNewMail() then
		if HasNewMail() then			
			MiniMapMailFrame:SetAlpha(1)		
		else
			MiniMapMailFrame:SetAlpha(0.2)			
		end					
		lastHasNewMail = HasNewMail()
	end	
end

C_Timer.NewTicker(0.1, watchMailBoxIcon)

--C_Timer.NewTicker(1, printMyButtons)

parent:SetScript("OnEvent", eventHandler)