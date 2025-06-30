/obj/item/computer_hardware/hard_drive/role/antivirus
	name = "NT Virus Buster Basic"
	desc = "An NT Brand anti-virus disk. Its the basic package, but its better than nothing."
	icon = 'icons/obj/module.dmi'
	icon_state = "antivirus4"
	item_state = "card-id"
	max_capacity = 16
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	icon_state = "datadisk0"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound =  'sound/items/handling/disk_pickup.ogg'
	var/resistcap = 6 //one higher than what it can cure
	virus_defense = 1
	custom_price = 50
	dont_instal = TRUE

/obj/item/computer_hardware/hard_drive/role/antivirus/update_overclocking(mob/living/user, obj/item/tool)
	return	//Hack function is done inside on_install

/obj/item/computer_hardware/hard_drive/role/antivirus/on_install(obj/item/modular_computer/install_into, mob/living/user)
	..()
	var/obj/item/computer_hardware/hard_drive/drive = install_into.all_components[MC_HDD]
	if(hacked)
		if(drive.virus_defense)
			to_chat(user, span_notice("<font color='#ff0033'>!! INTRUSION DETECTED !!</font> <font color='#00f7ff'>NTOS Virus Buster Lvl-[drive.virus_defense]</font> core integrity <font color='#ff6600'>BREACHED</font>. Protection services <font color='#ff0000'>DISABLED</font>."))
			drive.virus_defense = 0
			new /obj/effect/particle_effect/sparks/red(get_turf(holder))
			playsound(install_into, "sparks", 50, 1)
			install_into.uninstall_component(src)
			qdel(src)
		else
			to_chat(user, span_notice("<font color='#15ff00'>(SYS_CHECK)</font> → Antivirus module: <font color='#ff0000'>MISSING</font>."))
		playsound(install_into, 'sound/machines/defib_failed.ogg', 50, TRUE)
		return
	if(drive.virus_defense >= virus_defense)
		playsound(install_into, 'sound/machines/defib_saftyOff.ogg', 50, TRUE)
		to_chat(user, span_notice("Your device already has a <font color='#00f7ff'>NTOS Virus Buster</font> Subscription Package. Version currently installed <font color='#00f7ff'>Lvl-[drive.virus_defense]</font>."))
	else
		playsound(install_into, 'sound/machines/defib_success.ogg', 50, TRUE)
		drive.virus_defense = virus_defense
		to_chat(user, span_notice("<font color='#00f7ff'>NTOS Virus Buster Lvl-[drive.virus_defense]</font> sucessefuly installed. Your device is now <font color='#00ff2a'>SAFE!</font>"))
		new /obj/effect/particle_effect/sparks/blue(get_turf(holder))
		playsound(install_into, "sparks", 50, 1)
		install_into.uninstall_component(src)
		qdel(src)

/obj/item/computer_hardware/hard_drive/role/antivirus/tier2
	name = "NT Virus Buster Standard"
	desc = "An NT Brand anti-virus disk. This standard package will be enough to protect your system from most mundane malware."
	resistcap = 11
	icon_state = "antivirus1"
	virus_defense = 2

/obj/item/computer_hardware/hard_drive/role/antivirus/tier3
	name = "NT Virus Buster Essential"
	desc = "An NT Brand anti-virus disk. This version actually protects your device."
	resistcap = 16
	icon_state = "antivirus3"
	virus_defense = 3

/obj/item/computer_hardware/hard_drive/role/antivirus/tier4
	name = "NT Virus Buster Premium"
	desc = "The most expensive NT Virus Buster package. Nothing will top it!"
	resistcap = INFINITY
	icon_state = "antivirus2"
	virus_defense = 4

// Previous Medical use can be found here:

/obj/item/computer_hardware/hard_drive/role/antivirus/attack(mob/M, mob/user, def_zone)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/cured = 0
		if(MOB_ROBOTIC in H.mob_biotypes)
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
