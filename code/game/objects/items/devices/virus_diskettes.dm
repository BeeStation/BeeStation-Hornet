/obj/item/disk/virus
	name = "Virus Disk"
	desc = "This one is empty."
	icon_state = "datadisk0"
	var/destroyonuse = TRUE
	datum/malware/infection

/obj/item/disk/virus/suicide_act(mob/user)
	if (isipc(user))
		user.visible_message("<span class='suicide'>[user] is trying to install [infection.name] into their system! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		return (BRUTELOSS)
	return ..()
	
/obj/item/disk/virus/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(proximity)
		var/obj/machinery/computer/source/console_target = target
		var/datum/malware/xirus = new infection()
		if (istype(console_target) && xirus.can_install(console_target))
			if (xirus.install(console_target))
				to_chat(user, "<span class='notice'>You install [infection.name] on the [target].</span>")
				if (destroyonuse)
					qdel(src)
		else
			to_chat(user, "<span class='notice'>You cannot install [infection.name] on the [target].</span>")
			qdel(xirus)
		
/obj/item/disk/virus/clown
	name = "Honker Clownware"
	desc = "A disk containing the funny H0NK3R virus, which brings joy to the station."
	icon_state = "datadisk3"
	destroyonuse = FALSE

/obj/item/disk/virus/clown/Initialize()
	. = ..()
	infection = new datum/malware/clown()
		
/obj/item/disk/virus/killer
	name = "Console Bondage Malware"
	desc = "A disk containing the dreaded D0M3-N@T.r1x virus, which disables a console's ability to recieve inputs and outputs through it's hardware."
	icon_state = "datadisk1"

/obj/item/disk/virus/killer/Initialize()
	. = ..()
	infection = new datum/malware/killer()
		
/obj/item/disk/virus/tider
	name = "Tider Rootkit Malware"
	desc = "A disk containing the sneaky T1-D3R, which capable of hiding the identity of anyone using the console."
	icon_state = "datadisk2"

/obj/item/disk/virus/tider/Initialize()
	. = ..()
	infection = new datum/malware/tider()
		
/obj/item/disk/virus/cuban
	name = "Trojan Pete Malware"
	desc = "A disk containing everyone's beloved Trojan Pete Buddy, a virus that overloads the machine with ads and bloatware until it explodes."
	icon_state = "datadisk4"

/obj/item/disk/virus/cuban/Initialize()
	. = ..()
	infection = new datum/malware/cuban()
		
/obj/item/disk/virus/logger
	name = "Keylogger Malware"
	desc = "A disk containing the mighty Keylogger virus, the bane of all Heads of Personnel. Records the last used ID on the console."
	icon_state = "datadisk3"

/obj/item/disk/virus/logger/Initialize()
	. = ..()
	infection = new datum/malware/logger()
		
/obj/item/disk/virus/gate
	name = "Gate Daemon"
	desc = "A disk containing the mighty G4T3 virus. Inject into a console linked to a autolathe, cloner, or teleporter, and it will override the machine to manufacture hostile creatures."
	icon_state = "datadisk0"
	destroyonuse = FALSE

/obj/item/disk/virus/gate/Initialize()
	. = ..()
	infection = new datum/malware/gate()