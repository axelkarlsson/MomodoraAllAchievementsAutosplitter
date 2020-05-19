state("MomodoraRUtM", "v1.05b Steam") 
{
	// For tracking if we leave to the main menu
	short LevelId : 0x230F1A0;
	double Health : 0x2304CE8, 0x4, 0x0;

	// For start
	double DifficultySelector : 0x22C5A7C, 0xCB4, 0xC, 0x4, 0x41B0;

	// Pointer for various flags
	int FlagsPtr : 0x230C440, 0x0, 0x4, 0x60, 0x4, 0x4;
	double InGame : 0x230C440, 0x0, 0x4, 0x780;
	double CutsceneState: 0x230C440, 0x0, 0x4, 0xAB0;

	// Various boss flags not covered by FlagsPtr
	// Note: When updating, *actual health values* for these bosses can be found at these paths, except with a last offset of 0x230
	double Lubella : 0x231138C, 0x8, 0x140, 0x4, 0xCA0;
	//double Frida : 0x231138C, 0x34, 0x13C, 0x4, 0x1210;

	
	//For tracking achievement statuses
	
	double Deaths : 0x02304CE8, 0x4, 0x540;
	double RoomsVisited : 0x02304CE8, 0x4, 0x870;
	double CommonEnemiesKilled : 0x02304CE8, 0x4, 0x60, 0x4, 0x4, 0x490;
	double Difficulty : 0x0230C440, 0x0, 0x4, 0x60, 0x4, 0x4, 0x630;
	double BugsDelivered : 0x230C440, 0x0, 0x4, 0x60, 0x4, 0x4, 0x7C0;
	double ShroomDelivered : 0x02304CE8, 0x4, 0x60, 0x4, 0x4, 0x500;
	double GreenLeaf : 0x230C440, 0x0, 0x4, 0x60, 0x4, 0x4, 0x600;
	double MaxHealth : 0x02304CE8, 0x4, 0xA0;
	double Choir :  0x230C440, 0x0, 0x4, 0x60, 0x4, 0x4, 0x6A0;
	double BugCount : 0x230C440, 0x0, 0x4, 0x60, 0x4, 0x4, 0x3C0;
	double SaveSlot : 0x230C440, 0x0, 0x4, 0x60, 0x4, 0x4, 0xFA0;
	double ShroomFound : 0x230C440, 0x0, 0x4, 0x60, 0x4, 0x4, 0x480;
	
}

startup
{
	// SETTINGS START //
	settings.Add("100%Check", false, "100% Run");
	settings.Add("splits", true, "All Splits");

	settings.Add("edea", true, "Edea", "splits");
	settings.Add("lubella1", true, "Lubella 1", "splits");
	settings.Add("gardenKey", false, "Garden Key", "splits");
	settings.Add("frida", true, "Frida", "splits");
	settings.Add("fastChargeFragment", false, "Fast Charge Fragment", "splits");
	settings.Add("lubella2", true, "Lubella 2", "splits");
	settings.Add("soldier", true, "Soldier", "splits");
	settings.Add("warpFragment", true, "Warp Fragment", "splits");
	settings.Add("arsonist", true, "Arsonist", "splits");
	settings.Add("dashFragment", false, "Dash Fragment", "splits");
	settings.Add("monasteryKey", true, "Monastery Key", "splits");
	settings.Add("fennel", true, "Fennel", "splits");
	settings.Add("superChargeFragment", false, "Super Charge Fragment", "splits");
	settings.Add("sealedWind", false, "Sealed Wind", "splits");
	settings.Add("magnolia", true, "Lupiar and Magnolia", "splits");
	settings.Add("heavyArrows", false, "Heavy Arrows", "splits");
	settings.Add("freshSpringLeaf", true, "Fresh Spring Leaf", "splits");
	settings.Add("cloneAngel", true, "Clone Angel", "splits");
	settings.Add("queen", true, "Queen", "splits");
	settings.Add("choir", false, "Choir", "splits");
	settings.Add("yeet", false, "Yeet", "splits");
	settings.SetToolTip("100%Check", "If checked, will only split for Queen if Choir is defeated, 17 vitality fragments were obtained, and 20 bug ivories were collected.");

	settings.Add("achievements", false, "All Achievements");
	settings.Add("deathless", false, "Deathless","achievements");
	settings.Add("pacifist", false, "Pacifist","achievements");
	settings.Add("trueEnd", false, "True End","achievements");
	settings.Add("explorer", false, "Explorer","achievements");
	settings.Add("shroom", false, "Shroom","achievements");
	settings.Add("insane", false, "Insane","achievements");
	settings.Add("bugs", false, "Bugs","achievements");
	settings.Add("health", false, "Health","achievements");
	settings.Add("choirA", false, "Choir","achievements");
	// SETTINGS END //
	
	vars.CreateTextComponent = (Func<string, dynamic>)((name) =>
	{
		var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
		dynamic textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
        	timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));
        	textComponent.Settings.Text1 = name;
		return textComponent.Settings;
    	});
}

