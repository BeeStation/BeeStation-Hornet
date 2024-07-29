// This code is for dionae nymphs that get spread out in the room when a diona dies. One is player controlled.

/mob/living/simple_animal/hostile/retaliate/nymph
	name = "diona nymph"
	desc = "Is that a plant?"
	icon = 'icons/mob/animal.dmi'
	icon_state = "nymph"
	icon_living = "nymph"
	icon_dead = "nymph_dead"
	faction = list("diona")
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
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	attack_sound = 'sound/weapons/slash.ogg'
	var/can_namepick_as_adult = FALSE
	var/adult_name = "diona gestalt"
	var/death_msg = "expires with a pitiful chirrup..."

	var/amount_grown = 0
	var/max_grown = 250
	var/time_of_birth
	var/instance_num
	var/is_ghost_spawn = FALSE //For if a ghost can become this.
	var/is_drone = FALSE //Is a remote controlled nymph from a diona.
	var/drone_parent //The diona which can control the nymph, if there is one
	var/old_name // The diona nymph's old name.
	var/datum/action/nymph/evolve/evolve_ability //The ability to grow up into a diona.
	var/datum/action/nymph/SwitchFrom/switch_ability //The ability to switch back to the parent diona as a drone.
	var/list/features = list()
	var/grown_message_sent = FALSE
	var/time_spent_in_light

/mob/living/simple_animal/hostile/retaliate/nymph/Initialize()
	. = ..()
	time_of_birth = world.time
	add_verb(/mob/living/proc/lay_down)
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
	get_stat_tab_status()
	if(stat != CONSCIOUS)
		remove_status_effect(STATUS_EFFECT_PLANTHEALING)
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(loc)) //else, there's considered to be no light
		var/turf/T = loc
		light_amount = min(1,T.get_lumcount()) - 0.5
		if(light_amount > 0.2) //Is there light here?
			time_spent_in_light++  //If so, how long have we been somewhere with light?
			if(time_spent_in_light > 5) //More than 5 seconds spent in the light
				if(stat != CONSCIOUS)
					remove_status_effect(STATUS_EFFECT_PLANTHEALING)
					return
				apply_status_effect(STATUS_EFFECT_PLANTHEALING)
		else
			remove_status_effect(STATUS_EFFECT_PLANTHEALING)
			time_spent_in_light = 0  //No light? Reset the timer.

/mob/living/simple_animal/hostile/retaliate/nymph/handle_environment(datum/gas_mixture/environment)
	return

/mob/living/simple_animal/hostile/retaliate/nymph/death(gibbed)
	evolve_ability.Remove(src)
	if(is_drone)
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
		var/mob/living/simple_animal/hostile/retaliate/nymph/M = L
		if(mind == null) // No RRing fellow nymphs
			M.melee_damage = 25
			M.amount_grown += 50
			. = ..()
			return
		else
			M.melee_damage = 0
			. = ..()
			return
	. = ..()

/mob/living/simple_animal/hostile/retaliate/nymph/spawn_gibs()
	new /obj/effect/decal/cleanable/insectguts(drop_location())
	playsound(drop_location(), 'sound/effects/blobattack.ogg', 60, TRUE)

/mob/living/simple_animal/hostile/retaliate/nymph/attack_ghost(mob/dead/observer/user)
	if(client || key || ckey)
		to_chat(user, "<span class='warning'>\The [src] already has a player.")
		return
	if(!is_ghost_spawn)
		to_chat(user, "<span class='warning'>\The [src] is not possessable!")
		return
	var/control_ask = alert("Do you wish to take control of \the [src]", "Chirp Time?", "Yes", "No")
	if(control_ask == "No" || !src || QDELETED(src) || QDELETED(user))
		return FALSE
	if(QDELETED(src) || QDELETED(user) || !user.client)
		return
	var/mob/living/simple_animal/hostile/retaliate/nymph/newnymph = src
	newnymph.key = user.key
	newnymph.unique_name = TRUE
	to_chat(newnymph, "<span class='boldwarning'>Remember that you have forgotten all of your past lives and are a new person!</span>")

