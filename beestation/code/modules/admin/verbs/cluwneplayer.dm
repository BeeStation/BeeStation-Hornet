/mob/living/carbon/human/proc/cluwne()
    for(var/obj/item/W in src)  // they drop everything they have
        if(!dropItemToGround(W))
            qdel(W)
            regenerate_icons()
    
    var/datum/mind/M = mind

    var/mob/living/simple_animal/cluwne/newmob =  new(get_turf(src))

    M.transfer_to(newmob)
    if(key)  // afk (no mind)
        newmob.key = key

    qdel(src)