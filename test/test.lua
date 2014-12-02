#!/usr/bin/env lua

addonData = { ["version"] = "1.0",
}

require "wowTest"

test.outFileName = "testOut.xml"

FB_Frame = CreateFrame()
FactionBarsOptionsFrame = CreateFrame()
FactionBarsOptionsFrame_NumBars = CreateSlider("FactionBarsOptionsFrame_NumBars")

-- require the file to test
package.path = "../src/?.lua;'" .. package.path
require "FactionBars"
require "FactionBarsOptions"

function getTableSize( table )
	local count = 0
	for k,v in pairs(table) do
		count = count + 1
	end
	return count
end

function test.before()
	FB.OnLoad()
--	FB.ADDON_LOADED()
end
function test.after()
end
function test.test_Help()
	FB.Command("help")
end
function test.test_Rep()
	FB.Command("rep")
end
function test.test_OnUpdate()
	FB.OnUpdate()
	assertTrue( FB.lastUpdate )
end
function test.test_GenerateBarData_EmptyData()
	FB_repSaved = {}
	FB.barData = {}
	FB.GenerateBarData()
	local count = getTableSize( FB.barData )
	assertEquals( 0, count )
end

test.run()