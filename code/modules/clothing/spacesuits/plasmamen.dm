//Suits for the pink and grey skeletons! //EVA version no longer used in favor of the Jumpsuit version


/obj/item/clothing/suit/space/eva/plasmaman
	name = "EVA plasma envirosuit"
	desc = "A special plasma containment suit designed to be space-worthy, as well as worn over other clothing. Like its smaller counterpart, it can automatically extinguish the wearer in a crisis, and holds twice as many charges."
	allowed = list(/obj/item/gun, /obj/item/ammo_casing, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank)
	armor_type = /datum/armor/eva_plasmaman
	resistance_flags = FIRE_PROOF
	icon_state = "plasmaman_suit"
	inhand_icon_state = "plasmaman_suit"
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 10



/datum/armor/eva_plasmaman
	bio = 100
	fire = 100
	acid = 75
	bleed = 10

/obj/item/clothing/suit/space/eva/plasmaman/examine(mob/user)
	. = ..()
	. += span_notice("There [extinguishes_left == 1 ? "is" : "are"] [extinguishes_left] extinguisher charge\s left in this suit.")


/obj/item/clothing/suit/space/eva/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.fire_stacks)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message(span_warning("[H]'s suit automatically extinguishes [H.p_them()]!"),span_warning("Your suit automatically extinguishes you."))
			H.extinguish_mob()
			new /obj/effect/particle_effect/water(get_turf(H))


//I just want the light feature of the hardsuit helmet
/obj/item/clothing/head/helmet/space/plasmaman
	name = "plasma envirosuit helmet"
	desc = "A special containment helmet that allows plasma-based lifeforms to exist safely in an oxygenated environment. It is space-worthy, and may be worn in tandem with other EVA gear."
	icon = 'icons/obj/clothing/head/plasmaman_hats.dmi'
	worn_icon = 'icons/mob/clothing/head/plasmaman_head.dmi'
	icon_state = "helmet"
	inhand_icon_state = "helmet"
	greyscale_colors = "#DF5900#A349A4#DF5900"
	greyscale_config = /datum/greyscale_config/plasmaman_helmet_default
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_helmet_default_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_helmet_default_inhand_right
	greyscale_config_worn = /datum/greyscale_config/plasmaman_helmet_default_worn
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS
	strip_delay = 80
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	armor_type = /datum/armor/space_plasmaman
	resistance_flags = FIRE_PROOF
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 4
	light_on = FALSE
	var/helmet_on = FALSE
	var/smile = FALSE
	var/smile_color = "#FF0000"
	var/smile_state = "envirohelm_smile"
	var/visor_state = "enviro_visor"
	var/lamp_functional = TRUE
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_welding_screen)
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES
	visor_flags_inv = HIDEEYES|HIDEFACE|HIDEFACIALHAIR


/datum/armor/space_plasmaman
	bio = 100
	fire = 100
	acid = 75
	bleed = 10

/obj/item/clothing/head/helmet/space/plasmaman/Initialize(mapload)
	. = ..()
	visor_toggling()

/obj/item/clothing/head/helmet/space/plasmaman/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE))
		toggle_welding_screen(user)

/obj/item/clothing/head/helmet/space/plasmaman/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_welding_screen))
		toggle_welding_screen(user)
		return

	return ..()

/obj/item/clothing/head/helmet/space/plasmaman/proc/toggle_welding_screen(mob/living/user)
	if(!weldingvisortoggle(user))
		return
	if(helmet_on)
		to_chat(user, span_notice("Your helmet's torch can't pass through your welding visor!"))
		helmet_on = FALSE
	playsound(src, 'sound/mecha/mechmove03.ogg', 50, 1) //Visors don't just come from nothing
	update_icon()
	update_button_icons(user)

/obj/item/clothing/head/helmet/space/plasmaman/update_icon()
	update_overlays()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_worn_head()

/obj/item/clothing/head/helmet/space/plasmaman/attackby(obj/item/item, mob/living/user)
	. = ..()
	if(istype(item, /obj/item/light/bulb) && !lamp_functional)
		lamp_functional = TRUE
		qdel(item)
		to_chat(user, span_notice("You repair the broken headlamp!"))
	if(istype(item, /obj/item/toy/crayon))
		if(smile)
			to_chat(user, span_notice("Seems like someone already drew something on the helmet's visor."))
		else
			var/obj/item/toy/crayon/CR = item
			to_chat(user, span_notice("You start drawing a smiley face on the helmet's visor.."))
			if(do_after(user, 25, target = src))
				smile = TRUE
				smile_color = CR.paint_color
				to_chat(user, "You draw a smiley on the helmet visor.")
				update_icon()
				update_button_icons(user)
		return

