/datum/controller/subsystem/ticker/gather_roundend_feedback()
    ..()  // kind of shitcode, but this sort of thing is split into little bite-size chunks so it can be shoved in a url
    var/discordmsg = "--------------ROUND END--------------\n"
    discordmsg += "Round Number: [GLOB.round_id]\n"
    discordmsg += "Duration:     [DisplayTimeText(world.time - SSticker.round_start_time)]\n"
    discordmsg += "Players:      [GLOB.player_list.len]\n"
    discordmsg += "Survivors:    [.[POPCOUNT_SURVIVORS]]"
    discordsendmsg("ooc", discordmsg)
    discordmsg = "Escapees:     [.[POPCOUNT_ESCAPEES]]\n"
    discordmsg += "Integrity:    [.["station_integrity"]]\n"
    discordmsg += "Gamemode:     [SSticker.mode.name]\n"
    discordsendmsg("ooc", discordmsg)
    var/list/ded = SSblackbox.first_death
    discordmsg = ""
    if(ded)
        discordmsg += "First Death:     [ded["name"]], [ded["role"]], at [ded["area"]]\n"
        discordmsg += "Damage taken:    [ded["damage"]]\n"
        var/last_words = ded["last_words"] ? "Their last words were: \"[ded["last_words"]]\"" : "They had no last words."
        discordmsg += "[last_words]"
    else
        discordmsg += "Nobody died!"
    discordsendmsg("ooc", discordmsg)
    discordmsg = "--------------------------------------"
    discordsendmsg("ooc", discordmsg)
