/// 1 tile up
#define UI_HUMANITY_DISPLAY "WEST:6,CENTER+1:0"
/// 1 tile down
#define UI_BLOOD_DISPLAY "WEST:6,CENTER-1:0"
/// 2 tiles down
#define UI_VAMPRANK_DISPLAY "WEST:6,CENTER-2:-5"
/// 6 pixels to the right, zero tiles & 5 pixels DOWN.
#define UI_SUNLIGHT_DISPLAY "WEST:6,CENTER-0:0"

///Maptext define for Vampire HUDs
#define FORMAT_VAMPIRE_HUD_TEXT(valuecolor, value) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[round(value,1)]</font></div>")
///Maptext define for Vampire Sunlight HUDs
#define FORMAT_VAMPIRE_SUNLIGHT_TEXT(valuecolor, value) MAPTEXT("<div align='center' valign='bottom' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[value]</font></div>")

/atom/movable/screen/vampire
	icon = 'icons/vampires/actions_vampire.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/vampire/blood_counter
	name = "Vitae"
	icon_state = "blood_display"
	screen_loc = UI_BLOOD_DISPLAY

/atom/movable/screen/vampire/blood_counter/Click()
	. = ..()
	var/list/msg = list()
	var/mob/living/owner_mob = hud.mymob
	var/datum/antagonist/vampire/owner_vamp = IS_VAMPIRE(owner_mob)

	if(!owner_vamp)
		return

	msg += span_cultlarge("This is your Vitae-Counter.")
	msg += span_cult("Here you see your current level of blood-energy. This is used for all of your abilities, and sustains your very being.")
	msg += span_cult("\n<b>You need to drink a certain amount from living, sentient beings in order to level up.</b>")
	msg += span_cult("Your healing also depends on it. You reach your maximum healing potential at [BS_BLOOD_VOLUME_MAX_REGEN].")

	var/bloodlevel
	switch(owner_vamp.current_vitae)
		if(0 to 200)
			bloodlevel = "starved"
		if(201 to 500)
			bloodlevel = "thirsty"
		if(501 to 700)
			bloodlevel = "peckish"
		if(701 to INFINITY)
			bloodlevel = "content"

	msg += span_cult("Your current maximum is: [owner_vamp.max_vitae].")
	msg += span_cult("This shift, you have drank [owner_vamp.total_blood_drank] units of blood.")

	msg += span_cultlarge("\n<b>Right now, you are feeling <i>[bloodlevel].</i></b>")

	if(owner_vamp.vitae_goal_progress <= owner_vamp.current_vitae_goal)
		msg += span_cultlarge("\n<b>Your progress to the next level is: <i>[owner_vamp.vitae_goal_progress]/[owner_vamp.current_vitae_goal].</i></b>")
	else
		msg += span_cultlarge("\n<b>You have drank deeply and greedily. Upon next sol, you will level up.</b>")

	to_chat(usr, examine_block(msg.Join("\n")))

/atom/movable/screen/vampire/rank_counter
	name = "Vampire Rank"
	icon_state = "rank"
	screen_loc = UI_VAMPRANK_DISPLAY

/atom/movable/screen/vampire/rank_counter/Click()
	. = ..()
	var/list/msg = list()
	var/mob/living/owner_mob = hud.mymob
	var/datum/antagonist/vampire/owner_vamp = IS_VAMPIRE(owner_mob)

	if(!owner_vamp)
		return

	var/mob/living/carbon/human/vampire_human = owner_mob
	msg += span_cultlarge("This is your Rank-Counter.")
	msg += span_cult("Here you see your current progress in the mastery of your disciplines.")
	msg += span_cult("This is a measure of your main progress as a vampire, and, should you feed on another vampire(that has broken the masquerade), you will absorb half of their levels.")
	msg += span_cult("<b>With your current rank, you are considered as [owner_vamp.get_rank_string()] of your craft.</b>")
	msg += span_cult("\n<b>Currently, your rank affords you the following benefits:</b>")
	msg += span_cult("Max Regeneration rate: +[owner_vamp.vampire_regen_rate]")
	msg += span_cult("Max Vitae pool: +[owner_vamp.max_vitae - 600] ")
	msg += span_cult("Unarmed damage: +[vampire_human.dna.species.punchdamage - 9]")

	var/list/disciplinestext
	for(var/datum/discipline/discipline in owner_vamp.owned_disciplines)
		disciplinestext += "\n[discipline.name] - "
		disciplinestext += "Level:"
		disciplinestext += "[discipline.level - 1]"

	if(disciplinestext)
		msg += span_cult("\n<b>Your disciplines and their levels are:</b>[disciplinestext]")

	to_chat(usr, examine_block(msg.Join("\n")))

