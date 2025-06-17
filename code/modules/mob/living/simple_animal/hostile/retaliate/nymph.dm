// This code is for dionae nymphs that get spread out in the room when a diona dies. One is player controlled.

/mob/living/simple_animal/hostile/retaliate/nymph
	name = "diona nymph"
	desc = "Is that a plant?"
	icon = 'icons/mob/animal.dmi'
	icon_state = "nymph"
	icon_living = "nymph"
	icon_dead = "nymph_dead"
	faction = list(FACTION_DIONA)
	gender = NEUTER
	gold_core_spawnable = FRIENDLY_SPAWN
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSMOB
	density = FALSE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'icons/mob/pets_held.dmi'
	held_state = "nymph"
	footstep_type = FOOTSTEP_MOB_CLAW
	hud_type = /datum/hud/nymph
	butcher_results = list(/obj/item/food/meat/slab/human/mutant/diona = 4)
	initial_language_holder = /datum/language_holder/diona

	var/brute_damage = 0
	var/fire_damage = 0
	health = 50
	maxHealth = 50
	melee_damage = 1.5
	obj_damage = 10
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	attack_sound = 'sound/emotes/diona/hit.ogg'
	minbodytemp = 2.7
	var/can_namepick_as_adult = FALSE
	var/death_msg = "expires with a pitiful chirrup..."

	var/amount_grown = 0
	var/max_grown = 150
	var/time_of_birth
	var/instance_num
	var/is_ghost_spawn = TRUE //For if a ghost can become this.
	var/is_drone = FALSE //Is a remote controlled nymph from a diona.
	var/drone_parent //The diona which can control the nymph, if there is one
	var/old_name // The diona nymph's old name.
	var/datum/action/nymph/evolve/evolve_ability //The ability to grow up into a diona by yourself.
	var/datum/action/nymph/SwitchFrom/switch_ability //The ability to switch back to the parent diona as a drone.
	var/list/features = list()
	var/time_spent_in_light
	var/assimilating = FALSE
	var/grown_message_sent = FALSE

/mob/living/simple_animal/hostile/retaliate/nymph/Initialize(mapload)
	. = ..()
	time_of_birth = world.time
	evolve_ability = new
	evolve_ability.Grant(src)
	instance_num = rand(1, 1000)
	name = "[initial(name)] ([instance_num])"
	real_name = name
	regenerate_icons()
	ADD_TRAIT(src, TRAIT_MUTE, "nymph")
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	GLOB.poi_list |= src

/mob/living/simple_animal/hostile/retaliate/nymph/get_stat_tab_status()
	var/list/tab_data = ..()
	tab_data["Health"] = GENERATE_STAT_TEXT("[round((health / maxHealth) * 100)]%")
	if(!is_drone)
		tab_data["Growth"] = GENERATE_STAT_TEXT("[(round(amount_grown / max_grown * 100))]%")
	return tab_data

/mob/living/simple_animal/hostile/retaliate/nymph/Life(delta_time, times_fired)
	. = ..()
	if(!is_drone)
		update_progression()
	if(stat != CONSCIOUS)
		remove_status_effect(/datum/status_effect/planthealing)
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(loc)) //else, there's considered to be no light
		var/turf/T = loc
		light_amount = min(1,T.get_lumcount()) - 0.5
		if(light_amount > 0.2) //Is there light here?
			time_spent_in_light++  //If so, how long have we been somewhere with light?
			if(time_spent_in_light > 5) //More than 5 seconds spent in the light
				if(stat != CONSCIOUS)
					remove_status_effect(/datum/status_effect/planthealing)
					return
				apply_status_effect(/datum/status_effect/planthealing)
		else
			remove_status_effect(/datum/status_effect/planthealing)
			time_spent_in_light = 0  //No light? Reset the timer.

/mob/living/simple_animal/hostile/retaliate/nymph/death(gibbed)
	GLOB.poi_list -= src
	evolve_ability.Remove(src)
	if(is_drone)
		if(mind)
			switch_ability.on_activate(src, null) //If we have someone conscious in the drone, throw them out.
		switch_ability.Remove(src)
	return ..(gibbed,death_msg)

/mob/living/simple_animal/hostile/retaliate/nymph/adjustBruteLoss(amount, updating_health, forced)
	brute_damage = brute_damage + amount * damage_coeff[BRUTE] * CONFIG_GET(number/damage_multiplier)
	. = ..()