/obj/item/clothing/head/helmet/space/plasmaman/equipped(mob/living/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	var/obj/item/organ/lungs/living_lungs = human_user.get_organ_slot(ORGAN_SLOT_LUNGS)
	//Early return if its not on the head slot, on a mob that breathes plasma
	if(slot != ITEM_SLOT_HEAD || living_lungs.breathing_class == /datum/breathing_class/plasma || ishumantesting(human_user))
		return

	user.dropItemToGround(src)
	user.balloon_alert(user, "incompatible biology!")
	playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
	to_chat(user, span_danger("[src] buzzes smartly as it detaches from [user]'s head."))

/obj/item/clothing/head/helmet/space/plasmaman/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, item_layer, atom/origin)
	. = ..()
	if(!isinhands)
		if(smile)
			var/mutable_appearance/M = mutable_appearance('icons/mob/clothing/head/plasmaman_head.dmi', smile_state, item_layer)
			M.color = smile_color
			. += M
		if(helmet_on)
			. += mutable_appearance('icons/mob/clothing/head/plasmaman_head.dmi', visor_state + "_light", item_layer)
		if(!up)
			. += mutable_appearance('icons/mob/clothing/head/plasmaman_head.dmi', visor_state + "_weld", item_layer)
		if(attached_hat)
			. += attached_hat.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head/default.dmi')

/obj/item/clothing/head/helmet/space/plasmaman/wash(clean_types)
	. = ..()
	if(smile && (clean_types & CLEAN_TYPE_PAINT))
		smile = FALSE
		update_icon()
		return TRUE

/obj/item/clothing/head/helmet/space/plasmaman/attack_self(mob/user)
	helmet_on = !helmet_on
	if(!lamp_functional)
		to_chat(user, span_notice("Your helmet's torch is broken! You'll have to repair it with a lightbulb!"))
		set_light_on(FALSE)
		helmet_on = FALSE
		return
	if(helmet_on)
		if(!up)
			to_chat(user, span_notice("Your helmet's torch can't pass through your welding visor!"))
			helmet_on = FALSE
			return
		else
			set_light_on(TRUE)
	else
		set_light_on(FALSE)

	update_icon()
	user.update_worn_head() //So the mob overlay updates
	update_button_icons(user)

/obj/item/clothing/head/helmet/space/plasmaman/proc/smash_headlamp()
	if(!lamp_functional)
		return
	if(!helmet_on)
		return
	set_light_on(FALSE)
	helmet_on = FALSE
	playsound(src, 'sound/effects/glass_step.ogg', 100)
	to_chat(usr, span_danger("The [src]'s headlamp is smashed to pieces!"))
	lamp_functional = FALSE
	update_icon()
	usr.update_worn_head() //So the mob overlay updates
	update_button_icons(usr)

/obj/item/clothing/head/helmet/space/plasmaman/update_overlays()
	cut_overlays()

	if(!up)
		add_overlay(mutable_appearance('icons/obj/clothing/head/plasmaman_hats.dmi', visor_state + "_weld"))
	else if(helmet_on)
		add_overlay(mutable_appearance('icons/obj/clothing/head/plasmaman_hats.dmi', visor_state + "_light"))

	return ..()

/obj/item/clothing/head/helmet/space/plasmaman/security
	name = "security envirosuit helmet"
	desc = "A plasmaman containment helmet designed for security officers, protecting them from burning alive, along-side other undesirables."
	greyscale_colors = "#9F2A2E#2D2D2D#7D282D"
	armor_type = /datum/armor/plasmaman_security


/datum/armor/plasmaman_security
	melee = 10
	bio = 100
	fire = 100
	acid = 75
	stamina = 10
	bleed = 10

/obj/item/clothing/head/helmet/space/plasmaman/security/warden
	name = "warden's envirosuit helmet"
	desc = "A plasmaman containment helmet designed for the warden, a pair of white stripes being added to differentiate them from other members of security."
	greyscale_colors = "#9F2A2E#C0C0C0#7D282D"

/obj/item/clothing/head/helmet/space/plasmaman/medical
	name = "medical's envirosuit helmet"
	desc = "An envirohelmet designed for plasmaman medical doctors, having two stripes down it's length to denote as much"
	greyscale_colors = "#D2D2D2#498CB4#2D2D2D"

