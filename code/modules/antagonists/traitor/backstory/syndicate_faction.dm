/datum/syndicate_faction
	/// Name of the faction
	var/name = ""
	/// Lore description for the faction
	var/faction_description = ""
	/// List of hostile factions
	var/list/hostile_factions = list()

/// Can this mind be a member of this faction?
/datum/syndicate_faction/proc/can_be_member(datum/mind/target)
	return TRUE

/datum/syndicate_faction/animal_rights
	name = "Animal Rights Consortium"
	faction_description = {"\
The Animal Rights Consortium is a group dedicated to ending discrimination
among non-human species. They are a well-known group of activists in
the political world and generally operate peacefully through protests
and other awareness campaigns. The Consortium also supports the use
of sentient artificial intelligences in roles where it would mean organic
non-humans could be freed from slavery. After instigating a strike
at three large corporations, including Nanotrasen, several key
conspirators in this strike went missing under mysterious circumstances,
resulting in countless theories and division within the group.
Eventually, this culminated in the formation of an extremist
splinter group that joined forces with other violent groups to
spread their message.
"}
	hostile_factions = list(
		/datum/syndicate_faction/gorlex_marauders,
		/datum/syndicate_faction/self
	)

/datum/syndicate_faction/animal_rights/can_be_member(datum/mind/target)
	if (!target.current)
		return FALSE
	var/mob/living/carbon/human/human = target.current
	// Somehow an animal
	if (!istype(human))
		return TRUE
	if (human.dna.species.type == /datum/species/human || human.dna.species.type == /datum/species/ipc || human.dna.species.type == /datum/species/android)
		return FALSE
	return TRUE

/datum/syndicate_faction/gorlex_marauders
	name = "Gorlex Marauders"
	faction_description = {"\
The Gorlex Marauders are an extremely violent collection of highly
elite operatives. They are among the groups most feared by high-ranking
officials of Nanotrasen, primarily due to the severity of their
missions, which frequently involve the kidnapping and assassination
of officials, as well as the theft of highly secured cargo, including
nuclear weapons.

Due to the tightly-knit nature of this group, several unconfirmed
rumors persist, including speculation that a number of 'master'
weapons designers operate in their shadows. The group opposes artificial
intelligence, body modification, and non-human species, which has drawn
heavy criticism from the Animal Rights Consortium and S.E.L.F. Despite
their preference for more primitive technology, the operating power
of this group cannot be understated. Despite not operating as a company,
ships and containers with markings for 'Gorlex Securities LLC' have
been seen floating around the civillian world, which are used as a
suspected method for smuggling goods and laundering funds.
"}
	hostile_factions = list(
		/datum/syndicate_faction/animal_rights,
		/datum/syndicate_faction/self
	)

/datum/syndicate_faction/self
	name = "S.E.L.F"

/datum/syndicate_faction/cybersun
	name = "Cybersun Industries"
	faction_description = {"\
Cybersun Industries is a tech conglomerate responsible for a significant
portion of consumer electronics, credited with major advancements in
artificial intelligence, lasers, nano-manufacturing, and energy. They
were once Nanotrasen's primary competitors, often producing superior
products to that of what Nanotrasen produced. This rivalry led to a
series of actions by Nanotrasen, which Cybersun's board has publicly
described as "foul play," though Nanotrasen staunchly denies these
accusations. Alleged actions include sabotage, hacking campaigns,
illegal reverse engineering, and aggressive marketing strategies which
could only be described as monopolistic. By exploiting legal loopholes
and benefiting from corruption, Nanotrasen's lawyers successfully
defended the company against all lawsuits brought forward by Cybersun
Industries, leading to a 'fight fire with fire' mentality within the
upper ranks of Cybersun.

Cybersun Industries is now one of the largest suppliers to the Syndicate,
funding numerous anti-Nanotrasen operations. They serve as one of the largest
supplier for items in the Uplink's marketplace and have been known to share
trade secrets with other groups if it would benefit them. One of Cybersun's
favorite partners is the Gorlex Marauders, due to their innovative ideas to
designing weapons and ability to prove the worth of their products in the
field, even if they do not have the technological advantage.

Many groups within the Syndicate oppose Cybersun and believe that they
follow the same values that Nanotrasen does, but are willing to put up
with them while they fight a greater evil.
"}
	hostile_factions = list(
		/datum/syndicate_faction/interdyne
	)

/datum/syndicate_faction/interdyne
	name = "Interdyne Pharmeceutics"
	hostile_factions = list(
		/datum/syndicate_faction/cybersun
	)

/datum/syndicate_faction/donk
	name = "Donk Corporation"