/atom/movable/screen/vampire/sunlight_counter
	name = "Solar Flare Timer"
	icon_state = "sunlight"
	screen_loc = UI_SUNLIGHT_DISPLAY

/atom/movable/screen/vampire/sunlight_counter/Click()
	. = ..()
	var/list/msg = list()
	var/mob/living/owner_mob = hud.mymob
	var/datum/antagonist/vampire/owner_vamp = IS_VAMPIRE(owner_mob)

	if(!owner_vamp)
		return

	msg += span_cultlarge("This is the 'Sol' indicator.")
	msg += span_cult("Here you see the current state of Sol, the frequent solar flares given off by the nearby star.")
	msg += span_cult("While traditionally, vampires have thrived on space installations, Auri-Geminae's erratic solar behavior risks final death even in a shielded vessel.")

	var/normal_humanity_divisor = min(2, 1 + (owner_vamp.humanity / 10))
	var/divisor_turned_percentage = ((normal_humanity_divisor - 1) * 200) / 4
	msg += span_cult("\n<b>Your current humanity affords you a [divisor_turned_percentage]% resistance to the ravages of Sol.</b>")

	msg += span_cult("\n<b>When Sol hits, do not be found in the hallways. You will burn, and draw attention. A locker or maintenance can shield you.</b>")

	msg += span_cult("\nThe best measure of protection is of course afforded only by the terrible deathless sleep, 'Torpor.'")

	to_chat(usr, examine_block(msg.Join("\n")))

/atom/movable/screen/vampire/humanity_counter
	name = "Humanity"
	icon_state = "humanity"
	screen_loc = UI_HUMANITY_DISPLAY

/atom/movable/screen/vampire/humanity_counter/Click()
	. = ..()
	var/list/msg = list()
	var/mob/living/owner_mob = hud.mymob
	var/datum/antagonist/vampire/owner_vamp = IS_VAMPIRE(owner_mob)

	msg += span_cultlarge("This is your Humanity score.")
	msg += span_cult("Humanity is a measure of how closely a vampire clings to the morality and values of mortal life, and consequently how well they are able to resist the urges of the Beast.")
	msg += span_cult("This has an active effect on the curse of all cainites. Vampires with little humanity may find it harder to stay awake during the day, or to awaken from long periods of torpor. If your humanity is particularly low, you may even burst into flames in the presence of god's light.")

	var/humanitylevel
	switch(owner_vamp.humanity)
		if(0)
			humanitylevel = "Monstrous"
		if(1)
			humanitylevel = "Horrific"
		if(2)
			humanitylevel = "Bestial"
		if(3)
			humanitylevel = "Cold"
		if(4)
			humanitylevel = "Unfeeling"
		if(5)
			humanitylevel = "Removed"
		if(6)
			humanitylevel = "Distant"
		if(7)
			humanitylevel = "Normal"
		if(8)
			humanitylevel = "Caring"
		if(9)
			humanitylevel = "Compassionate"
		if(10)
			humanitylevel = "Saintly"

	// Pardon me for my math, i was never good at this.

	var/normal_humanity_divisor = min(2, 1 + (owner_vamp.humanity / 10))
	var/divisor_turned_percentage = ((normal_humanity_divisor - 1) * 200) / 4

	msg += span_cult("\n<b>Right now, others would describe you as <i>'[humanitylevel]',</i> giving you a [divisor_turned_percentage]% resistance to the ravages of Sol.</b>")
	if(owner_vamp.humanity > 7)
		msg += span_cult("Due to your connection to your own human soul, you have achieved the masquerade ability.")

	msg += span_cult("\n<b>You may gain humanity by engaging in human activities, such as:</b>")
	msg += span_cult("Hugging different mortals: [length(owner_vamp.humanity_trackgain_hugged)] of [owner_vamp.humanity_hugging_goal].")
	msg += span_cult("Petting various animals: [length(owner_vamp.humanity_trackgain_petted)] of [owner_vamp.humanity_petting_goal].")
	msg += span_cult("Looking at art: [length(owner_vamp.humanity_trackgain_art)] of [owner_vamp.humanity_art_goal].")

	to_chat(usr, examine_block(msg.Join("\n")))

