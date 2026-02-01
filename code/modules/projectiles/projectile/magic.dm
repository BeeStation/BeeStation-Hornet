/obj/projectile/magic
	name = "bolt of nothing"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	armour_penetration = 100
	armor_flag = NONE
	martial_arts_no_deflect = TRUE
	/// determines what type of antimagic can block the spell projectile
	var/antimagic_flags = MAGIC_RESISTANCE
	/// determines the drain cost on the antimagic item
	var/antimagic_charge_cost = 1

/obj/projectile/magic/prehit_pierce(atom/target)
	. = ..()

	if(isliving(target))
		var/mob/living/victim = target
		if(victim.can_block_magic(antimagic_flags))
			visible_message(("<span class='warning'>[src] fizzles on contact with [victim]!</span>"))
			return PROJECTILE_DELETE_WITHOUT_HITTING

/obj/projectile/magic/burger
	name = "bolt of nutrition"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "bigbiteburger"
	hitsound = 'sound/weapons/bite.ogg'

/obj/projectile/magic/burger/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!isliving(target))
		return
	var/mob/living/chubbs = target

//If you're remotely hungry, you're safe. If you are not hungry, you're fat now.
	if(chubbs.nutrition <= NUTRITION_LEVEL_FED)
		chubbs.nutrition = NUTRITION_LEVEL_WELL_FED
	else
		chubbs.nutrition += 250

/obj/projectile/magic/death
	name = "bolt of death"
	icon_state = "pulse1_bl"

/obj/projectile/magic/death/on_hit(mob/living/target)
	. = ..()
	if(isliving(target))
		target.death()

/obj/projectile/magic/prison_orb
	name = "arcane prison"
	icon_state = "prison_orb"
	martial_arts_no_deflect = TRUE
	speed = 3
	var/captured = FALSE

/obj/projectile/magic/prison_orb/prehit_pierce(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/victim = target
		var/obj/structure/prison_orb/new_prison = new(get_turf(victim))
		victim.forceMove(new_prison) //They are now inside of the bubble
		new_prison.update_icon()
		captured = TRUE
		return PROJECTILE_DELETE_WITHOUT_HITTING

/obj/projectile/magic/prison_orb/Destroy()
	if(!captured)
		new /obj/effect/temp_visual/prison_burst(loc)
		playsound(loc, 'sound/magic/repulse.ogg', 35, TRUE)
	return ..()

/obj/structure/prison_orb
	name = "arcane prison"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "prison_orb"
	max_integrity = 45 //It only lasts a few seconds, but can be broken a bit faster if desired
	density = TRUE
	var/pop_effect = /obj/effect/temp_visual/prison_burst

/obj/structure/prison_orb/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, take_damage), max_integrity, BRUTE, "", FALSE), 10 SECONDS)

/obj/structure/prison_orb/update_icon(updates)
	cut_overlays()
	for(var/atom/movable/something as anything in contents)
		if(isliving(something))
			var/image/victim_overlay = image(something.icon, something.icon_state)
			victim_overlay.copy_overlays(something)
			add_overlay(victim_overlay)
	add_overlay("prison_orb_overlay")
	return ..()

/obj/structure/prison_orb/Destroy()
	var/turf/dropturf = get_turf(src)
	for(var/atom/movable/something as anything in contents)
		if(isliving(something))
			var/mob/living/victim = something
			victim.Knockdown(3 SECONDS)
		something.forceMove(dropturf) //Just in case they dropped something inside.
	new /obj/effect/temp_visual/prison_burst(dropturf)
	return ..()

/obj/effect/temp_visual/prison_burst
	name = "prison orb"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "prison_orb_burst"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 3

/obj/projectile/magic/dismember
	name = "bolt of dismembering"
	icon_state = "scatterlaser"

