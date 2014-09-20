-----------------------------------------
-- Author  :  $Author:$
-- Date    :  $Date:$
-- Revision:  $Revision:$
-----------------------------------------
-- These are functions from wow that have been needed by addons so far
-- Not a complete list of the functions.
-- Most are only stubbed enough to pass the tests
-- This is not intended to replace WoWBench, but to provide a stub structure for
--     automated unit tests.

local itemDB = {
}

-- simulate an internal inventory
myInventory = { ["9999"] = 52, }
globals = {}
accountExpansionLevel = 4   -- 0 to 5

-- simulate the data structure that is the flight map
-- Since most the data assumes Alliance, base it on being at Stormwind
TaxiNodes = {
	{["name"] = "Stormwind", ["type"] = "CURRENT", ["hops"] = 0, ["cost"] = 0},
	{["name"] = "Rebel Camp", ["type"] = "REACHABLE", ["hops"] = 1, ["cost"] = 40},
	{["name"] = "Ironforge", ["type"] = "NONE", ["hops"] = 1, ["cost"]=1000},
}
MerchantInventory = {
	{["id"] = 7073, ["name"] = "Broken Fang", ["cost"] = 5000, ["link"] = "|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0|h[Broken Fang]|h|r"},
	{["id"] = 6742, ["name"] = "UnBroken Fang", ["cost"] = 10000, ["link"] = "|cff9d9d9d|Hitem:6742:0:0:0:0:0:0:0:80:0:0|h[UnBroken Fang]|h|r"},
}

-- WOW's function renames
strmatch = string.match
strfind = string.find
strsub = string.sub
strtolower = string.lower
time = os.time
max = math.max

-- WOW's functions
function getglobal( globalStr )
	-- set the globals table to return what is needed from the 'globals'
	return globals[ globalStr ]
end
function hooksecurefunc(externalFunc, internalFunc)
end

-- WOW's structures
SlashCmdList = {}
FACTION_BAR_COLORS = {
	[1] = {r = 1.0, g = 0, b = 0},                  -- 36000 Hated - Red
	[2] = {r = 1.0, g = 0.5019608, b = 0},          -- 3000 Hostile - Orange
	[3] = {r = 1.0, g = 0.8196079, b = 0},          -- 3000 Unfriendly - Yellow
	[4] = {r = 0.8, g = 0.9, b = 0.8},              -- 3000 Neutral - Grey
	[5] = {r = 1.0, g = 1.0, b = 1.0},              -- 6000 Friendly - White
	[6] = {r = 0, g = 0.6, b = 0.1},                -- 12000 Honored - Green
	[7] = {r = 0, g = 0, b = 1.0},                  -- 21000 Revered - Blue
	[8] = {r = 0.5803922, g = 0, b = 0.827451},     -- 1000 Exalted - Purple
}

-- WOW's constants
-- http://www.wowwiki.com/BagId
NUM_BAG_SLOTS=4

-- WOW's frames
Frame = {
		["Events"] = {},
		["Hide"] = function() end,
		["RegisterEvent"] = function(event) Frame.Events.event = true; end,
		["SetPoint"] = function() end,
		["UnregisterEvent"] = function(event) Frame.Events.event = nil; end,
		["GetName"] = function(self) return self.name end,
}
function CreateFrame( frameType, frameName, parentFrame, inheritFrame )
	--http://www.wowwiki.com/API_CreateFrame
	return Frame
end

function CreateFontString(name,...)
	--print("Creating new FontString: "..name)
	FontString = {}
	for k,v in pairs(Frame) do
		FontString[k] = v
	end
	FontString["SetText"] = function(text) end
	FontString.name=name
	return FontString
end

function CreateStatusBar(name,...)
	StatusBar = {}
	for k,v in pairs(Frame) do
		StatusBar[k] = v
	end
	StatusBar.name=name

	return StatusBar
end

Slider = {
		["GetName"] = function() return ""; end,
		["SetText"] = function(text) end,
}
function CreateSlider( name, ... )
	Slider = {}
	for k,v in pairs(Frame) do
		Slider[k] = v
	end
	Slider.name=name
	Slider[name.."Text"] = CreateFontString(name.."Text")
	Slider["GetName"] = function(self) return self.name; end
	Slider["SetText"] = function(text) end
	return Slider
end

function ChatFrame_AddMessageEventFilter()
end

-- WOW's resources
DEFAULT_CHAT_FRAME={ ["AddMessage"] = print, }
UIErrorsFrame={ ["AddMessage"] = print, }