/mob/living/simple_animal/hostile/retaliate/nymph/proc/update_progression()
	if(amount_grown < max_grown)
		amount_grown++
	if(amount_grown > max_grown)
		amount_grown = max_grown
	if(!grown_message_sent && amount_grown == max_grown)
		to_chat(src, "<span class='userdanger'>You feel like you're ready to grow up!</span>")
		grown_message_sent = TRUE

/mob/living/simple_animal/hostile/retaliate/nymph/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(isdiona(arrived))
		if(mind != null || stat == DEAD || is_drone) //Does the nymph on the ground have a mind, dead or a drone?
			return // If so, ignore the diona
		var/mob/living/carbon/human/H = arrived
		var/list/limbs_to_heal = H.get_missing_limbs()
		if(!LAZYLEN(limbs_to_heal))
			return
		playsound(H, 'sound/creatures/venus_trap_hit.ogg', 25, 1)
		var/obj/item/bodypart/healed_limb = pick(limbs_to_heal)
		H.regenerate_limb(healed_limb)
		for(var/obj/item/bodypart/body_part in H.bodyparts)
			if(body_part.body_zone == healed_limb)
				body_part.brute_dam = brute_damage
				body_part.burn_dam = fire_damage
		balloon_alert(arrived, "[arrived] assimilates [src]")
		QDEL_NULL(src)

/datum/action/nymph/evolve
	name = "Evolve"
	desc = "Evolve into your adult form with the help of another nymph."
	background_icon_state = "bg_default"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "grow"

/datum/action/nymph/evolve/Trigger()
	. = ..()
	var/mob/living/simple_animal/hostile/retaliate/nymph/user = owner
	if(!isnymph(user))
		return
	if(user.is_drone)
		to_chat(user, "<span class='danger'>You can't grow up as a lone nymph drone!")
		return
	if(user.movement_type & VENTCRAWLING)
		to_chat(user, "<span class='danger'>You cannot evolve while in a vent.</span>")
		return
	if(user.stat != CONSCIOUS)
		return
	if(user.amount_grown >= user.max_grown)
		if(user.incapacitated()) //something happened to us while we were choosing.
			return
		for(var/mob/living/simple_animal/hostile/retaliate/nymph/helpers in view(1,user.loc))
			if(helpers.mind != null)
				continue
			playsound(user, 'sound/creatures/venus_trap_death.ogg', 25, 1)
			user.evolve(helpers)
			return TRUE
		to_chat(user, "<span class='danger'>You don't have any nymphs around you to help you grow up!</span>") // There is no one around to help you.
	else
		to_chat(user, "<span class='danger'>You are not fully grown.</span>")
		return FALSE

/mob/living/simple_animal/hostile/retaliate/nymph/handle_mutations_and_radiation()
	if(radiation > 50)
		heal_overall_damage(1,1, 0, BODYTYPE_ORGANIC)
	. = ..()