/obj/projectile/magic/dismember/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/victim = target
	var/list/parts = list()
	var/obj/item/bodypart/chosen_limb

	for(var/obj/item/bodypart/limb in victim.bodyparts)
		if(istype(limb, /obj/item/bodypart/leg) || istype(limb, /obj/item/bodypart/arm))
			parts += limb

	//Progress toward nugget
	if(length(parts))
		chosen_limb = pick(parts)
	//Or pop the head off once we're there
	else
		chosen_limb = victim.get_bodypart(BODY_ZONE_HEAD)

	chosen_limb.dismember(BRUTE)

/obj/projectile/magic/drain
	name = "vitality draining stream"
	icon_state = "nothing"
	range = 7
	var/datum/beam/drain_beam

/obj/projectile/magic/drain/fire(angle, atom/direct_target)
	if(!firer)
		CRASH("Projectile [src] fired with no firer") //We don't even want any of the rest of this to play out if we don't have a firer
	drain_beam = firer.Beam(src, icon = 'icons/effects/beam.dmi', icon_state = "lifedrain", time = 10 SECONDS, maxdistance = 7, beam_color = COLOR_RED)
	return ..()

/obj/projectile/magic/drain/on_hit(mob/living/target, blocked, pierce_hit)
	. = ..()
	if(!isliving(target))
		return
	target.apply_status_effect(/datum/status_effect/life_drain, firer, fired_from)

/obj/projectile/magic/drain/Destroy()
	if(!QDELETED(drain_beam))
		QDEL_NULL(drain_beam)
	return ..()

/datum/status_effect/life_drain
	id = "life_drain"
	alert_type = null
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = 0.3 SECONDS
	duration = 10 SECONDS
	var/datum/beam/drain_beam
	var/mob/living/carbon/wizard
	var/obj/item/gun/magic/wand/drain/wand

/datum/status_effect/life_drain/on_creation(mob/living/new_owner, mob/living/firer, fired_from, duration_override)
	if(isnull(firer) || isnull(fired_from) || !iscarbon(firer) || !iscarbon(new_owner))
		qdel(src)
		return
	wizard = firer
	wand = fired_from
	wand.active_effect = src
	drain_beam = wizard.Beam(new_owner, icon = 'icons/effects/beam.dmi', icon_state = "lifedrain", time = 12 SECONDS, maxdistance = 7, beam_color = COLOR_RED)
	RegisterSignal(drain_beam, COMSIG_QDELETING, PROC_REF(end_drain))
	new_owner.visible_message(span_warningbold("[wizard] begins draining the life force from [new_owner]!"), span_warningbold("[wizard] is draining your life force! You need to get away from them to stop it!"))
	. = ..()

/datum/status_effect/life_drain/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/life_drain)

/datum/status_effect/life_drain/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/life_drain)

/datum/status_effect/life_drain/tick()
	if(!iscarbon(owner) || owner.stat > HARD_CRIT) //If they're dead or non-humanoid, this spell fails
		end_drain()
		return
	if(!iscarbon(wizard)) //You never know what might happen with wizards around
		end_drain()
		return

	if(HAS_TRAIT(owner, TRAIT_INCAPACITATED) || owner.stat)
		//If the victim is incapacitated, drain their health
		owner.take_overall_damage(1, 1, 5, updating_health = TRUE)
	else
		//If they aren't incapacitated yet, drain only their stamina
		owner.take_overall_damage(0, 0, 7, updating_health = TRUE)

	//Wizard heals at a steady rate over the duration of the spell regardless of the victim's state
	wizard.heal_overall_damage(1, 1, 5, updating_health = TRUE)

	//Weird beam visuals if it isn't redrawn due to the beam sending players into crit
	drain_beam.redrawing()

/datum/status_effect/life_drain/proc/end_drain()
	SIGNAL_HANDLER
	if(QDELING(src))
		return
	if(!QDELETED(drain_beam))
		QDEL_NULL(drain_beam)
	wand.active_effect = null
	qdel(src)

//This is a shameless combintion of sec temperature gun and gluon grenade code
/obj/projectile/magic/icy_blast
	name = "icy blast"
	icon_state = "ice_2"
	range = 8
	var/temperature = -100
	var/ground_freeze_range = 2 //radius, so a 5x5 area

