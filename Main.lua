--[[

UI Layers

1. background
2. border
3. artwork
4. overlay
5. highlight

]]--

local height = 32

local parent = CreateFrame('Frame','Mine',UIParent)
parent:SetPoint('TOPRIGHT', MinimapCluster, 'TOPLEFT', 25, 0)
parent:RegisterEvent('ADDON_LOADED')
parent:SetSize(32, height)
parent.t = parent:CreateTexture()
parent.t:SetColorTexture(0.5,0.5,0.5,0.3)
parent.t:SetMask('Interface\\Buttons\\buttonhilight-Square')
parent.t:SetAllPoints(parent)
parent:Show()

local movedButtonNames = {}
local movedButtons = {}

local function addButton(button)
	if button:GetName() == nil then return end
	if button:GetParent():GetName() == 'Mine' then return end
	local width, height = button:GetSize()
	width = floor(width)
	height = floor(height)
	if width > 33 or height > 33 then return end

	table.insert(movedButtonNames, button:GetName())
	table.insert(movedButtons, button)

	local offsetX = table.getn(movedButtonNames)

	parent:SetSize(32 * offsetX, 32)

	button:SetParent(parent)
	button:SetPoint('TOPLEFT', 32 * (offsetX - 1), 0)
end

local function findButtons(frame)
	for i, child in ipairs({frame:GetChildren()}) do
		addButton(child);
	end
end

local function squareMiniMap()
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
	if event == 'ADDON_LOADED' then
		refreshAll()					
	end
end

local lastHasNewMail = nil

local function watchMailBoxIcon()	
	BuffFrame:SetPoint('TOPRIGHT', MinimapCluster, 'TOPLEFT', 25, -40)			
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

parent:SetScript('OnEvent', eventHandler)