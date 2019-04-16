/obj/item/clothing/neck/necklace/dope/cursed
    var/datum/mind/linked_mind = null
    var/datum/mind/hostage_mind = null
    var/mob/current_body = null

/obj/item/clothing/neck/necklace/dope/cursed/attack_self(mob/user)
    . = ..()
    if(!linked_mind && user.mind)
        linked_mind = user.mind
        current_body = user
        to_chat(user, "<b>You have achieved immortality</b>")

/obj/item/clothing/neck/necklace/dope/cursed/equipped(mob/user, slot)
    . = ..()
    var/datum/mind/u_mind = user.mind
    if(slot == SLOT_NECK && linked_mind && user.mind != linked_mind)
        if(user.mind && user.mind != linked_mind)
            hostage_mind = user.mind
            user.ghostize(0)
        linked_mind.transfer_to(user)
        current_body = user

/obj/item/clothing/neck/necklace/dope/cursed/dropped(mob/user)
    . = ..()
    if(hostage_mind)
        if(user.mind)
            user.ghostize(0)
        hostage_mind.transfer_to(user)
        current_body = null