/obj/projectile/magic/icy_blast/on_hit(atom/target, blocked, pierce_hit)
	if(iscarbon(target))
		var/mob/living/carbon/hit_mob = target
		var/thermal_protection = 1 - hit_mob.get_insulation_protection(hit_mob.bodytemperature + temperature)

		hit_mob.adjust_bodytemperature((thermal_protection * temperature) + temperature)
	. = ..()

/obj/projectile/magic/icy_blast/Destroy()
	//This isn't a hitsound because we want it to play regardless of hit
	playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 75, TRUE)
	for(var/turf/open/floor/F in view(ground_freeze_range,loc))
		F.MakeSlippery(TURF_WET_PERMAFROST, 1 MINUTES)
	return ..()

/obj/projectile/magic/healing
	name = "bolt of healing"
	icon_state = "ion"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	martial_arts_no_deflect = FALSE
	///Heal this much of each damage type if revival and limb regeneration aren't applicable
	var/amount_healed = 25

/obj/projectile/magic/healing/on_hit(mob/living/target)
	. = ..()
	if(!isliving(target))
		return

	if(target.suiciding)
		target.visible_message(span_warning("[target]'s body twitches a bit, but it seems the wand's magic is not powerful enough!"))
		return

	if(target.revive()) //This fails if the target is already alive, or if they have too much damage to be revived. Both cases we instead heal some damage.
		target.visible_message(span_notice("[target]'s body twitches and comes back to life!"))
		return

	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		var/limbs_to_heal = carbon_target.get_missing_limbs()

		if(length(limbs_to_heal))
			var/obj/item/bodypart/limb = pick(limbs_to_heal)
			carbon_target.regenerate_limb(limb)
			target.visible_message(span_notice("[carbon_target]'s [carbon_target.get_bodypart(limb)] miraculously regrows!"))
			return

		else
			carbon_target.regenerate_organs() //slap this on top of the "generic" healing done if no limbs are missing and they aren't dead
			carbon_target.restore_blood()

	target.adjustOxyLoss(-amount_healed)
	target.adjustBruteLoss(-amount_healed)
	target.adjustFireLoss(-amount_healed)
	target.adjustToxLoss(-amount_healed)
	target.adjustCloneLoss(-amount_healed)
	target.adjustStaminaLoss(-amount_healed*2)
	target.visible_message(span_notice("[target]'s wounds close before your eyes!"))

/obj/projectile/magic/potential
	name = "bolt of latent potential"
	icon_state = "ion"
	var/good_mutation_list = list()
	var/bad_mutation_list = list()
	var/minor_mutation_list = list()

/obj/projectile/magic/potential/Initialize(mapload)
	. = ..()
	//Populate our mutation lists
	for(var/mutation as anything in GLOB.all_mutations)
		var/datum/mutation/initialized_mutation = GET_INITIALIZED_MUTATION(mutation)
		switch(initialized_mutation.quality)
			if(POSITIVE)
				if(!length(initialized_mutation.species_allowed)) //Skip these, we only want universal mutations on this list
					good_mutation_list += initialized_mutation
			if(NEGATIVE)
				if(!istype(initialized_mutation, /datum/mutation/race)) //No monkey in our bad mutations. Staff of change already does this.
					bad_mutation_list += initialized_mutation
			if(MINOR_NEGATIVE)
				minor_mutation_list += initialized_mutation

