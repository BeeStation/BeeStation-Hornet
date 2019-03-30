/mob/verb/Give(var/mob/living/l)
    set category = "Object"
    set name = "Give"
    set desc = "Give whatever's in your hand to someone."
    set src in oview(1)
    var/obj/item/i = get_active_held_item()
    if(!istype(l))
        return
    if(!i)
        to_chat(src, "You must be holding your gift in your active hand.")
        return
    if(input(l, "[src] is trying to give you [i], will you accept?", "Yes", "No") == "No")
        to_chat(src, "[l] didn't accept [i].")
        return
    l.put_in_hands(i)
    
    