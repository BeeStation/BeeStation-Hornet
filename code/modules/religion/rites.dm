/datum/religion_rites
/// name of the religious rite
	var/name = "religious rite"
/// Description of the religious rite
	var/desc = "immm gonna rooon"
/// length it takes to complete the ritual
	var/ritual_length = (10 SECONDS) //total length it'll take
/// list of invocations said (strings) throughout the rite
	var/list/ritual_invocations //strings that are by default said evenly throughout the rite
/// message when you invoke
	var/invoke_msg
	var/favor_cost = 0

/datum/religion_rites/New()
	. = ..()
	if(!GLOB?.religious_sect)
		return
	LAZYADD(GLOB.religious_sect.active_rites, src)

/datum/religion_rites/Destroy()
	if(!GLOB?.religious_sect)
		return
	LAZYREMOVE(GLOB.religious_sect.active_rites, src)
	return ..()


///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, atom/religious_tool)
	if(GLOB.religious_sect?.favor < favor_cost)
		to_chat(user, "<span class='warning'>This rite requires more favor!</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You begin to perform the rite of [name]...</span>")
	if(!LAZYLEN(ritual_invocations))
		if(do_after(user, target = user, delay = ritual_length))
			if(invoke_msg)
				user.say(invoke_msg)
			return TRUE
		return FALSE
	var/first_invoke = TRUE
	for(var/i in ritual_invocations)
		if(first_invoke) //instant invoke
			user.say(i)
			first_invoke = FALSE
			continue
		if(!do_after(user, target = user, delay = ritual_length/ritual_invocations.len))
			return FALSE
		user.say(i)
	if(!do_after(user, target = user, delay = ritual_length/ritual_invocations.len)) //because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg)
	return TRUE


///Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, atom/religious_tool)
	GLOB.religious_sect.on_riteuse(user,religious_tool)
	return TRUE


/*********Technophiles**********/

/datum/religion_rites/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android."
	ritual_length = 1 MINUTES
	ritual_invocations = list("By the inner workings of our god...",
						"... We call upon you, in the face of adversity...",
						"... to complete us, removing that which is undesirable...")
	invoke_msg = "... Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 500

/datum/religion_rites/synthconversion/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
			return FALSE
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [movable_reltool].</span>")
		return FALSE
	return ..()

/datum/religion_rites/synthconversion/invoke_effect(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool?.buckled_mobs?.len)
		return FALSE
	var/mob/living/carbon/human/human2borg = locate() in movable_reltool.buckled_mobs
	if(!human2borg)
		return FALSE
	human2borg.set_species(/datum/species/android)
	human2borg.visible_message("<span class='notice'>[human2borg] has been converted by the rite of [name]!</span>")
	return ..()

/*********Ever-Burning Candle**********/

///apply a bunch of fire immunity effect to clothing
/datum/religion_rites/fireproof/proc/apply_fireproof(obj/item/clothing/fireproofed)
	fireproofed.name = "unmelting [fireproofed.name]"
	fireproofed.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	fireproofed.heat_protection = chosen_clothing.body_parts_covered
	fireproofed.resistance_flags |= FIRE_PROOF

/datum/religion_rites/fireproof
	name = "Unmelting Wax"
	desc = "Grants fire immunity to any piece of clothing."
	ritual_length = 15 SECONDS
	ritual_invocations = list("And so to support the holder of the Ever-Burning candle...",
	"... allow this unworthy apparel to serve you ...",
	"... make it strong enough to burn a thousand times and more ...")
	invoke_msg = "... Come forth in your new form, and join the unmelting wax of the one true flame!"
	favor_cost = 500
///the piece of clothing that will be fireproofed, only one per rite
	var/obj/item/clothing/chosen_clothing