/obj/projectile/magic/potential/on_hit(mob/living/target)
	if(!iscarbon(target))
		target.visible_message(span_notice("[src] seems to have no effect on [target]!"))
		return

	var/mob/living/carbon/carbon_target = target
	if(!carbon_target.can_mutate())
		target.visible_message(span_notice("[src] seems to have no effect on [carbon_target]!"))
		return

	if(HAS_TRAIT(carbon_target, TRAIT_POTENTIAL_UNLOCKED))
		carbon_target.dna.remove_all_mutations() //Yes even the ones not from the staff
		REMOVE_TRAIT(carbon_target, TRAIT_POTENTIAL_UNLOCKED, MAGIC_TRAIT)
		target.visible_message(span_notice("The hidden potential of [carbon_target] fades away!"))

	else
		var/mutations_to_add = list()
		if(!istype(carbon_target.dna.species.inert_mutation, /datum/mutation/dwarfism) && prob(50)) //if they have an innate species mutation, 50% chance to pick it
			mutations_to_add += carbon_target.dna.species.inert_mutation
		else
			mutations_to_add += pick(good_mutation_list)

		if(!IS_WIZARD(carbon_target)) //Wizards only get the good ones
			mutations_to_add += pick(bad_mutation_list)
			mutations_to_add += pick(minor_mutation_list)

		for(var/datum/mutation/mutation in mutations_to_add)
			mutation.mutadone_proof = FALSE //We want mutadone to be effective regardless of what was pulled
			if(carbon_target.dna.mutation_in_sequence(mutation))
				carbon_target.dna.activate_mutation(mutation)
			else
				carbon_target.dna.add_mutation(mutation, MUT_EXTRA)

		ADD_TRAIT(carbon_target, TRAIT_POTENTIAL_UNLOCKED, MAGIC_TRAIT)
		target.visible_message(span_notice("[target] glows for a brief moment as the magic is absorbed into them!"))
	return ..()

/obj/projectile/magic/teleport
	name = "bolt of teleportation"
	icon_state = "bluespace"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	martial_arts_no_deflect = FALSE
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6

/obj/projectile/magic/teleport/on_hit(mob/target)
	. = ..()
	var/teleammount = 0
	var/teleloc = target
	if(!isturf(target))
		teleloc = target.loc
	for(var/atom/movable/stuff in teleloc)
		if(!stuff.anchored && stuff.loc && !isobserver(stuff))
			if(do_teleport(stuff, stuff, 10, channel = TELEPORT_CHANNEL_MAGIC))
				teleammount++
				var/datum/effect_system/smoke_spread/smoke = new
				smoke.set_up(max(round(4 - teleammount),0), stuff.loc) //Smoke drops off if a lot of stuff is moved for the sake of sanity
				smoke.start()

/obj/projectile/magic/door
	name = "bolt of door creation"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	var/list/door_types = list(/obj/structure/mineral_door/wood, /obj/structure/mineral_door/iron, /obj/structure/mineral_door/copper, /obj/structure/mineral_door/silver, /obj/structure/mineral_door/gold, /obj/structure/mineral_door/uranium, /obj/structure/mineral_door/sandstone, /obj/structure/mineral_door/transparent/plasma, /obj/structure/mineral_door/transparent/diamond)

/obj/projectile/magic/door/on_hit(atom/target)
	. = ..()
	if(istype(target, /obj/machinery/door))
		OpenDoor(target)
	else
		var/turf/T = get_turf(target)
		if(isclosedturf(T) && !isindestructiblewall(T))
			CreateDoor(T)

/obj/projectile/magic/door/proc/CreateDoor(turf/T)
	var/door_type = pick(door_types)
	var/obj/structure/mineral_door/D = new door_type(T)
	T.ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	D.Open()

