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
	var/recalling = 0
	var/outfits = 2
	var/free_pen = 0
	var/promotable = FALSE
	var/static/list/buyable_items = list()
	var/list/tags = list()

/obj/item/device/gangtool/Initialize(mapload)
	..()
	update_icon()
	for(var/i in subtypesof(/datum/gang_item))
		var/datum/gang_item/G = i
		var/id = initial(G.id)
		var/cat = initial(G.category)
		if(id)
			if(!islist(buyable_items[cat]))
				buyable_items[cat] = list()
			buyable_items[cat][id] = new G

/obj/item/device/gangtool/Destroy()
	if(gang)
		gang.gangtools -= src
	return ..()

/obj/item/device/gangtool/attack_self(mob/user)
	..()
	if (!can_use(user))
		return
	var/datum/antagonist/gang/boss/L = user.mind.has_antag_datum(/datum/antagonist/gang/boss)
	var/dat
	if(!gang)
		dat += "This device is not registered.<br><br>"
		if(L)
			if(promotable && L.gang.leaders.len < L.gang.max_leaders)
				dat += "Give this device to another member of your organization to use to promote them to Lieutenant.<br><br>"
				dat += "If this is meant as a spare device for yourself:<br>"
			dat += "<a href='?src=[REF(src)];register=1'>Register Device as Spare</a><br>"
		else if(promotable)
			var/datum/antagonist/gang/sweet = user.mind.has_antag_datum(/datum/antagonist/gang)
			if(sweet.gang.leaders.len < sweet.gang.max_leaders)
				dat += "You have been selected for a promotion!<br>"
				dat += "<a href='?src=[REF(src)];register=1'>Accept Promotion</a><br>"
			else
				dat += "No promotions available: All positions filled.<br>"
		else
			dat += "This device is not authorized to promote.<br>"
	else
		dat += "Registration: <B>[gang.name] Gang Boss</B><br>"
		dat += "Organization Size: <B>[gang.members.len]</B> | Station Control: <B>[gang.territories.len] territories under control.</B> | Influence: <B>[gang.influence]</B><br>"
		dat += "Time until Influence grows: <B>[time2text(gang.next_point_time - world.time, "mm:ss")]</B><br>"
		dat += "<a href='?src=[REF(src)];commute=1'>Send message to Gang</a><br>"
		dat += "<a href='?src=[REF(src)];recall=1'>Recall shuttle</a><br>"
		dat += "<hr>"
		for(var/cat in buyable_items)
			dat += "<b>[cat]</b><br>"
			for(var/id in buyable_items[cat])
				var/datum/gang_item/G = buyable_items[cat][id]
				if(!G.can_see(user, gang, src))
					continue

				var/cost = G.get_cost_display(user, gang, src)
				if(cost)
					dat += cost + " "

				var/toAdd = G.get_name_display(user, gang, src)
				if(G.can_buy(user, gang, src))
					toAdd = "<a href='?src=[REF(src)];purchase=1;id=[id];cat=[cat]'>[toAdd]</a>"
				dat += toAdd
				var/extra = G.get_extra_info(user, gang, src)
				if(extra)
					dat += "<br><i>[extra]</i>"
				dat += "<br>"
			dat += "<br>"

	dat += "<a href='?src=[REF(src)];choice=refresh'>Refresh</a><br>"

	var/datum/browser/popup = new(user, "gangtool", "Welcome to GangTool v4.0", 340, 625)
	popup.set_content(dat)
	popup.open()

/obj/item/device/gangtool/Topic(href, href_list)
	if(!can_use(usr))
		return

	add_fingerprint(usr)

	if(href_list["register"])
		register_device(usr)

	else if(!gang) //Gangtool must be registered before you can use the functions below
		return

	if(href_list["purchase"])
		if(islist(buyable_items[href_list["cat"]]))
			var/list/L = buyable_items[href_list["cat"]]
			var/datum/gang_item/G = L[href_list["id"]]
			if(G && G.can_buy(usr, gang, src))
				G.purchase(usr, gang, src, FALSE)

	if(href_list["commute"])
		ping_gang(usr)
	if(href_list["recall"])
		recall(usr)
	attack_self(usr)

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