/datum/religion_rites/fireproof/perform_rite(mob/living/user, atom/religious_tool)
	var/turf/T = get_turf(religious_tool)
	var/list/L = T.contents
	if(!locate(/obj/item/clothing) in L)
		to_chat(user, "<span class='warning'>There is no clothing on the altair!</span>")
		return FALSE
	for(var/obj/item/clothing/apparel in L)
		if(apparel.max_heat_protection_temperature >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
			continue //we ignore anything that is already fireproof
		chosen_clothing = apparel //the apparel has been chosen by our lord and savior
		return ..()
	return FALSE

/datum/religion_rites/fireproof/invoke_effect(mob/living/user, atom/religious_tool)
	if(!QDELETED(chosen_clothing) && get_turf(religious_tool) == chosen_clothing.loc) //check if the same clothing is still there
		if(istype(chosen_clothing, /obj/item/clothing/suit/hooded) || istype(chosen_clothing, /obj/item/clothing/suit/space/hardsuit))
			for(var/obj/item/clothing/head/integrated_helmet in chosen_clothing.contents) //check if the clothing has a hood/helmet integrated and fireproof it if there is one.
				apply_fireproof(integrated_helmet)
		apply_fireproof(chosen_clothing)
		playsound(get_turf(religious_tool), 'sound/magic/fireball.ogg', 50, TRUE)
		chosen_clothing = null //our lord and savior no longer cares about this apparel
		return ..()
	chosen_clothing = null
	to_chat(user, "<span class='warning'>The clothing that was chosen for the rite is no longer on the altar!</span>")
	return FALSE


/datum/religion_rites/burning_sacrifice
	name = "Candle Fuel"
	desc = "Sacrifice a buckled burning corpse for favor, the more burn damage the corpse has, the more favor you will receive."
	ritual_length = 20 SECONDS
	ritual_invocations = list("To feed the fire of the one true flame ...",
	"... to make it burn brighter ...",
	"... so that it may consume all in its path ...",
	"... I offer you this pitiful being ...")
	invoke_msg = "... may it join you in the amalgamation of wax and fire, and become one in the black and white scene. "
///the burning corpse chosen for the sacrifice of the rite
	var/mob/living/carbon/chosen_sacrifice

/datum/religion_rites/burning_sacrifice/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, "<span class='warning'>Nothing is buckled to the altar!</span>")
		return FALSE
	for(var/corpse in movable_reltool.buckled_mobs)
		if(!iscarbon(corpse))// only works with carbon corpse since most normal mobs can't be set on fire.
			to_chat(user, "<span class='warning'>Only carbon lifeforms can be properly burned for the sacrifice!</span>")
			return FALSE
		chosen_sacrifice = corpse
		if(chosen_sacrifice.stat != DEAD)
			to_chat(user, "<span class='warning'>You can only sacrifice dead bodies, this one is still alive!</span>")
			chosen_sacrifice = null
			return FALSE
		if(!chosen_sacrifice.on_fire)
			to_chat(user, "<span class='warning'>This corpse needs to be on fire to be sacrificed!</span>")
			chosen_sacrifice = null
			return FALSE
		return ..()

/datum/religion_rites/burning_sacrifice/invoke_effect(mob/living/user, atom/movable/religious_tool)
	if(!(chosen_sacrifice in religious_tool.buckled_mobs)) //checks one last time if the right corpse is still buckled
		to_chat(user, "<span class='warning'>The right sacrifice is no longer on the altar!</span>")
		chosen_sacrifice = null
		return FALSE
	if(!chosen_sacrifice.on_fire)
		to_chat(user, "<span class='warning'>The sacrifice is no longer on fire, it needs to burn until the end of the rite!</span>")
		chosen_sacrifice = null
		return FALSE
	if(chosen_sacrifice.stat != DEAD)
		to_chat(user, "<span class='warning'>The sacrifice has to stay dead for the rite to work!</span>")
		chosen_sacrifice = null
		return FALSE
	var/favor_gained = 100 + round(chosen_sacrifice.getFireLoss())
	GLOB.religious_sect?.adjust_favor(favor_gained, user)
	to_chat(user, "<span class='notice'>[GLOB.deity] absorbs the burning corpse and any trace of fire with it. [GLOB.deity] rewards you with [favor_gained] favor.</span>")
	chosen_sacrifice.dust(force = TRUE)
	playsound(get_turf(religious_tool), 'sound/effects/supermatter.ogg', 50, TRUE)
	chosen_sacrifice = null
	return ..()


/datum/religion_rites/infinite_candle
	name = "Immortal Candles"
	desc = "Creates 5 candles that never run out of wax."
	ritual_length = 10 SECONDS
	invoke_msg = "please lend us five of your candles so we may bask in your burning glory."
	favor_cost = 200

/datum/religion_rites/infinite_candle/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/altar_turf = get_turf(religious_tool)
	for(var/i in 1 to 5)
		new /obj/item/candle/infinite(altar_turf)
	playsound(altar_turf, 'sound/magic/fireball.ogg', 50, TRUE)
	return ..()

/**** Carp rites ****/

/datum/religion_rites/summon_carp
	name = "Summon Carp"
	desc = "Creates a Sentient Space Carp, if a soul is willing to take it."
	ritual_length = 90 SECONDS
	ritual_invocations = list("Grant us a new follower ...",
	"... let them enter our realm ...",
	"... become one with our world ...",
	"... to swim in our space ...",
	"... and help our cause ...")
	invoke_msg = "... We summon thee, Holy Carp!"
	favor_cost = 500