/obj/projectile/magic/door/proc/OpenDoor(obj/machinery/door/D)
	if(istype(D, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = D
		A.locked = FALSE
	D.open()

/obj/projectile/magic/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	martial_arts_no_deflect = FALSE
	/// If set, this projectile will only do a certain wabbajack effect
	var/set_wabbajack_effect
	/// If set, this projectile will only pass certain changeflags to wabbajack
	var/set_wabbajack_changeflags

/obj/projectile/magic/change/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/victim = target
		victim.wabbajack(set_wabbajack_effect, set_wabbajack_changeflags)

/obj/projectile/magic/animate
	name = "bolt of animation"
	icon_state = "red_1"
	damage = 0
	damage_type = BURN
	nodamage = TRUE

/obj/projectile/magic/animate/on_hit(atom/target, blocked = FALSE)
	. = ..()
	target.animate_atom_living(firer)

/atom/proc/animate_atom_living(mob/living/owner = null)
	if((isitem(src) || isstructure(src)) && !is_type_in_list(src, GLOB.protected_objects))
		if(istype(src, /obj/structure/statue/petrified))
			var/obj/structure/statue/petrified/P = src
			if(P.petrified_mob)
				var/mob/living/L = P.petrified_mob
				var/mob/living/simple_animal/hostile/statue/S = new(P.loc, owner)
				S.name = "statue of [L.name]"
				if(owner)
					S.faction = list("[REF(owner)]")
				S.icon = P.icon
				S.icon_state = P.icon_state
				S.copy_overlays(P, TRUE)
				S.color = P.color
				S.atom_colours = P.atom_colours.Copy()
				if(L.mind)
					L.mind.transfer_to(S)
					if(owner)
						to_chat(S, span_userdanger("You are an animate statue. You cannot move when monitored, but are nearly invincible and deadly when unobserved! Do not harm [owner], your creator."))
				P.forceMove(S)
				return
		else
			var/obj/O = src
			if(istype(O, /obj/item/gun))
				new /mob/living/simple_animal/hostile/mimic/copy/ranged(loc, src, owner)
			else
				new /mob/living/simple_animal/hostile/mimic/copy(loc, src, owner)

	else if(istype(src, /mob/living/simple_animal/hostile/mimic/copy))
		// Change our allegiance!
		var/mob/living/simple_animal/hostile/mimic/copy/C = src
		if(owner)
			C.ChangeOwner(owner)

/obj/projectile/magic/spellblade
	name = "blade energy"
	icon_state = "lavastaff"
	damage = 15
	damage_type = BURN
	dismemberment = 50
	nodamage = FALSE
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/arcane_barrage
	name = "arcane bolt"
	icon_state = "arcane_barrage"
	damage = 20
	damage_type = BURN
	nodamage = FALSE
	hitsound = 'sound/weapons/barragespellhit.ogg'
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/locker
	name = "locker bolt"
	icon_state = "locker"
	nodamage = TRUE
	martial_arts_no_deflect = FALSE
	var/weld = TRUE
	var/created = FALSE //prevents creation of more then one locker if it has multiple hits
	var/locker_suck = TRUE
	var/datum/weakref/locker_ref

/obj/projectile/magic/locker/Initialize(mapload)
	. = ..()
	var/obj/structure/closet/decay/locker_temp_instance = new(src)
	locker_ref = WEAKREF(locker_temp_instance)

/obj/projectile/magic/locker/prehit_pierce(atom/A)
	. = ..()
	if(. == PROJECTILE_DELETE_WITHOUT_HITTING)
		var/obj/structure/closet/decay/locker_temp_instance = locker_ref.resolve()
		qdel(locker_temp_instance)
		return PROJECTILE_DELETE_WITHOUT_HITTING

	if(isliving(A) && locker_suck)
		var/mob/living/target = A
		var/obj/structure/closet/decay/locker_temp_instance = locker_ref.resolve()
		if(!locker_temp_instance?.insertion_allowed(target))
			return
		target.forceMove(src)
		return PROJECTILE_PIERCE_PHASE

/obj/projectile/magic/locker/on_hit(target)
	if(created)
		return ..()
	var/obj/structure/closet/decay/C = new(get_turf(src))
	if(LAZYLEN(contents))
		for(var/atom/movable/AM in contents)
			AM.forceMove(C)
		C.welded = TRUE
		C.update_icon()
	created = TRUE
	return ..()

/obj/projectile/magic/locker/Destroy()
	locker_suck = FALSE
	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(src))
	. = ..()

/obj/structure/closet/decay
	breakout_time = 600
	icon_welded = null
	material_drop_amount = 0
	var/magic_icon = "cursed"
	var/weakened_icon = "decursed"
	icon_door = "cursed"
	var/weakened_icon_door = "decursed"

/obj/structure/closet/decay/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(locker_magic_timer)), 5)

