// These have no functionality. They're just flavortext for the Archive of the Kindred
/datum/vampire_clan/gangrel
	name = CLAN_GANGREL
	description = "Closer to Animals than Vampires, known as Werewolves waiting to happen, \n\
		these are the most fearful of True Faith, being the most lethal thing they would ever see the night of. \n\
		Full Moons do not seem to have an effect, despite common-told stories. \n\
		The Favorite Vassal turns into a Werewolf whenever their Master does."
	joinable_clan = FALSE

/datum/vampire_clan/gangrel/handle_clan_life()
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

/datum/vampire_clan/tzimisce
	name = CLAN_TZIMISCE
	description = "The Tzimisce Clan has no knowledge about it. \n\
		If you see one, you should probably run away.\n\
		*the rest of the page is full of undecipherable scribbles...*"
	joinable_clan = FALSE

/datum/vampire_clan/hecata
	name = CLAN_HECATA
	description = "This Clan is composed of curious practioners of dark magic who enjoy toying with the dead. \n\
		Often compared to the Lasombra, they sometimes act in similar ways and draw power from the void. \n\
		However, they are also very different, and place an emphasis on creating zombie like puppets from the dead. \n\
		They are able to raise the dead as temporary vassals, permanently revive dead vassals, communicate to their vassals from afar, and summon wraiths. \n\
		Their Favorite Vassal also has inherited a small fraction of their power, being able to call wraiths into the world as well."
	joinable_clan = FALSE

/datum/vampire_clan/lasombra
	name = CLAN_LASOMBRA
	description = "This Clan seems to adore living in the Shadows, worshipping it's secrets. \n\
		They take their research and vanity seriously, they are always very proud of themselves after even minor achievements. \n\
		They appear to be in search of a station with a veil weakness to be able to channel their shadow's abyssal powers. \n\
		Thanks to this, they have also evolved a dark liquid in their veins, which makes them able to manipulate shadows. \n\
		Their Favorite Vassal appears to have been imbued with abyssal essence and is able to blend in with the shadows."
	joinable_clan = FALSE

/datum/vampire_clan/nosferatu
	name = CLAN_NOSFERATU
	description = "The Nosferatu Clan is unable to blend in with the crew, with no abilities such as Masquerade and Veil. \n\
		Additionally, has a permanent bad back and looks like a Vampire upon a simple examine, and is entirely unidentifiable, \n\
		they can fit in the vents regardless of their form and equipment. \n\
		The Favorite Vassal is permanently disfigured, and can also ventcrawl, but only while entirely nude."
	joinable_clan = FALSE
