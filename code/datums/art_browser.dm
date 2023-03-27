
/datum/art_browser
	var/owner_ckey
	var/list/owned = list()

/datum/art_browser/New(ckey)
	owner_ckey = ckey

/datum/art_browser/proc/refresh_owned()
	owned = list()
	for(var/entry in SSpersistence.paintings["library"])
		if(entry["owner"] == owner_ckey)
			owned += list(entry)

/datum/art_browser/ui_state(mob/user)
	return GLOB.always_state

/datum/art_browser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ArtGallery")
		ui.open()

/datum/art_browser/ui_data(mob/user)
	var/list/data = list()
	data["library"] = SSpersistence.paintings["library"] ? SSpersistence.paintings["library"] : 0
	data["owned"] = owned ? owned : 0
	return data

/datum/art_browser/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/portraits/library)
	)

/datum/art_browser/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/list/chosen_portrait = SSpersistence.paintings["library"][params["selected"]]
	var/author = chosen_portrait["ckey"]
	var/title = chosen_portrait["title"]
	var/price = chosen_portrait["price"]
	var/owner = chosen_portrait["owner"]

	if(owner == usr.ckey)
		to_chat(usr, "<span class='warning'>You already own this painting!</span>")
		return
	if(price > usr.client?.get_metabalance())
		to_chat(usr, "<span class='warning'>You don't have enough [CONFIG_GET(string/metacurrency_name)]s to buy this painting.</span>")
		return
	usr.client?.inc_metabalance(price * -1, TRUE, "Purchased [title].")
	SSpersistence.add_art_payout(owner, round(price * 0.25))
	SSpersistence.add_art_payout(author, round(price * 0.25))
	if(SSticker.current_state != GAME_STATE_PLAYING) // for flexing purposes
		to_chat(world, "<span class='nicegreen'>[usr.ckey] purchased [title] from [owner] for [price] [CONFIG_GET(string/metacurrency_name)]s!</span>")
	SSpersistence.paintings["library"][params["selected"]]["owner"] = usr.ckey
	SSpersistence.paintings["library"][params["selected"]]["price"] += 500
	refresh_owned()


/client/verb/browseart()
	set category = "OOC"
	set name = "Browse Art Gallery"
	set desc = "View your art collection!"

	if(SSpersistence.initialized)
		player_details.artbrowser.refresh_owned()
		player_details.artbrowser.ui_interact(usr)
	else
		to_chat(src, "<span class='warning'>Please wait for the game to initialize!</span>")