/obj/structure/closet/decay/proc/locker_magic_timer()
	if(welded)
		addtimer(CALLBACK(src, PROC_REF(bust_open)), 5 MINUTES)
		icon_state = magic_icon
		update_icon()
	else
		addtimer(CALLBACK(src, PROC_REF(decay)), 15 SECONDS)

/obj/structure/closet/decay/after_weld(weld_state)
	if(weld_state)
		unmagify()

/obj/structure/closet/decay/proc/decay()
	animate(src, alpha = 0, time = 30)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), 30)

/obj/structure/closet/decay/open(mob/living/user, force, special_effects)
	. = ..()
	if(.)
		if(icon_state == magic_icon) //check if we used the magic icon at all before giving it the lesser magic icon
			unmagify()
		else
			addtimer(CALLBACK(src, PROC_REF(decay)), 15 SECONDS)

/obj/structure/closet/decay/proc/unmagify()
	icon_state = weakened_icon
	icon_door = weakened_icon_door
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(decay)), 15 SECONDS)

/obj/projectile/magic/flying
	name = "bolt of flying"
	icon_state = "flight"
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/flying/on_hit(mob/living/target)
	. = ..()
	if(isliving(target))
		var/atom/throw_target = get_edge_target_turf(target, angle2dir(Angle))
		target.throw_at(throw_target, 200, 4)

/obj/projectile/magic/bounty
	name = "bolt of bounty"
	icon_state = "bounty"
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/bounty/on_hit(mob/living/target)
	. = ..()
	if(isliving(target))
		target.apply_status_effect(/datum/status_effect/bounty, firer)

/obj/projectile/magic/antimagic
	name = "bolt of antimagic"
	icon_state = "antimagic"
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/antimagic/on_hit(mob/living/target)
	. = ..()
	if(isliving(target))
		target.apply_status_effect(/datum/status_effect/antimagic)

/obj/projectile/magic/fetch
	name = "bolt of fetching"
	icon_state = "fetch"
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/fetch/on_hit(mob/living/target)
	. = ..()
	if(isliving(target))
		var/atom/throw_target = get_edge_target_turf(target, get_dir(target, firer))
		target.throw_at(throw_target, 200, 4)

/obj/projectile/magic/sapping
	name = "bolt of sapping"
	icon_state = "sapping"
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/sapping/on_hit(mob/living/target)
	. = ..()
	if(isliving(target))
		SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, REF(src), /datum/mood_event/sapped)

/obj/projectile/magic/necropotence
	name = "bolt of necropotence"
	icon_state = "necropotence"
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/necropotence/on_hit(target)
	. = ..()
	if(!isliving(target))
		return

	// Performs a soul tap on living targets hit.
	// Takes away max health, but refreshes their spell cooldowns (if any)
	var/datum/action/spell/tap/tap = new(src)
	if(tap.is_valid_spell(target, target))
		tap.on_cast(target, target)

	qdel(tap)

/obj/projectile/magic/wipe
	name = "bolt of possession"
	icon_state = "wipe"
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/wipe/on_hit(mob/living/carbon/target)
	. = ..()
	if(iscarbon(target))
		for(var/x in target.get_traumas())//checks to see if the victim is already going through possession
			if(istype(x, /datum/brain_trauma/special/imaginary_friend/trapped_owner))
				target.visible_message(span_warning("[src] vanishes on contact with [target]!"))
				return BULLET_ACT_BLOCK
		to_chat(target, span_warning("Your mind has been opened to possession!"))
		possession_test(target)
		return BULLET_ACT_HIT

