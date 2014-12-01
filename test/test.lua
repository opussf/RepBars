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



function test.before()
	FB.OnLoad()
--	FB.ADDON_LOADED()
end
function test.after()
end
function test.test_Help()
	FB.Command("help")
end

test.run()