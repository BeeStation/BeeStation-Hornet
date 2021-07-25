/obj/item/disk/antivirus
	name = "NTOS defender"
	desc = "The default antivirus for all nanotrasen systems. Just plug it in and watch it fail to work."
	var/resistcap = 6 //one higher than what it can cure
	icon_state = "antivirus4"

/obj/item/disk/antivirus/attack(mob/M, mob/user, def_zone)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/cured = 0
		if(MOB_ROBOTIC in H.mob_biotypes)
			H.say("Installing [src]. Please do not turn your [H.dna.species] unit off or otherwise disturb it during the installation process")
			if(do_mob(user, H, 450)) //it has unlimited uses, but that's balanced by being very slow
				H.say("[src] succesfully installed. Initiating scan.")
				for(var/thing in H.diseases)
					var/datum/disease/D = thing
					if(istype(D, /datum/disease/advance))
						var/datum/disease/advance/A = D
						if(A.resistance >= resistcap)
							if(A.stealth <= 4)
								H.say("Failed to delete [D].exe")
							continue
					else if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
						H.say("Failed to delete [D].exe")
						continue
					cured += 1
					H.say("[D].exe deleted...")
					D.cure(TRUE)
					stoplag(5 - cured)
				if(cured)
					H.forcesay("[cured] malicious files were deleted. Thank you for using [src]")
				else
					H.forcesay("No malicious files detected!")
			return
		else
			return ..()


/obj/item/disk/antivirus/tier2
	name = "Ahoy"
	desc = "A free antivirus, which works on most mundane malware, but allows most well-engineered viruses to slip past."
	resistcap = 11
	icon_state = "antivirus1"

/obj/item/disk/antivirus/tier3
	name = "McValozk"
	desc = "A robust antivirus for most needs, most noteable for its ties to a notorious expatriate, who the brand has since denounced."
	resistcap = 16
	icon_state = "antivirus3"

/obj/item/disk/antivirus/tier4
	name = "Nano-Ton"
	desc = "An expensive, non-standard antivirus mostly used by bigwigs with something to hide."
	resistcap = INFINITY
	icon_state = "antivirus2"
