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
	/// does the altar auto-delete the rite
	var/auto_delete = TRUE

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

/datum/religion_rites/proc/can_afford(mob/living/user)
	if(GLOB.religious_sect?.favor < favor_cost)
		to_chat(user, "<span class='warning'>This rite requires more favor!</span>")
		return FALSE
	return TRUE

///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, atom/religious_tool)
	if(!can_afford(user))
		return FALSE
	to_chat(user, "<span class='notice'>You begin to perform the rite of [name]...</span>")
	if(!ritual_invocations)
		if(do_after(user, target = user, delay = ritual_length))
			return TRUE
		return FALSE
	var/first_invoke = TRUE
	for(var/i in ritual_invocations)
		if(first_invoke) //instant invoke
			user.say(i)
			first_invoke = FALSE
			continue
		if(!length(ritual_invocations)) //we divide so we gotta protect
			return FALSE
		if(!do_after(user, target = user, delay = ritual_length/length(ritual_invocations)))
			return FALSE
		user.say(i)
	if(!do_after(user, target = user, delay = ritual_length/length(ritual_invocations))) //because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg)
	return TRUE


///Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, atom/religious_tool)
	SHOULD_CALL_PARENT(TRUE)
	GLOB.religious_sect.on_riteuse(user,religious_tool)
	return TRUE


/**** Technophile Sect ****/

/datum/religion_rites/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android. Buckle a human to convert them, otherwise it will convert you."
	ritual_length = 30 SECONDS
	ritual_invocations = list("By the inner workings of our god ...",
						"... We call upon you, in the face of adversity ...",
						"... to complete us, removing that which is undesirable ...")
	invoke_msg = "... Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 1000

/datum/religion_rites/synthconversion/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user,"<span class='warning'>You're going to convert the one buckled on [movable_reltool].</span>")
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
			return FALSE
		if(isandroid(user))
			to_chat(user,"<span class='warning'>You've already converted yourself. To convert others, they must be buckled to [movable_reltool].</span>")
			return FALSE
		to_chat(user,"<span class='warning'>You're going to convert yourself with this ritual.</span>")
	return ..()

/datum/religion_rites/synthconversion/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!movable_reltool?.buckled_mobs?.len)
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		return FALSE
	rite_target.set_species(/datum/species/android)
	rite_target.visible_message("<span class='notice'>[rite_target] has been converted by the rite of [name]!</span>")
	return TRUE


/datum/religion_rites/machine_blessing
	name = "Receive Blessing"
	desc = "Receive a blessing from the machine god to further your ascension."
	ritual_length = 5 SECONDS
	ritual_invocations =list( "Let your will power our forges.",
							"...Help us in our great conquest!")
	invoke_msg = "The end of flesh is near!"
	favor_cost = 2000

/datum/religion_rites/machine_blessing/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	var/blessing = pick(
					/obj/item/organ/cyberimp/arm/surgery,
					/obj/item/organ/cyberimp/eyes/hud/diagnostic,
					/obj/item/organ/cyberimp/eyes/hud/medical,
					/obj/item/organ/cyberimp/mouth/breathing_tube,
					/obj/item/organ/cyberimp/chest/thrusters,
					/obj/item/organ/eyes/robotic/glow)
	new blessing(altar_turf)
	return TRUE

/**** Ever-Burning Candle sect ****/

///apply a bunch of fire immunity effect to clothing
/datum/religion_rites/fireproof/proc/apply_fireproof(obj/item/clothing/fireproofed)
	fireproofed.name = "unmelting [fireproofed.name]"
	fireproofed.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	fireproofed.heat_protection = chosen_clothing.body_parts_covered
	fireproofed.resistance_flags |= FIRE_PROOF

/datum/religion_rites/fireproof
	name = "Unmelting Protection"
	desc = "Grants fire immunity to any piece of clothing."
	ritual_length = 15 SECONDS
	ritual_invocations = list("And so to support the holder of the Ever-Burning candle...",
	"... allow this unworthy apparel to serve you ...",
	"... make it strong enough to burn a thousand time and more ...")
	invoke_msg = "... Come forth in your new form, and join the unmelting wax of the one true flame!"
	favor_cost = 1000
///the piece of clothing that will be fireproofed, only one per rite
	var/obj/item/clothing/chosen_clothing

