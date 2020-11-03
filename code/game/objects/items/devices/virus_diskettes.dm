/obj/item/disk/virus
	name = "Virus Disk"
	desc = "This one is empty."
	icon_state = "datadisk0"
	datum/virus/infection

/obj/item/disk/virus/suicide_act(mob/user)
	if (isipc(user))
		user.visible_message("<span class='suicide'>[user] is trying to install [infection.name] into their drive! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		return (BRUTELOSS)
	return ..()
	
/obj/item/disk/virus/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(proximity)
		var/obj/machinery/computer/source/console_target = target
		if (istype(console_target) && infection.can_install(console_target))
			if (infection.install(console_target))
				to_chat(user, "<span class='notice'>You install [infection.name] on the [target].</span>")
				qdel(src)
		else
			to_chat(user, "<span class='notice'>You cannot install [infection.name] on the [target].</span>")
		
/obj/item/disk/virus/killer
	name = "Console Killer Virus Disk"
	desc = "A disk containing the dreaded K1LL3R virus, which effectively disables a console and makes it's OS unable to operate."
	icon_state = "datadisk1"

/obj/item/disk/virus/killer/Initialize()
	. = ..()
	infection = new datum/virus/killer()
		
/obj/item/disk/virus/tider
	name = "Tider Rootkit Disk"
	desc = "A disk containing the sneaky T1-D3R, which capable of hiding the identity of anyone using the console."
	icon_state = "datadisk2"

/obj/item/disk/virus/tider/Initialize()
	. = ..()
	infection = new datum/virus/tider()
		
/obj/item/disk/virus/logger
	name = "Keylogger Disk"
	desc = "A disk containing the mighty Keylogger virus, the bane of all Heads of Personnel. Records the last used ID on the console."
	icon_state = "datadisk3"

/obj/item/disk/virus/logger/Initialize()
	. = ..()
	infection = new datum/virus/tider()
		
/obj/item/disk/virus/cuban
	name = "Trojan Pete Disk"
	desc = "A disk containing everyone's beloved Trojan Pete Buddy, a virus that overloads the machine with ads and bloatware until it explodes."
	icon_state = "datadisk4"

/obj/item/disk/virus/cuban/Initialize()
	. = ..()
	infection = new datum/virus/cuban()