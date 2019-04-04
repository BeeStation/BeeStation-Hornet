/datum/controller/subsystem/ticker/gather_roundend_feedback()
    ..()
    var/list/discordmsg = list()
    discordmsg += "--------------ROUND END--------------"
    discordmsg += "Round Number: [GLOB.round_id]"
    discordmsg += "Duration:     [DisplayTimeText(world.time - SSticker.round_start_time)]"
    discordmsg += "Players:      [GLOB.player_list.len]"
    discordmsg += "Survivors:    [.[POPCOUNT_SURVIVORS]]"
    discordmsg += "Escapees:     [.[POPCOUNT_ESCAPEES]]"
    discordmsg += "Integrity:    [.["station_integrity"]]"
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