/obj/item/clothing/head/helmet/space/plasmaman/genetics
	name = "geneticist's envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for geneticists."
	greyscale_colors = "#D2D2D2#0093C4#2D2D2D"

/obj/item/clothing/head/helmet/space/plasmaman/viro
	name = "virology envirosuit helmet"
	desc = "The helmet worn by the safest people on the station, those who are completely immune to the monstrosities they create."
	greyscale_colors = "#D2D2D2#2D8800#2D2D2D"

/obj/item/clothing/head/helmet/space/plasmaman/chemist
	name = "chemistry envirosuit helmet"
	desc = "A plasmaman envirosuit designed for chemists, two orange stripes going down it's face."
	greyscale_colors = "#D2D2D2#D26F00#2D2D2D"

/obj/item/clothing/head/helmet/space/plasmaman/paramedic
	name = "paramedic envirosuit helmet"
	desc = "An envirosuit helmet only for the bravest medical plasmaman."
	greyscale_colors = "#2C3A4E#D9D9D9#2C3A4E"

/obj/item/clothing/head/helmet/space/plasmaman/security/secmed
	name = "brig physician envirosuit helmet"
	desc = "An envirosuit helmet made for brig physicians."
	greyscale_colors = "#A5A9B6#B72B2F#A5A9B6"

/obj/item/clothing/head/helmet/space/plasmaman/science
	name = "science envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for scientists."
	greyscale_colors = "#E6E6E6#9E00EA#E6E6E6"

/obj/item/clothing/head/helmet/space/plasmaman/robotics
	name = "robotics envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for roboticists."
	greyscale_colors = "#313131#722BA4#313131"

/obj/item/clothing/head/helmet/space/plasmaman/engineering
	name = "engineering envirosuit helmet"
	desc = "A space-worthy helmet specially designed for engineer plasmamen, the usual purple stripes being replaced by engineering's orange."
	greyscale_colors = "#F0DE00#D75600#F0DE00"
	armor_type = /datum/armor/plasmaman_engineering
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT


/datum/armor/plasmaman_engineering
	bio = 100
	fire = 100
	acid = 75
	bleed = 10

/obj/item/clothing/head/helmet/space/plasmaman/engineering/atmospherics
	name = "atmospherics envirosuit helmet"
	desc = "A space-worthy helmet specially designed for atmos technician plasmamen, the usual purple stripes being replaced by engineering's blue."
	greyscale_colors = "#F0DE00#0098CA#F0DE00"

/obj/item/clothing/head/helmet/space/plasmaman/mailman
	name = "mailman envirosuit helmet"
	desc = "<i>'Right-on-time'</i> mail plasmamen service head wear."
	greyscale_colors = "#091544#e6c447#091544"

/obj/item/clothing/head/helmet/space/plasmaman/cargo
	name = "cargo envirosuit helmet"
	desc = "An plasmaman envirohelmet designed for cargo techs and quartermasters."
	greyscale_colors = "#ADADAD#BB9042#ADADAD"

/obj/item/clothing/head/helmet/space/plasmaman/mining
	name = "mining envirosuit helmet"
	desc = "A khaki helmet given to plasmamen miners operating on lavaland."
	greyscale_colors = "#55524A#8A5AE1#55524A"

/obj/item/clothing/head/helmet/space/plasmaman/chaplain
	name = "chaplain's envirosuit helmet"
	desc = "An envirohelmet specially designed for only the most pious of plasmamen."
	greyscale_colors = "#313131#743474#313131"

/obj/item/clothing/head/helmet/space/plasmaman/white
	name = "white envirosuit helmet"
	desc = "A generic white envirohelm."
	greyscale_colors = "#D2D2D2#743474#D2D2D2"

/obj/item/clothing/head/helmet/space/plasmaman/bartender
	name = "white envirosuit helmet with top hat"
	desc = "A generic white envirohelm with a top-hat affixed to the top"
	greyscale_colors = "#E6E6E6#A349A4#E6E6E6"

/obj/item/clothing/head/helmet/space/plasmaman/bartender/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/head/hat = new /obj/item/clothing/head/hats/tophat
	attached_hat = hat
	hat.forceMove(src)
	update_icon()
	add_verb(/obj/item/clothing/head/helmet/space/verb/unattach_hat)

