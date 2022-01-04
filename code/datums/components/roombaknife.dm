//Roombas With Knives
/datum/component/roombaknife
    dupe_mode = COMPONENT_DUPE_ALLOWED
    var/knife_damage
    var/cooldown

/datum/component/roombaknife/Initialize(damage = 0)
    knife_damage = damage
    RegisterSignal(parent, COMSIG_MOVABLE_BUMP, .proc/knife_collide)
    RegisterSignal(parent, COMSIG_ATOM_ENTERED, .proc/knife_crossed)
    RegisterSignal(parent, COMSIG_ROOMBA_DESTROY, .proc/roomba_destroyed)

/datum/component/roombaknife/proc/stab(mob/living/carbon/C)
    if(istype(C) && cooldown <= world.time)
        var/atom/movable/P = parent
        var/leg
        if(prob(50))
            leg = LEG_RIGHT
        else
            leg = LEG_LEFT
        C.apply_damage(netdamage, BRUTE, blocked = def_check)
		P.visible_message("<span class='warning'>[C.name] is stabbed in the leg by [P.name].</span>")
		playsound(get_turf(P), 'sound/weapons/slice.ogg', 50, 1)
		cooldown = (world.time + 8) //spike cooldown is equal to default unarmed attack speed

/datum/component/roombaknife/proc/knife_collide()
    return

/datum/component/roombaknife/proc/knife_crossed()
    return

/datum/component/roombaknife/proc/roomba_destroyed()
    qdel(src) //No more!!