 //Suits for the pink and grey skeletons! //EVA version no longer used in favor of the Jumpsuit version


/obj/item/clothing/suit/space/eva/plasmaman
	name = "EVA plasma envirosuit"
	desc = "A special plasma containment suit designed to be space-worthy, as well as worn over other clothing. Like its smaller counterpart, it can automatically extinguish the wearer in a crisis, and holds twice as many charges."
	allowed = list(/obj/item/gun, /obj/item/ammo_casing, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/transforming/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 75, "stamina" = 0)
	resistance_flags = FIRE_PROOF
	icon_state = "plasmaman_suit"
	item_state = "plasmaman_suit"
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 10


/obj/item/clothing/suit/space/eva/plasmaman/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There [extinguishes_left == 1 ? "is" : "are"] [extinguishes_left] extinguisher charge\s left in this suit.</span>"


/obj/item/clothing/suit/space/eva/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.fire_stacks)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message("<span class='warning'>[H]'s suit automatically extinguishes [H.p_them()]!</span>","<span class='warning'>Your suit automatically extinguishes you.</span>")
			H.ExtinguishMob()
			new /obj/effect/particle_effect/water(get_turf(H))


//I just want the light feature of the hardsuit helmet
/obj/item/clothing/head/helmet/space/plasmaman
	name = "plasma envirosuit helmet"
	desc = "A special containment helmet that allows plasma-based lifeforms to exist safely in an oxygenated environment. It is space-worthy, and may be worn in tandem with other EVA gear."
	icon_state = "plasmaman-helm"
	item_state = "plasmaman-helm"
	strip_delay = 80
	flash_protect = 2
	tint = 2
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 75, "stamina" = 0)
	resistance_flags = FIRE_PROOF
	light_system = MOVABLE_LIGHT
	light_range = 4
	light_on = FALSE
	var/helmet_on = FALSE
	var/smile = FALSE
	var/smile_color = "#FF0000"
	var/visor_icon = "envisor"
	var/smile_state = "envirohelm_smile"
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_welding_screen/plasmaman)
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES
	visor_flags_inv = HIDEEYES|HIDEFACE|HIDEFACIALHAIR

/obj/item/clothing/head/helmet/space/plasmaman/Initialize(mapload)
	. = ..()
	visor_toggling()
	update_icon()
	cut_overlays()

/obj/item/clothing/head/helmet/space/plasmaman/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE))
		toggle_welding_screen(user)

/obj/item/clothing/head/helmet/space/plasmaman/proc/toggle_welding_screen(mob/living/user)
	if(weldingvisortoggle(user))
		if(helmet_on)
			to_chat(user, "<span class='notice'>Your helmet's torch can't pass through your welding visor!</span>")
			helmet_on = FALSE
			playsound(src, 'sound/mecha/mechmove03.ogg', 50, 1) //Visors don't just come from nothing
			update_icon()
		else
			playsound(src, 'sound/mecha/mechmove03.ogg', 50, 1) //Visors don't just come from nothing
			update_icon()

/obj/item/clothing/head/helmet/space/plasmaman/update_icon()
	cut_overlays()
	add_overlay(visor_icon)
	..()
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

/obj/item/clothing/head/helmet/space/plasmaman/attackby(obj/item/C, mob/living/user)
	. = ..()
	if(istype(C, /obj/item/toy/crayon))
		if(smile == FALSE)
			var/obj/item/toy/crayon/CR = C
			to_chat(user, "<span class='notice'>You start drawing a smiley face on the helmet's visor..</span>")
			if(do_after(user, 25, target = src))
				smile = TRUE
				smile_color = CR.paint_color
				to_chat(user, "You draw a smiley on the helmet visor.")
				update_icon()
				return
		if(smile == TRUE)
			to_chat(user, "<span class='notice'>Seems like someone already drew something on this helmet's visor.</span>")

/obj/item/clothing/head/helmet/space/plasmaman/worn_overlays(mutable_appearance/standing, isinhands)
	. = ..()
	if(!isinhands && smile)
		var/mutable_appearance/M = mutable_appearance('icons/mob/clothing/head.dmi', smile_state)
		M.color = smile_color
		. += M
	if(!isinhands && !up)
		. += mutable_appearance('icons/mob/clothing/head.dmi', visor_icon)
	else
		cut_overlays()

/obj/item/clothing/head/helmet/space/plasmaman/ComponentInitialize()
	. = ..()
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, .proc/wipe_that_smile_off_your_face)

