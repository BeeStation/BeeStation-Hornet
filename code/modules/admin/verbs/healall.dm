/client/proc/healall()
    set name = "Heal Everybody"
    set desc = "Heals every mob in the game"
    set category = "Fun"
    if(!src.holder)
        to_chat(src, "Only administrators may use this command.")
        return
    if(!check_rights(R_FUN))
        to_chat(src, "You need the fun permission to use this command.")
        return
    message_admins("[key_name_admin(usr)] healed all mobs")
    to_chat(world, "<b>The gods have miraculously given everyone new life!</b>")
    for(var/mob/living/M in world)
        M.revive(TRUE, TRUE)