/obj/effect/proc_holder/spell/targeted/lesserlichdom
	name = "Lesser Bind Soul"
	desc = "A weak version of the dark necromantic pact that can forever bind your soul to an \
	item of your choosing. So long as both your body and the item remain \
	intact and on the same plane you can revive from death for a limited number of times, though the time \
	between reincarnations grows massively with use, along with the weakness \
	that the new skeleton body will experience upon 'birth'. Note that \
	becoming a lesser lich destroys all internal organs except the brain."
	school = "necromancy"
	charge_max = 10
	clothes_req = FALSE
	centcom_cancast = FALSE
	invocation = "MINUS POTENS NECREM IMORTIUM!"
	invocation_type = INVOCATION_SHOUT
	range = -1
	level_max = 0 //cannot be improved
	cooldown_min = 10
	include_user = TRUE

	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "skeleton"

/obj/effect/proc_holder/spell/targeted/lesserlichdom/cast(list/targets,mob/user = usr)
	for(var/mob/M in targets)
		var/list/hand_items = list()
		if(iscarbon(M))
			hand_items = list(M.get_active_held_item(),M.get_inactive_held_item())
		if(!length(hand_items))
			to_chat(M, "<span class='warning'>You must hold an item you wish to make your phylactery...</span>")
			return
		if(!M.mind.hasSoul)
			to_chat(user, "<span class='warning'>You do not possess a soul.</span>")
			return

		var/obj/item/marked_item

		for(var/obj/item/item in hand_items)
			// I ensouled the nuke disk once. But it's probably a really
			// mean tactic, so probably should discourage it.
			if((item.item_flags & ABSTRACT) || HAS_TRAIT(item, TRAIT_NODROP) || SEND_SIGNAL(item, COMSIG_ITEM_IMBUE_SOUL, user))
				continue
			marked_item = item
			to_chat(M, "<span class='warning'>You begin to focus your very being into [item]...</span>")
			break

		if(!marked_item)
			to_chat(M, "<span class='warning'>None of the items you hold are suitable for emplacement of your fragile soul.</span>")
			return

		playsound(user, 'sound/effects/pope_entry.ogg', 100)

		if(!do_after(M, 50, target=marked_item, timed_action_flags = IGNORE_HELD_ITEM))
			to_chat(M, "<span class='warning'>Your soul snaps back to your body as you stop ensouling [marked_item]!</span>")
			return

		marked_item.name = "lesser ensouled [marked_item.name]"
		marked_item.desc += "\nA terrible aura surrounds this item, its very existence is offensive to life itself..."
		marked_item.add_atom_colour("#187918", ADMIN_COLOUR_PRIORITY)

		new /obj/item/lesserphylactery(marked_item, M.mind)

		to_chat(M, "<span class='userdanger'>With a hideous feeling of emptiness you watch in horrified fascination as skin sloughs off bone! Blood boils, nerves disintegrate, eyes boil in their sockets! As your organs crumble to dust in your fleshless chest you come to terms with your choice. You're a lesser lich!</span>")
		M.mind.hasSoul = FALSE
		// No revival other than lichdom revival
		if(isliving(M))
			var/mob/living/L = M
			L.sethellbound()
		else
			M.mind.hellbound = TRUE
		M.set_species(/datum/species/skeleton)
		// no robes spawn for a lesser spell
		// you only get one phylactery.
		M.mind.RemoveSpell(src)


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

	var/mob/old_body = mind.current
	var/mob/living/carbon/human/lich = new(item_turf)
	// no robes spawn for lesser spell

	lich.real_name = mind.name
	mind.transfer_to(lich)
	mind.grab_ghost(force=TRUE)
	lich.hardset_dna(null,null,lich.real_name,null, new /datum/species/skeleton,null)
	to_chat(lich, "<span class='warning'>Your bones clatter and shudder as you are pulled back into this world!</span>")
	var/turf/body_turf = get_turf(old_body)
	lich.Paralyze(400 + 200*resurrections) // paralyzed for longer due to lesser spell
	resurrections++
	if(old_body?.loc)
		if(iscarbon(old_body))
			var/mob/living/carbon/C = old_body
			for(var/obj/item/W in C)
				C.dropItemToGround(W)
			for(var/X in C.internal_organs)
				var/obj/item/organ/I = X
				I.Remove(C)
				I.forceMove(body_turf)
		var/wheres_wizdo = dir2text(get_dir(body_turf, item_turf))
		if(wheres_wizdo)
			old_body.visible_message("<span class='warning'>Suddenly [old_body.name]'s corpse falls to pieces! You see a strange energy rise from the remains, and speed off towards the [wheres_wizdo]!</span>")
			body_turf.Beam(item_turf,icon_state="lichbeam", time = 20 + 20 * resurrections) // beam shows for longer on the lesser spell
		old_body.dust()
	if(resurrections >= 2)
		to_chat(lich,"<span class='userdanger'>You feel your lesser phylactery break from over-usage. You will no longer be able to resurrect on death.")
		qdel(src)
	return "Respawn of [mind] successful."
