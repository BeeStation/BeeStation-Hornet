/*
//////////////////////////////////////
Blight
	Visible
	High resistance
	Decreases stage speed.
	Transmitable

Bonus
	Kills botnis

//////////////////////////////////////
*/

/datum/symptom/blight

	name = "Blight"
	desc = "The virus spreads a chemical agent through the air that kills plant life."
	stealth = -2
	resistance = 4
	stage_speed = -1
	transmittable = 1
	level = 0
	severity = 2
	base_message_chance = 100
	symptom_delay_min = 30
	symptom_delay_max = 90
	var/range = FALSE
	var/high_power = 1
	threshold_desc = "<b>Resistance 9:</b> Doubles the radius of the effect.<br>\
					  <b>Stage Speed 7:</b> Decimates nearby plant life.<br>\
            
/datum/symptom/blight/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 7)
		high_power = TRUE
    power = 2
	if(A.properties["transmittable"] >= 8)
		range = TRUE

/datum/symptom/blight/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(3)
			if(prob(base_message_chance))
				to_chat(M, "<span class='warning'>[pick("You smell chemicals", "Your skin itches")]</span>")
		if(4)
			Alkali_fire_stage_4(M, A)
			M.IgniteMob()
			to_chat(M, "<span class='userdanger'>Your sweat bursts into flames!</span>")
			M.emote("scream")
		if(5)
			Alkali_fire_stage_5(M, A)
			M.IgniteMob()
			to_chat(M, "<span class='userdanger'>Your skin erupts into an inferno!</span>")
			M.emote("scream")
			if(M.fire_stacks < 0)
				M.visible_message("<span class='warning'>[M]'s sweat sizzles and pops on contact with water!</span>")
				explosion(get_turf(M),0,0,2 * explosion_power)
				Alkali_fire_stage_5(M, A)

/obj/effect/proc_holder/spell/aoe_turf/revenant/blight/proc/blight(turf/T, mob/user)
	if(high_power)
		for(var/obj/structure/spacevine/vine in T)
			vine.add_atom_colour("#823abb", TEMPORARY_COLOUR_PRIORITY)
			new /obj/effect/temp_visual/revenant(vine.loc)
			QDEL_IN(vine, 10)
		for(var/obj/structure/glowshroom/shroom in T)
			shroom.add_atom_colour("#823abb", TEMPORARY_COLOUR_PRIORITY)
			new /obj/effect/temp_visual/revenant(shroom.loc)
			QDEL_IN(shroom, 10)
	for(var/obj/machinery/hydroponics/tray in T)
		new /obj/effect/temp_visual/revenant(tray.loc)
		tray.pestlevel = rand(8, 10)
		tray.weedlevel = rand(8, 10)
		tray.toxic = rand(45, 55)