/obj/item/device/gangtool/proc/register_device(mob/user)
	if(gang)	//It's already been registered!
		return
	var/datum/antagonist/gang/G = user.mind.has_antag_datum(/datum/antagonist/gang)
	if(G)
		gang = G.gang
		gang.gangtools += src
		update_icon()
		if(!(user.mind in gang.leaders) && promotable)
			G.promote()
			free_pen = TRUE
			gang.message_gangtools("[user] has been promoted to Lieutenant.")
			to_chat(user, "The <b>Gangtool</b> you registered will allow you to purchase weapons and equipment, and send messages to your gang.")
			to_chat(user, "Unlike regular gangsters, you may use <b>recruitment pens</b> to add recruits to your gang. Use them on unsuspecting crew members to recruit them. Don't forget to get your one free pen from the gangtool.")
	else
		to_chat(user, "<span class='warning'>ACCESS DENIED: Unauthorized user.</span>")

/obj/item/device/gangtool/proc/recall(mob/user)
	if(!recallchecks(user))
		return
	if(recalling)
		to_chat(user, "<span class='warning'>Error: Recall already in progress.</span>")
		return
	gang.message_gangtools("[user] is attempting to recall the emergency shuttle.")
	recalling = TRUE
	to_chat(user, "<span class='info'>[icon2html(src, loc)]Generating shuttle recall order with codes retrieved from last call signal...</span>")
	addtimer(CALLBACK(src, PROC_REF(recall2), user), rand(100,300))

/obj/item/device/gangtool/proc/recall2(mob/user)
	if(!recallchecks(user))
		return
	to_chat(user, "<span class='info'>[icon2html(src, loc)]Shuttle recall order generated. Accessing station long-range communication arrays...</span>")
	addtimer(CALLBACK(src, PROC_REF(recall3), user), rand(100,300))

/obj/item/device/gangtool/proc/recall3(mob/user)
	if(!recallchecks(user))
		return
	var/list/living_crew = list()//shamelessly copied from mulligan code, there should be a helper for this
	living_crew = get_living_station_crew()
	var/malc = CONFIG_GET(number/midround_antag_life_check)
	if(living_crew.len / GLOB.joined_player_list.len <= malc) //Shuttle cannot be recalled if too many people died
		to_chat(user, "<span class='warning'>[icon2html(src, user)]Error: Station communication systems compromised. Unable to establish connection.</span>")
		recalling = FALSE
		return
	to_chat(user, "<span class='info'>[icon2html(src, loc)]Comm arrays accessed. Broadcasting recall signal...</span>")
	addtimer(CALLBACK(src, PROC_REF(recallfinal), user), rand(100,300))

/obj/item/device/gangtool/proc/recallfinal(mob/user)
	if(!recallchecks(user))
		return
	recalling = FALSE
	log_game("[key_name(user)] has tried to recall the shuttle with a gangtool.")
	message_admins("[key_name_admin(user)] has tried to recall the shuttle with a gangtool.", 1)
	if(SSshuttle.cancelEvac(user))
		gang.recalls--
		return TRUE

	to_chat(user, "<span class='info'>[icon2html(src, loc)]No response received. Emergency shuttle cannot be recalled at this time.</span>")
	return

/obj/item/device/gangtool/proc/recallchecks(mob/user)
	if(!can_use(user))
		return
	if(SSshuttle.emergencyNoRecall)
		return
	if(!gang.recalls)
		to_chat(user, "<span class='warning'>Error: Unable to access communication arrays. Firewall has logged our signature and is blocking all further attempts.</span>")
		return
	if(SSshuttle.emergency.mode != SHUTTLE_CALL) //Shuttle can only be recalled when it's moving to the station
		to_chat(user, "<span class='warning'>[icon2html(src, user)]Emergency shuttle cannot be recalled at this time.</span>")
		recalling = FALSE
		return
	if(!is_station_level(user.z)) //Shuttle can only be recalled while on station
		to_chat(user, "<span class='warning'>[icon2html(src, user)]Error: Device out of range of station communication arrays.</span>")
		recalling = FALSE
		return
	return TRUE

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


/obj/item/device/gangtool/spare
	outfits = TRUE

/obj/item/device/gangtool/spare/lt
	promotable = TRUE
