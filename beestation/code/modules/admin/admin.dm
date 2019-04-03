/datum/admins/announce()
    ..()
    discordsendmsg("ooc", "***[usr.client.holder.fakekey ? "Administrator" : usr.key] Announces:***\n          [message]"")