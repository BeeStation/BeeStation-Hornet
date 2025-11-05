/datum/vampire_clan/toreador
	name = CLAN_TOREADOR
	description = "The Toreador are a clan of vampires known for being some of the most beautiful, sensual, seductive, emotional and glamorous of the Kindred.<br><br>\
		Responsible for the legends of vampires who seduce and entice their prey with beauty, love and sensuality. Famous and infamous as a clan of artists and innovators, they are one of the bastions of the Camarilla, as their very survival depends on the facades of civility and grace on which the sect prides itself. <br><br>\
		They are inherently divas by blood, and their humanity and sense of morality may plummit as fast as it rises."
	join_icon_state = "toreador"
	join_description = "Artists, Pleasure-workers, Celebrities. These are the people of the toreador clan. They are by far the closest to humanity of all kindred, each a deeply sensitive individual.\n\
		<b>DISCIPLINES:</b> Presence, Auspex, Celerity"
	blood_drink_type = VAMPIRE_DRINK_SNOBBY
	default_humanity = 9
	joinable_clan = TRUE

/datum/vampire_clan/toreador/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	vampiredatum.owned_disciplines += new /datum/discipline/celerity(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/potence(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/presence(vampiredatum)
