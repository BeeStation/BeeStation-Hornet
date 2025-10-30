/datum/vampire_clan/gangrel
	name = CLAN_GANGREL
	description = "Closer to Animals than Vampires, known as Werewolves waiting to happen, \n\
		these are the most fearful of True Faith, being the most lethal thing they would ever see the night of. \n\
		Full Moons do not seem to have an effect, despite common-told stories. \n\
		The Favorite ghoul turns into a Werewolf whenever their Master does."
	joinable_clan = TRUE

/datum/vampire_clan/gangrel/handle_clan_life()
	. = ..()
	var/area/current_area = get_area(vampiredatum.owner.current)
	if(istype(current_area, /area/chapel))
		to_chat(vampiredatum.owner.current, span_warning("You don't belong in holy areas! The Faith burns you!"))
		vampiredatum.owner.current.adjustFireLoss(20)
		vampiredatum.owner.current.adjust_fire_stacks(2)
		vampiredatum.owner.current.IgniteMob()