///gets called when receiving the CLEAN_ACT signal from something, i.e soap or a shower. exists to remove any smiley faces drawn on the helmet.
/obj/item/clothing/head/helmet/space/plasmaman/proc/wipe_that_smile_off_your_face()
	SIGNAL_HANDLER

	if(smile)
		smile = FALSE
		cut_overlays()

/obj/item/clothing/head/helmet/space/plasmaman/attack_self(mob/user)
	helmet_on = !helmet_on
	icon_state = "[initial(icon_state)][helmet_on ? "-light":""]"
	item_state = icon_state
	user.update_inv_head() //So the mob overlay updates

	if(helmet_on)
		if(!up)
			to_chat(user, "<span class='notice'>Your helmet's torch can't pass through your welding visor!</span>")
			set_light_on(FALSE)
		else
			set_light_on(TRUE)
	else
		set_light_on(FALSE)

	for(var/X in actions)
		var/datum/action/A=X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/plasmaman/security
	name = "security envirosuit helmet"
	desc = "A plasmaman containment helmet designed for security officers, protecting them from burning alive, along-side other undesirables."
	icon_state = "security_envirohelm"
	item_state = "security_envirohelm"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 75, "stamina" = 10)

/obj/item/clothing/head/helmet/space/plasmaman/security/warden
	name = "warden's envirosuit helmet"
	desc = "A plasmaman containment helmet designed for the warden, a pair of white stripes being added to differentiate them from other members of security."
	icon_state = "warden_envirohelm"
	item_state = "warden_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/medical
	name = "medical's envirosuit helmet"
	desc = "An envirohelmet designed for plasmaman medical doctors, having two stripes down it's length to denote as much"
	icon_state = "doctor_envirohelm"
	item_state = "doctor_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/genetics
	name = "geneticist's envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for geneticists."
	icon_state = "geneticist_envirohelm"
	item_state = "geneticist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/viro
	name = "virology envirosuit helmet"
	desc = "The helmet worn by the safest people on the station, those who are completely immune to the monstrosities they create."
	icon_state = "virologist_envirohelm"
	item_state = "virologist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/chemist
	name = "chemistry envirosuit helmet"
	desc = "A plasmaman envirosuit designed for chemists, two orange stripes going down it's face."
	icon_state = "chemist_envirohelm"
	item_state = "chemist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/emt
	name = "paramedic envirosuit helmet"
	desc = "An envirosuit helmet only for the bravest medical plasmaman."
	icon_state = "emt_envirohelm"
	item_state = "emt_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/security/secmed
	name = "brig physician envirosuit helmet"
	desc = "An envirosuit helmet made for brig physicians."
	icon_state = "secmed_envirohelm"
	item_state = "secmed_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/science
	name = "science envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for scientists."
	icon_state = "scientist_envirohelm"
	item_state = "scientist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/robotics
	name = "robotics envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for roboticists."
	icon_state = "roboticist_envirohelm"
	item_state = "roboticist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/engineering
	name = "engineering envirosuit helmet"
	desc = "A space-worthy helmet specially designed for engineer plasmamen, the usual purple stripes being replaced by engineering's orange."
	icon_state = "engineer_envirohelm"
	item_state = "engineer_envirohelm"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 10, "fire" = 100, "acid" = 75, "stamina" = 0)