/obj/projectile/magic/wipe/proc/possession_test(mob/living/carbon/M)
	var/datum/brain_trauma/special/imaginary_friend/trapped_owner/trauma = M.gain_trauma(/datum/brain_trauma/special/imaginary_friend/trapped_owner)
	var/poll_message = "Do you want to play as [M.real_name]?"
	var/ban_key = BAN_ROLE_ALL_ANTAGONISTS
	if(M.mind?.assigned_role)
		poll_message = "[poll_message] Job:[M.mind.assigned_role]."
	if(M.mind?.special_role)
		poll_message = "[poll_message] Status:[M.mind.special_role]."
	else if(M.mind)
		var/datum/antagonist/A = M.mind.has_antag_datum(/datum/antagonist)
		if(A)
			poll_message = "[poll_message] Status:[A.name]."
			ban_key = A.banning_key
	var/datum/poll_config/config = new()
	config.question = poll_message
	config.check_jobban = ban_key
	config.poll_time = 10 SECONDS
	config.jump_target = M
	config.role_name_text = "ghost possession"
	config.alert_pic = M
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_for_target(config, M)
	if(M.stat == DEAD)//boo.
		return
	if(candidate)
		var/oldkey = M.key
		M.ghostize(FALSE)
		M.key = candidate.key

		trauma.friend.key = oldkey
		trauma.friend.reset_perspective(null)
		trauma.friend.Show()
		trauma.friend_initialized = TRUE

		to_chat(M, "You have been noticed by a ghost, and it has possessed you!")
	else
		to_chat(M, span_notice("Your mind has managed to go unnoticed in the spirit world."))
		qdel(trauma)

/// Gives magic projectiles an area of effect radius that will bump into any nearby mobs
/obj/projectile/magic/aoe
	damage = 0

	/// The AOE radius that the projectile will trigger on people.
	var/trigger_range = 1
	/// Whether our projectile will only be able to hit the original target / clicked on atom
	var/can_only_hit_target = FALSE

	/// Whether our projectile leaves a trail behind it  as it moves.
	var/trail = FALSE
	/// The duration of the trail before deleting.
	var/trail_lifespan = 0 SECONDS
	/// The icon the trail uses.
	var/trail_icon = 'icons/obj/wizard.dmi'
	/// The icon state the trail uses.
	var/trail_icon_state = "trail"

/obj/projectile/magic/aoe/Range()
	if(trigger_range >= 1)
		for(var/mob/living/nearby_guy in range(trigger_range, get_turf(src)))
			if(nearby_guy.stat == DEAD)
				continue
			if(nearby_guy == firer)
				continue
			// Bump handles anti-magic checks for us, conveniently.
			return Bump(nearby_guy)

	return ..()

/obj/projectile/magic/aoe/can_hit_target(atom/target, list/passthrough, direct_target = FALSE, ignore_loc = FALSE)
	if(can_only_hit_target && target != original)
		return FALSE
	return ..()

/obj/projectile/magic/aoe/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(trail)
		create_trail()

/// Creates and handles the trail that follows the projectile.
/obj/projectile/magic/aoe/proc/create_trail()
	if(!trajectory)
		return

	var/datum/point/vector/previous = trajectory.return_vector_after_increments(1, -1)
	var/obj/effect/overlay/trail = new /obj/effect/overlay(previous.return_turf())
	trail.pixel_x = previous.return_px()
	trail.pixel_y = previous.return_py()
	trail.icon = trail_icon
	trail.icon_state = trail_icon_state
	//might be changed to temp overlay
	trail.set_density(FALSE)
	trail.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	QDEL_IN(trail, trail_lifespan)

/obj/projectile/magic/aoe/lightning
	name = "lightning bolt"
	icon_state = "tesla_projectile" //Better sprites are REALLY needed and appreciated!~
	damage = 15
	damage_type = BURN
	nodamage = FALSE
	speed = 0.3

	/// The power of the zap itself when it electrocutes someone
	var/zap_power = 20000
	/// The range of the zap itself when it electrocutes someone
	var/zap_range = 15
	/// The flags of the zap itself when it electrocutes someone
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_MOB_STUN | ZAP_OBJ_DAMAGE
	/// A reference to the chain beam between the caster and the projectile
	var/datum/beam/chain

