/datum/gear/ooc
	subtype_path = /datum/gear/ooc
	sort_category = "OOC"
	cost = 10000

/datum/gear/ooc/char_slot
	display_name = "extra character slot"
	description = "An extra charslot. Pretty self-explanatory."
	cost = 10000

/datum/gear/ooc/char_slot/purchase(var/client/C)
	C?.prefs?.max_save_slots += 1

/datum/gear/ooc/real_antagtoken
	display_name = "antag token"
	description = "If you can afford it, you deserve it."
	cost = 100000
	multi_purchase = TRUE

/datum/gear/ooc/real_antagtoken/purchase(var/client/C)
	C.inc_antag_token_count(1)
	message_admins("[C.ckey] has purchased a genuine antag token.")
	log_game("[C.ckey] has purchased a genuine antag token.")

/datum/gear/ooc/lootbox
	display_name = "Loadout Loot Box"
	description = "Gives a random item from the shop. If it's a duplicate, you receive half back. Free sense of pride and accomplishment included in every box."
	cost = 5000
	multi_purchase = TRUE

/datum/gear/ooc/lootbox/purchase(var/client/C)
	var/finding_item = TRUE
	var/datum/gear/TG
	while(finding_item)
		TG = GLOB.gear_datums[pick(GLOB.gear_datums)]
		if(!istype(TG, /datum/gear/donator) && !istype(TG, /datum/gear/ooc/lootbox))
			finding_item = FALSE
			if(TG.id in C.prefs.purchased_gear)
				if(SSticker.current_state != 3)
					to_chat(world, "<span class=boldannounce>[C.ckey] bought a lootbox, and got a [TG.display_name], but it was a duplicate.")
				else
					to_chat(C.mob, "<span class=boldannounce>You got a [TG.display_name] in a lootbox, but it was a duplicate.")
				C.inc_metabalance(cost * 0.5, TRUE, "Received a duplicate in a lootbox.")
			else
				if(!TG.multi_purchase)
					C.prefs.purchased_gear += TG.id
				TG.purchase(C)
				if(SSticker.current_state != 3)
					if(!istype(TG, /datum/gear/ooc/real_antagtoken))
						to_chat(world, "<span class=boldannounce>[C.ckey] bought a lootbox, and got a [TG.display_name].")
					else
						to_chat(world, "<font color='red' size='4'>[C.ckey] got an antag token in a lootbox!")
				else
					to_chat(C.mob, "<span class=boldannounce>You got a [TG.display_name] in a lootbox.")