-- stub some external API functions (try to keep alphabetical)
function CombatTextSetActiveUnit( who )
end
function BuyMerchantItem( index, quantity )
	-- adds quantity of index to myInventory
	-- no return value
	local itemID = INEED.getItemIdFromLink( GetMerchantItemLink( index ) )
	if myInventory[itemID] then
		myInventory[itemID] = myInventory[itemID] + quantity
	else
		myInventory[itemID] = quantity
	end
	INEED.UNIT_INVENTORY_CHANGED()

	-- meh
end
function GetAccountExpansionLevel()
	-- http://www.wowwiki.com/API_GetAccountExpansionLevel
	-- returns 0 to 4 (5)
	return accountExpansionLevel
end
function GetAddOnMetadata(addon, field)
	local addonData = { ["version"] = "1.0",
	}
	return addonData[field]
end
function GetCoinTextureString( copperIn, fontHeight )
-- simulates the Wow function:  http://www.wowwiki.com/API_GetCoinTextureString
-- fontHeight is ignored for now.
	if copperIn then
		-- cannot return exactly what WoW does, but can make a simular string
		local gold = math.floor(copperIn / 10000); copperIn = copperIn - (gold * 10000)
		local silver = math.floor(copperIn / 100); copperIn = copperIn - (silver * 100)
		local copper = copperIn
		return( (gold and gold.."G")..
				(silver and ((gold and " " or "")..silver.."S"))..
				(copper and ((silver and " " or "")..copper.."C")) )
	end
end
function GetContainerNumFreeSlots( bagId )
	-- http://www.wowwiki.com/API_GetContainerNumFreeSlots
	-- http://www.wowwiki.com/BagType
	-- returns numberOfFreeSlots, BagType
	-- BagType should be 0
	bagInfo = {
		[0] = {16, 0},
	}
	if bagInfo[bagId] then
		return unpack(bagInfo[bagId])
	else
		return 0, 0
	end
end
function GetItemCount( itemID, includeBank )
	-- print( itemID, myInventory[itemID] )
	return myInventory[itemID] or 0
end
function GetItemInfo( itemID )
	-- returns name, itemLink
	local itemData = {
			["7073"] = { "Broken Fang", "|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0|h[Broken Fang]|h|r" },
			["6742"] = { "UnBroken Fang", "|cff9d9d9d|Hitem:6742:0:0:0:0:0:0:0:80:0:0|h[UnBroken Fang]|h|r" },
	}
	if itemData[itemID] then return unpack( itemData[itemID] ) end
end
function GetMerchantNumItems()
	return 2
end
function GetMerchantItemLink( index )
	-- returns a link for item at index
	local merchantItems = { "|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0|h[Broken Fang]|h|r",
		"|cff9d9d9d|Hitem:6742:0:0:0:0:0:0:0:80:0:0|h[UnBroken Fang]|h|r",
	}
	return merchantItems[index]
end
function GetMerchantItemInfo( index )
	--local itemName, _, price, quantity = GetMerchantItemInfo( i )
	local merchantItemInfo = { { "Broken Fang", "", 5000, 1 },  -- 50 silver
			{ "UnBroken Fang", "", 10000, 1 },            -- 1 gold
	}
	return unpack( merchantItemInfo[index] )
end
function GetNumRoutes( nodeId )
	-- http://wowprogramming.com/docs/api/GetNumRoutes
	-- returns numHops
	return TaxiNodes[nodeId].hops
end
function GetRealmName()
	return "testRealm"
end
function NumTaxiNodes()
	-- http://www.wowwiki.com/API_NumTaxiNodes
	local count = 0
	for _ in pairs(TaxiNodes) do
		count = count + 1
	end
	return count
end
function PlaySoundFile( file )
end
function TaxiNodeCost( nodeId )
	-- http://www.wowwiki.com/API_TaxiNodeCost
	return TaxiNodes[nodeId].cost
end
function TaxiNodeName( nodeId )
	-- http://www.wowwiki.com/API_TaxiNodeName
	return TaxiNodes[nodeId].name
end
function TaxiNodeGetType( nodeId )
	-- http://www.wowwiki.com/API_TaxiNodeGetType
	return TaxiNodes[nodeId].type
end
function UnitClass( who )
	local unitClasses = {
		["player"] = "Warlock",
	}
	return unitClasses[who]
end
function UnitFactionGroup( who )
	-- http://www.wowwiki.com/API_UnitFactionGroup
	local unitFactions = {
		["player"] = {"Alliance", "Alliance"}
	}
	return unpack( unitFactions[who] )
end
function UnitName( who )
	local unitNames = {
		["player"] = "testPlayer",
	}
	return unitNames[who]
end
function UnitRace( who )
	local unitRaces = {
		["player"] = "Human",
	}
	return unitRaces[who]
end
function UnitSex( who )
	-- 1 = unknown, 2 = Male, 3 = Female
	local unitSex = {
		["player"] = 3,
	}
	return unitSex[who]
end