/obj/projectile/magic/aoe/lightning/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "lightning[rand(1, 12)]")
	return ..()

/obj/projectile/magic/aoe/lightning/on_hit(target)
	. = ..()
	tesla_zap(src, zap_range, zap_power, zap_flags)

/obj/projectile/magic/aoe/lightning/Destroy()
	QDEL_NULL(chain)
	return ..()

/obj/projectile/magic/aoe/lightning/no_zap
	zap_power = 10000
	zap_range = 4
	zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE

/obj/projectile/magic/fireball
	name = "fireball"
	icon_state = "fireball"
	damage = 10
	damage_type = BURN
	nodamage = FALSE

	/// Heavy explosion range of the fireball
	var/exp_heavy = 0
	/// Light explosion range of the fireball
	var/exp_light = 2
	/// Fire radius of the fireball
	var/exp_fire = 2
	/// Flash radius of the fireball
	var/exp_flash = 3

/obj/projectile/magic/fireball/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	var/turf/target_turf = get_turf(target)
	explosion(
		target_turf,
		devastation_range = -1,
		heavy_impact_range = exp_heavy,
		light_impact_range = exp_light,
		flame_range = exp_fire,
		flash_range = exp_flash,
		adminlog = FALSE,
	)

///Fireball's little brother
/obj/projectile/magic/firebolt
	name = "bolt of fire"
	icon_state = "fireball"
	damage = 20 //Because this one doesn't do an actual explosion, direct hit damage is much higher
	damage_type = BURN
	nodamage = FALSE

/obj/projectile/magic/firebolt/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	var/turf/target_turf = get_turf(target)

	if(isliving(target))
		var/mob/living/target_mob = target
		target_mob.fire_stacks += 5 //One stop drop and roll can put this out, two if it spreads during the knockdown
		target_mob.ignite_mob()

	explosion(
		target_turf,
		devastation_range = -1,
		heavy_impact_range = -1,
		light_impact_range = -1,
		flame_range = 2,
		flash_range = 1,
		adminlog = FALSE,
	)

	//We don't want the damage from making a real explosion happen, but we do still want to send things flying. Good thing we have a global proc for that.
	goonchem_vortex(target_turf, 1, 3)


/obj/projectile/magic/aoe/magic_missile
	name = "magic missile"
	icon_state = "magicm"
	range = 20
	speed = 5
	trigger_range = 0
	can_only_hit_target = TRUE
	nodamage = FALSE
	paralyze = 6 SECONDS
	hitsound = 'sound/magic/mm_hit.ogg'

	trail = TRUE
	trail_lifespan = 0.5 SECONDS
	trail_icon_state = "magicmd"

/obj/projectile/magic/aoe/magic_missile/lesser
	color = "red" //Looks more culty this way
	range = 10

/obj/projectile/magic/aoe/juggernaut
	name = "Gauntlet Echo"
	icon_state = "cultfist"
	alpha = 180
	damage = 30
	damage_type = BRUTE
	knockdown = 50
	hitsound = 'sound/weapons/punch3.ogg'
	trigger_range = 0
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	ignored_factions = list("cult")
	range = 15
	speed = 7

/obj/projectile/magic/spell/juggernaut/on_hit(atom/target, blocked)
	. = ..()
	var/turf/target_turf = get_turf(src)
	playsound(target_turf, 'sound/weapons/resonator_blast.ogg', 100, FALSE)
	new /obj/effect/temp_visual/cult/sac(target_turf)
	for(var/obj/adjacent_object in range(1, src))
		if(!adjacent_object.density)
			continue
		if(istype(adjacent_object, /obj/structure/destructible/cult))
			continue

		adjacent_object.take_damage(90, BRUTE, MELEE, 0)
		new /obj/effect/temp_visual/cult/turf/floor(get_turf(adjacent_object))

//still magic related, but a different path

/obj/projectile/temp/chill
	name = "bolt of chills"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = FALSE
	armour_penetration = 100
	temperature = -200 // Cools you down greatly per hit