/obj/item/clothing/head/helmet/space/plasmaman/engineering/atmospherics
	name = "atmospherics envirosuit helmet"
	desc = "A space-worthy helmet specially designed for atmos technician plasmamen, the usual purple stripes being replaced by engineering's blue."
	icon_state = "atmos_envirohelm"
	item_state = "atmos_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/cargo
	name = "cargo envirosuit helmet"
	desc = "An plasmaman envirohelmet designed for cargo techs and quartermasters."
	icon_state = "cargo_envirohelm"
	item_state = "cargo_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/mining
	name = "mining envirosuit helmet"
	desc = "A khaki helmet given to plasmamen miners operating on lavaland."
	icon_state = "explorer_envirohelm"
	item_state = "explorer_envirohelm"
	visor_icon = "explorer_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/chaplain
	name = "chaplain's envirosuit helmet"
	desc = "An envirohelmet specially designed for only the most pious of plasmamen."
	icon_state = "chap_envirohelm"
	item_state = "chap_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/white
	name = "white envirosuit helmet"
	desc = "A generic white envirohelm."
	icon_state = "white_envirohelm"
	item_state = "white_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/hat
	name = "white envirosuit helmet with top hat"
	desc = "A generic white envirohelm with a top-hat affixed to the top"
	icon_state = "hat_envirohelm"
	item_state = "hat_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/gold
	name = "designer envirosuit helmet"
	desc = "A Plasmi-Deluxe envirosuit helmet with gold woven into the fabric. A designer model like this is probably worth a pretty penny"
	icon_state = "gold_envirohelm"
	item_state = "gold_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/curator
	name = "curator's envirosuit helmet"
	desc = "A slight modification on a tradiational voidsuit helmet, this helmet was Nano-Trasen's first solution to the *logistical problems* that come with employing plasmamen. Despite their limitations, these helmets still see use by historian and old-styled plasmamen alike."
	icon_state = "prototype_envirohelm"
	item_state = "prototype_envirohelm"
	actions_types = list(/datum/action/item_action/toggle_welding_screen/plasmaman)
	smile_state = "prototype_smile"
	visor_icon = "prototype_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/botany
	name = "botany envirosuit helmet"
	desc = "A green and blue envirohelmet designating it's wearer as a botanist. While not specially designed for it, it would protect against minor planet-related injuries."
	icon_state = "botany_envirohelm"
	item_state = "botany_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/janitor
	name = "janitor's envirosuit helmet"
	desc = "A grey helmet bearing a pair of purple stripes, designating the wearer as a janitor."
	icon_state = "janitor_envirohelm"
	item_state = "janitor_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/exploration
	name = "exploration envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for the exploration crew, decked out in their iconic garish turquiose."
	icon_state = "exploration_envirohelm"
	item_state = "exploration_envirohelm"
	visor_icon = "explorer_envisor"

//mime and clown
/obj/item/clothing/head/helmet/space/plasmaman/mime
	name = "mime's envirosuit helmet"
	desc = "A black and white envirosuit helmet, specially made for the mime. Rattling bones won't stop your silent shenanigans!"
	icon_state = "mime_envirohelm"
	item_state = "mime_envirohelm"
	visor_icon = "mime_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/honk
	name = "clown's envirosuit helmet"
	desc = "A multicolor helmet that smells of bananium and security's tears."
	icon_state = "honk_envirohelm"
	item_state = "honk_envirohelm"
	visor_icon = "clown_envisor"
	smile_state = "clown_smile"

//command helms
/obj/item/clothing/head/helmet/space/plasmaman/command
	name = "captain's envirosuit helmet"
	desc = "A helmet issued to the head of the command staff. Sleak and stylish, as all captains should be."
	icon_state = "command_envirohelm"
	item_state = "command_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/engineering/ce
	name = "chief engineer's envirohelmet"
	desc = "An envirohelmet designed for the Chief Engineer. It reeks of Poly and plasma."
	icon_state = "ce_envirohelm"
	item_state = "ce_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/cmo
	name = "chief medical officer's envirohelmet"
	desc = "A helmet issued to the chief of the medical staff."
	icon_state = "cmo_envirohelm"
	item_state = "cmo_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/security/hos
	name = "head of security's helmet"
	desc = "A reinforced envirohelmet issued to the head of the security staff. You'll need it."
	icon_state = "hos_envirohelm"
	item_state = "hos_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/rd
	name = "research director's envirosuit helmet"
	desc = "A custom made envirosuit helmet made using advanced nanofibers. Fashionable and easy to wear."
	icon_state = "rd_envirohelm"
	item_state = "rd_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/hop
	name = "head of personnel's envirosuit helmet"
	desc = "An envirosuit helmet made for the Head of Personnel. Some corgi hair is stuck to it."
	icon_state = "hop_envirohelm"
	item_state = "hop_envirohelm"

//centcom envirohelms
/obj/item/clothing/head/helmet/space/plasmaman/commander
	name = "CentCom commander envirosuit helmet"
	desc = "A special containment helmet designed for the Higher Central Command Staff. Not many of these exist, as CentCom does not usually employ plasmamen to higher staff positions due to their complications."
	icon_state = "commander_envirohelm"
	item_state = "commander_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/official
	name = "CentCom official envirosuit helmet"
	desc = "A special containment helmet designed for CentCom Staff. They sure do love their green."
	icon_state = "official_envirohelm"
	item_state = "official_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/intern
	name = "CentCom intern envirosuit helmet"
	desc = "A special containment helmet designed for CentCom Staff. You know, so any coffee spills don't kill the poor sod."
	icon_state = "intern_envirohelm"
	item_state = "intern_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/replacement/equipped(mob/living/carbon/user, slot)
	..()
	if(slot == ITEM_SLOT_HEAD && !isplasmaman(user))
		user.dropItemToGround(src)
		to_chat(user, "<span class='danger'>[src] doesn't fit on your head and falls to the ground.</span>")

