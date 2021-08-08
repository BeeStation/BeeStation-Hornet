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
	var/brightness_on = 4 //luminosity when the light is on
	var/on = FALSE
	var/smile = FALSE
	var/smile_color = "#FF0000"
	var/visor_icon = "envisor"
	var/smile_state = "envirohelm_smile"
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_welding_screen/plasmaman)
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES
	visor_flags_inv = HIDEEYES|HIDEFACE|HIDEFACIALHAIR

/obj/item/clothing/head/helmet/space/plasmaman/Initialize()
	. = ..()
	visor_toggling()
	update_icon()
	cut_overlays()

/obj/item/clothing/head/helmet/space/plasmaman/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE))
		toggle_welding_screen(user)

/obj/item/clothing/head/helmet/space/plasmaman/proc/toggle_welding_screen(mob/living/user)
	if(weldingvisortoggle(user))
		if(on)
			to_chat(user, "<span class='notice'>Your helmet's torch can't pass through your welding visor!</span>")
			on = FALSE
			playsound(src, 'sound/mecha/mechmove03.ogg', 50, 1) //Visors don't just come from nothing
			update_icon()
		else
			playsound(src, 'sound/mecha/mechmove03.ogg', 50, 1) //Visors don't just come from nothing
			update_icon()

/obj/item/clothing/head/helmet/space/plasmaman/worn_overlays(isinhands)
	. = ..()
	if(!isinhands && !up)
		. += mutable_appearance('icons/mob/head.dmi', visor_icon)
	else
		cut_overlays()

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

/obj/item/clothing/head/helmet/space/plasmaman/worn_overlays(isinhands)
	. = ..()
	if(!isinhands && smile)
		var/mutable_appearance/M = mutable_appearance('icons/mob/head.dmi', smile_state)
		M.color = smile_color
		. += M
	if(!isinhands && !up)
		. += mutable_appearance('icons/mob/head.dmi', visor_icon)
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
	on = !on
	icon_state = "[initial(icon_state)][on ? "-light":""]"
	item_state = icon_state
	user.update_inv_head() //So the mob overlay updates

	if(on)
		if(!up)
			to_chat(user, "<span class='notice'>Your helmet's torch can't pass through your welding visor!</span>")
			set_light(0)
		else
			set_light(brightness_on)
	else
		set_light(0)

	for(var/X in actions)
		var/datum/action/A=X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/plasmaman/security
	name = "security plasma envirosuit helmet"
	desc = "A plasmaman containment helmet designed for security officers, protecting them from being flashed and burning alive, along-side other undesirables."
	icon_state = "security_envirohelm"
	item_state = "security_envirohelm"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 75, "stamina" = 10)

/obj/item/clothing/head/helmet/space/plasmaman/security/warden
	name = "warden's plasma envirosuit helmet"
	desc = "A plasmaman containment helmet designed for the warden, a pair of white stripes being added to differeciate them from other members of security."
	icon_state = "warden_envirohelm"
	item_state = "warden_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/medical
	name = "medical's plasma envirosuit helmet"
	desc = "An envriohelmet designed for plasmaman medical doctors, having two stripes down it's length to denote as much"
	icon_state = "doctor_envirohelm"
	item_state = "doctor_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/genetics
	name = "geneticist's plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for geneticists."
	icon_state = "geneticist_envirohelm"
	item_state = "geneticist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/viro
	name = "virology plasma envirosuit helmet"
	desc = "The helmet worn by the safest people on the station, those who are completely immune to the monstrosities they create."
	icon_state = "virologist_envirohelm"
	item_state = "virologist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/chemist
	name = "chemistry plasma envirosuit helmet"
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
	name = "science plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for scientists."
	icon_state = "scientist_envirohelm"
	item_state = "scientist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/robotics
	name = "robotics plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for roboticists."
	icon_state = "roboticist_envirohelm"
	item_state = "roboticist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/engineering
	name = "engineering plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for engineer plasmamen, the usual purple stripes being replaced by engineering's orange."
	icon_state = "engineer_envirohelm"
	item_state = "engineer_envirohelm"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 10, "fire" = 100, "acid" = 75, "stamina" = 0)

/obj/item/clothing/head/helmet/space/plasmaman/atmospherics
	name = "atmospherics plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for atmos technician plasmamen, the usual purple stripes being replaced by engineering's blue."
	icon_state = "atmos_envirohelm"
	item_state = "atmos_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/cargo
	name = "cargo plasma envirosuit helmet"
	desc = "An plasmaman envirohelmet designed for cargo techs and quartermasters."
	icon_state = "cargo_envirohelm"
	item_state = "cargo_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/mining
	name = "mining plasma envirosuit helmet"
	desc = "A khaki helmet given to plasmamen miners operating on lavaland."
	icon_state = "explorer_envirohelm"
	item_state = "explorer_envirohelm"
	visor_icon = "explorer_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/chaplain
	name = "chaplain's plasma envirosuit helmet"
	desc = "An envirohelmet specially designed for only the most pious of plasmamen."
	icon_state = "chap_envirohelm"
	item_state = "chap_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/white
	name = "white plasma envirosuit helmet"
	desc = "A generic white envirohelm."
	icon_state = "white_envirohelm"
	item_state = "white_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/hat
	name = "white plasma envirosuit helmet with top hat"
	desc = "A generic white envirohelm with a top-hat affixed to the top"
	icon_state = "hat_envirohelm"
	item_state = "hat_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/gold
	name = "designer envirosuit helmet"
	desc = "A Plasmi-Deluxe envirosuit helmet with gold woven into the fabric. A designer model like this is probably worth a pretty penny"
	icon_state = "gold_envirohelm"
	item_state = "gold_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/curator
	name = "curator's plasma envirosuit helmet"
	desc = "A slight modification on a tradiational voidsuit helmet, this helmet was Nano-Trasen's first solution to the *logistical problems* that come with employing plasmamen. Despite their limitations, these helmets still see use by historian and old-styled plasmamen alike."
	icon_state = "prototype_envirohelm"
	item_state = "prototype_envirohelm"
	actions_types = list(/datum/action/item_action/toggle_welding_screen/plasmaman)
	smile_state = "prototype_smile"
	visor_icon = "prototype_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/botany
	name = "botany plasma envirosuit helmet"
	desc = "A green and blue envirohelmet designating it's wearer as a botanist. While not specially designed for it, it would protect against minor planet-related injuries."
	icon_state = "botany_envirohelm"
	item_state = "botany_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/janitor
	name = "janitor's plasma envirosuit helmet"
	desc = "A grey helmet bearing a pair of purple stripes, designating the wearer as a janitor."
	icon_state = "janitor_envirohelm"
	item_state = "janitor_envirohelm"