/mob/living/simple_animal/hostile/retaliate/nymph/adjustFireLoss(amount, updating_health, forced)
	fire_damage = fire_damage + amount * damage_coeff[BURN] * CONFIG_GET(number/damage_multiplier)
	. = ..()

/mob/living/simple_animal/hostile/retaliate/nymph/UnarmedAttack(atom/A, proximity)
	melee_damage = 1.5
	. = ..()

/mob/living/simple_animal/hostile/retaliate/nymph/attack_animal(mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/retaliate/nymph) && stat != DEAD)
		var/mob/living/simple_animal/hostile/retaliate/nymph/user = L
		if(mind == null) // No RRing fellow nymphs
			if(user.is_drone)
				to_chat(user, span_danger("You can't grow up as a lone nymph drone!"))
				return
			if(user.assimilating)
				return
			user.assimilating = TRUE
			playsound(user, 'sound/creatures/venus_trap_death.ogg', 25, 1)
			balloon_alert(user, "[user] starts assimilating [src]")
			toggle_ai(AI_OFF)
			if(do_after(user, 30 SECONDS, src))
				user.evolve(src)
				return
			else
				toggle_ai(AI_ON)
				user.assimilating = FALSE
				return
		else
			user.melee_damage = 0
	. = ..()

/mob/living/simple_animal/hostile/retaliate/nymph/spawn_gibs()
	new /obj/effect/decal/cleanable/insectguts(drop_location())
	playsound(drop_location(), 'sound/effects/blobattack.ogg', 60, TRUE)

/mob/living/simple_animal/hostile/retaliate/nymph/attack_ghost(mob/dead/observer/user)
	if(client || key || ckey)
		to_chat(user, span_warning("\The [src] already has a player."))
		return
	if(!is_ghost_spawn || stat == DEAD || is_drone)
		to_chat(user, span_warning("\The [src] is not possessable!"))
		return
	var/control_ask = tgui_alert(usr, "Do you wish to take control of \the [src]", "Chirp Time?", list("Yes", "No"))
	if(control_ask != "Yes" || !src || QDELETED(src) || QDELETED(user))
		return FALSE
	if(QDELETED(src) || QDELETED(user) || !user.client)
		return
	var/mob/living/simple_animal/hostile/retaliate/nymph/newnymph = src
	newnymph.key = user.key
	newnymph.unique_name = TRUE
	to_chat(newnymph, span_boldwarning("Remember that you have forgotten all of your past lives and are a new person!"))

/mob/living/simple_animal/hostile/retaliate/nymph/proc/update_progression()
	if(amount_grown < max_grown)
		amount_grown++
	if(amount_grown > max_grown)
		amount_grown = max_grown
	if(!grown_message_sent && amount_grown == max_grown)
		to_chat(src, span_userdanger("You feel like you're ready to grow up by yourself!"))
		grown_message_sent = TRUE

/mob/living/simple_animal/hostile/retaliate/nymph/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(nymph_assimilation), source, arrived)

/mob/living/simple_animal/hostile/retaliate/nymph/proc/nymph_assimilation(datum/source, atom/movable/arrived)
	if(isdiona(arrived))
		if(mind != null || stat == DEAD || is_drone) //Does the nymph on the ground have a mind, dead or a drone?
			return // If so, ignore the diona
		var/mob/living/carbon/human/arrived_diona = arrived
		var/list/limbs_to_heal = arrived_diona.get_missing_limbs()
		if(!LAZYLEN(limbs_to_heal))
			return
		toggle_ai(AI_OFF)
		if(!do_after(arrived_diona, 5 SECONDS, source, progress = TRUE))
			toggle_ai(AI_IDLE)
			return
		playsound(arrived_diona, 'sound/creatures/venus_trap_hit.ogg', 25, 1)
		var/obj/item/bodypart/healed_limb = pick(limbs_to_heal)
		arrived_diona.regenerate_limb(healed_limb)
		for(var/obj/item/bodypart/body_part in arrived_diona.bodyparts)
			if(body_part.body_zone == healed_limb)
				body_part.brute_dam = brute_damage
				body_part.burn_dam = fire_damage
		balloon_alert(arrived_diona, "[arrived_diona] assimilates [src]")
		QDEL_NULL(src)