/obj/item/clothing/head/helmet/space/plasmaman/gold
	name = "designer envirosuit helmet"
	desc = "A Plasmi-Deluxe envirosuit helmet with gold woven into the fabric. A designer model like this is probably worth a pretty penny."
	greyscale_colors = "#C47D0C#C47D0C#C47D0C"
	custom_price = 4500

/obj/item/clothing/head/helmet/space/plasmaman/curator
	name = "curator's envirosuit helmet"
	desc = "A slight modification on a tradiational voidsuit helmet, this helmet was Nano-Trasen's first solution to the *logistical problems* that come with employing plasmamen. Despite their limitations, these helmets still see use by historian and old-styled plasmamen alike."
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	icon_state = "prototype_envirohelm"
	inhand_icon_state = "prototype_envirohelm"
	smile_state = "prototype_smile"

/obj/item/clothing/head/helmet/space/plasmaman/botany
	name = "botany envirosuit helmet"
	desc = "A green and blue envirohelmet designating it's wearer as a botanist. While not specially designed for it, it would protect against minor planet-related injuries."
	greyscale_colors = "#5FA31E#0D49FF#5FA31E"

/obj/item/clothing/head/helmet/space/plasmaman/janitor
	name = "janitor's envirosuit helmet"
	desc = "A grey helmet bearing a pair of purple stripes, designating the wearer as a janitor."
	greyscale_colors = "#ADADAD#7E3391#FCFF00"

/obj/item/clothing/head/helmet/space/plasmaman/exploration
	name = "exploration envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for the exploration crew, decked out in their iconic garish turquiose."
	greyscale_colors = "#CFC7B8#50BA5C#CFC7B8"

//mime and clown
/obj/item/clothing/head/helmet/space/plasmaman/mime
	name = "mime's envirosuit helmet"
	desc = "A black and white envirosuit helmet, specially made for the mime. Rattling bones won't stop your silent shenanigans!"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	icon_state = "mime_envirohelm"
	inhand_icon_state = "mime_envirohelm"
	visor_state = "mime_visor"

/obj/item/clothing/head/helmet/space/plasmaman/honk
	name = "clown's envirosuit helmet"
	desc = "A multicolor helmet that smells of bananium and security's tears."
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	icon_state = "honk_envirohelm"
	inhand_icon_state = "honk_envirohelm"
	smile_state = "clown_smile"
	visor_state = "clown_visor"

//command helms
/obj/item/clothing/head/helmet/space/plasmaman/command
	name = "captain's envirosuit helmet"
	desc = "A helmet issued to the head of the command staff. Sleak and stylish, as all captains should be."
	greyscale_colors = "#005478#D7C73F#005478"

/obj/item/clothing/head/helmet/space/plasmaman/engineering/ce
	name = "chief engineer's envirohelmet"
	desc = "An envirohelmet designed for the Chief Engineer. It reeks of Poly and plasma."
	greyscale_colors = "#D7D7C4#D75600#D7D7C4"

/obj/item/clothing/head/helmet/space/plasmaman/cmo
	name = "chief medical officer's envirohelmet"
	desc = "A helmet issued to the chief of the medical staff."
	greyscale_colors = "#6FABCE#E6E6E6#6FABCE"

/obj/item/clothing/head/helmet/space/plasmaman/security/hos
	name = "head of security's helmet"
	desc = "A reinforced envirohelmet issued to the head of the security staff. You'll need it."
	greyscale_colors = "#2F2E31#C7B83C#2F2E31"

/obj/item/clothing/head/helmet/space/plasmaman/rd
	name = "research director's envirosuit helmet"
	desc = "A custom made envirosuit helmet made using advanced nanofibers. Fashionable and easy to wear."
	greyscale_colors = "#6F5828#A349A4#6F5828"

/obj/item/clothing/head/helmet/space/plasmaman/hop
	name = "head of personnel's envirosuit helmet"
	desc = "An envirosuit helmet made for the Head of Personnel. Some corgi hair is stuck to it."
	greyscale_colors = "#005478#AA1916#005478"

//centcom envirohelms
/obj/item/clothing/head/helmet/space/plasmaman/commander
	name = "CentCom commander envirosuit helmet"
	desc = "A special containment helmet designed for the Higher Central Command Staff. Not many of these exist, as CentCom does not usually employ plasmamen to higher staff positions due to their complications."
	greyscale_colors = "#007F00#E1C709#007F00"

