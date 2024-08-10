#!/usr/bin/env lua

require "wowTest"

test.outFileName = "testOut.xml"
-- test.coberturaFileName = "../coverage.xml"

-- FactionBarsOptionsFrame = CreateFrame()
-- FactionBarsOptionsFrame_NumBars = CreateSlider("FactionBarsOptionsFrame_NumBars")

-- require the file to test
ParseTOC( "../src/FactionBars.toc" )

function test.before()
	FB_repSaved = {}
	chatLog = {}
	FB.OnLoad()
	FB.UpdateOptions()
end
function test.after()
	-- test.dump( FB_repSaved )
	-- test.dump( chatLog )
	-- test.dump( FB )
	-- test.dump( FB_factionmap )
end
function test.test_FactionBar_Registers_Slash_Command()
	assertTrue( SlashCmdList["FB"] )
end
function test.test_FactionBar_sessionStartIsSet()
	assertEquals( time(), FB.sessionStart )
end
function test.test_FactionGainEvent_Increase_Normal_Faction_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Reputation with Darkmoon Faire increased by 92" )
	assertTrue( FB_repSaved["Darkmoon Faire"] )
end
function test.test_FactionGainEvent_Increase_Normal_Value_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Reputation with Darkmoon Faire increased by 50" )
	now = time()
	testValue = FB_repSaved["Darkmoon Faire"][now] or FB_repSaved["Darkmoon Faire"][now-1]
	assertEquals( 50, testValue )
end
function test.test_FactionGainEvent_Decrease_Normal_Faction_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Reputation with Darkmoon Faire decreased by 25" )
	assertTrue( FB_repSaved["Darkmoon Faire"] )
end
function test.test_FactionGainEvent_Decrease_Normal_Value_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Reputation with Darkmoon Faire decreased by 69" )
	now = time()
	testValue = FB_repSaved["Darkmoon Faire"][now] or FB_repSaved["Darkmoon Faire"][now-1]
	assertEquals( -69, testValue )
end
function test.test_FactionGainEvent_Increase_AccountWide_Faction_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Your Warband's reputation with Find my Name increased by 16" )
	assertTrue( FB_repSaved["Find my Name"] )
end
function test.test_FactionGainEvent_Increase_AccountWide_Value_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Your Warband's reputation with Find my Name increased by 5" )
	now = time()
	testValue = FB_repSaved["Find my Name"][now] or FB_repSaved["Find my Name"][now-1]
	assertEquals( 5, testValue )
end
function test.test_FactionGainEvent_Decrease_AccountWide_Faction_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Your Warband's reputation with Find my Name decreased by 11" )
	assertTrue( FB_repSaved["Find my Name"] )
end
function test.test_FactionGainEvent_Decrease_AccountWide_Value_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Your Warband's reputation with Find my Name decreased by 7" )
	now = time()
	testValue = FB_repSaved["Find my Name"][now] or FB_repSaved["Find my Name"][now-1]
	assertEquals( -7, testValue )
end
function test.notest_FactionGainEvent_Increase_Guild_Faction_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Reputation with Guild decreased by 14" )
	assertTrue( FB_repSaved["Test Guild"] )
end
function test.test_FactionGainEvent_Increase_Normal_Value_Captured_multipleValues()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Reputation with Stormwind increased by 101" )
	FB.FactionGainEvent( FB_Frame, "repEvent", "Reputation with Stormwind increased by 202" )
	now = time()
	testValue = FB_repSaved["Stormwind"][now] or FB_repSaved["Stormwind"][now-1]
	assertEquals( 303, testValue )
end
function test.test_Help()
	FB.Command( "help" )
	assertEquals( 5, #chatLog )
end
function test.test_UI_unlock()
	FB.uiUnlocked = false
	FB.Command( "lock" )
	assertTrue( FB.uiUnlocked )
end
function test.test_UI_lock()
	FB.uiUnlocked = true
	FB.Command( "lock" )
	assertFalse( FB.uiUnlocked )
end
function test.test_UI_uireset()
	FB_Frame.points = { { "BOTTOM" } }
	FB.Command( "uireset" )
	assertEquals( "TOP", FB_Frame.points[1][1] )
end
function test.test_Command_ShowRep()
	FB_repSaved = { ["Alliance"] = {[time()] = 15, [time()-15] = 15 } }
	FB.Command( "rep" )
	assertEquals( 2, #chatLog )
	assertEquals( "Faction Bars> Alliance (Honored): ", chatLog[2].msg )
end
function test.test_Command_ShowRep_zeros_old_data()
	FB_repSaved = { ["Stormwind"] = {[100.0] = 15, [200] = 15, [300] = 15 } }
	FB.Command( "rep" )
	assertEquals( 45, FB_repSaved["Stormwind"][0] )
end

test.run()