/mob/living/simple_animal/hostile/retaliate/nymph/verb/evolve(var/mob/living/simple_animal/hostile/retaliate/nymph/helpers)
	if(istype(loc, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/L = loc
		src.loc = L.loc
		qdel(L)

	src.visible_message(
		("<span class='warning'>[src] begins to shift and quiver, and after engulfing another nymph, erupts in a shower of shed bark as it splits into a tangle of nearly a dozen new dionaea."),
		("<span class='warning'>You begin to shift and quiver, feeling your awareness splinter. All at once, we consume our stored nutrients and, along with a friend, surge with growth, splitting into a tangle of at least a dozen new vines. We have attained our gestalt form. Our friends should help with obtaining the rest of our limbs...")
	)

	var/mob/living/carbon/human/species/diona/adult = new /mob/living/carbon/human/species/diona(src.loc)
	adult.set_species(SPECIES_DIONA)
	adult.dna.features = src.features
	for(var/obj/item/bodypart/body_part in adult.bodyparts) //No limbs for you, small diona.
		if(istype(body_part, /obj/item/bodypart/l_arm) || istype(body_part, /obj/item/bodypart/r_arm) || istype(body_part, /obj/item/bodypart/l_leg) || istype(body_part, /obj/item/bodypart/r_leg)) // I'm sorry.
			for(var/obj/item/organ/nymph_organ/I in body_part)
				QDEL_NULL(I)
			QDEL_NULL(body_part)
		if(istype(body_part, /obj/item/bodypart/chest))
			body_part.brute_dam = helpers.brute_damage
			body_part.burn_dam = helpers.fire_damage
		if(istype(body_part, /obj/item/bodypart/head))
			body_part.brute_dam = brute_damage
			body_part.burn_dam = fire_damage
	adult.update_body()
	adult.updateappearance()
	adult.nutrition = NUTRITION_LEVEL_HUNGRY
	if(!("neutral" in src.faction))
		adult.faction = src.faction
	if(old_name)
		adult.real_name = src.old_name
	else
		adult.fully_replace_character_name(name, adult.dna.species.random_name(gender))
	if(mind)
		mind.transfer_to(adult)
	else
		adult.key = src.key
	QDEL_NULL(helpers)
	qdel(src)

/datum/action/nymph/SwitchFrom
	name = "Return"
	desc = "Return back into your adult form."
	background_icon_state = "bg_default"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "return"

/datum/action/nymph/SwitchFrom/Trigger(DroneParent)
	. = ..()
	var/mob/living/simple_animal/hostile/retaliate/nymph/user = owner
	if(!isnymph(user))
		return
	if(user.movement_type & VENTCRAWLING)
		to_chat(user, "<span class='danger'>You cannot switch while in a vent.</span>")
		return
	SwitchFrom(user, DroneParent)

/datum/action/nymph/SwitchFrom/proc/SwitchFrom(mob/living/simple_animal/hostile/retaliate/nymph/user, mob/living/carbon/M)
	var/datum/mind/C = user.mind
	M = user.drone_parent
	if(user.stat == CONSCIOUS)
		user.visible_message("<span class='notice'>[user] \
			stops moving and starts staring vacantly into space.</span>",
			"<span class='notice'>You stop moving this form...</span>")
	else
		to_chat(M, "<span class='notice'>You abandon this nymph...</span>")
	C.transfer_to(M)
	M.mind = C
	M.visible_message("<span class='notice'>[M] blinks and looks \
		around.</span>",
		"<span class='notice'>...and move this one instead.</span>")

/mob/living/simple_animal/hostile/retaliate/nymph/mob_try_pickup(mob/living/user)
	if(!ishuman(user))
		return
	if(user.get_active_held_item())
		to_chat(user, "<span class='warning'>Your hands are full!</span>")
		return FALSE
	if(buckled)
		to_chat(user, "<span class='warning'>[src] is buckled to something!</span>")
		return FALSE
	mob_pickup(user)
	return TRUE

/mob/living/simple_animal/hostile/retaliate/nymph/mob_pickup(mob/living/L)
	if(resting)
		resting = FALSE
		update_resting()
	var/obj/item/clothing/head/mob_holder/nymph/holder = new(get_turf(src), src, held_state, head_icon, held_lh, held_rh, worn_slot_flags)
	L.visible_message("<span class='warning'>[L] scoops up [src]!</span>")
	L.put_in_hands(holder)

/obj/item/clothing/head/mob_holder/nymph

/obj/item/clothing/head/mob_holder/nymph/relaymove(mob/user) // Hold nymph like petulant child...
	user.visible_message("<span class='notice'>[user] starts to squirm in [loc]'s hands!",
	"<span class='notice'>You start to squirm in [loc]'s hands...</span>")
	if(do_after(src, 8 SECONDS, user, NONE, TRUE))
		release()

/obj/item/clothing/head/mob_holder/nymph/microwave_act(obj/machinery/microwave/M)
	. = ..()
	M.muck()
	held_mob.adjustFireLoss(50)
	Destroy()