/datum/religion_rites/summon_carp/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	new /obj/effect/temp_visual/bluespace_fissure/long(altar_turf)
	user.visible_message("<span class'notice'>A tear in reality appears above the altar!</span>")
	var/list/jobbans = list(ROLE_BRAINWASHED, ROLE_DEATHSQUAD, ROLE_DRONE, ROLE_LAVALAND, ROLE_MIND_TRANSFER, ROLE_POSIBRAIN, ROLE_SENTIENCE)
	var/list/candidates = pollGhostCandidates("Do you wish to be summoned as a Holy Carp?", jobbans, null, FALSE,)
	if(!length(candidates))
		new /obj/effect/gibspawner/generic(altar_turf)
		user.visible_message("<span class='warning'>The carp pool was not strong enough to bring forth a space carp.")
		GLOB.religious_sect?.adjust_favor(400, user)
		return NOT_ENOUGH_PLAYERS
	var/mob/dead/observer/selected = pick_n_take(candidates)
	var/datum/mind/M = new /datum/mind(selected.key)
	var/carp_species = pick(/mob/living/simple_animal/hostile/carp/megacarp, /mob/living/simple_animal/hostile/carp)
	var/mob/living/simple_animal/hostile/carp = new carp_species(altar_turf)
	carp.name = "Holy Space-Carp ([rand(1,999)])"
	carp.key = selected.key
	carp.sentience_act()
	carp.maxHealth += 100
	carp.health += 100
	M.transfer_to(carp)
	if(GLOB.religion)
		carp.mind?.holy_role = HOLY_ROLE_PRIEST
		to_chat(carp, "There is already an established religion onboard the station. You are an acolyte of [GLOB.deity]. Defer to the Chaplain.")
		GLOB.religious_sect?.on_conversion(carp)
	playsound(altar_turf, 'sound/effects/slosh.ogg', 50, TRUE)
	return ..()

/datum/religion_rites/summon_carpsuit
	name = "Summon Carp-Suit"
	desc = "Summons a Space-Carp Suit"
	ritual_length = 60 SECONDS
	ritual_invocations = list("We shall become one ...",
	"... we shall blend in ...",
	"... we shall join in the ways of the carp ...",
	"... grant us new clothing ...")
	invoke_msg = "So we can swim."
	favor_cost = 300
	var/obj/item/clothing/suit/chosen_clothing

/datum/religion_rites/summon_carpsuit/perform_rite(mob/living/user, atom/religious_tool)
	var/turf/T = get_turf(religious_tool)
	var/list/L = T.contents
	if(!locate(/obj/item/clothing/suit) in L)
		to_chat(user, "<span class='warning'>There is no suit clothing on the altar!</span>")
		return FALSE
	for(var/obj/item/clothing/suit/apparel in L)
		chosen_clothing = apparel //the apparel has been chosen by our lord and savior
		return ..()
	return FALSE

/datum/religion_rites/summon_carpsuit/invoke_effect(mob/living/user, atom/religious_tool)
	if(!QDELETED(chosen_clothing) && get_turf(religious_tool) == chosen_clothing.loc) //check if the same clothing is still there
		user.visible_message("<span class'notice'>The [chosen_clothing] transforms!</span>")
		qdel(chosen_clothing)
		new /obj/item/clothing/suit/space/hardsuit/carp/old(get_turf(religious_tool))
		playsound(get_turf(religious_tool), 'sound/effects/slosh.ogg', 50, TRUE)
		chosen_clothing = null //our lord and savior no longer cares about this apparel
		return ..()
	chosen_clothing = null
	to_chat(user, "<span class='warning'>The clothing that was chosen for the rite is no longer on the altar!</span>")
	return FALSE

/datum/religion_rites/flood_area
	name = "Flood Area"
	desc = "Flood the area with water vapor, great for learning to swim!"
	ritual_length = 40 SECONDS
	ritual_invocations = list("We must swim ...",
	"... but to do so, we need water ...",
	"... grant us a great flood ...",
	"... soak us in your glory ...",
	"... we shall swim forever ...")
	invoke_msg = "... in our own personal ocean."
	favor_cost = 200

/datum/religion_rites/flood_area/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/open/T = get_turf(religious_tool)
	if(istype(T))
		T.atmos_spawn_air("water_vapor=5000;TEMP=255")
	return ..()
