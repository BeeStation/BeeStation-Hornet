/datum/vampire_clan/ventrue
	name = CLAN_VENTRUE
	description = "The Ventrue have long been one of the proudest lines of vampires. Its members work hard to maintain a reputation for honor, genteel behavior, and leadership.<br><br>\
		A sense of noblesse oblige has long pervaded the clan, accompanied by the genuine belief that the Ventrue know what is best for everyone.<br><br>\
		They not only consider themselves the oldest clan, but see themselves as the enforcers of tradition and the rightful leaders of Kindred society. "
	join_icon_state = "ventrue"
	blood_drink_type = VAMPIRE_DRINK_SNOBBY
	default_humanity = 9
	princely_score_bonus = 15	// IT'S OVER NIN- ten. It's over ten.
	joinable_clan = TRUE

/datum/vampire_clan/ventrue/New(datum/antagonist/vampire/owner_datum)
	. = ..()

	vampiredatum.owned_disciplines += new /datum/discipline/presence(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/dominate/ventrue(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/fortitude(vampiredatum)
