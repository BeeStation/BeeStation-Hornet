/proc/forcecryo(mob/target)
    var/turf/T = get_turf(target)
    new /obj/effect/temp_visual/tornado(T)
    sleep(20)
    var/obj/machinery/cryopod/C = new /obj/machinery/cryopod(T)
    target.invisibility = INVISIBILITY_MAXIMUM
    C.invisibility = INVISIBILITY_MAXIMUM
    C.close_machine(target)
    C.despawn_occupant()
    qdel(C)
    