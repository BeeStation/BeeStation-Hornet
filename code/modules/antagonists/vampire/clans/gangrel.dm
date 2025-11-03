/datum/vampire_clan/gangrel
	name = CLAN_GANGREL
	description = "Often mistaken as werewolves, gangrel carry the smell of wet dog wherever they go.<br><br>\
		These Nomads who hold closer ties to the wild places than most of their city-bound cousins, are also closer to the animal aspect of the Beast, and are masters of the Protean Discipline.<br><br>\
		They were one of the seven founding clans of the Camarilla, but became disillusioned with the sect around 400 years ago, its elders eventually deciding to sever its ties and become an independent clan."
	join_icon_state = "gangrel"
	join_description = "Often mistaken as werewolves, gangrel carry the smell of wet dog wherever they go. Their unique bond with the beast within allows them to transform parts of their body into powerful claws, even becoming entirely different beings.\n\
		<b>DISCIPLINES:</b> Animalism, Protean, Fortitude"
	default_humanity = 2

/datum/vampire_clan/gangrel/New(datum/antagonist/vampire/owner_datum)
	. = ..()
