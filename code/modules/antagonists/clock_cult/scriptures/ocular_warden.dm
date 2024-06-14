#define OCULAR_WARDEN_PLACE_RANGE 4
#define OCULAR_WARDEN_RANGE 3

/datum/clockcult/scripture/create_structure/ocular_warden
	name = "Ocular Warden"
	desc = "An eye turret that will fire upon nearby targets. Requires 2 invokers."
	tip = "Place these around to prevent crew from rushing past your defenses."
	button_icon_state = "Ocular Warden"
	power_cost = 400
	invokation_time = 50
	invokation_text = list("Summon thee to defend our temple")
	summoned_structure = /obj/structure/destructible/clockwork/ocular_warden
	cogs_required = 3
	invokers_required = 2
	category = SPELLTYPE_STRUCTURES

/datum/clockcult/scripture/create_structure/ocular_warden/check_special_requirements(mob/user)
	if(!..())
		return FALSE
	for(var/obj/structure/destructible/clockwork/structure in get_turf(invoker))
		to_chat(invoker, "<span class='brass'>You cannot invoke that here, the tile is occupied by [structure].</span>")
		return FALSE
	for(var/obj/structure/destructible/clockwork/ocular_warden/AC in range(OCULAR_WARDEN_PLACE_RANGE))
		to_chat(invoker, "<span class='nezbere'>There is another ocular warden nearby, placing them too close will cause them to fight!</span>")
		return FALSE
	return TRUE

/obj/structure/destructible/clockwork/ocular_warden
	name = "ocular warden"
	desc = "A wide, open eye that stares intently into your soul. It seems resistant to energy based weapons."
	clockwork_desc = "A defensive device that will fight any nearby intruders."
	break_message = "<span class='warning'>A black ooze leaks from the ocular warden as it slowly sinks to the ground.</span>"
	icon_state = "ocular_warden"
	max_integrity = 60
	armor = list(MELEE = -80,  BULLET = -50, LASER = 40, ENERGY = 40, BOMB = 20, BIO = 0, RAD = 0, STAMINA = 0)
	var/cooldown

/obj/structure/destructible/clockwork/ocular_warden/process(delta_time)
	//Can we fire?
	if(world.time < cooldown)
		return
	//Check hostiles in range
	var/list/valid_targets = list()
	for(var/mob/living/potential in hearers(OCULAR_WARDEN_RANGE, src))
		if(!is_servant_of_ratvar(potential) && !potential.stat)
			valid_targets += potential
	if(!LAZYLEN(valid_targets))
		return
	var/mob/living/target = pick(valid_targets)
	playsound(get_turf(src), 'sound/machines/clockcult/ocularwarden-target.ogg', 60, TRUE)
	if(!target)
		return
	dir = get_dir(get_turf(src), get_turf(target))
	target.apply_damage(max(10 - (get_dist(src, target)*2.5), 5)*delta_time, BURN)
	new /obj/effect/temp_visual/ratvar/ocular_warden(get_turf(target))
	new /obj/effect/temp_visual/ratvar/ocular_warden(get_turf(src))
	playsound(get_turf(target), 'sound/machines/clockcult/ocularwarden-dot1.ogg', 60, TRUE)
	cooldown = world.time + 20

/obj/structure/destructible/clockwork/ocular_warden/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/clockwork/ocular_warden/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

#undef OCULAR_WARDEN_PLACE_RANGE
