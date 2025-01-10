/datum/bloodsucker_clan/nosferatu
	name = CLAN_NOSFERATU
	description = "The Nosferatu Clan is unable to blend in with the crew, with no abilities such as Masquerade and Veil. \n\
		Additionally, has a permanent bad back and looks like a Bloodsucker upon a simple examine, and is entirely unidentifiable, \n\
		they can fit in the vents regardless of their form and equipment. \n\
		The Favorite Vassal is permanetly disfigured, and can also ventcrawl, but only while entirely nude."
	clan_objective = /datum/objective/bloodsucker/kindred
	join_icon_state = "nosferatu"
	join_description = "You are permanetly disfigured, look like a Bloodsucker to all who examine you, \
		lose your Masquerade ability, but gain the ability to Ventcrawl even while clothed."
	blood_drink_type = BLOODSUCKER_DRINK_INHUMANELY

/datum/bloodsucker_clan/nosferatu/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	for(var/datum/action/cooldown/bloodsucker/power as anything in bloodsuckerdatum.powers)
		if(istype(power, /datum/action/cooldown/bloodsucker/masquerade) || istype(power, /datum/action/cooldown/bloodsucker/veil))
			bloodsuckerdatum.RemovePower(power)

	ADD_TRAIT(bloodsuckerdatum.owner.current, TRAIT_DISFIGURED, TRAIT_BLOODSUCKER)
	bloodsuckerdatum.owner.add_quirk(/datum/quirk/badback)
	bloodsuckerdatum.owner.current.ventcrawler = VENTCRAWLER_ALWAYS

/datum/bloodsucker_clan/nosferatu/Destroy(force)
	for(var/datum/action/cooldown/bloodsucker/power in bloodsuckerdatum.powers)
		bloodsuckerdatum.RemovePower(power)
	bloodsuckerdatum.give_starting_powers()

	REMOVE_TRAIT(bloodsuckerdatum.owner.current, TRAIT_DISFIGURED, TRAIT_BLOODSUCKER)
	bloodsuckerdatum.owner.remove_quirk(/datum/quirk/badback)
	bloodsuckerdatum.owner.current.ventcrawler = VENTCRAWLER_NONE
	return ..()

/datum/bloodsucker_clan/nosferatu/handle_clan_life(datum/antagonist/bloodsucker/source)
	. = ..()
	if(!HAS_TRAIT(bloodsuckerdatum.owner.current, TRAIT_NO_BLOOD))
		bloodsuckerdatum.owner.current.blood_volume = BLOOD_VOLUME_SURVIVE

/datum/bloodsucker_clan/nosferatu/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
	vassaldatum.owner.current.ventcrawler = VENTCRAWLER_NUDE
	ADD_TRAIT(bloodsuckerdatum.owner.current, TRAIT_DISFIGURED, TRAIT_BLOODSUCKER)

	to_chat(vassaldatum.owner.current, "<span class='notice'>Additionally, you can now ventcrawl while naked, and are permanently disfigured.</span>")