//replacements for vendors
/obj/item/clothing/head/helmet/space/plasmaman/replacement
	name = "replacement envirosuit helmet"
	desc = "An outdated helmet that allows plasma-based lifeforms to exist safely in an oxygenated environment, still kept in use as replacement helmets."

/obj/item/clothing/head/helmet/space/plasmaman/replacement/security
	name = "security replacement envirosuit helmet"
	desc = "An outdated containment helmet designed for security officers."
	icon_state = "security_envirohelm"
	item_state = "security_envirohelm"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 75, "stamina" = 0)

/obj/item/clothing/head/helmet/space/plasmaman/replacement/medical
	name = "medical replacement envirosuit helmet"
	desc = "An outdated envirohelmet designed for plasmaman medical doctors, having two stripes down it's length to denote as much."
	icon_state = "doctor_envirohelm"
	item_state = "doctor_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/replacement/genetics
	name = "geneticist replacement envirosuit helmet"
	desc = "An outdated plasmaman envirohelmet designed for geneticists."
	icon_state = "geneticist_envirohelm"
	item_state = "geneticist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/replacement/viro
	name = "virology replacement envirosuit helmet"
	desc = "The replacement helmet worn by the safest people on the station, those who are completely immune to the monstrosities they create."
	icon_state = "virologist_envirohelm"
	item_state = "virologist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/replacement/chemist
	name = "chemistry replacement envirosuit helmet"
	desc = "A plasmaman envirosuit designed for chemists, two orange stripes going down it's face."
	icon_state = "chemist_envirohelm"
	item_state = "chemist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/replacement/science
	name = "science replacement envirosuit helmet"
	desc = "A replacement plasmaman envirohelmet designed for scientists."
	icon_state = "scientist_envirohelm"
	item_state = "scientist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/replacement/robotics
	name = "robotics replacement envirosuit helmet"
	desc = "A replacement plasmaman envirohelmet designed for roboticists."
	icon_state = "roboticist_envirohelm"
	item_state = "roboticist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/replacement/engineering
	name = "engineering replacement envirosuit helmet"
	desc = "A replacement helmet designed for engineer plasmamen, the usual purple stripes being replaced by engineering's orange."
	item_state = "engineer_envirohelm"
	icon_state = "engineer_envirohelm"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 10, "fire" = 100, "acid" = 75, "stamina" = 0)

/obj/item/clothing/head/helmet/space/plasmaman/replacement/engineering/atmospherics
	name = "atmospherics replacement envirosuit helmet"
	desc = "A space-worthy helmet specially designed for atmos technician plasmamen, the usual purple stripes being replaced by engineering's blue."
	icon_state = "atmos_envirohelm"
	item_state = "atmos_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/replacement/cargo
	name = "cargo replacement envirosuit helmet"
	desc = "An replacement envirohelmet designed for cargo techs and quartermasters."
	icon_state = "cargo_envirohelm"
	item_state = "cargo_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/replacement/mining
	name = "mining replacement envirosuit helmet"
	desc = "A khaki replacement helmet given to plasmamen miners operating on lavaland."
	icon_state = "explorer_envirohelm"
	item_state = "explorer_envirohelm"
	visor_icon = "explorer_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/replacement/chaplain
	name = "chaplain's replacement envirosuit helmet"
	desc = "An outdated envirohelmet specially designed for only the most pious of plasmamen."
	icon_state = "chap_envirohelm"
	item_state = "chap_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/replacement/white
	name = "white replacement envirosuit helmet"
	desc = "A generic white envirohelm, slightly dated."
	icon_state = "white_envirohelm"
	item_state = "white_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/replacement/curator
	name = "curator's replacement envirosuit helmet"
	desc = "A traditional voidsuit helmet, this helmet was Nano-Trasen's first solution to the *logistical problems* that come with employing plasmamen. Despite their limitations, these helmets still see use by historian and old-styled plasmamen alike."
	icon_state = "prototype_envirohelm"
	item_state = "prototype_envirohelm"
	actions_types = list()
	smile_state = "prototype_smile"

