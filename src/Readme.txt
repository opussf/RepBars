RepBars

This is another addon to be ripped from XH.

Idea:
To present tracker bars for gained reputation, and to try to predict obtaining reputation goal.

Problem to solve:
Blizzard's default rep gain UI only shows current state, and it only lets you track a single rep at a time.
Changing the rep bar to the most recent faction does not work well while gaining rep with many reputations during a single fight, or session, or day.

Goals:
Show the rep gained for the last n factions, with smaller rep bars that auto-clear themselves.
Keep track of, and use to predict a goal, the rep gain over:
* Last 30 minutes
* Session
* Day
* Week
* Month
* 6 Months
* Life of addon

Options:
Display default rep bar / change to last rep gained
Grow up / down
Number of bars
Display Time
Place / background
Show:
[] rate graph
[] text
[]

Bar size (x and y)
-- if y is too small, enable option for mouseover zoom or tooltip

Found links:
http://www.wowinterface.com/forums/showthread.php?t=40444

Lesson Learned:
Create your own Init function for the options panel, and call that once the values are loaded.
Relying on the OnLoad or OnShow is unreliable because they happen before the values are loaded.


Versions:
0.04    Refactor the options panel logic.  See Lesson Learned ^^^^
0.03    Adding cooldown bars
0.02    Working on Options pane
0.01b   Initial Version and working