/mob/living/simple_animal/hostile/retaliate/nymph/handle_mutations_and_radiation()
	if(radiation > 50)
		heal_overall_damage(1,1, 0, BODYTYPE_ORGANIC)
	. = ..()

/mob/living/simple_animal/hostile/retaliate/nymph/proc/evolve(var/mob/living/simple_animal/hostile/retaliate/nymph/nymphs)
	if(istype(loc, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/L = loc
		src.loc = L.loc
		qdel(L)

	src.visible_message(span_warning("[src] begins to shift and quiver, and after engulfing another nymph, erupts in a shower of shed bark as it splits into a tangle of a new diona gestalt."),
		span_warning("You begin to shift and quiver, feeling your awareness splinter. All at once, we consume our stored nutrients and, along with a friend, surge with growth, splitting into a tangle of at least a dozen new vines. We have attained our gestalt form. Our friends should help with obtaining the rest of our limbs...")
	)

	var/mob/living/simple_animal/hostile/retaliate/nymph/helpers
	if(!nymphs)
		helpers = new /mob/living/simple_animal/hostile/retaliate/nymph(src.loc)
	else
		helpers = nymphs
	var/mob/living/carbon/human/species/diona/adult = new /mob/living/carbon/human/species/diona(src.loc)
	adult.set_species(SPECIES_DIONA)

	for(var/obj/item/bodypart/body_part in adult.bodyparts) //No limbs for you, small diona.
		if(istype(body_part, /obj/item/bodypart/chest))
			body_part.brute_dam = helpers.brute_damage
			body_part.burn_dam = helpers.fire_damage
		else if(istype(body_part, /obj/item/bodypart/head))
			body_part.brute_dam = brute_damage
			body_part.burn_dam = fire_damage
		else // If its not a chest AND not a head
			for(var/obj/item/organ/nymph_organ/I in body_part)
				QDEL_NULL(I)
			body_part.drop_limb(TRUE)

	if(!("neutral" in src.faction))
		adult.faction = src.faction
	if(old_name)
		adult.real_name = old_name
		adult.dna.features = features
	else
		adult.fully_replace_character_name(name, adult.dna.species.random_name(gender))
		adult.dna.features["mcolor"] = sanitize_hexcolor(RANDOM_COLOUR)
	if(mind)
		mind.transfer_to(adult)
	else
		adult.key = src.key

	adult.dna.update_dna_identity()
	adult.update_body()
	adult.updateappearance()
	adult.nutrition = NUTRITION_LEVEL_HUNGRY
	REMOVE_TRAIT(adult, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	QDEL_NULL(helpers)
	qdel(src)

/mob/living/simple_animal/hostile/retaliate/nymph/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced)
	if(!..())
		emote("chitter")

/datum/action/nymph/evolve
	name = "Evolve"
	desc = "Evolve into your adult form with the help of another nymph."
	background_icon_state = "bg_default"
	icon_icon = 'icons/hud/actions/actions_spells.dmi'
	button_icon_state = "grow"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED

/datum/action/nymph/evolve/on_activate(mob/user, atom/target)
	var/mob/living/simple_animal/hostile/retaliate/nymph/nymph = owner
	if(!isnymph(nymph))
		return
	if(nymph.is_drone)
		to_chat(user, span_danger("You can't grow up as a drone!"))
		return
	if(nymph.movement_type & VENTCRAWLING)
		to_chat(user, span_danger("You cannot evolve while in a vent."))
		return
	if(nymph.amount_grown >= nymph.max_grown)
		playsound(nymph, 'sound/creatures/venus_trap_death.ogg', 25, 1)
		nymph.evolve()
	else
		to_chat(user, span_danger("You are not ready to grow up by yourself."))
		return FALSE

/datum/action/nymph/SwitchFrom
	name = "Return"
	desc = "Return back into your adult form."
	background_icon_state = "bg_default"
	icon_icon = 'icons/hud/actions/actions_spells.dmi'
	button_icon_state = "return"

/datum/action/nymph/SwitchFrom/pre_activate(mob/user, atom/target)
	var/mob/living/simple_animal/hostile/retaliate/nymph/nymph = owner
	var/mob/living/carbon/human/drone_diona = nymph.drone_parent
	if(!isnymph(nymph))
		return FALSE
	if(nymph.movement_type & VENTCRAWLING)
		to_chat(nymph, span_danger("You cannot switch while in a vent."))
		return FALSE
	if(QDELETED(drone_diona)) // FUCK SOMETHING HAPPENED TO THE MAIN DIONA, ABORT ABORT ABORT
		nymph.is_drone = FALSE //We're not a drone anymore!!!! Panic!
		to_chat(nymph, span_danger("You feel like your gestalt is gone! Something must have gone wrong..."))
		nymph.switch_ability.Remove(nymph)
		return FALSE
	. = ..()

/datum/action/nymph/SwitchFrom/on_activate(mob/user, atom/target)
	var/mob/living/simple_animal/hostile/retaliate/nymph/nymph = owner
	var/mob/living/carbon/human/drone_diona = nymph.drone_parent
	SwitchFrom(nymph, drone_diona)

/datum/action/nymph/SwitchFrom/proc/SwitchFrom(mob/living/simple_animal/hostile/retaliate/nymph/user, mob/living/carbon/M)
	var/datum/mind/C = user.mind
	M = user.drone_parent
	if(user.stat == CONSCIOUS)
		user.visible_message(span_notice("[user] stops moving and starts staring vacantly into space."), span_notice("You stop moving this form..."))
	else
		to_chat(M, span_notice("You abandon this nymph..."))
	C.transfer_to(M)
	M.mind = C
	M.visible_message(span_notice("[M] blinks and looks around."), span_notice("...and move this one instead."))

/mob/living/simple_animal/hostile/retaliate/nymph/mob_try_pickup(mob/living/user)
	if(!ishuman(user))
		return
	if(user.get_active_held_item())
		to_chat(user, span_warning("Your hands are full!"))
		return FALSE
	if(buckled)
		to_chat(user, span_warning("[src] is buckled to something!"))
		return FALSE
	mob_pickup(user)
	return TRUE

/mob/living/simple_animal/hostile/retaliate/nymph/mob_pickup(mob/living/L)
	if(resting)
		resting = FALSE
		update_resting()
	toggle_ai(AI_OFF)
	var/obj/item/clothing/head/mob_holder/nymph/holder = new(get_turf(src), src, held_state, head_icon, held_lh, held_rh, worn_slot_flags)
	if(stat == DEAD && mind)
		holder.tool_behaviour = TOOL_SEED
	L.visible_message(span_warning("[L] scoops up [src]!"))
	L.put_in_hands(holder)

/obj/item/clothing/head/mob_holder/nymph
	var/moving_cooldown
	var/on_head
	//Variables for planting a dead nymph into a hydroponics tray
	tool_behaviour = null
	fake_seed = null
	grind_results = list(/datum/reagent/consumable/chlorophyll = 20)
	juice_typepath = /datum/reagent/consumable/chlorophyll

/obj/item/clothing/head/mob_holder/nymph/Initialize(mapload, mob/living/M, worn_state, head_icon, lh_icon, rh_icon, worn_slot_flags)
	if(M.mind)
		fake_seed = new /obj/item/seeds/nymph
		fake_seed.mind = M.mind
	. = ..()

/obj/item/clothing/head/mob_holder/nymph/relaymove(mob/user) // Hold nymph like petulant child...
	if(moving_cooldown <= world.time)
		moving_cooldown = world.time + 50
		user.visible_message(span_notice("[user] starts to squirm in [loc]'s hands!"),
		span_notice("You start to squirm in [loc]'s hands..."))
		if(on_head)
			release()
		if(do_after(held_mob, 8 SECONDS, user, NONE, TRUE))
			release()

/obj/item/clothing/head/mob_holder/nymph/microwave_act(obj/machinery/microwave/M)
	. = ..()
	M.muck()
	held_mob.adjustFireLoss(50)
	Destroy()

/obj/item/clothing/head/mob_holder/nymph/release()
	on_head = FALSE
	var/mob/living/simple_animal/hostile/retaliate/nymph/nymph_mob = held_mob
	nymph_mob.toggle_ai(AI_ON)
	. = ..()

/obj/item/clothing/head/mob_holder/nymph/equipped()
	. = ..()
	on_head = TRUE

/obj/item/clothing/head/mob_holder/nymph/on_grind()
	playsound(held_mob, 'sound/effects/splat.ogg', 50, 1)
	qdel(held_mob)
	. = ..()