/obj/item/clothing/head/helmet/space/plasmaman/replacement/botany
	name = "botany replacement envirosuit helmet"
	desc = "A green and blue replacement envirohelmet designating it's wearer as a botanist. While not specially designed for it, it would protect against minor planet-related injuries."
	icon_state = "botany_envirohelm"
	item_state = "botany_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/replacement/janitor
	name = "janitor's replacement envirosuit helmet"
	desc = "A replacement grey helmet bearing a pair of purple stripes, designating the wearer as a janitor."
	icon_state = "janitor_envirohelm"
	item_state = "janitor_envirohelm"

// The Mark 2 variants of the standard envirohelms.
/obj/item/clothing/head/helmet/space/plasmaman/mark2
	name = "Mk.II envirosuit helmet"
	desc = "A sleek new plasmaman containment helmet, painted in classic Hazardous Orange."
	icon_state = "assistant_openvirohelm"
	item_state = "assistant_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/security/mark2
	name = "security Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for security officers, retaining all the old protections for a new era of fragile law enforcement."
	icon_state = "security_openvirohelm"
	item_state = "security_openvirohelm"
	visor_icon = "openvisor"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 75, "stamina" = 10)

/obj/item/clothing/head/helmet/space/plasmaman/security/warden/mark2
	name = "warden's Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for the warden. All the chic of the standard look with the Warden's iconic reflective white stripe."
	icon_state = "warden_openvirohelm"
	item_state = "warden_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/medical/mark2
	name = "medical's Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for medical doctors. Glue your fellow crewmen back together and make a fashion statement while you're at it."
	icon_state = "doctor_openvirohelm"
	item_state = "doctor_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/genetics/mark2
	name = "geneticist's Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for geneticists. Pushing the boundaries of organic life never looked so good!"
	icon_state = "geneticist_openvirohelm"
	item_state = "geneticist_envirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/viro/mark2
	name = "virology Mk.II envirosuit helmet"
	desc = "The helmet worn by the safest people on the station, those who are completely immune to the monstrosities they create, including the monstrosities of outdated fashion"
	icon_state = "virologist_openvirohelm"
	item_state = "virologist_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/chemist/mark2
	name = "chemistry Mk.II envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for chemists."
	icon_state = "chemist_openvirohelm"
	item_state = "chemist_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/emt/mark2
	name = "paramedic Mk.II envirosuit helmet"
	desc = "A new and improved envirosuit helmet only for the bravest medical plasmaman."
	icon_state = "emt_openvirohelm"
	item_state = "emt_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/security/secmed/mark2
	name = "brig physician Mk.II envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for brig physicians."
	icon_state = "secmed_openvirohelm"
	item_state = "secmed_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/science/mark2
	name = "science Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for scientists."
	icon_state = "scientist_openvirohelm"
	item_state = "scientist_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/robotics/mark2
	name = "robotics Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for roboticists."
	icon_state = "roboticist_openvirohelm"
	item_state = "roboticist_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/engineering/mark2
	name = "engineering Mk.II envirosuit helmet"
	desc = "A new iteration upon the classic space-worthy design, painted in classic engineering pigments."
	icon_state = "engineer_openvirohelm"
	item_state = "engineer_openvirohelm"
	visor_icon = "openvisor"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 10, "fire" = 100, "acid" = 75, "stamina" = 0)

