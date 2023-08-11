/// Handles adding and removing donator items from clients
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