/obj/item/clothing/head/helmet/space/plasmaman/official
	name = "CentCom official envirosuit helmet"
	desc = "A special containment helmet designed for CentCom Staff. They sure do love their green."
	greyscale_colors = "#099756#C0C0C0#099756"

/obj/item/clothing/head/helmet/space/plasmaman/intern
	name = "CentCom intern envirosuit helmet"
	desc = "A special containment helmet designed for CentCom Staff. You know, so any coffee spills don't kill the poor sod."
	greyscale_colors = "#088756#313131#088756"

// The Mark 2 variants of the standard envirohelms.
/obj/item/clothing/head/helmet/space/plasmaman/mark2
	name = "Mk.II envirosuit helmet"
	desc = "A sleek new plasmaman containment helmet, painted in classic Hazardous Orange."
	greyscale_colors = "#DF5900#A349A4"
	greyscale_config = /datum/greyscale_config/plasmaman_helmet_mark2
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_helmet_mark2_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_helmet_mark2_inhand_right
	greyscale_config_worn = /datum/greyscale_config/plasmaman_helmet_mark2_worn
	visor_state = "mark2_visor"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/security
	name = "security Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for security officers, retaining all the old protections for a new era of fragile law enforcement."
	greyscale_colors = "#9F2A2E#2D2D2D"
	armor_type = /datum/armor/mark2_security


/datum/armor/mark2_security
	melee = 10
	bio = 100
	fire = 100
	acid = 75
	stamina = 10
	bleed = 10

/obj/item/clothing/head/helmet/space/plasmaman/mark2/security/warden
	name = "warden's Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for the warden. All the chic of the standard look with the Warden's iconic reflective white stripe."
	greyscale_colors = "#9F2A2E#C0C0C0"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/medical
	name = "medical's Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for medical doctors. Glue your fellow crewmen back together and make a fashion statement while you're at it."
	greyscale_colors = "#E6E6E6#5A96BB"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/genetics
	name = "geneticist's Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for geneticists. Pushing the boundaries of organic life never looked so good!"
	greyscale_colors = "#E6E6E6#0097CA"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/viro
	name = "virology Mk.II envirosuit helmet"
	desc = "The helmet worn by the safest people on the station, those who are completely immune to the monstrosities they create, including the monstrosities of outdated fashion"
	greyscale_colors = "#E6E6E6#339900"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/chemist
	name = "chemistry Mk.II envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for chemists."
	greyscale_colors = "#E6E6E6#FF8800"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/paramedic
	name = "paramedic Mk.II envirosuit helmet"
	desc = "A new and improved envirosuit helmet only for the bravest medical plasmaman."
	greyscale_colors = "#2C3A4E#D9D9D9"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/security/secmed
	name = "brig physician Mk.II envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for brig physicians."
	greyscale_colors = "#A5A9B6#B72B2F"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/science
	name = "science Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for scientists."
	greyscale_colors = "#E6E6E6#9E00EA"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/robotics
	name = "robotics Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for roboticists."
	greyscale_colors = "#2F2E31#932500"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/engineering
	name = "engineering Mk.II envirosuit helmet"
	desc = "A new iteration upon the classic space-worthy design, painted in classic engineering pigments."
	greyscale_colors = "#E8D700#D75600"
	armor_type = /datum/armor/mark2_engineering
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT


/datum/armor/mark2_engineering
	bio = 100
	fire = 100
	acid = 75
	bleed = 10

/obj/item/clothing/head/helmet/space/plasmaman/mark2/engineering/atmospherics
	name = "atmospherics Mk.II envirosuit helmet"
	desc = "A new iteration upon the classic space-worthy design, painted in classic atmosian pigments."
	greyscale_colors = "#E8D700#0098CA"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/cargo
	name = "cargo Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for cargo techs and quartermasters. Neo-liberal grifting has never been this groovy"
	greyscale_colors = "#ADADAD#BB9042"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/mailman
	name = "mailman Mk.II envirosuit helmet"
	desc = "<i>'Right-on-time'</i> a modernized mail plasmamen service head wear."
	greyscale_colors = "#091544#e6c447"


