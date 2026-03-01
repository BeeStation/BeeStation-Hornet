/datum/clockcult/scripture/create_structure/ocular_warden
	name = "Ocular Warden"
	desc = "An eye turret that will fire upon nearby targets. Requires 2 invokers."
	tip = "Place these around to prevent crew from rushing past your defenses."
	invokation_text = list("Summon thee to defend our temple")
	invokation_time = 5 SECONDS
	invokers_required = 2
	button_icon_state = "Ocular Warden"
	power_cost = 400
	cogs_required = 3
	summoned_structure = /obj/structure/destructible/clockwork/ocular_warden
	category = SPELLTYPE_STRUCTURES

	/// How far the warden must be from other wardens
	var/place_range = 4

/datum/clockcult/scripture/create_structure/ocular_warden/can_invoke()
	. = ..()
	if(!.)
		return FALSE

	for(var/obj/structure/destructible/clockwork/ocular_warden/warden in range(place_range))
		invoker.balloon_alert(invoker, "too close to another warden!")
		return FALSE

/obj/structure/destructible/clockwork/ocular_warden
	name = "ocular warden"
	desc = "A wide, open eye that stares intently into your soul. It seems resistant to energy based weapons."
	clockwork_desc = span_brass("A defensive device that will fight any nearby intruders.")
	break_message = span_warning("A black ooze leaks from the ocular warden as it slowly sinks to the ground.")
	icon_state = "ocular_warden"
	max_integrity = 60
	armor_type = /datum/armor/clockwork_ocular_warden

	/// How long the warden must wait before attacking again
	var/cooldown = 2 SECONDS
	/// The range at which the warden can attack
	var/range = 3

	COOLDOWN_DECLARE(attack_cooldown)

/datum/armor/clockwork_ocular_warden
	melee = -80
	bullet = -50
	laser = 40
	energy = 40
	bomb = 20

/obj/structure/destructible/clockwork/ocular_warden/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/clockwork/ocular_warden/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/destructible/clockwork/ocular_warden/process(delta_time)
	if(!COOLDOWN_FINISHED(src, attack_cooldown))
		return

	// Select a target
	var/list/valid_targets = list()
	for(var/mob/living/potential_target in viewers(range, src))
		if(IS_SERVANT_OF_RATVAR(potential_target))
			continue
		if(potential_target.stat != CONSCIOUS)
			continue

		valid_targets += potential_target

	if(!length(valid_targets))
		return

	COOLDOWN_START(src, attack_cooldown, cooldown)

	var/mob/living/target = pick(valid_targets)

	// Face target and apply burn
	dir = get_dir(get_turf(src), get_turf(target))
	target.apply_damage(max(10 - get_dist(src, target) * 2.5, 5) * delta_time, BURN)

	// Visual effects and sounds
	new /obj/effect/temp_visual/ratvar/ocular_warden(get_turf(target))
	playsound(get_turf(target), 'sound/machines/clockcult/ocularwarden-dot1.ogg', 60, TRUE)

	new /obj/effect/temp_visual/ratvar/ocular_warden(get_turf(src))
	playsound(get_turf(src), 'sound/machines/clockcult/ocularwarden-target.ogg', 60, TRUE)
