
// A bodge item to send priority_announce messages.
// See priority_announce.dm for how to properly configure this in round.

/obj/item/patool
	name = "Announcement Device"
	desc = "Debug tool for sending priority announcements."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-red"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	var/a_text = ""				// Announcement Contents.
	var/a_title = ""			// Title the announcement?
	var/a_sound					// The sound to play, the main reason I bothered to set this all up.
	var/a_type = "CentCom"		// 'Priority', 'Captain', or anything else for centcom.
	var/a_override = ""			// If centcom, set the sender title.
	var/a_id = ""				// Append a sender ID name.

/obj/item/patool/attack_self(mob/user)
	..()
	//Admin only fucko.
	if(user && (!user.client || !user.client.holder))
		return
	priority_announce(a_text, a_title, a_sound, a_type, a_override, a_id)


//Allow them to be used from observer with a confirmation box.
//Stolen with only some shame from fun_balloon code.
/obj/item/patool/attack_ghost(mob/user)
	if(!user.client || !user.client.holder)
		return
	var/confirmation = alert("Trigger Announcer [src]","Priority Announcer","Yes","No")
	if(confirmation == "Yes")
		priority_announce(a_text, a_title, a_sound, a_type, a_override, a_id)
