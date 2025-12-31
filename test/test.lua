#!/usr/bin/env lua

require "wowTest"

test.outFileName = "testOut.xml"
test.coberturaFileName = "../coverage.xml"
test.coverageReportPercent = true

-- require the file to test
ParseTOC( "../src/FactionBars.toc" )

function test.before()
	FB_repSaved = {}
	FB_factionmap = {}
	FB_barData = {}
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
	FB.FactionGainEvent( FB_Frame, "repEvent", "Reputation with Darkmoon Faire increased by 92." )
	assertTrue( FB_repSaved["Darkmoon Faire"] )
end
function test.test_FactionGainEvent_Increase_Normal_Value_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Reputation with Darkmoon Faire increased by 50." )
	now = time()
	testValue = FB_repSaved["Darkmoon Faire"][now] or FB_repSaved["Darkmoon Faire"][now-1]
	assertEquals( 50, testValue )
end
function test.test_FactionGainEvent_Decrease_Normal_Faction_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Reputation with Darkmoon Faire decreased by 25." )
	assertTrue( FB_repSaved["Darkmoon Faire"] )
end
function test.test_FactionGainEvent_Decrease_Normal_Value_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Reputation with Darkmoon Faire decreased by 69." )
	now = time()
	testValue = FB_repSaved["Darkmoon Faire"][now] or FB_repSaved["Darkmoon Faire"][now-1]
	assertEquals( -69, testValue )
end
function test.test_FactionGainEvent_Increase_AccountWide_Faction_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Your Warband's reputation with Find my Name increased by 16." )
	assertTrue( FB_repSaved["Find my Name"] )
end
function test.test_FactionGainEvent_Increase_AccountWide_Value_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Your Warband's reputation with Find my Name increased by 5." )
	now = time()
	testValue = FB_repSaved["Find my Name"][now] or FB_repSaved["Find my Name"][now-1]
	assertEquals( 5, testValue )
end
function test.test_FactionGainEvent_Decrease_AccountWide_Faction_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Your Warband's reputation with Find my Name decreased by 11." )
	assertTrue( FB_repSaved["Find my Name"] )
end
function test.test_FactionGainEvent_Decrease_AccountWide_Value_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Your Warband's reputation with Find my Name decreased by 7." )
	now = time()
	testValue = FB_repSaved["Find my Name"][now] or FB_repSaved["Find my Name"][now-1]
	assertEquals( -7, testValue )
end
function test.notest_FactionGainEvent_Increase_Guild_Faction_Captured()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Reputation with Guild decreased by 14." )
	assertTrue( FB_repSaved["Test Guild"] )
end
function test.test_FactionGainEvent_Increase_Normal_Value_Captured_multipleValues()
	FB.FactionGainEvent( FB_Frame, "repEvent", "Reputation with Stormwind increased by 101." )
	FB.FactionGainEvent( FB_Frame, "repEvent", "Reputation with Stormwind increased by 202." )
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
	FB_options.formatString = "(%s):"
	FB.Command( "rep" )
	assertEquals( 2, #chatLog )
	assertEquals( "Faction Bars> Alliance (Honored):", chatLog[2].msg )
end
function test.test_Command_ShowRep_zeros_old_data()
	FB_repSaved = { ["Stormwind"] = {[100.0] = 15, [200] = 15, [300] = 15 } }
	FB.Command( "rep" )
	assertEquals( 45, FB_repSaved["Stormwind"][0] )
end
function test.test_formatStr_isNil()
	FB_repSaved = { ["Alliance"] = {[time()] = 15, [time()-15] = 15 } }
	FB_options.formatString = nil
	FB.Command( "rep" )
	assertEquals( "Faction Bars> Alliance", chatLog[2].msg )
end
function test.test_formatStr_standing()
	FB_repSaved = { ["Alliance"] = {[time()] = 15, [time()-15] = 15 } }
	FB_options.formatString = "%s"
	FB.Command( "rep" )
	assertEquals( "Faction Bars> Alliance Honored", chatLog[2].msg )
end
function test.test_formatStr_percent()
	FB_repSaved = { ["Alliance"] = {[time()] = 15, [time()-15] = 15 } }
	FB_options.formatString = "%p"
	FB.Command( "rep" )
	assertEquals( "Faction Bars> Alliance 11.58%", chatLog[2].msg )
end
function test.test_formatStr_lastGain()
	FB_repSaved = { ["Alliance"] = {[time()] = 15, [time()-15] = 15 } }
	FB_options.formatString = "%l"
	FB.Command( "rep" )
	assertEquals( "Faction Bars> Alliance 15", chatLog[2].msg )
end
function test.test_formatStr_rangeGain()
	FB_repSaved = { ["Alliance"] = {[time()] = 15, [time()-15] = 15 } }
	FB_options.formatString = "%t"
	FB.Command( "rep" )
	assertEquals( "Faction Bars> Alliance 30", chatLog[2].msg )
end
function test.test_formatStr_repTilNext()
	FB_repSaved = { ["Alliance"] = {[time()] = 15, [time()-15] = 15 } }
	FB_options.formatString = "%n"
	FB.Command( "rep" )
	assertEquals( "Faction Bars> Alliance 10610", chatLog[2].msg )
end
function test.test_formatStr_repAge()
	FB_repSaved = { ["Alliance"] = {[time()-5] = 15, [time()-15] = 15 } }
	FB_options.formatString = "%a"
	FB.Command( "rep" )
	assertEquals( "Faction Bars> Alliance 5 Sec", chatLog[2].msg )
end
function test.test_formatStr_repTimeTilReaction()
	FB_repSaved = { ["Alliance"] = {[time()] = 15, [time()-15] = 15 } }
	FB_options.formatString = "%g"
	FB.Command( "rep" )
	assertEquals( "Faction Bars> Alliance 7 Day 8 Hr", chatLog[2].msg )
end
function test.test_formatStr_repCountTilReaction()
	FB_repSaved = { ["Alliance"] = {[time()] = 15, [time()-15] = 15 } }
	FB_options.formatString = "%c"
	FB.Command( "rep" )
	assertEquals( "Faction Bars> Alliance 708 reps", chatLog[2].msg )
end
function test.test_formatStr_max()
	FB_repSaved = nil
	FB_repSaved = { ["Max"] = {[time()-130] = 15, [time()-120] = 15 } }
	FB_options.formatString = "(%s %p): %l (%t) -> %n (%a) %c"
	FB.Command( "rep" )
	assertEquals( "Faction Bars> Max (Exalted ): 15 (30) -> 0 (2 Min) 0 reps", chatLog[2].msg )
end

function test.test_formatStr_combined()
	FB_repSaved = { ["Alliance"] = {[time()-130] = 15, [time()-120] = 15 } }
	FB_options.formatString = "(%s %p): %l (%t) -> %n (%a) in %g %c"
	FB.Command( "rep" )
	assertEquals( "Faction Bars> Alliance (Honored 11.58%): 15 (30) -> 10610 (2 Min) in 7 Day 8 Hr 708 reps", chatLog[2].msg )
end
function test.test_formatStr_mine()
	FB_repSaved = { ["Alliance"] = {[time()-130] = 15, [time()-120] = 15 } }
	FB_options.formatString = "(%s %p): %l (%t) -> %n (%a) %c"
	FB.Command( "rep" )
	assertEquals( "Faction Bars> Alliance (Honored 11.58%): 15 (30) -> 10610 (2 Min) 708 reps", chatLog[2].msg )
end


test.run()