/obj/item/clothing/head/helmet/space/plasmaman/mark2/mining
	name = "mining Mk.II envirosuit helmet"
	desc = "A new styling of the classi khaki helmet given to plasmamen miners."
	greyscale_colors = "#E1D9CA#2BFF92"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/chaplain
	name = "chaplain's Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for only the most pious of plasmamen. Old age traditions wrapped in a new age shell."
	greyscale_colors = "#313131#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/white
	name = "white Mk.II envirosuit helmet"
	desc = "The generic white envirohelm brought into a new era of fashion."
	greyscale_colors = "#E6E6E6#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/botany
	name = "botany Mk.II envirosuit helmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for botanists. Now specially designed against minor planet-related injuries."
	greyscale_colors = "#54911A#0650D7"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/janitor
	name = "janitor's Mk.II envirosuit helmet"
	desc = "A new look for the flashy janitor enviro helmet. Get the appreciation you deserve with this cutting edge vogue."
	greyscale_colors = "#ADADAD#FCFF00"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/exploration
	name = "mining envirosuit helmet"
	desc = "A new plasmaman envirohelmet designed for the exploration crew, decked out in their iconic garish turquiose."
	greyscale_colors = "#E1D9CA#2BFF92"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/command
	name = "captain's Mk.II envirosuit helmet"
	desc = "A new age helmet issued to the head of the command staff. Sleeker and stylish-er, as all captains should be."
	greyscale_colors = "#005478#D7C73F"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/engineering/ce
	name = "chief engineer's Mk.II envirohelmet"
	desc = "A stylish new iteration upon the original plasmaman containment helmet design for the Chief Engineer. This one doesn't smell as strongly of bird poo."
	greyscale_colors = "#D7D7C4#D75600"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/cmo
	name = "chief medical officer's Mk.II envirohelmet"
	desc = "A sleek new helmet issued to the chief of the medical staff. Show off that big forehead of yours to all the squares in science."
	greyscale_colors = "#6FABCE#E6E6E6"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/security/hos
	name = "head of security's Mk.II envirosuit helmet"
	desc = "A new variant of the head of security's classic reinforced envirohelmet. You'll still need it."
	greyscale_colors = "#232A35#8A0400"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/rd
	name = "research director's Mk.II envirosuit helmet"
	desc = "A stylish new helmet issued to the director of the research staff. Show off that big forehead of yours to all the wimps in medical."
	greyscale_colors = "#6F5828#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/hop
	name = "head of personnel's Mk.II envirosuit helmet"
	desc = "An new envirosuit helmet made for the Head of Personnel, sprayed with Corgi pheromones."
	greyscale_colors = "#005478#AA1916"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/gold
	name = "designer's envirosuit helmet Mk.II"
	desc = "A Plasmi-Deluxe envirosuit helmet with gold woven into the fabric. This one is the newest version."
	greyscale_colors = "#C47D0C#C47D0C"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/commander
	name = "CentCom commander Mk.II envirosuit helmet"
	desc = "A special containment helmet designed for the Higher Central Command Staff. Not many of these exist, as CentCom does not usually employ plasmamen to higher staff positions due to their complications."
	greyscale_colors = "#007F00#E1C709"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/official
	name = "CentCom official Mk.II envirosuit helmet"
	desc = "A special containment helmet designed for CentCom Staff. They sure do love their green."
	greyscale_colors = "#099756#C0C0C0"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/intern
	name = "CentCom intern envirosuit helmet"
	desc = "A special containment helmet designed for CentCom Staff. You know, so any coffee spills don't kill the poor sod."
	greyscale_colors = "#088756#313131"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/bartender
	name = "white envirosuit helmet with top hat"
	desc = "A new plasmaman envirohelmet designed for the bartenders, with a top-hat affixed to the top."
	greyscale_colors = "#E6E6E6#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/mime
	name = "mime's envirosuit helmet"
	desc = "A new plasmaman envirohelmet designed for the mimes."
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	icon_state = "mime_mark2"
	inhand_icon_state = "mime_mark2"
	visor_state = "mime_visor_mk2"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/clown
	name = "clown's envirosuit helmet"
	desc = "A new plasmaman envirohelmet designed for the clowns."
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	icon_state = "clown_mark2"
	inhand_icon_state = "clown_mark2"
	visor_state = "clown_visor_mk2"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/bartender/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/head/hat = new /obj/item/clothing/head/hats/tophat
	attached_hat = hat
	hat.forceMove(src)
	update_icon()
	add_verb(/obj/item/clothing/head/helmet/space/verb/unattach_hat)

