// These have no functionality. They're just flavortext for the Archive of the Kindred
/datum/vampire_clan/gangrel
	name = CLAN_GANGREL
	description = "Closer to Animals than Vampires, known as Werewolves waiting to happen, \n\
		these are the most fearful of True Faith, being the most lethal thing they would ever see the night of. \n\
		Full Moons do not seem to have an effect, despite common-told stories. \n\
		The Favorite Vassal turns into a Werewolf whenever their Master does."
	joinable_clan = FALSE

/datum/vampire_clan/gangrel/on_enter_frenzy(datum/antagonist/vampire/source)
	ADD_TRAIT(vampiredatum.owner.current, TRAIT_STUNIMMUNE, TRAIT_FRENZY)

/datum/vampire_clan/gangrel/on_exit_frenzy(datum/antagonist/vampire/source)
	REMOVE_TRAIT(vampiredatum.owner.current, TRAIT_STUNIMMUNE, TRAIT_FRENZY)

/datum/vampire_clan/gangrel/handle_clan_life(datum/antagonist/vampire/source)
	. = ..()
	var/area/current_area = get_area(vampiredatum.owner.current)
	if(istype(current_area, /area/chapel))
		to_chat(vampiredatum.owner.current, span_warning("You don't belong in holy areas! The Faith burns you!"))
		vampiredatum.owner.current.adjustFireLoss(20)
		vampiredatum.owner.current.adjust_fire_stacks(2)
		vampiredatum.owner.current.IgniteMob()

/datum/vampire_clan/toreador
	name = CLAN_TOREADOR
	description = "The most charming Clan of them all, allowing them to very easily disguise among the crew. \n\
		More in touch with their morals, they suffer and benefit more strongly from humanity cost or gain of their actions. \n\
		Known as 'The most humane kind of vampire', they have an obsession with perfectionism and beauty \n\
		The Favorite Vassal gains the Mesmerize ability."
	joinable_clan = FALSE
	blood_drink_type = VAMPIRE_DRINK_SNOBBY

/datum/vampire_clan/brujah
	name = CLAN_BRUJAH
	description = "The Brujah Clan has proven to be the strongest in melee combat, boasting a powerful punch. \n\
		They also appear to be more calm than the others, entering their 'frenzies' whenever they want, but dont seem affected much by them. \n\
		Be wary, as they are fearsome warriors, rebels and anarchists, with an inclination towards Frenzy. \n\
		The Favorite Vassal gains brawn and a massive increase in brute damage from punching."
	joinable_clan = FALSE

/datum/vampire_clan/tzimisce
	name = CLAN_TZIMISCE
	description = "The Tzimisce Clan has no knowledge about it. \n\
		If you see one, you should probably run away.\n\
		*the rest of the page is full of undecipherable scribbles...*"
	joinable_clan = FALSE
