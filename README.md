[![Build Status](https://travis-ci.org/opussf/RepBars.svg?branch=master)](https://travis-ci.org/opussf/RepBars)

# Reputation Bars

This addon shows progress bars for the laste few faction gains for a period of time.

## Idea:
Faction gain reports tend to go by rather quick.
Possibly the first time you know that you gained reputation with a faction is when you change rank.

This addon shows the last few factions that you have changed reputation with.

## Problem to solve:
I wanted to see the last few factions.
A previous addon of mine was showing the last faction with change, and it got confused when there were 2 or more at a time.

This addon can be configured to show any number of bars for factions with history up to the last 3 months.
The options panel will scale the number of bars as large as you want.

It also tries to calculate the number of reps needed, and how long that will take.

## Goals:
* Better dispaly of information, with more history.
* Show how long or how many gains will be needed until the next level.

## How to use:
Install the addon.

Open the configuration panel with ```/fb```.
Choose the options that you wish to see.

Gain reputation with factions.

The bars update every 5 seconds.

## The Display Explained
With all the options turned on, your display will look like:

```
<Name> (<Rank> <Rank%>): <lastGain> (<totalGain in time>) -> <repNeeded> (<ageOfLastGain>) in <expectedTimeFrame> <#ofReps> reps
```

## TODOs
- [ ] #1 Allow moving frame, with locking and unlocking
- [ ] #2 Option to hide in combat (to free up the screen)
- [ ] #3 Configuration option for width
- [ ] Option to auto scale time frame to show last known faction change


