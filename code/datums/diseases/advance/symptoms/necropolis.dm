/datum/symptom/necroseed
	name = "Necropolis Seed"
	desc = "An infantile form of the root of Lavaland's tendrils. Forms a symbiotic bond with the host, making them stronger and hardier, at the cost of speed. Should the disease be cured, the host will be weakened"
	stealth = 0
	resistance = 3
	stage_speed = -10
	transmittable = -3
	level = 9
	base_message_chance = 5
	severity = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/tendrils = FALSE
	var/chest = FALSE
	var/fireproof = FALSE
	threshold_desc = "<b>Stealth 8:</b> Upon death, the host's soul will solidify into an unholy artifact, rendering them utterly unrevivable in the process.<br>\
					  <b>Resistance 15:</b> The area near the host roils with paralyzing tendrils.<br>\
					  <b>Resistance 20:</b>	Host becomes immune to heat, ash, and lava"
	var/list/cached_tentacle_turfs
	var/turf/last_location
	var/tentacle_recheck_cooldown = 100

/datum/symptom/necroseed/Start(datum/disease/advance/A)
  if(!..())
    return
	if(A.properties["resistance"] >= 15)
		tendrils = TRUE
	if(A.properties["stealth"] >= 8)
		chest = TRUE
	if(A.properties["resistance"] >= 20)
		fireproof = TRUE
    
/datum/symptom/necroseed/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
	if(2)
		if(prob(base_message_chance))
			to_chat(M, "<span class='notice'>Your skin feels scaly</span>")
	if(3, 4)
		if(prob(base_message_chance))
			to_chat(M, "<span class='notice'>[pick("Your skin is hard.", "You feel stronger.", "You feel invincible.")]</span>")
	if(5)
		a.affected_mob.punchdamagelow = 5
		a.affected_mob.punchdamagehigh = 15
		a.affected_mob.punchstunthreshold = 11
        a.affected_mob.brutemod = .6
		a.affected_mob.burnmod = .6
		a.affected_mob.heatmod = .6
		a.affected_mob.speedmod = 1
	if(fireproof)
		ADD_TRAIT(M, TRAIT_RESISTHEAT, DISEASE_TRAIT)
		ADD_TRAIT(M, TRAIT_RESISTHIGHPRESSURE, DISEASE_TRAIT)
		a.affected_mob.weather_immunities |= "ash"
		a.affected_mob.weather_immunities |= "lava"
	if(tendrils)
		tendril
	return
  
/datum/symptom/necroseed/tendril(datum/disease/advance/A)
	. = ..()
	if(isturf(loc))
		if(!LAZYLEN(cached_tentacle_turfs) || loc != last_location || tentacle_recheck_cooldown <= world.time)
			LAZYCLEARLIST(cached_tentacle_turfs)
			last_location = loc
			tentacle_recheck_cooldown = world.time + initial(tentacle_recheck_cooldown)
			for(var/turf/open/T in orange(4, loc))
				LAZYADD(cached_tentacle_turfs, T)
		for(var/t in cached_tentacle_turfs)
			if(isopenturf(t))
				if(prob(10))
					new /obj/effect/temp_visual/goliath_tentacle(t, src)
			else
				cached_tentacle_turfs -= t
				
/datum/symptom/necroseed/on_stage_change(new_stage, datum/disease/advance/A)
	if(!..())
		return FALSE
	var/mob/living/carbon/M = A.affected_mob
	if(A.stage = 5)
		to_chat(M, "<span class='danger'>You feel weak and powerless as the necropolis' blessing leaves your body, leaving you slow and weak.</span>")
    	a.affected_mob.punchdamagelow = 1
    	a.affected_mob.punchdamagehigh = 5
    	a.affected_mob.punchstunthreshold = 10
    	a.affected_mob.brutemod = 1.5
    	a.affected_mob.burnmod = 1.5
    	a.affected_mob.heatmod = 1.5
    	a.affected_mob.speedmod = 2
	if(fireproof)
		REMOVE_TRAIT(A.affected_mob, TRAIT_RESISTHIGHPRESSURE, DISEASE_TRAIT)
		REMOVE_TRAIT(A.affected_mob, TRAIT_RESISTHEAT, DISEASE_TRAIT)
		a.affected_mob.weather_immunities |-= "ash"
		a.affected_mob.weather_immunities |-= "lava"
	return TRUE
  
/datum/symptom/necroseed/End(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage = 5)
		to_chat(M, "<span class='danger'>You feel weak and powerless as the necropolis' blessing leaves your body, leaving you slow and weak.</span>")
		a.affected_mob.punchdamagelow = 1
		a.affected_mob.punchdamagehigh = 5
		a.affected_mob.punchstunthreshold = 10
		a.affected_mob.brutemod = 1.5
		a.affected_mob.burnmod = 1.5
		a.affected_mob.heatmod = 1.5
		a.affected_mob.speedmod = 2
	if(fireproof)
		REMOVE_TRAIT(A.affected_mob, TRAIT_RESISTHIGHPRESSURE, DISEASE_TRAIT)
		REMOVE_TRAIT(A.affected_mob, TRAIT_RESISTHEAT, DISEASE_TRAIT)
    	a.affected_mob.weather_immunities |-= "ash"
    	a.affected_mob.weather_immunities |-= "lava"
		
/datum/symptom/necroseed/OnDeath(datum/disease/advance/A)
	if(!..())
		return
	if(chest)
		var/mob/living/M = A.affected_mob
		to_chat(M, "<span class='danger'>Your soul is ripped from your body!</span>")
		affected_mob.visible_message("<span class='danger'>[affected_mob] explodes into a shower of gore, leaving behind an ominous, fleshy chest.</span>")
		a.affected_mob.hellbound = 1
		affected_mob.gib()
		new /obj/structure/closet/crate/necropolis/tendril(M.loc)