/obj/item/clothing/head/helmet/space/plasmaman/engineering/atmospherics/mark2
	name = "atmospherics Mk.II envirosuit helmet"
	desc = "A new iteration upon the classic space-worthy design, painted in classic atmosian pigments."
	icon_state = "atmos_openvirohelm"
	item_state = "atmos_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/cargo/mark2
	name = "cargo Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for cargo techs and quartermasters. Neo-liberal grifting has never been this groovy"
	icon_state = "cargo_openvirohelm"
	item_state = "cargo_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/mining/mark2
	name = "mining Mk.II envirosuit helmet"
	desc = "A new styling of the classi khaki helmet given to plasmamen miners."
	icon_state = "explorer_openvirohelm"
	item_state = "explorer_openvirohelm"
	visor_icon = "explorer_openvisor"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/chaplain/mark2
	name = "chaplain's Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for only the most pious of plasmamen. Old age traditions wrapped in a new age shell."
	icon_state = "chap_openvirohelm"
	item_state = "chap_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/white/mark2
	name = "white Mk.II envirosuit helmet"
	desc = "The generic white envirohelm brought into a new era of fashion."
	icon_state = "white_openvirohelm"
	item_state = "white_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/botany/mark2
	name = "botany Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for botanists. Now specially designed against minor planet-related injuries."
	icon_state = "botany_openvirohelm"
	item_state = "botany_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/janitor/mark2
	name = "janitor's Mk.II envirosuit helmet"
	desc = "A new look for the flashy janitor enviro helmet. Get the appreciation you deserve with this cutting edge vogue."
	icon_state = "janitor_openvirohelm"
	item_state = "janitor_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/exploration/mark2
	name = "mining envirosuit helmet"
	desc = "A new plasmaman envirohelmet designed for the exploration crew, decked out in their iconic garish turquiose."
	icon_state = "exploration_openvirohelm"
	item_state = "exploration_openvirohelm"
	visor_icon = "explorer_openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/command/mark2
	name = "captain's Mk.II envirosuit helmet"
	desc = "A new age helmet issued to the head of the command staff. Sleeker and stylish-er, as all captains should be."
	icon_state = "command_openvirohelm"
	item_state = "command_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/engineering/ce/mark2
	name = "chief engineer's Mk.II envirohelmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for the Chief Engineer. This one doesn't smell as strongly of bird poo."
	icon_state = "ce_openvirohelm"
	item_state = "ce_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/cmo/mark2
	name = "chief medical officer's Mk.II envirohelmet"
	desc = "A sleek new helmet issued to the chief of the medical staff. Show off that big forehead of yours to all the squares in science."
	icon_state = "cmo_openvirohelm"
	item_state = "cmo_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/security/hos/mark2
	name = "head of security's Mk.II envirosuit helmet"
	desc = "A new variant of the head of security's classic reinforced envirohelmet. You'll still need it."
	icon_state = "hos_openvirohelm"
	item_state = "hos_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/rd/mark2
	name = "research director's Mk.II envirosuit helmet"
	desc = "A stylish new helmet issued to the director of the research staff. Show off that big forehead of yours to all the wimps in medical."
	icon_state = "rd_openvirohelm"
	item_state = "rd_openvirohelm"
	visor_icon = "openvisor"

/obj/item/clothing/head/helmet/space/plasmaman/hop/mark2
	name = "head of personnel's Mk.II envirosuit helmet"
	desc = "An new envirosuit helmet made for the Head of Personnel, sprayed with Corgi pheromones."
	icon_state = "hop_openvirohelm"
	item_state = "hop_openvirohelm"
	visor_icon = "openvisor"

// The Protective helmet variants

/obj/item/clothing/head/helmet/space/plasmaman/command/protective
	name = "captain's Mk.II envirosuit helmet"
	desc = "A better protected helmet issued to the head of the command staff. This might help. Might."
	icon_state = "command_armouredenvirohelm"
	item_state = "command_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/engineering/ce/protective
	name = "chief engineer's Mk.II envirohelmet"
	desc = "A braced plasmaman containment helmet design for the Chief Engineer."
	icon_state = "ce_armouredenvirohelm"
	item_state = "ce_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/cmo/protective
	name = "chief medical officer's Mk.II envirohelmet"
	desc = "A bulky new helmet issued to the chief of the medical staff."
	icon_state = "cmo_armouredenvirohelm"
	item_state = "cmo_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/security/hos/protective
	name = "head of security's Mk.II envirosuit helmet"
	desc = "A better-armoured variant of the head of security's classic reinforced envirohelmet."
	icon_state = "hos_armouredenvirohelm"
	item_state = "hos_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/rd/protective
	name = "research director's Mk.II envirosuit helmet"
	desc = "An encumbering new helmet issued to the director of the research staff."
	icon_state = "rd_armouredenvirohelm"
	item_state = "rd_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/hop/protective
	name = "head of personnel's Mk.II envirosuit helmet"
	desc = "An new, debatably safer envirosuit helmet made for the Head of Personnel."
	icon_state = "hop_armouredenvirohelm"
	item_state = "hop_armouredenvirohelm"
	visor_icon = "armouredenvisor"


