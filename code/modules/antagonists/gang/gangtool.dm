//gangtool device
/obj/item/device/gangtool
	name = "suspicious device"
	desc = "A strange device of sorts. Hard to really make out what it actually does if you don't know how to operate it."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags_1 = CONDUCT_1
	var/datum/team/gang/gang //Which gang uses this?
	var/static/list/buyable_items = list()
	var/list/tags = list()
	var/selected_cat

/obj/item/device/gangtool/Initialize(mapload)
	..()
	update_icon()
	for(var/i in subtypesof(/datum/gang_item))
		var/datum/gang_item/G = i
		var/name = initial(G.name)
		var/cat = initial(G.category)
		if(name)
			if(!islist(buyable_items[cat]))
				buyable_items[cat] = list()
			buyable_items[cat][name] = new G

/obj/item/device/gangtool/Destroy()
	if(gang)
		gang.gangtools -= src
	return ..()

/obj/item/device/gangtool/attack_self(mob/user)
	..()
	if (!can_use(user))
		return
	if(!gang)
		var/datum/antagonist/gang/boss/boss = user.mind.has_antag_datum(/datum/antagonist/gang/boss)
		gang = boss.gang

	ui_interact(user)


/obj/item/device/gangtool/update_icon()
	overlays.Cut()
	var/image/I = new(icon, "[icon_state]-overlay")
	if(gang)
		I.color = gang.color
	overlays.Add(I)

/obj/item/device/gangtool/proc/ping_gang(mob/user)
	if(!can_use(user))
		return
	var/message = stripped_input(user,"Discreetly send a gang-wide message.","Send Message")
	if(!message || !can_use(user))
		return
	if(!is_station_level(user.z))
		to_chat(user, "<span class='info'>[icon2html(src, user)]Error: Station out of range.</span>")
		return
	if(gang.members.len)
		var/datum/antagonist/gang/G = user.mind.has_antag_datum(/datum/antagonist/gang)
		if(!G)
			return
		var/ping = "<span class='danger'><B><i>[gang.name] [G.message_name] [user.real_name]</i>: [message]</B></span>"
		for(var/datum/mind/ganger in gang.members)
			if(ganger.current && is_station_level(ganger.current.z) && (ganger.current.stat == CONSCIOUS))
				to_chat(ganger.current, ping)
		for(var/mob/M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [ping]")
		user.log_talk(message,LOG_SAY, tag="[gang.name] gangster")




/obj/item/device/gangtool/proc/can_use(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(user.incapacitated())
		return
	if(!(src in user.contents))
		return
	if(!user.mind)
		return
	var/datum/antagonist/gang/G = user.mind.has_antag_datum(/datum/antagonist/gang)
	if(!G)
		to_chat(user, "<span class='notice'>Huh, what's this?</span>")
		return
	if(!isnull(gang) && G.gang != gang)
		to_chat(user, "<span class='danger'>You cannot use gang tools owned by enemy gangs!</span>")
		return
	else if(!G.gang.check_gangster_swag(user)>1)
		to_chat(user, "<span class='danger'>You cannot use gang tools while undercover!</span>")
		return
	return TRUE


/obj/item/device/gangtool/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/device/gangtool/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GangTool", name)
		// This UI is only ever opened by one person,
		// and never is updated outside of user input.
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/device/gangtool/ui_data(mob/user)
	if(!user.mind)
		return
	var/list/data = list()
	if(gang)
		data["influence"] = gang.influence
	return data

/obj/item/device/gangtool/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()
	for(var/category in buyable_items)
		var/list/cat = list(
			"name" = category,
			"items" = (category == selected_cat ? list() : null))
		for(var/item in buyable_items[category])
			var/datum/gang_item/I = buyable_items[category][item]
			cat["items"] += list(list(
				"name" = I.name,
				"cost" = I.cost,
				"desc" = I.desc,
			))
		data["categories"] += list(cat)
	return data

/obj/item/device/gangtool/ui_act(action, params)
	switch(action)
		if("buy")
			var/item_name = params["name"]
			var/list/buyables = list()
			for(var/category in buyable_items)
				buyables += buyable_items[category]
			if(item_name in buyables)
				var/datum/gang_item/I = buyables[item_name]
				I.purchase(usr,gang,src)
				return TRUE