//mime and clown
/obj/item/clothing/head/helmet/space/plasmaman/mime
	name = "mime envirosuit helmet"
	desc = "A black and white envirosuit helmet, specially made for the mime. Rattling bones won't stop your silent shinanigains!"
	icon_state = "mime_envirohelm"
	item_state = "mime_envirohelm"
	visor_icon = "mime_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/honk
	name = "clowns envirosuit helmet"
	desc = "A multicolor helmet that smellls of bananium and securitys tears."
	icon_state = "honk_envirohelm"
	item_state = "honk_envirohelm"
	visor_icon = "clown_envisor"
	smile_state = "clown_smile"

//command helms

/obj/item/clothing/head/helmet/space/plasmaman/command
	name = "captains envirosuit helmet"
	desc = "A helmet issued to the head of the command staff. Sleak and Stylish, as all captains should be."
	icon_state = "command_envirohelm"
	item_state = "command_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/engineering/ce
	name = "chief engineers envirohelmet"
	desc = "An envirohelmet designed for the chief engineer. It reeks of poly and plasma."
	icon_state = "ce_envirohelm"
	item_state = "ce_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/cmo
	name = "chief medical officers envirohelmet"
	desc = "A helmet issued to the head of the command staff. Sleak and Stylish, as all captains should be."
	icon_state = "cmo_envirohelm"
	item_state = "cmo_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/security/hos
	name = "head of securitys helmet"
	desc = "A reinforced envirohelmet issued to the head of the security staff. You'll need it."
	icon_state = "hos_envirohelm"
	item_state = "hos_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/rd
	name = "research directors envirosuit helmet"
	desc = "A custom made envirosuit helmet made using advanced nanofibers. Fashionable and easy to wear."
	icon_state = "rd_envirohelm"
	item_state = "rd_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/hop
	name = "head of personnels envirosuit helmet"
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

//replacements for vendors
/obj/item/clothing/head/helmet/space/plasmaman/replacement
	name = "replacement envirosuit helmet"
	desc = "An outdated helmet that allows plasma-based lifeforms to exist safely in an oxygenated environment, still kept in use as replacement helmets. While it is space worthy, it lacks the UV protection newer models come with.."
	flash_protect = 0

/obj/item/clothing/head/helmet/space/plasmaman/replacement/security
	name = "replacement security envirosuit helmet"
	desc = "An outdated containment helmet designed for security officers, lacks the UV shielding a standard helmet possesses."
	icon_state = "security_envirohelm"
	item_state = "security_envirohelm"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 75, "stamina" = 0)

/obj/item/clothing/head/helmet/space/plasmaman/replacement/medical
	name = "medical's replacement envirosuit helmet"
	desc = "An outdated envriohelmet designed for plasmaman medical doctors, having two stripes down it's length to denote as much, lacks UV shielding."
	icon_state = "doctor_envirohelm"
	item_state = "doctor_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/replacement/genetics
	name = "geneticist's replacement envirosuit helmet"
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
	name = "replacement engineering envirosuit helmet"
	desc = "A replacement helmet designed for engineer plasmamen, the usual purple stripes being replaced by engineering's orange, despite its age it has some UV protection for welding.."
	item_state = "engineer_envirohelm"
	icon_state = "engineer_envirohelm"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 10, "fire" = 100, "acid" = 75, "stamina" = 0)
	flash_protect = 1

/obj/item/clothing/head/helmet/space/plasmaman/replacement/atmospherics
	name = "replacement atmospherics envirosuit helmet"
	desc = "A space-worthy helmet specially designed for atmos technician plasmamen, the usual purple stripes being replaced by engineering's blue, despite its age is has some UV protection for welding."
	icon_state = "atmos_envirohelm"
	item_state = "atmos_envirohelm"
	flash_protect = 1

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
	name = "chaplain's replace envirosuit helmet"
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
	desc = "A tradiational voidsuit helmet, this helmet was Nano-Trasen's first solution to the *logistical problems* that come with employing plasmamen. Despite their limitations, these helmets still see use by historian and old-styled plasmamen alike."
	icon_state = "prototype_envirohelm"
	item_state = "prototype_envirohelm"
	actions_types = list()

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
