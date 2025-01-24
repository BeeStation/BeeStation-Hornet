/datum/vampire_clan/nosferatu
	name = CLAN_NOSFERATU
	description = "The Nosferatu Clan is unable to blend in with the crew, with no abilities such as Masquerade and Veil. \n\
		Additionally, has a permanent bad back and looks like a Vampire upon a simple examine, and is entirely unidentifiable, \n\
		they can fit in the vents regardless of their form and equipment. \n\
		The Favorite Vassal is permanetly disfigured, and can also ventcrawl, but only while entirely nude."
	clan_objective = /datum/objective/vampire/kindred
	join_icon_state = "nosferatu"
	join_description = "You are permanetly disfigured, look like a Vampire to all who examine you, \
		lose your Masquerade ability, but gain the ability to Ventcrawl even while clothed."
	blood_drink_type = VAMPIRE_DRINK_INHUMANELY

/datum/vampire_clan/nosferatu/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	for(var/datum/action/cooldown/vampire/power as anything in vampiredatum.powers)
		if(istype(power, /datum/action/cooldown/vampire/masquerade) || istype(power, /datum/action/cooldown/vampire/veil))
			vampiredatum.RemovePower(power)

	ADD_TRAIT(vampiredatum.owner.current, TRAIT_DISFIGURED, TRAIT_VAMPIRE)
	vampiredatum.owner.add_quirk(/datum/quirk/badback)
	vampiredatum.owner.current.ventcrawler = VENTCRAWLER_ALWAYS

/datum/vampire_clan/nosferatu/Destroy(force)
	for(var/datum/action/cooldown/vampire/power in vampiredatum.powers)
		vampiredatum.RemovePower(power)
	vampiredatum.give_starting_powers()

	REMOVE_TRAIT(vampiredatum.owner.current, TRAIT_DISFIGURED, TRAIT_VAMPIRE)
	vampiredatum.owner.remove_quirk(/datum/quirk/badback)
	vampiredatum.owner.current.ventcrawler = VENTCRAWLER_NONE
	return ..()

/datum/vampire_clan/nosferatu/handle_clan_life(datum/antagonist/vampire/source)
	. = ..()
	if(!HAS_TRAIT(vampiredatum.owner.current, TRAIT_NO_BLOOD))
		vampiredatum.owner.current.blood_volume = BLOOD_VOLUME_SURVIVE

/datum/vampire_clan/nosferatu/on_favorite_vassal(datum/antagonist/vampire/source, datum/antagonist/vassal/vassaldatum)
	vassaldatum.owner.current.ventcrawler = VENTCRAWLER_NUDE
	ADD_TRAIT(vampiredatum.owner.current, TRAIT_DISFIGURED, TRAIT_VAMPIRE)

	to_chat(vassaldatum.owner.current, span_notice("Additionally, you can now ventcrawl while naked, and are permanently disfigured."))
