/datum/controller/subsystem/ticker/proc/sendtodiscord(var/survivors, var/escapees, var/integrity)
    var/discordmsg = ""
    discordmsg += "--------------ROUND END--------------\n"
    discordmsg += "Round Number: [GLOB.round_id]\n"
    discordmsg += "Duration: [DisplayTimeText(world.time - SSticker.round_start_time)]\n"
    discordmsg += "Players: [GLOB.player_list.len]\n"
    discordmsg += "Survivors: [survivors]\n"
    discordmsg += "Escapees: [escapees]\n"
    discordmsg += "Integrity: [integrity]\n"
    discordmsg += "Gamemode: [SSticker.mode.name]\n"
	discordsendmsg("ooc", discordmsg)
	discordmsg = ""
    var/list/ded = SSblackbox.first_death
    if(ded)
        discordmsg += "First Death: [ded["name"]], [ded["role"]], at [ded["area"]]\n"
        var/last_words = ded["last_words"] ? "Their last words were: \"[ded["last_words"]]\"\n" : "They had no last words.\n"
        discordmsg += "[last_words]\n"
    else
        discordmsg += "Nobody died!\n"
    discordmsg += "--------------------------------------\n"
    discordsendmsg("ooc", discordmsg)