init
{
	// HashSet to hold splits already hit
	// In case of dying after triggering a split, triggering it again can cause a false double split without this
	vars.Splits = new HashSet<string>();

	// Dictionary which holds MemoryWatchers that correspond to each flag
	vars.Flags = new Dictionary<string, MemoryWatcher<double>>();
	
	// Function that'll return if 100% conditions are met
	vars.Is100Run = (Func<bool>)(() =>
	{
		return vars.Flags["choir"].Current == 1 && 
			   vars.Flags["vitalityFragments"].Current == 17 && 
			   vars.Flags["ivoryBugs"].Current == 20;
	});

	vars.yeet = new bool();
	//For All Achievements Tracking
	//foreach
	vars.achievementList = new List<string>();
	vars.achievementList.Add("Deathless");
	vars.achievementList.Add("Pacifist");
	vars.achievementList.Add("Explorer");
	vars.achievementList.Add("Shroom");
	vars.achievementList.Add("Bugs");
	vars.achievementList.Add("Choir");
	vars.achievementList.Add("Health");
	vars.achievementList.Add("Insane");
	vars.achievementList.Add("True End");

	vars.trackedAchievementList = null;

	//For tracking when achievements are completed and later reverted (if you deliver shroom and then die you still have the achievement)
	vars.achievedDict = new Dictionary<string, bool>();
	foreach(string name in vars.achievementList)
	{
		vars.achievedDict.Add(name, false);
	}

	vars.achievementTrackerDict = null;

	vars.activeSlot = 0;

	vars.UpdateAchievementTrackers = (Action<Process>)((proc) =>
	{
		foreach(string name in vars.achievementTrackerDict.Keys)
		{
			if(!vars.achievedDict[name])
			{
				switch (name)
				{
				case "Deathless":
				     //0 good, 1+ bad
				     vars.achievementTrackerDict[name].Text2 = (current.Deaths == 0) ? "Deathless" : "Not Deathless";
				     break;
				case "Pacifist":
		     		     //0 good, 1+ bad
		     		     vars.achievementTrackerDict[name].Text2 = (current.CommonEnemiesKilled == 0) ? "Pacifist" : "Murderer";
		     		     break;
				case "Explorer":
		     		     //454 Done
				     if(current.RoomsVisited == 454){ vars.achievedDict[name] = true;}
		     		     vars.achievementTrackerDict[name].Text2 = (current.RoomsVisited == 454) ? "Explored" : String.Format("{0}/454",current.RoomsVisited);
		     		     break;
				case "Shroom":
		     		     //1 done test
				     if(current.ShroomDelivered == 1){ vars.achievedDict[name] = true;}
		     		     vars.achievementTrackerDict[name].Text2 = (current.ShroomDelivered == 1) ? "Delivered" : ((current.ShroomFound == 1) ? "Not Delivered" : "Not Found");
		     		     break;
				case "Bugs":
				     if(current.BugsDelivered == 1) {vars.achievedDict[name] = true;}
		     		     //1 done in BugsDelivered, BugCount is how many are collected
		     		     vars.achievementTrackerDict[name].Text2 = (current.BugsDelivered == 1) ? "Delivered" : String.Format("{0}/20",current.BugCount);
		     		     break;
				case "Choir":
		     		     //1 done
     				     if(current.Choir == 1){ vars.achievedDict[name] = true;}
		     		     vars.achievementTrackerDict[name].Text2 = (current.Choir == 1) ? "Killed" : "Alive";
		     		     break;
				case "Health":
				     if(current.MaxHealth == 18){ vars.achievedDict[name] = true;}
		     		     //17 is done, tracks maxhealth and insane starts with 1 so max health is 18, -1 means 17 fragments
		     		     vars.achievementTrackerDict[name].Text2 = String.Format("{0}/17",current.MaxHealth - 1);
		     		     break;
				case "Insane":
		     		     vars.achievementTrackerDict[name].Text2 = (current.Difficulty == 4) ? "Insane" : "Not insane";
		     		     break;
				case "True End":
		     		     vars.achievementTrackerDict[name].Text2 = (current.GreenLeaf == 1) ? "True End" : "Normal End";
		     		     break;
				}
			}
		}
	
	});


	vars.UpdateTrackerComponents = (Action<Process>)((proc) =>
	{
		bool tooManyComponents = false;
		if(vars.achievementTrackerDict != null)
		{
			foreach(string key in vars.achievementTrackerDict.Keys)
			{
			if(!vars.trackedAchievementList.Contains(key))
				{
				vars.achievementTrackerDict = new Dictionary<string,dynamic>();
				}
			}
		}
		else
		{
			vars.achievementTrackerDict = new Dictionary<string,dynamic>();
		}
		
		bool ComponentFound = false;
		List<dynamic> removeableComponents = new List<dynamic>();
		foreach (string name in vars.trackedAchievementList)
		{
			ComponentFound = false;   
			foreach (dynamic component in timer.Layout.Components)
			{
				if (component.GetType().Name != "TextComponent") continue;
				if (!vars.trackedAchievementList.Contains(component.Settings.Text1) && vars.achievementList.Contains(component.Settings.Text1)) removeableComponents.Add(component);
				if (component.Settings.Text1 == name)
				{
					vars.achievementTrackerDict[name] = component.Settings;
					ComponentFound = true;
				}
		        }    
			if(!ComponentFound)
			{
			       vars.achievementTrackerDict[name] = vars.CreateTextComponent(name);
			}
		}
		foreach (dynamic component in removeableComponents)
		{
			//print("trying to remove a component");
			//timer.Layout.LayoutComponents.Remove(component);
		}

	});


	vars.UpdateTrackerList = (Func<List<string>>) (() =>
	{
		var list = new List<string>();
		if(settings["deathless"]) list.Add("Deathless");
		if(settings["pacifist"]) list.Add("Pacifist");
		if(settings["trueEnd"]) list.Add("True End");
		if(settings["explorer"]) list.Add("Explorer");
		if(settings["shroom"]) list.Add("Shroom");
		if(settings["insane"]) list.Add("Insane");
		if(settings["bugs"]) list.Add("Bugs");
		if(settings["health"]) list.Add("Health");
		if(settings["choirA"]) list.Add("Choir");
		return list;
	});
}

