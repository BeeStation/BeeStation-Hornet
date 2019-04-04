/datum/controller/subsystem/ticker/proc/sendtodiscord(var/survivors, var/escapees, var/integrity)
    var/list/discordmsg = list()
    discordmsg += "--------------ROUND END--------------"
    discordmsg += "Round Number: [GLOB.round_id]"
    discordmsg += "Duration:     [DisplayTimeText(world.time - SSticker.round_start_time)]"
    discordmsg += "Players:      [GLOB.player_list.len]"
    discordmsg += "Survivors:    [survivors]"
    discordmsg += "Escapees:     [escapees]"
    discordmsg += "Integrity:    [integrity]"
    discordmsg += "Gamemode:     [SSticker.mode.name]"
    var/list/ded = SSblackbox.first_death
    if(ded)
        discordmsg += "First Death:     [ded["name"]], [ded["role"]], at [ded["area"]]"
        discordmsg += "Damage taken:    [ded["damage"]]"
        var/last_words = ded["last_words"] ? "Their last words were: \"[ded["last_words"]]\"" : "They had no last words."
        discordmsg += "[last_words]"
    else
        discordmsg += "Nobody died!"
    discordmsg += "--------------------------------------"
    for(var/line in discordmsg)
        discordsendmsg("ooc", line)