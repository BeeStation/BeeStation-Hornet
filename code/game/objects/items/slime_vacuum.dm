//Tool to move slimes around
//code\game\objects\items\slime_vacuum.dm
/obj/item/slime_gun
	name = "slime vacuum"
	desc = "It really sucks."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "slimegun"
	///Maximum distance a slime can be picked up from
	var/max_distance_input = 6
	///Maximum distance a slime can be placed down from
	var/max_distance_output = 3
	///Max capacity for how many slimes we can hold
	var/max_capacity = 3
	///List of mobs we can succ
	var/list/store_blacklist

/obj/item/slime_gun/Initialize(mapload)
	. = ..()
	store_blacklist = typecacheof(/mob/living/simple_animal/slime)

/obj/item/slime_gun/examine(mob/user)
	to_chat(user, "<span class='notice'>[contents.len ? "The vacuum contains [contents.len] slimes" : "The vacuum is empty"]</span>")
	. = ..()

/obj/item/slime_gun/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(is_type_in_typecache(target, store_blacklist) && get_dist(get_turf(src), get_turf(target)) < max_distance_input && contents.len < max_capacity) //inhale
		var/atom/movable/AM = target
		AM.throw_at(get_turf(src), get_dist(get_turf(src), get_turf(target)), 1, force = MOVE_FORCE_EXTREMELY_WEAK)
		RegisterSignal(AM, COMSIG_MOVABLE_IMPACT, .proc/inhale, AM)
	else if(isturf(target) && contents.len && get_dist(get_turf(src), target) < max_distance_output) //exhale
		var/atom/movable/AM = contents[contents.len]
		AM.forceMove(get_turf(target))
	else if(contents.len >= max_capacity)
		to_chat(user, "<span class='warning'>The vacuum is full!</span>")

///move targets inside the gun
/obj/item/slime_gun/proc/inhale(atom/movable/target)
	if(get_dist(get_turf(src), get_turf(target)) <= 1)
		target?.forceMove(src)
