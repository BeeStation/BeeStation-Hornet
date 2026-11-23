/datum/action/spell/lesserlichdom
	name = "Lesser Bind Soul"
	desc = "A weak version of the dark necromantic pact that can forever bind your soul to an \
	item of your choosing. So long as both your body and the item remain \
	intact and on the same plane you can revive from death for a limited number of times, though the time \
	between reincarnations grows massively with use, along with the weakness \
	that the new skeleton body will experience upon 'birth'. Note that \
	becoming a lesser lich destroys all internal organs except the brain."
	school = "necromancy"
	spell_requirements = NONE
	invocation = "MINUS POTENS NECREM IMORTIUM!"
	invocation_type = INVOCATION_SHOUT
	cooldown_time = 10 SECONDS
	button_icon_state = "skeleton"

/datum/action/spell/lesserlichdom/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE

	// We call this here so we can get feedback if they try to cast it when they shouldn't.
	if(!is_valid_spell(owner, owner))
		if(feedback)
			to_chat(owner, span_warning("You do not possess a soul."))
		return FALSE

	return TRUE

/datum/action/spell/lesserlichdom/is_valid_spell(mob/user, atom/target)
	return isliving(user) && !HAS_TRAIT(user, TRAIT_NO_SOUL)

/datum/action/spell/lesserlichdom/on_cast(mob/user, atom/target)
	. = ..()
	var/list/hand_items = list()
	if(iscarbon(user))
		hand_items = list(user.get_active_held_item(),user.get_inactive_held_item())
	if(!length(hand_items))
		to_chat(user, span_warning("You must hold an item you wish to make your phylactery..."))
		return

	var/obj/item/marked_item

	for(var/obj/item/item in hand_items)
		// I ensouled the nuke disk once. But it's probably a really
		// mean tactic, so probably should discourage it.
		if((item.item_flags & ABSTRACT) || HAS_TRAIT(item, TRAIT_NODROP) || SEND_SIGNAL(item, COMSIG_ITEM_IMBUE_SOUL, user))
			continue
		marked_item = item
		to_chat(user, span_warning("You begin to focus your very being into [item]..."))
		break

	if(!marked_item)
		to_chat(user, span_warning("None of the items you hold are suitable for emplacement of your fragile soul."))
		return

	playsound(user, 'sound/effects/pope_entry.ogg', 100)

	if(!do_after(user, 5 SECONDS, target = marked_item, timed_action_flags = IGNORE_HELD_ITEM))
		to_chat(user, span_warning("Your soul snaps back to your body as you stop ensouling [marked_item]!"))
		return

	marked_item.name = "lesser ensouled [marked_item.name]"
	marked_item.desc += "\nA terrible aura surrounds this item, its very existence is offensive to life itself..."
	marked_item.add_atom_colour("#187918", ADMIN_COLOUR_PRIORITY)

	new /obj/item/lesserphylactery(marked_item, user.mind)

	to_chat(user, span_userdanger("With a hideous feeling of emptiness you watch in horrified fascination as skin sloughs off bone! Blood boils, nerves disintegrate, eyes boil in their sockets! As your organs crumble to dust in your fleshless chest you come to terms with your choice. You're a lesser lich!"))

	// No soul. You just sold it
	ADD_TRAIT(user, TRAIT_NO_SOUL, LICH_TRAIT)

	user.set_species(/datum/species/skeleton)
	// no robes spawn for a lesser spell
	// you only get one phylactery.
	src.Remove(user)

/obj/item/lesserphylactery
	name = "lesser phylactery"
	desc = "Stores souls. Revives lesser liches. Also repels mosquitos. Can only be used to revive a lich twice."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bluespace"
	color = "#187918"
	light_color = "#187918"
	light_system = MOVABLE_LIGHT
	light_range = 3
	var/lon_range = 3
	var/resurrections = 0
	var/datum/mind/mind
	var/respawn_time = 3600  //Double the time of a regular phylactery

	var/static/active_phylacteries = 0

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/lesserphylactery)

/obj/item/lesserphylactery/Initialize(mapload, datum/mind/newmind)
	. = ..()
	mind = newmind
	name = "lesser phylactery of [mind.name]"

	active_phylacteries++
	AddElement(/datum/element/point_of_interest)
	START_PROCESSING(SSobj, src)

/obj/item/lesserphylactery/Destroy(force=FALSE)
	STOP_PROCESSING(SSobj, src)
	active_phylacteries--
	return ..()

/obj/item/lesserphylactery/process()
	if(QDELETED(mind))
		qdel(src)
		return
	if(!mind.current || (mind.current && mind.current.stat == DEAD))
		addtimer(CALLBACK(src, PROC_REF(rise)), respawn_time, TIMER_UNIQUE)

/obj/item/lesserphylactery/proc/rise()
	if(mind.current && mind.current.stat != DEAD)
		return "[mind] already has a living body: [mind.current]"

	var/turf/item_turf = get_turf(src)
	if(!item_turf)
		return "[src] is not at a turf? NULLSPACE!?"

	var/mob/living/old_body = mind.current
	var/mob/living/carbon/human/lich = new(item_turf)
	// no robes spawn for lesser spell

	lich.real_name = mind.name
	mind.transfer_to(lich)
	mind.grab_ghost(force=TRUE)
	lich.hardset_dna(null,null,lich.real_name,null, new /datum/species/skeleton,null)
	to_chat(lich, span_warning("Your bones clatter and shudder as you are pulled back into this world!"))
	var/turf/body_turf = get_turf(old_body)
	lich.Paralyze(400 + 200*resurrections) // paralyzed for longer due to lesser spell
	resurrections++
	if(old_body?.loc)
		if(iscarbon(old_body))
			var/mob/living/carbon/C = old_body
			for(var/obj/item/W in C)
				C.dropItemToGround(W)
			for(var/X in C.organs)
				var/obj/item/organ/I = X
				I.Remove(C)
				I.forceMove(body_turf)
		var/wheres_wizdo = dir2text(get_dir(body_turf, item_turf))
		if(wheres_wizdo)
			old_body.visible_message(span_warning("Suddenly [old_body.name]'s corpse falls to pieces! You see a strange energy rise from the remains, and speed off towards the [wheres_wizdo]!"))
			body_turf.Beam(item_turf,icon_state="lichbeam", time = 20 + 20 * resurrections) // beam shows for longer on the lesser spell
		old_body.dust()
	if(resurrections >= 2)
		to_chat(lich, span_userdanger("You feel your lesser phylactery break from over-usage. You will no longer be able to resurrect on death."))
		qdel(src)
	return "Respawn of [mind] successful."