// The Protective helmet variants
/obj/item/clothing/head/helmet/space/plasmaman/protective
	name = "protective envirosuit helmet"
	desc = "This helmet was originally designed for engineering crews on the more ramshackle plasma mining colonies. Now, after several design improvements and class-action lawsuits, this helmet has been distributed once more as a fun cosmetic choice for NTs plasmafolk."
	greyscale_colors = "#DF5900#A349A4"
	greyscale_config = /datum/greyscale_config/plasmaman_helmet_protective
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_helmet_protective_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_helmet_protective_inhand_right
	greyscale_config_worn = /datum/greyscale_config/plasmaman_helmet_protective_worn
	visor_state = "protective_visor"

/obj/item/clothing/head/helmet/space/plasmaman/protective/security
	name = "security protective envirosuit helmet"
	desc = "A braced plasmaman containment helmet designed for security officers."
	greyscale_colors = "#9F2A2E#2D2D2D"

/obj/item/clothing/head/helmet/space/plasmaman/protective/security/warden
	name = "warden's protective envirosuit helmet"
	desc = "A braced plasmaman containment helmet designed for the warden."
	greyscale_colors = "#9F2A2E#C0C0C0"

/obj/item/clothing/head/helmet/space/plasmaman/protective/medical
	name = "medical's protective envirosuit helmet"
	desc = "A braced plasmaman containment helmet designed for medical doctors."
	greyscale_colors = "#E6E6E6#5A96BB"

/obj/item/clothing/head/helmet/space/plasmaman/protective/genetics
	name = "geneticist's protective envirosuit helmet"
	desc = "A braced plasmaman containment helmet designed for geneticists."
	greyscale_colors = "#E6E6E6#0097CA"

/obj/item/clothing/head/helmet/space/plasmaman/protective/viro
	name = "virology protective envirosuit helmet"
	desc = "The helmet worn by the safest people on the station, those who are completely immune to the monstrosities they create."
	greyscale_colors = "#E6E6E6#339900"

/obj/item/clothing/head/helmet/space/plasmaman/protective/chemist
	name = "chemistry protective envirosuit helmet"
	desc = "A braced plasmaman containment helmet designed for chemists."
	greyscale_colors = "#E6E6E6#FF8800"

/obj/item/clothing/head/helmet/space/plasmaman/protective/paramedic
	name = "paramedic protective envirosuit helmet"
	desc = "A new and improved envirosuit helmet only for the bravest medical plasmaman."
	greyscale_colors = "#2C3A4E#EBEBEB"

/obj/item/clothing/head/helmet/space/plasmaman/protective/security/secmed
	name = "brig physician protective envirosuit helmet"
	desc = "A braced plasmaman containment helmet designed for brig physicians."
	greyscale_colors = "#A5A9B6#C4373C"

/obj/item/clothing/head/helmet/space/plasmaman/protective/science
	name = "science protective envirosuit helmet"
	desc = "A braced plasmaman containment helmet designed for scientists."
	greyscale_colors = "#E6E6E6#9E00EA"

/obj/item/clothing/head/helmet/space/plasmaman/protective/robotics
	name = "robotics protective envirosuit helmet"
	desc = "A braced plasmaman containment helmet designed for roboticists."
	greyscale_colors = "#3F3B4C#722BA4"

/obj/item/clothing/head/helmet/space/plasmaman/protective/engineering
	name = "engineering protective envirosuit helmet"
	desc = "A safer looking re-imagining of the classic space-worthy design, painted in classic engineering pigments."
	greyscale_colors = "#E8D700#D75600"
	armor_type = /datum/armor/protective_engineering
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT


/datum/armor/protective_engineering
	bio = 100
	fire = 100
	acid = 75
	bleed = 10

/obj/item/clothing/head/helmet/space/plasmaman/protective/engineering/atmospherics
	name = "atmospherics protective envirosuit helmet"
	desc = "A safer looking re-imagining of the classic space-worthy design, painted in classic atmosian pigments."
	greyscale_colors = "#E8D700#0098CA"

/obj/item/clothing/head/helmet/space/plasmaman/protective/cargo
	name = "cargo protective envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for cargo techs and quartermasters."
	greyscale_colors = "#ADADAD#BB9042"

/obj/item/clothing/head/helmet/space/plasmaman/protective/mailman
	name = "mailman Mk.II envirosuit helmet"
	desc = "<i>'Right-on-time'</i> a braced mail plasmamen service head wear."
	greyscale_colors = "#091544#e6c447"

/obj/item/clothing/head/helmet/space/plasmaman/protective/mining
	name = "mining Mk.II envirosuit helmet"
	desc = "A new styling of the classic khaki helmet given to plasmamen miners."
	greyscale_colors = "#55524A#8A5AE1"

