/obj/item/organ/heart/cursed
	name = "cursed heart"
	desc = "A heart that, when inserted, will force you to pump it manually."
	icon_state = "cursedheart-off"
	icon_base = "cursedheart"
	decay_factor = 0
	actions_types = list(/datum/action/item_action/organ_action/cursed_heart)
	var/last_pump = 0
	var/add_colour = TRUE //So we're not constantly recreating colour datums
	var/pump_delay = 30 //you can pump 1 second early, for lag, but no more (otherwise you could spam heal)
	var/blood_loss = 100 //600 blood is human default, so 5 failures (below 122 blood is where humans die because reasons?)

	//How much to heal per pump, negative numbers would HURT the player
	var/heal_brute = 0
	var/heal_burn = 0
	var/heal_oxy = 0


/obj/item/organ/heart/cursed/attack(mob/living/carbon/human/H, mob/living/carbon/human/user, obj/target)
	if(H == user && istype(H))
		playsound(user,'sound/effects/singlebeat.ogg',40,1)
		user.temporarilyRemoveItemFromInventory(src, TRUE)
		Insert(user)
	else
		return ..()

/obj/item/organ/heart/cursed/on_life(delta_time, times_fired)
	SHOULD_CALL_PARENT(FALSE)
	if(world.time > (last_pump + pump_delay))
		if(ishuman(owner) && owner.client) //While this entire item exists to make people suffer, they can't control disconnects.
			var/mob/living/carbon/human/H = owner
			if(H.dna && !HAS_TRAIT(H, TRAIT_NO_BLOOD))
				H.blood.volume = max(H.blood.volume - blood_loss, 0)
				to_chat(H, span_userdanger("You have to keep pumping your blood!"))
				if(add_colour)
					H.add_client_colour(/datum/client_colour/cursed_heart_blood) //bloody screen so real
					add_colour = FALSE
		else
			last_pump = world.time //lets be extra fair *sigh*

/obj/item/organ/heart/cursed/on_insert(mob/living/carbon/accursed)
	. = ..()
	to_chat(accursed, span_userdanger("Your heart has been replaced with a cursed one, you have to pump this one manually otherwise you'll die!"))

/obj/item/organ/heart/cursed/Remove(mob/living/carbon/M, special = 0, pref_load = FALSE)
	..()
	M.remove_client_colour(/datum/client_colour/cursed_heart_blood)

/datum/action/item_action/organ_action/cursed_heart
	name = "Pump your blood"

//You are now brea- pumping blood manually
/datum/action/item_action/organ_action/cursed_heart/on_activate(mob/user, atom/target)
	if(. && istype(target, /obj/item/organ/heart/cursed))
		var/obj/item/organ/heart/cursed/cursed_heart = target

		if(world.time < cursed_heart.last_pump + (cursed_heart.pump_delay-10)) //no spam
			to_chat(owner, span_userdanger("Too soon!"))
			return

		cursed_heart.last_pump = world.time
		start_cooldown(cursed_heart.pump_delay-10)
		playsound(owner,'sound/effects/singlebeat.ogg',40,1)
		to_chat(owner, span_notice("Your heart beats."))

		var/mob/living/carbon/human/H = owner
		if(istype(H))
			if(H.dna && !HAS_TRAIT(H, TRAIT_NO_BLOOD))
				H.blood.volume = min(H.blood.volume + cursed_heart.blood_loss*0.5, BLOOD_VOLUME_MAXIMUM)
				H.remove_client_colour(/datum/client_colour/cursed_heart_blood)
				cursed_heart.add_colour = TRUE
				H.adjustBruteLoss(-cursed_heart.heal_brute)
				H.adjustFireLoss(-cursed_heart.heal_burn)
				H.adjustOxyLoss(-cursed_heart.heal_oxy)


/datum/client_colour/cursed_heart_blood
	priority = 100 //it's an indicator you're dying, so it's very high priority
	colour = "red"
