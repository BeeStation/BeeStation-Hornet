/datum/vampire_clan/caitiff
	name = CLAN_CAITIFF
	description = "The Caitiff are seen as either vile thinbloods, or vile mongrels, either case you are likely not to make many friends.<br><br>\
		In your case, your blood is strong enough to grant you some basic abilities of various disciplines.<br><br>\
		Do not let any kindred know your heritage, for your own good."
	join_description = "The average thinblood, hated by polite kindred society. Expect to get killed by the first proper vampire that finds out your mongrel lineage."
	join_icon_state = "caitiff"
	default_humanity = 7
	joinable_clan = TRUE

/datum/vampire_clan/caitiff/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	vampiredatum.owned_disciplines += new /datum/discipline/caitiff(vampiredatum)
