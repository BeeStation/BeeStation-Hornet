/mob/living/carbon/human/verb/Give(var/mob/living/carbon/human/l in view(1))
    set category = "Object"
    set name = "Give"
    set desc = "Give whatever's in your hand to someone."
    
    var/obj/item/i = usr.get_active_held_item()

    if(src == usr || !istype(l))
        return
    if(!i)
        to_chat(usr, "You must be holding your gift in your active hand.")
        return
    if(alert(l, "[usr] is trying to give you \the [i], will you accept?", "Yes", "No") == "No")
        to_chat(usr, "[l] didn't accept \the [i].")
        return

    l.put_in_hands(i)

    