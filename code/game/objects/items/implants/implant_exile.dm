//Exile implants will allow you to use the station gate, but not return home.
//This will allow security to exile badguys/for badguys to exile their kill targets

/obj/item/implant/exile
	name = "exile implant"
	desc = "Prevents you from returning from away missions."
	activated = 0

/obj/item/implant/exile/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Employee Exile Implant<BR>
				<b>Implant Details:</b> The onboard gateway system has been modified to reject entry by individuals containing this implant<BR>"}
	return dat

/obj/item/implanter/exile
	name = "implanter (exile)"
	imp_type = /obj/item/implant/exile

/obj/item/implantcase/exile
	name = "implant case - 'Exile'"
	desc = "A glass case containing an exile implant."
	imp_type = /obj/item/implant/exile


//For hotel staff, prevents them entering the station Z-level, dusts you if you remove it

/obj/item/implant/exile/hotel
	name = "super exile implant"
	desc = "nice try hotel staff"

/obj/item/implant/exile/hotel/on_implanted(mob/user)
	user.AddComponent(/datum/component/stationloving/hotelloving)

/obj/item/implant/exile/hotel/removed(mob/unimplanted) // Incase they try self surgery
	visible_message("<span class='danger'>The implant's anti-removal mechanisms activate!</span>")
	unimplanted.dust()
	message_admins("[ADMIN_LOOKUPFLW(unimplanted)] tried to remove their hotel staff implant to enter the station and was dusted.")
	if(!QDELETED(src)) //If you try to qdel when the implant is removed without an implant case it causes a loop of qdels and gibbing
		qdel(src)

/datum/component/stationloving/hotelloving/in_bounds()
	if(SSticker.current_state <= GAME_STATE_PREGAME)
		return TRUE
	var/turf/T = get_turf(parent)
	if(!T)
		return FALSE
	if(is_station_level(T.z)) // Are they on the station Z-level? If so trigger relocate()
		return FALSE
	return TRUE

//Override to plop the disk back to a syndie crew spawn rather than somewhere on the station.

/datum/component/stationloving/hotelloving/relocate()
	var/mob/hotelstaff = parent
	if(ismob(hotelstaff))
		if(!QDELETED(src)) // if you don't do this the body gets continuously dusted forever. While this is funny, an infinitely large pile of remains that crashes clients on right click isn't.
			qdel(src)
		to_chat(hotelstaff,"<span class='danger'>The implant's anti-escape mechanisms activate!</span>")
		hotelstaff.dust() // Nice try hotel staff
		message_admins("[ADMIN_LOOKUPFLW(hotelstaff)] tried to enter the station as hotel staff and was dusted.")
	else
		qdel(src) // This should only ever be applied to mobs

/obj/item/implant/exile/station
	name = "station exile implant"
	desc = "Explodes upon reaching the station."
	
/obj/item/implant/exile/station/on_implanted(mob/user)
	user.AddComponent(/datum/component/stationloving/exile)

/datum/component/stationloving/exile/in_bounds()
	if(SSticker.current_state <= GAME_STATE_PREGAME)
		return TRUE
	var/turf/T = get_turf(parent)
	if(!T)
		return FALSE
	if(is_station_level(T.z))
		return FALSE
	return TRUE

/datum/component/stationloving/exile/relocate()
	explosion(src,round(0.4),round(0.8),round(2),round(2), flame_range = round(2))


/obj/item/implanter/exile/station
	name = "implanter (station exile)"
	imp_type = /obj/item/implant/exile/station

/obj/item/implantcase/exile/station
	name = "implant case - 'Station Exile'"
	desc = "A glass case containing a station exile implant."
	imp_type = /obj/item/implant/exile/station
