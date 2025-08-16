/datum/pain_source

/// Update the damage overlay, pain level between:
/// 0: no pain
/// 100: max pain
/datum/pain_source/proc/update_damage_overlay(pain_level)
	if(pain_level)
		var/severity = 0
		switch(pain_level)
			if(5 to 15)
				severity = 1
			if(15 to 30)
				severity = 2
			if(30 to 45)
				severity = 3
			if(45 to 70)
				severity = 4
			if(70 to 85)
				severity = 5
			if(85 to INFINITY)
				severity = 6
		overlay_fullscreen("pain", /atom/movable/screen/fullscreen/brute, severity)
	else
		clear_fullscreen("pain")
