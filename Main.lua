--[[

UI Layers

1. background
2. border
3. artwork
4. overlay
5. highlight

]]--

local height = 32

local x = 0
local y = 0

function OnClickXYPos()
	if not UnitExists('target') then 
		print('You have no target to send location information for')
		return 
	end
	if UnitIsPlayer('target') then 		
		SendChatMessage('I am at location [' .. round(x * 100, 2) .. ', '.. round(y * 100, 2) ..']', 'WHISPER', nil, UnitName('target'));
		SetRaidTarget('target', 4);
	else
		local index = GetChannelName("General")
		SendChatMessage('%t is at location [' .. round(x * 100, 2) .. ', '.. round(y * 100, 2) ..']', 'CHANNEL', nil, index);
		SetRaidTarget('target', 8);
	end
end

local frmMain = CreateFrame('Button','XYPos',UIParent)
frmMain:RegisterForClicks('AnyUp')
frmMain:SetScript('OnClick', OnClickXYPos)
frmMain:SetSize(170, height)
frmMain:SetPoint('TOP')

local backdrop = CreateFrame("Frame", "Backdrop", frmMain, "BackdropTemplate")
backdrop:SetAllPoints()
backdrop.backdropInfo = {
	bgFile = nil,                                       -- String - Which texture file to use as frame background (.blp or .tga format) 
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",  -- String- Which texture file to use as frame edge blp or .tga format) 
	tile = true,    									-- Boolean - whether background texture is tiled or streched 
	tileSize = 16,  									-- Number - Control how large each copy of the bgFile becomes on-screen 
	edgeSize = 16,   									-- Number - Control how large each copy of the edgeFile becomes on-screen (i.e. border thickness and corner size) 
	insets = { left = 4, right = 4, top = 4, bottom = 4, },
}
backdrop:ApplyBackdrop()
frmMain:Show()

local xyPos = frmMain:CreateFontString(frmMain, 'OVERLAY', 'GameTooltipText') 
xyPos:SetTextColor(1, 1, 1, 1)
xyPos:SetPoint('CENTER',0,0)

function round(number, precision)
   local fmtStr = string.format('%%0.%sf',precision)
   number = string.format(fmtStr,number)
   return number
end

function updatePos()
	local map = C_Map.GetBestMapForUnit('player')
	local position = C_Map.GetPlayerMapPosition(map, 'player')
	x, y = position:GetXY()
	xyPos:SetText('Location [' .. round(x * 100, 2) .. ', '.. round(y * 100, 2) ..']')
end

C_Timer.NewTicker(0.1, updatePos)

local parent = CreateFrame('Frame','Mine',UIParent)
parent:SetPoint('TOPRIGHT', MinimapCluster, 'TOPLEFT', 25, 0)
parent:RegisterEvent('ADDON_LOADED')
parent:SetSize(32, height)
parent.t = parent:CreateTexture()
parent.t:SetColorTexture(0.5,0.5,0.5,0.3)
parent.t:SetMask('Interface\\Buttons\\buttonhilight-Square')
parent.t:SetAllPoints(parent)
parent:Show()

--local frmMain = CreateFrame('Frame','zzz',UIParent)
--frmMain:SetSize(150, 150)
--frmMain.t = frmMain:CreateTexture()
--frmMain:SetPoint('CENTER', 100, 100)
--frmMain.t:SetTexture('Interface\\DialogFrame\\ui-dialogbox-gold-background.blp')
--frmMain.t:SetMask('interface/buttons/ui-autocastableoverlay.blp')
--frmMain.t:SetAllPoints(frmMain)
--frmMain:Show()

-- Credits: https://git.tukui.org/Azilroka/ProjectAzilroka/-/blob/f13975c053ecbd8f78a4942166947b0902a2606f/Modules/SquareMinimapButtons.lua
--local function SkinMinimapButton()	
--	MiniMapTrackingIcon:ClearAllPoints()
--	MiniMapTrackingIcon:SetPoint('CENTER')
--	MiniMapTrackingBackground:SetAlpha(0)
--	MiniMapTrackingIconOverlay:SetAlpha(0)
--	MiniMapTrackingButton:SetAlpha(0)
--end

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

function printParentChildName(button, width, height)
	local parentName = button:GetParent():GetName()	
	local childName = button:GetName()
	
	print(parentName .. '-->' .. childName .. '[' .. width .. ',' .. height .. ']')			
end

function addButton(button)	
	if button:GetName() == nil then return end
	--if isInTable(BlizzButtons, button:GetName()) then return end	
	if button:GetParent():GetName() == 'Mine' then return end
	local width, height = button:GetSize()	
	width = floor(width)
	height = floor(height)
	
	if width > 33 or height > 33 then 
		--printParentChildName(button, width, height)	
		return 
	end
	
	--printParentChildName(button, width, height)	
		
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
	print('------------------------------------')
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
	--SkinMinimapButton()	
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
	--DisableAddOn('SexyMap')
	BuffFrame:SetPoint('TOPRIGHT', MinimapCluster, 'TOPLEFT', 25, -40)		
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

parent:SetScript('OnEvent', eventHandler)