update
{	
	// Clear any hit splits if timer stops
	if (timer.CurrentPhase == TimerPhase.NotRunning)
	{
		vars.Splits.Clear();
		vars.trackedAchievementList = vars.UpdateTrackerList();
		vars.UpdateTrackerComponents(game);
		vars.yeet = false;
		if(current.InGame == 1)
		{
			vars.UpdateAchievementTrackers(game);
		}
	}

	// Initialize flags when the flags pointer gets initialized/changes, or we load up LiveSplit while in-game
	if (old.FlagsPtr != current.FlagsPtr || current.FlagsPtr != 0 && vars.Flags.Count == 0)
	{
		// Last offsets of FlagsPtr to read
		Dictionary<string, int> flagOffsets = new Dictionary<string, int>
		{
			{"edea",                0xE0},
			{"gardenKey",           0x700},
			{"fastChargeFragment",  0x5B0},
			{"soldier",             0x4D0},
			{"warpFragment",        0x5C0},
			{"arsonist",            0x9E0},
			{"dashFragment",        0x5D0},
			{"monasteryKey",        0x260},
			{"fennel",              0x3D0},
			{"superChargeFragment", 0x5A0},
			{"sealedWind",          0xA90},
			{"magnolia",            0x660},
			{"heavyArrows",         0x670},
			{"freshSpringLeaf",     0x600},
			{"cloneAngel",          0x640},
			{"choir",               0x6A0},
			{"ivoryBugs",           0x3C0},
			{"vitalityFragments",   0xAE0},
		};

		vars.Flags = flagOffsets.Keys
	  							.ToDictionary(key => key, key => new MemoryWatcher<double>((IntPtr)current.FlagsPtr + flagOffsets[key]));
	}

	// Update all MemoryWatchers in vars.Flags
	new List<MemoryWatcher<double>>(vars.Flags.Values).ForEach((Action<MemoryWatcher<double>>)(mw => mw.Update(game)));

	if(current.InGame == 1 && vars.activeSlot == current.SaveSlot)
	{
		vars.UpdateAchievementTrackers(game);
	}
}

