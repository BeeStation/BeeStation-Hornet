/datum/vampire_clan/brujah
	name = CLAN_BRUJAH
	description = "Mostly independent of the Camarilla's strictures, the Brujah prefer their own councils and street courts over princely salons.<br>\
		They are a fallen clan, a people who have slid from warrior-scholars into fierce, argumentative rebels. Yet the embers of discipline and wisdom still glow beneath the rage.<br><br>\
		At the same time, many Brujah are pragmatic. They respect competence, reward power, and will accept arrangements that let them keep their autonomy while serving a purpose. For the right price, leverage, or chance to settle scores, princes were known recruit Brujah as scourges or enforcers, so long as those Brujah retain visible independence."
	join_icon_state = "brujah"
	default_humanity = 8
	princely_score_bonus = 2
	joinable_clan = TRUE

/datum/vampire_clan/brujah/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	vampiredatum.owned_disciplines += new /datum/discipline/celerity(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/potence/brujah(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/presence(vampiredatum)

/datum/vampire_clan/brujah/on_apply()
	. = ..()
	set_antag_hud(vampiredatum.owner.current, "brujah")
