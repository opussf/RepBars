#!/usr/bin/env lua

require "wowTest"

test.outFileName = "testOut.xml"

-- FB_Frame = CreateFrame()
-- FactionBarsOptionsFrame = CreateFrame()
-- FactionBarsOptionsFrame_NumBars = CreateSlider("FactionBarsOptionsFrame_NumBars")

-- require the file to test
ParseTOC( "../src/FactionBars.toc" )

function test.before()
	FB.OnLoad()
end
function test.after()
end
function test.test_()
end

test.run()