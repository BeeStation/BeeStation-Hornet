/// Handles adding and removing special items from clients
/datum/preferences/proc/handle_donator_items()
	var/datum/loadout_category/DLC = GLOB.loadout_categories["Donator"] // stands for donator loadout category but the other def for DLC works too xD
	if(!CONFIG_GET(flag/donator_items)) // donator items are only accesibile by servers with a patreon
		return
	if(IS_PATRON(parent.ckey) || is_admin(parent.ckey))
		var/any_changed = FALSE
		for(var/gear_id in DLC.gear)
			var/datum/gear/AG = DLC.gear[gear_id]
			if(AG.id in purchased_gear)
				continue
			any_changed = TRUE
			purchased_gear += AG.id
			AG.purchase(parent)
		if(any_changed)
			mark_undatumized_dirty_player()
	else if(length(purchased_gear) || length(equipped_gear))
		var/any_changed = FALSE
		for(var/gear_id in DLC.gear)
			var/datum/gear/RG = DLC.gear[gear_id]
			if(!(RG.id in purchased_gear) && !(RG.id in equipped_gear))
				continue
			any_changed = TRUE
			equipped_gear -= RG.id
			purchased_gear -= RG.id
		if(any_changed)
			mark_undatumized_dirty_player()
			mark_undatumized_dirty_character()

/datum/preferences/proc/handle_maintainer_items()
	var/datum/loadout_category/MLC = GLOB.loadout_categories["Maintainer"] // stands for Maintainer loadout category, doesn't sound as good, but hey, consistency
	if(!CONFIG_GET(flag/maintainer_items)) // donator items are only accesibile by servers with a patreon
		return
	if(IS_MAINTAINER(parent.ckey) || is_admin(parent.ckey))//should admins get access to maintainer items?
		var/any_changed = FALSE
		for(var/gear_id in MLC.gear)
			var/datum/gear/AG = MLC.gear[gear_id]
			if(AG.id in purchased_gear)
				continue
			any_changed = TRUE
			purchased_gear += AG.id
			AG.purchase(parent)
		if(any_changed)
			mark_undatumized_dirty_player()
	else if(length(purchased_gear) || length(equipped_gear))
		var/any_changed = FALSE
		for(var/gear_id in MLC.gear)
			var/datum/gear/RG = MLC.gear[gear_id]
			if(!(RG.id in purchased_gear) && !(RG.id in equipped_gear))
				continue
			any_changed = TRUE
			equipped_gear -= RG.id
			purchased_gear -= RG.id
		if(any_changed)
			mark_undatumized_dirty_player()
			mark_undatumized_dirty_character()







/*
/// Handles adding and removing maintainer/contributor(?) items from clients
/datum/preferences/proc/handle_maintainer_items()

	if(!CONFIG_GET(flag/donator_items)) // donator items are only accesibile by servers with a ... wait how do you tie in a git account?


	if(ckey(preference_source?.ckey) == ckey(get_top_contrib())) //what is this bruh about? - OK apparently it's smack dabbled in the middle of the datum job/equip, move this somewhere else?
		var/obj/item/clothing/under/dress/skirt/coder/coderskirt = new()//prevent nullspace, change new()
		if(H.w_uniform)
			H.dropItemToGround(H.w_uniform)
		if(!H.equip_to_slot_if_possible(coderskirt, ITEM_SLOT_ICLOTHING))
			to_chat(H, "<span class='warning'>You failed to don your favorite skirt today.</span>")
		else
			to_chat(H, "<span class='notice'>Roses are red, violets are blue, You are the top contributer, get back to developement instead of playing the game!</span>")
*/