/obj/item/clothing/head/helmet/space/plasmaman/protective/chaplain
	name = "chaplain's protective envirosuit helmet"
	desc = "A braced plasmaman containment helmet design for only the most pious of plasmamen."
	greyscale_colors = "#313131#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/protective/white
	name = "white protective envirosuit helmet"
	desc = "The generic white envirohelm wrapped in a bulky, possibly more protective shell."
	greyscale_colors = "#E6E6E6#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/protective/botany
	name = "botany protective envirosuit helmet"
	desc = "A braced plasmaman containment helmet designed for botanists."
	greyscale_colors = "#54911A#0650D7"

/obj/item/clothing/head/helmet/space/plasmaman/protective/janitor
	name = "janitor's protective envirosuit helmet"
	desc = "A bulkier variation on the janitor envirohelmet."
	greyscale_colors = "#ADADAD#FCFF00"

/obj/item/clothing/head/helmet/space/plasmaman/protective/exploration
	name = "mining protective envirosuit helmet"
	desc = "A new plasmaman envirohelmet designed for the exploration crew, decked out in their iconic garish turquiose."
	greyscale_colors = "#CFC7B8#0CD46C"

/obj/item/clothing/head/helmet/space/plasmaman/protective/command
	name = "captain's protective envirosuit helmet"
	desc = "A better protected helmet issued to the head of the command staff. This might help. Might."
	greyscale_colors = "#005478#D7C73F"

/obj/item/clothing/head/helmet/space/plasmaman/protective/engineering/ce
	name = "chief engineer's protective envirohelmet"
	desc = "A braced plasmaman containment helmet designed for the Chief Engineer."
	greyscale_colors = "#D7D7C3#D75600"

/obj/item/clothing/head/helmet/space/plasmaman/protective/cmo
	name = "chief medical officer's protective envirohelmet"
	desc = "A bulky new helmet issued to the chief of the medical staff."
	greyscale_colors = "#6FABCE#E6E6E6"

/obj/item/clothing/head/helmet/space/plasmaman/protective/security/hos
	name = "head of security's protective envirosuit helmet"
	desc = "A better-armoured variant of the head of security's classic reinforced envirohelmet."
	greyscale_colors = "#232A35#8A0400"

/obj/item/clothing/head/helmet/space/plasmaman/protective/rd
	name = "research director's protective envirosuit helmet"
	desc = "An encumbering new helmet issued to the director of the research staff."
	greyscale_colors = "#6F5828#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/protective/hop
	name = "head of personnel's protective envirosuit helmet"
	desc = "An new, debatably safer envirosuit helmet made for the Head of Personnel."
	greyscale_colors = "#005478#AA1916"

/obj/item/clothing/head/helmet/space/plasmaman/protective/gold
	name = "designer's protective envirosuit helmet"
	desc = "A Plasmi-Deluxe envirosuit helmet with gold woven into the fabric. This one is the newest version."
	greyscale_colors = "#C47D0C#C47D0C"

/obj/item/clothing/head/helmet/space/plasmaman/protective/commander
	name = "CentCom commander protective envirosuit helmet"
	desc = "A special containment helmet designed for the Higher Central Command Staff. Not many of these exist, as CentCom does not usually employ plasmamen to higher staff positions due to their complications."
	greyscale_colors = "#007F00#E1C709"

/obj/item/clothing/head/helmet/space/plasmaman/protective/official
	name = "CentCom official protective envirosuit helmet"
	desc = "A special containment helmet designed for CentCom Staff. They sure do love their green."
	greyscale_colors = "#099756#C0C0C0"

/obj/item/clothing/head/helmet/space/plasmaman/protective/intern
	name = "CentCom intern protective envirosuit helmet"
	desc = "A special containment helmet designed for CentCom Staff. You know, so any coffee spills don't kill the poor sod."
	greyscale_colors = "#088756#313131"

/obj/item/clothing/head/helmet/space/plasmaman/protective/bartender
	name = "white envirosuit helmet with top hat"
	desc = "A special containment helmet designed for the bartenders, with a top-hat affixed to the top."
	greyscale_colors = "#E6E6E6#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/protective/bartender/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/head/hat = new /obj/item/clothing/head/hats/tophat
	attached_hat = hat
	hat.forceMove(src)
	update_icon()
	add_verb(/obj/item/clothing/head/helmet/space/verb/unattach_hat)