start
{
	if(old.DifficultySelector > 0 && current.DifficultySelector == 0)
	{
		vars.activeSlot = current.SaveSlot;
		foreach(string name in vars.achievementList)
		{
			vars.achievedDict[name] = false;
		}
		return true;
	}
}

reset
{
	return (current.LevelId == 1 && old.LevelId != 1);
}

split
{
	// Only split if we're in-game
	if (current.InGame == 1)
	{
		// Split if a flag has changed
		// Note: Some values count things, like enemies defeated. These will fail silently.
		foreach (string key in vars.Flags.Keys)
		{
			if (vars.Flags[key].Old != vars.Flags[key].Current)
			{
				if (vars.Splits.Contains(key))
				{
					return false;
				}

				vars.Splits.Add(key);
				return settings[key];
			}
		}

		// Lubella 1
		if (current.Lubella > 0 && old.Lubella == 0 && current.LevelId == 73)
		{
			if (vars.Splits.Contains("lubella1"))
			{
				return false;
			}

			vars.Splits.Add("lubella1");
			return settings["lubella1"];
		}

		// Lubella 2
		if (current.LevelId == 153)
		{
			if (vars.Splits.Contains("lubella2"))
			{
				return false;
			}

			vars.Splits.Add("lubella2");
			return settings["lubella2"];
		}
    
		// Frida
		if (current.LevelId == 141 && current.CutsceneState == 0 && old.CutsceneState == 500)
		{
			if (vars.Splits.Contains("frida"))
			{
				return false;
			}

			vars.Splits.Add("frida");
			return settings["frida"];
		}

		// Queen
		if (current.CutsceneState == 1000 && old.CutsceneState != 1000 && current.LevelId == 232)
		{
			if (vars.Splits.Contains("queen"))
			{
				return false;
			}

			// 100% check if applicable
			if (settings["100%Check"] && !vars.Is100Run())
			{
				return false;
			}

			vars.Splits.Add("queen");
			return settings["queen"];
		}
		
		//Catskip
		if(current.LevelId == 255 && old.Health - current.Health == 10)
		{
			vars.yeet = true;
		}
		
		if (current.LevelId == 256 && old.LevelId == 255 && vars.yeet)
		{
			if (vars.Splits.Contains("yeet"))
			{
				return false;
			}
			
			vars.Splits.Add("yeet");
			return settings["yeet"];
		}
	}
}
