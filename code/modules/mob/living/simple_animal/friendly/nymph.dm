// This code is for dionae nymphs that get spread out in the room when a diona dies. One is player controlled.

/mob/living/simple_animal/nymph
	name = "diona nymph"
	desc = "Is that a plant?"
	icon = 'icons/mob/animal.dmi'
	icon_state = "nymph"
	icon_living = "nymph"
	icon_dead = "crab_dead"
	speak_language = /datum/language/sylvan
	speak_emote = list("chirrups")
	gender = NEUTER
	gold_core_spawnable = FRIENDLY_SPAWN
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'icons/mob/pets_held.dmi'
	held_state = "nymph"
	footstep_type = FOOTSTEP_MOB_CLAW
	hud_type = /datum/hud/nymph

	health = 100
	maxHealth = 100
	var/can_namepick_as_adult = FALSE
	var/adult_name = "diona gestalt"
	var/death_msg = "expires with a pitiful chirrup..."

	var/amount_grown = 0
	var/max_grown = 200
	var/time_of_birth
	var/instance_num

/mob/living/simple_animal/nymph/Initialize()
	. = ..()
	time_of_birth = world.time


	add_verb(/mob/living/simple_animal/nymph/proc/merge)
	add_verb(/mob/living/proc/lay_down)
	//AddAbility(new/obj/effect/proc_holder/alien/hide(null))
	//AddAbility(new/obj/effect/proc_holder/)

	instance_num = rand(1, 1000)
	name = "[initial(name)] ([instance_num])"
	real_name = name
	regenerate_icons()

	set_species(SPECIES_DIONA)
	grant_language(/datum/language/common)
	grant_language(/datum/language/sylvan)


/mob/living/simple_animal/nymph/Stat()
	..()
	if (statpanel("Status"))
		stat(null, text("Growth: [round(amount_grown/max_grown)]%"))

/mob/living/simple_animal/nymph/say_quote(var/message, var/datum/language/speaking = null)
	var/verb = pick(speak_emote)
	var/ending = copytext(message, length(message))
	if(speaking && (speaking.name != "Galactic Common"))
		verb = speaking.get_spoken_verb(ending)
	else if(ending == "?")
		verb += " curiously"
	return verb


/mob/living/simple_animal/nymph/death(gibbed)
	return ..(gibbed,death_msg)

/mob/living/simple_animal/nymph/attack_ghost(mob/dead/observer/user)
	if(client || key || ckey)
		to_chat(user, "<span class='warning'>\The [src] already has a player.")
	var/control_ask = alert("Do you wish to take control of \the [src]", "Chirp Time?", "Yes", "No")
	if(control_ask == "No" || !src || QDELETED(src) || QDELETED(user))
		return FALSE
	if(QDELETED(src) || QDELETED(user) || !user.client)
		return
	if(client || key || ckey)
		to_chat(user, "<span class='warning'>\The [src] already has a player.")
	var/mob/living/simple_animal/nymph/newnymph = new(loc)
	newnymph.key = user.key
	newnymph.unique_name = TRUE
	to_chat(newnymph, "<span class='boldwarning'>Remember that you have forgotten all of your past lives and are a new person!</span>")



/mob/living/simple_animal/nymph/proc/confirm_evolution()
	if(amount_grown < max_grown)
		to_chat(src, "You are not yet ready for your growth...")
		return null

	if(istype(loc, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/L = loc
		src.loc = L.loc
		qdel(L)

	src.visible_message(
		("<span class='warning'>[src] begins to shift and quiver, and erupts in a shower of shed bark as it splits into a tangle of nearly a dozen new dionaea."),
		("<span class='warning'>You begin to shift and quiver, feeling your awareness splinter. All at once, we consume our stored nutrients to surge with growth, splitting into a tangle of at least a dozen new dionaea. We have attained our gestalt form.")
	)
	return SPECIES_DIONA


/mob/living/simple_animal/nymph/verb/evolve()
	name = "Evolve"
	desc = "Evolve into your adult form"

	if(stat != CONSCIOUS)
		return

	if(amount_grown < max_grown)
		to_chat(src, "<span class='warning'>You are not fully grown.")
		return

	// confirm_evolution() handles choices and other specific requirements.
	var/new_species = confirm_evolution()
	if(!new_species)
		return

	var/mob/living/carbon/human/adult = new /mob/living/carbon/human(get_turf(src))
	adult.set_species(new_species)

	if(src.faction != "neutral")
		adult.faction = src.faction

	if(mind)
		mind.transfer_to(adult)
		if(can_namepick_as_adult)
			var/newname = sanitize(input(adult, "You have become an adult. Choose a name for yourself.", "Adult Name") as null|text, MAX_NAME_LEN)
			if(!newname)
				adult.fully_replace_character_name(name, "[src.adult_name]")
			else
				adult.fully_replace_character_name(name, newname)
	else
		adult.key = src.key

	for (var/obj/item/W in src.contents)
		src.forceMove(src.loc)

	qdel(src)


/mob/living/simple_animal/nymph/proc/update_progression()
	if(amount_grown < max_grown)
		amount_grown++
	return

/mob/living/simple_animal/nymph/proc/merge()
	name = "Merge"
	desc = "Merge with another nymph."

	if(stat == DEAD || paralysis || weakened || stunned || restrained())
		return

	if(istype(src.loc,/mob/living/carbon))
		src.verbs -= /mob/living/carbon/diona/proc/merge
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))

		if(!(src.Adjacent(C)) || !(C.client)) continue

		if(istype(C,/mob/living/carbon/human))
			var/mob/living/carbon/human/D = C
			if(D.species && D.species.name == SPECIES_DIONA)
				choices += C

	var/mob/living/M = input(src,"Who do you wish to merge with?") in null|choices

	if(!M)
		to_chat(src, "There is nothing nearby to merge with.")
	else if(!do_merge(M))
		to_chat(src, "You fail to merge with \the [M]...")


/mob/living/simple_animal/nymph/proc/do_merge(var/mob/living/carbon/human/H)
	if(!istype(H) || !src || !(src.Adjacent(H)))
		return 0
	to_chat(H, "You feel your being twine with that of \the [src] as it merges with your biomass.")
	to_chat(src, "You feel your being twine with that of \the [H] as you merge with its biomass.")
	loc = H
	verbs += /mob/living/carbon/diona/proc/split
	verbs -= /mob/living/simple_animal/nymph/proc/merge
	return TRUE