/obj/item/clothing/head/helmet/space/plasmaman/protective
	name = "protective envirosuit helmet"
	desc = "This helmet was originally designed for engineering crews on the more ramshackle plasma mining colonies. Now, after several design improvements and class-action lawsuits, this helmet has been distributed once more as a fun cosmetic choice for NTs plasmafolk."
	icon_state = "assistant_armouredenvirohelm"
	item_state = "assistant_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/security/protective
	name = "security protective envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for security officers."
	icon_state = "security_armouredenvirohelm"
	item_state = "security_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/security/warden/protective
	name = "warden's Mk.II envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for the warden."
	icon_state = "warden_armouredenvirohelm"
	item_state = "warden_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/medical/protective
	name = "medical's Mk.II envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for medical doctors."
	icon_state = "doctor_armouredenvirohelm"
	item_state = "doctor_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/genetics/protective
	name = "geneticist's Mk.II envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for geneticists."
	icon_state = "geneticist_armouredenvirohelm"
	item_state = "geneticist_armouredvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/viro/protective
	name = "virology Mk.II envirosuit helmet"
	desc = "The helmet worn by the safest people on the station, those who are completely immune to the monstrosities they create."
	icon_state = "virologist_armouredenvirohelm"
	item_state = "virologist_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/chemist/protective
	name = "chemistry Mk.II envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for chemists."
	icon_state = "chemist_armouredenvirohelm"
	item_state = "chemist_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/emt/protective
	name = "paramedic Mk.II envirosuit helmet"
	desc = "A new and improved envirosuit helmet only for the bravest medical plasmaman."
	icon_state = "emt_armouredenvirohelm"
	item_state = "emt_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/security/secmed/protective
	name = "brig physician Mk.II envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for brig physicians."
	icon_state = "secmed_armouredenvirohelm"
	item_state = "secmed_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/science/protective
	name = "science Mk.II envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for scientists."
	icon_state = "scientist_armouredenvirohelm"
	item_state = "scientist_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/robotics/protective
	name = "robotics Mk.II envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for roboticists."
	icon_state = "roboticist_armouredenvirohelm"
	item_state = "roboticist_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/engineering/protective
	name = "engineering Mk.II envirosuit helmet"
	desc = "A safer looking re-imagining of the classic space-worthy design, painted in classic engineering pigments."
	icon_state = "engineer_armouredenvirohelm"
	item_state = "engineer_armouredenvirohelm"
	visor_icon = "armouredenvisor"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 10, "fire" = 100, "acid" = 75, "stamina" = 0)

/obj/item/clothing/head/helmet/space/plasmaman/engineering/atmospherics/protective
	name = "atmospherics Mk.II envirosuit helmet"
	desc = "A safer looking re-imagining of the classic space-worthy design, painted in classic atmosian pigments."
	icon_state = "atmos_armouredenvirohelm"
	item_state = "atmos_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/cargo/protective
	name = "cargo Mk.II envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for cargo techs and quartermasters."
	icon_state = "cargo_armouredenvirohelm"
	item_state = "cargo_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/mining/protective
	name = "mining Mk.II envirosuit helmet"
	desc = "A new styling of the classic khaki helmet given to plasmamen miners."
	icon_state = "explorer_armouredenvirohelm"
	item_state = "explorer_armouredenvirohelm"
	visor_icon = "explorer_armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/chaplain/protective
	name = "chaplain's Mk.II envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for only the most pious of plasmamen."
	icon_state = "chap_armouredenvirohelm"
	item_state = "chap_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/white/protective
	name = "white Mk.II envirosuit helmet"
	desc = "The generic white envirohelm wrapped in a bulky, possibly more protective shell."
	icon_state = "white_armouredenvirohelm"
	item_state = "white_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/botany/protective
	name = "botany Mk.II envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for botanists."
	icon_state = "botany_armouredenvirohelm"
	item_state = "botany_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/janitor/protective
	name = "janitor's Mk.II envirosuit helmet"
	desc = "A bulkier variation on the janitor envirohelmet."
	icon_state = "janitor_armouredenvirohelm"
	item_state = "janitor_armouredenvirohelm"
	visor_icon = "armouredenvisor"

/obj/item/clothing/head/helmet/space/plasmaman/exploration/protective
	name = "mining envirosuit helmet"
	desc = "A new plasmaman envirohelmet designed for the exploration crew, decked out in their iconic garish turquiose."
	icon_state = "exploration_armouredenvirohelm"
	item_state = "exploration_armouredenvirohelm"
	visor_icon = "explorer_armouredenvisor"
