/mob/living/carbon/human/verb/Give(var/mob/living/carbon/human/l in view(1))
    set category = "Object"
    set name = "Give"
    set desc = "Give whatever's in your hand to someone."

    var/obj/item/i = usr.get_active_held_item()

    if(src == usr || !istype(l))
        return
    if(!i)
        to_chat(usr, "<span class='notice'>You must be holding your gift in your active hand.</span>")
        return
    if(alert(l, "[usr] is trying to give you \the [i], will you accept?", "Yes", "No") == "No")
        to_chat(usr, "[l] didn't accept \the [i].")
        return

    if(!(usr in range(1, src))) // so if they walk away with the alert window open, it doesnt teleport
        to_chat(usr, "<span class='notice'>You're too far away!</span>")
        return

    l.put_in_hands(i)

/mob/living/carbon/human/CtrlShiftClickOn(var/mob/living/carbon/human/l in view(1))
    ..()
    Give(l)


