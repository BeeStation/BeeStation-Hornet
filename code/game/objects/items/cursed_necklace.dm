/obj/item/clothing/neck/necklace/dope/cursed
    var/linked_ckey
    var/hostage_ckey
    var/mob/current_body = null

/obj/item/clothing/neck/necklace/dope/cursed/attack_self(mob/user)
    . = ..()
    if(!user.ckey)
        return 0
    if(!linked_ckey && user.ckey)
        linked_ckey = user.ckey
        current_body = user
        to_chat(user, "<b>You have achieved immortality</b>")

/obj/item/clothing/neck/necklace/dope/cursed/equipped(mob/user, slot)
    . = ..()
    if(slot == ITEM_SLOT_NECK && linked_ckey && user.ckey != linked_ckey)
        if(user.ckey && user.ckey == linked_ckey)
            hostage_ckey = user.ckey
            user.ghostize(FALSE,SENTIENCE_ERASE)
        user.ckey = linked_ckey
        current_body = user

/obj/item/clothing/neck/necklace/dope/cursed/dropped(mob/user)
    . = ..()
    if(hostage_ckey)
        if(user.ckey)
            user.ghostize(FALSE,SENTIENCE_ERASE)
        user.ckey = hostage_ckey
        current_body = null