/// Update Blood Counter + Rank Counter
/datum/antagonist/vampire/proc/update_hud()
	var/valuecolor
	switch(current_vitae)
		if(0 to 200)
			valuecolor = "#560808"
		if(201 to 300)
			valuecolor = "#a32a2a"
		if(301 to 500)
			valuecolor = "#d55c5c"
		if(501 to 700)	// This isn't janky, a tiny bit lenience is baked in.
			valuecolor = "#ffc2c2"
		if(701 to INFINITY)
			valuecolor = "#ffffff"

	blood_display?.maptext = FORMAT_VAMPIRE_HUD_TEXT(valuecolor, current_vitae)

	if(vamprank_display)
		if(vampire_level_unspent > 0)
			vamprank_display.icon_state = "[initial(vamprank_display.icon_state)]_up"
		else
			vamprank_display.icon_state = initial(vamprank_display.icon_state)
		vamprank_display.maptext = FORMAT_VAMPIRE_HUD_TEXT("#ffd8d8", vampire_level)

	if(humanity_display)
		var/humanityvaluecolor
		switch(humanity)
			if(0 to 2)
				humanityvaluecolor = "#600000"
			if(3 to 4)
				humanityvaluecolor = "#a71c1c"
			if(4 to 5)
				humanityvaluecolor = "#db4646"
			if(6 to 8)	// same here
				humanityvaluecolor = "#e8adad"
			if(9 to 10)
				humanityvaluecolor = "#ffffff"

		humanity_display.maptext = FORMAT_VAMPIRE_HUD_TEXT(humanityvaluecolor, humanity)

	if(sunlight_display)
		var/sunlightvaluecolor = "#ffffff"
		if(SSsunlight.sunlight_active)
			sunlightvaluecolor = "#FF5555"
			sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_day"
		else
			switch(round(SSsunlight.time_til_cycle, 1))
				if(0 to 30)
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_30"
					sunlightvaluecolor = "#FFCCCC"
				if(31 to 60)
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_60"
					sunlightvaluecolor = "#FFE6CC"
				if(61 to 90)
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_90"
					sunlightvaluecolor = "#FFFFCC"
				else
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_night"
					sunlightvaluecolor = "#FFFFFF"

		sunlight_display.maptext = FORMAT_VAMPIRE_SUNLIGHT_TEXT( \
			sunlightvaluecolor, \
			(SSsunlight.time_til_cycle >= 60) ? "[round(SSsunlight.time_til_cycle / 60, 1)] m" : "[round(SSsunlight.time_til_cycle, 1)] s" \
		)

/// 1 tile up
#undef UI_HUMANITY_DISPLAY
/// 1 tile down
#undef UI_BLOOD_DISPLAY
/// 2 tiles down
#undef UI_VAMPRANK_DISPLAY
/// 6 pixels to the right, zero tiles & 5 pixels DOWN.
#undef UI_SUNLIGHT_DISPLAY

///Maptext define for Vampire HUDs
#undef FORMAT_VAMPIRE_HUD_TEXT
///Maptext define for Vampire Sunlight HUDs
#undef FORMAT_VAMPIRE_SUNLIGHT_TEXT
