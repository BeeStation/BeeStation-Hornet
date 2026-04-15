/datum/vampire_clan/tremere
	name = CLAN_TREMERE
	description = "In the (comparatively) little time since their founding, the Tremere have made incredible inroads within vampiric society and are arguably the most powerful clan in the modern nights.<br><br>\
		This is due in no small part to their strict hierarchy, secretive nature, and mastery of Thaumaturgy, all of which elicit suspicion, fear, and respect from other Cainites.<br><br>\
		The Tremere stand as a pillar of the Camarilla and are one of its main defenders, despite the fact that they exist almost as a subsect."
	join_icon_state = "tremere"
	default_humanity = 7
	princely_score_bonus = 8
	joinable_clan = TRUE

/datum/vampire_clan/tremere/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	vampiredatum.owned_disciplines += new /datum/discipline/dominate(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/auspex(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/thaumaturgy(vampiredatum)
