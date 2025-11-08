/obj/item/computer_hardware/hard_drive/role/antivirus
	name = "NTOS VB Basic"
	desc = "An NT Brand anti-virus disk. Its the basic package, but its better than nothing."
	icon = 'icons/obj/module.dmi'
	icon_state = "antivirus1"
	inhand_icon_state = "card-id"
	max_capacity = 16
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	icon_state = "antivirus1"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound =  'sound/items/handling/disk_pickup.ogg'
	var/resistcap = 6 //one higher than what it can cure
	virus_defense = ANTIVIRUS_BASIC
	custom_price = PAYCHECK_MEDIUM
	dont_instal = TRUE
	open_overlay = "disk_open"
	var/sender_disk_typepath = /obj/item/computer_hardware/hard_drive/role/virus/antivirus

/obj/item/computer_hardware/hard_drive/role/antivirus/update_overclocking(mob/living/user, obj/item/tool)
	var/obj/item/computer_hardware/hard_drive/role/virus/antivirus/new_disk = new sender_disk_typepath(get_turf(src))
	new_disk.hacked = TRUE
	new_disk.name = "[initial(name)] (crack)"
	new_disk.desc = "Cracked version of an NT Virus Buster subscription, made for sharing!"
	new_disk.max_capacity = max_capacity
	new_disk.icon_state = initial(icon_state)
	new_disk.icon = initial(icon)
	new_disk.update_appearance()
	new /obj/effect/particle_effect/sparks/red(get_turf(holder))
	playsound(src, "sparks", 50, 1)
	qdel(src)
	return	//Hack function is done inside on_install

/obj/item/computer_hardware/hard_drive/role/antivirus/on_install(obj/item/modular_computer/install_into, mob/living/user)
	..()
	var/obj/item/computer_hardware/hard_drive/drive = install_into.all_components[MC_HDD]
	if(drive.virus_defense >= virus_defense)
		playsound(install_into, 'sound/machines/defib_saftyOff.ogg', 50, TRUE)
		balloon_alert(user, "Your device already has a <font color='#00f7ff'>NTOS Virus Buster</font> Subscription Package. Version currently installed <font color='#00f7ff'>Lvl-[drive.virus_defense]</font>.")
		to_chat(user, span_notice("Your device already has a <span class='cfc_cyan'>NTOS Virus Buster</span> Subscription Package. Version currently installed <span class='cfc_cyan'>Lvl-[drive.virus_defense]</span>."))
	else
		playsound(install_into, 'sound/machines/defib_success.ogg', 50, TRUE)
		drive.virus_defense = virus_defense
		balloon_alert(user, "<font color='#00f7ff'>NTOS Virus Buster Lvl-[drive.virus_defense]</font> sucessefuly installed. Your device is now <font color='#00ff2a'>SAFE!</font>")
		to_chat(user, span_notice("<span class='cfc_cyan'>NTOS Virus Buster Lvl-[drive.virus_defense]</span> sucessefuly installed. Your device is now <span class='cfc_green'>SAFE!</span>"))
		new /obj/effect/particle_effect/sparks/blue(get_turf(holder))
		playsound(install_into, "sparks", 50, 1)
		component_qdel()
		drive.trojan = FALSE	// Resets trojan victim status

/obj/item/computer_hardware/hard_drive/role/antivirus/tier2
	name = "NTOS VB Standard"
	desc = "An NT Brand anti-virus disk. This standard package will be enough to protect your system from most mundane malware."
	resistcap = 11
	icon_state = "antivirus2"
	virus_defense = ANTIVIRUS_MEDIUM
	sender_disk_typepath = /obj/item/computer_hardware/hard_drive/role/virus/antivirus/tier_2

/obj/item/computer_hardware/hard_drive/role/antivirus/tier3
	name = "NTOS VB Essential"
	desc = "An NT Brand anti-virus disk. This version actually protects your device."
	resistcap = 16
	icon_state = "antivirus3"
	virus_defense = ANTIVIRUS_GOOD
	sender_disk_typepath = /obj/item/computer_hardware/hard_drive/role/virus/antivirus/tier_3

/obj/item/computer_hardware/hard_drive/role/antivirus/tier4
	name = "NTOS VB Premium"
	desc = "The most expensive NTOS Virus Buster package. Nothing will top it!"
	resistcap = INFINITY
	icon_state = "antivirus4"
	virus_defense = ANTIVIRUS_BEST
	sender_disk_typepath = /obj/item/computer_hardware/hard_drive/role/virus/antivirus/tier_4

// Previous Medical use can be found here:

/obj/item/computer_hardware/hard_drive/role/antivirus/attack(mob/M, mob/user, def_zone)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/cured = 0
		if(H.mob_biotypes & MOB_ROBOTIC)
			H.say("Installing [src]. Please do not turn your [H.dna.species] unit off or otherwise disturb it during the installation process", forced = "antivirus")
			if(do_after(user, 45 SECONDS, H)) //it has unlimited uses, but that's balanced by being very slow
				H.say("[src] successfully installed. Initiating scan.", forced = "antivirus")
				for(var/thing in H.diseases)
					var/datum/disease/D = thing
					if(istype(D, /datum/disease/advance))
						var/datum/disease/advance/A = D
						if(A.resistance >= resistcap)
							if(A.stealth <= 4)
								H.say("Failed to delete [D].exe", forced = "antivirus")
							continue
					else if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
						H.say("Failed to delete [D].exe", forced = "antivirus")
						continue
					cured += 1
					H.say("[D].exe deleted...", forced = "antivirus")
					D.cure(TRUE)
					stoplag(5 - cured)
				if(cured)
					H.say("[cured] malicious files were deleted. Thank you for using [src].", forced = "antivirus")
				else
					H.say("No malicious files detected!", forced = "antivirus")
			return
		else
			return ..()