/datum/religion_rites/fireproof/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/clothing/apparel in get_turf(religious_tool))
		if(apparel.max_heat_protection_temperature >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
			continue //we ignore anything that is already fireproof
		chosen_clothing = apparel //the apparel has been chosen by our lord and savior
		return ..()
	return FALSE

/datum/religion_rites/fireproof/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!QDELETED(chosen_clothing) && get_turf(religious_tool) == chosen_clothing.loc) //check if the same clothing is still there
		if(istype(chosen_clothing,/obj/item/clothing/suit/hooded))
			for(var/obj/item/clothing/head/integrated_helmet in chosen_clothing.contents) //check if the clothing has a hood/helmet integrated and fireproof it if there is one.
				apply_fireproof(integrated_helmet)
		apply_fireproof(chosen_clothing)
		playsound(get_turf(religious_tool), 'sound/magic/fireball.ogg', 50, TRUE)
		chosen_clothing = null //our lord and savior no longer cares about this apparel
		return TRUE
	chosen_clothing = null
	to_chat(user,"<span class='warning'>The clothing that was chosen for the rite is no longer on the altar!</span>")
	return FALSE


/datum/religion_rites/burning_sacrifice
	name = "Burning Offering"
	desc = "Sacrifice a buckled burning corpse for favor, the more burn damage the corpse has the more favor you will receive."
	ritual_length = 20 SECONDS
	ritual_invocations = list("Burning body ...",
	"... cleansed by the flame ...",
	"... we were all created from fire ...",
	"... and to it ...")
	invoke_msg = "... WE RETURN! "
///the burning corpse chosen for the sacrifice of the rite
	var/mob/living/carbon/chosen_sacrifice

/datum/religion_rites/burning_sacrifice/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user,"<span class='warning'>Nothing is buckled to the altar!</span>")
		return FALSE
	for(var/corpse in movable_reltool.buckled_mobs)
		if(!iscarbon(corpse))// only works with carbon corpse since most normal mobs can't be set on fire.
			to_chat(user,"<span class='warning'>Only carbon lifeforms can be properly burned for the sacrifice!</span>")
			return FALSE
		chosen_sacrifice = corpse
		if(chosen_sacrifice.stat != DEAD)
			to_chat(user,"<span class='warning'>You can only sacrifice dead bodies, this one is still alive!</span>")
			return FALSE
		if(!chosen_sacrifice.on_fire)
			to_chat(user,"<span class='warning'>This corpse needs to be on fire to be sacrificed!</span>")
			return FALSE
		return ..()

/datum/religion_rites/burning_sacrifice/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	if(!(chosen_sacrifice in religious_tool.buckled_mobs)) //checks one last time if the right corpse is still buckled
		to_chat(user,"<span class='warning'>The right sacrifice is no longer on the altar!</span>")
		chosen_sacrifice = null
		return FALSE
	if(!chosen_sacrifice.on_fire)
		to_chat(user,"<span class='warning'>The sacrifice is no longer on fire, it needs to burn until the end of the rite!</span>")
		chosen_sacrifice = null
		return FALSE
	if(chosen_sacrifice.stat != DEAD)
		to_chat(user,"<span class='warning'>The sacrifice has to stay dead for the rite to work!</span>")
		chosen_sacrifice = null
		return FALSE
	var/favor_gained = 100 + round(chosen_sacrifice.getFireLoss())
	GLOB.religious_sect.adjust_favor(favor_gained, user)
	to_chat(user, "<span class='notice'>[GLOB.deity] absorbs the burning corpse and any trace of fire with it. [GLOB.deity] rewards you with [favor_gained] favor.")
	chosen_sacrifice.dust(force = TRUE)
	playsound(get_turf(religious_tool), 'sound/effects/supermatter.ogg', 50, TRUE)
	chosen_sacrifice = null
	return TRUE

/datum/religion_rites/infinite_candle
	name = "Immortal Candles"
	desc = "Creates 5 candles that never run out of wax."
	ritual_length = 10 SECONDS
	invoke_msg = "Burn bright, little candles, for you will only extinguish along with the universe."
	favor_cost = 200

/datum/religion_rites/infinite_candle/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	for(var/i in 1 to 5)
		new /obj/item/candle/infinite(altar_turf)
	playsound(altar_turf, 'sound/magic/fireball.ogg', 50, TRUE)
	return TRUE
