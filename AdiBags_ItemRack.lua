--[[
AdiBags_ItemRack - Adds ItemRack set filters to AdiBags.
--]]

local _, ns = ...

local addon = LibStub('AceAddon-3.0'):GetAddon('AdiBags')
local L = setmetatable({}, {__index = addon.L})

-- The filter itself
-- Use a priority slightly higher than the Gear Manager filter one
local setFilter = addon:RegisterFilter("ItemRackSets", 92, 'ABEvent-1.0')
setFilter.uiName = L['ItemRack item sets']
setFilter.uiDesc = L['Put items belonging to one or more sets of ItemRack in specific sections.']

local function sendFiltersChanged()
	setFilter:SendMessage('AdiBags_FiltersChanged')
end


local timer = nil
local oldSaveSet = nil
local oldDeleteSet = nil
local frame = CreateFrame("Frame", nil)
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:SetScript("OnEvent", function(self, event, ...)
	if timer ~= nil then
		timer:Cancel()
	end
		
	timer = C_Timer.NewTimer(0.5, function(...)
		timer = nil
		sendFiltersChanged()
	end)
end)

local function itemRackUpdated(event, setName)
	sendFiltersChanged()
end
ItemRack:RegisterExternalEventListener("ITEMRACK_SET_SAVED", itemRackUpdated)
ItemRack:RegisterExternalEventListener("ITEMRACK_SET_DELETED", itemRackUpdated)

function setFilter:OnInitialize()
	self.db = addon.db:RegisterNamespace('ItemRackSets', {})

end

function setFilter:OnEnable()
	addon:UpdateFilters()
end

function setFilter:OnDisable()
	addon:UpdateFilters()
end

function setFilter:Filter(data)
	local bag = data["bag"]
	local slot = data["slot"]
	local id = ItemRack.GetID(bag, slot)
	local sets = self:findSetsForItem(id)
	
	local label = nil
	local fmt = "Set: %s"
	for _, set in ipairs(sets) do
		if label == nil then
			label = set
		else
			fmt = "Sets: %s"
			label = label .. ", " .. set
		end
	end
	
	if label ~= nil then
		return L[fmt]:format(label), L["ItemRack, Equipment"]
	end
end

function setFilter:GetFilterOptions()
end

function setFilter:findSetsForItem(searchId)
	local sets = {}
	
	for name, set in pairs(ItemRackUser.Sets) do
		if name ~= nil and name ~= "nil" and string.sub(name, 1, 1) ~= "~" then
			for _, id in pairs(set["equip"]) do
				if id ~= "0" then
					if ItemRack.SameID(searchId, id) then
						table.insert(sets, name)
					end
				end
			end
		end
	end
	
	table.sort(sets)
	return sets
end
