/**
 * Gives Vampires the ability to choose a Clan.
 * If they are already in a Clan, or is in a Frenzy, they will not be able to do so.
 * The arg is optional and should really only be an Admin setting a Clan for a player.
 * If set however, it will give them the control of their Clan instead of the Vampire.
 * This is selected through a radial menu over the player's body, even when an Admin is setting it.
 * Args:
 * person_selecting - Mob override for stuff like Admins selecting someone's clan.
 */
/datum/antagonist/vampire/proc/assign_clan_and_bane()
	if(my_clan || owner.current.has_status_effect(/datum/status_effect/frenzy))
		return

	var/list/options = list()
	var/list/radial_display = list()
	for(var/datum/vampire_clan/all_clans as anything in typesof(/datum/vampire_clan))
		if(!initial(all_clans.joinable_clan)) //flavortext only
			continue

		options[initial(all_clans.name)] = all_clans

		var/datum/radial_menu_choice/option = new
		option.image = image(icon = initial(all_clans.join_icon), icon_state = initial(all_clans.join_icon_state))
		option.info = "[span_boldnotice(initial(all_clans.name))]\n[span_cult(get_clan_description(all_clans.name))]"
		radial_display[initial(all_clans.name)] = option

	var/chosen_clan
	if(istype(owner.current.loc, /obj/structure/closet))
		var/obj/structure/closet/container = owner.current.loc
		chosen_clan = show_radial_menu(owner.current, container, radial_display, radius = 45)
	else
		chosen_clan = show_radial_menu(owner.current, owner.current, radial_display, radius = 45)

	chosen_clan = options[chosen_clan]

	if(QDELETED(src) || QDELETED(owner.current) || !chosen_clan)
		return FALSE

	my_clan = new chosen_clan(src)

	my_clan.on_apply()
