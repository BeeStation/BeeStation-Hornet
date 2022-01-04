//Roombas With Knives
/datum/component/roombaknife
    dupe_mode = COMPONENT_DUPE_ALLOWED
    var/knife_damage
    var/cooldown

    var/static/list/default_connections = list(
		COMSIG_ATOM_ENTERED = .proc/knife_crossed,
	)

/datum/component/roombaknife/Initialize(damage = 0)
    knife_damage = damage
    RegisterSignal(parent, COMSIG_ATOM_ENTERED, .proc/knife_crossed)
    RegisterSignal(parent, COMSIG_ROOMBA_DESTROY, .proc/roomba_destroyed)
    add_connect_loc_behalf_to_parent()

/datum/component/roombaknife/proc/add_connect_loc_behalf_to_parent()
	if(ismovable(parent))
		AddComponent(/datum/component/connect_loc_behalf, parent, default_connections)

/datum/component/roombaknife/proc/stab(mob/living/carbon/C)
    if(istype(C) && cooldown <= world.time)
        var/atom/movable/P = parent
        var/leg
        if(prob(50))
            leg = BODY_ZONE_R_LEG
        else
            leg = BODY_ZONE_L_LEG
        C.apply_damage(knife_damage, BRUTE, leg)
        P.visible_message("<span class='warning'>[C.name] is stabbed in the leg by [P.name].</span>")
        playsound(get_turf(P), 'sound/weapons/slice.ogg', 50, 1)
        cooldown = (world.time + 8) //Knife cooldown is equal to default unarmed attack speed

/datum/component/roombaknife/proc/knife_crossed(datum/source, atom/movable/M, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(iscarbon(M))
		var/mob/living/carbon/C = M
		stab(C)

/datum/component/roombaknife/proc/roomba_destroyed()
    qdel(src) //No more!!
