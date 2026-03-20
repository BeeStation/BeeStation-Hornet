/obj/item/clothing/head/costume/foilhat
	name = "tinfoil hat"
	desc = "Thought control rays, psychotronic scanning. Don't mind that, I'm protected cause I made this hat."
	icon_state = "foilhat"
	inhand_icon_state = null
	clothing_flags = EFFECT_HAT | SNUG_FIT
	armor_type = /datum/armor/costume_foilhat
	equip_delay_other = 140
	var/datum/brain_trauma/mild/phobia/conspiracies/paranoia
	var/mutable_appearance/psychic_overlay


/datum/armor/costume_foilhat
	laser = -5
	stamina = 50

/obj/item/clothing/head/costume/foilhat/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	user.sec_hud_set_implants()
	if(!(slot & ITEM_SLOT_HEAD))
		return
	if(paranoia)
		QDEL_NULL(paranoia)
	paranoia = new()
	paranoia.trauma_flags &= ~TRAUMA_CLONEABLE

	RegisterSignal(user, COMSIG_HUMAN_SUICIDE_ACT, PROC_REF(call_suicide))

	user.gain_trauma(paranoia, TRAUMA_RESILIENCE_MAGIC)
	to_chat(user, span_warning("As you don the foiled hat, an entire world of conspiracy theories and seemingly insane ideas suddenly rush into your mind. What you once thought unbelievable suddenly seems.. undeniable. Everything is connected and nothing happens just by accident. You know too much and now they're out to get you. "))

	psychic_overlay = mutable_appearance()
	psychic_overlay.appearance = user.appearance
	psychic_overlay.plane = ANTI_PSYCHIC_PLANE
	user.add_overlay(psychic_overlay)

/obj/item/clothing/head/costume/foilhat/MouseDrop(atom/over_object)
	//God Im sorry
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(src == C.head)
			to_chat(C, span_userdanger("Why would you want to take this off? Do you want them to get into your mind?!"))
			return
	return ..()

/obj/item/clothing/head/costume/foilhat/dropped(mob/user)
	. = ..()
	if(paranoia)
		QDEL_NULL(paranoia)

	UnregisterSignal(user, COMSIG_HUMAN_SUICIDE_ACT)

	if(isliving(user))
		var/mob/living/L = user
		L.sec_hud_set_implants()
	user.cut_overlay(psychic_overlay)

/obj/item/clothing/head/costume/foilhat/attack_hand(mob/user, list/modifiers)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.head)
			to_chat(user, span_userdanger("Why would you want to take this off? Do you want them to get into your mind?!"))
			return
	return ..()

/obj/item/clothing/head/costume/foilhat/plasmaman
	name = "tinfoil envirosuit helmet"
	desc = "The Syndicate is a hoax! Dogs are fake! Space Station 13 is just a money laundering operation! See the truth!"
	icon = 'icons/obj/clothing/head/plasmaman_hats.dmi'
	worn_icon = 'icons/mob/clothing/head/plasmaman_head.dmi'
	icon_state = "tinfoil_envirohelm"
	inhand_icon_state = "tinfoil_envirohelm"
	strip_delay = 150
	clothing_flags = STOPSPRESSUREDAMAGE | EFFECT_HAT | SNUG_FIT | HEADINTERNALS
	armor_type = /datum/armor/foilhat_plasmaman
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	light_system = MOVABLE_LIGHT
	light_range = 4
	light_power = 1
	light_on = TRUE
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	dynamic_hair_suffix = ""
	dynamic_fhair_suffix = ""
	flash_protect = FLASH_PROTECTION_WELDER
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	bang_protect = 1 //make this consistent with other plasmaman helmets
	resistance_flags = NONE
	dog_fashion = null
	///Is the light on?
	var/on = FALSE


/datum/armor/foilhat_plasmaman
	bio = 100
	fire = 50
	acid = 50
	stamina = 50

/obj/item/clothing/head/costume/foilhat/plasmaman/attack_self(mob/user)
	on = !on
	icon_state = "[initial(icon_state)][on ? "-light":""]"
	inhand_icon_state = icon_state
	user.update_worn_head() //So the mob overlay updates

	if(on)
		set_light(TRUE)
	else
		set_light(FALSE)

	update_item_action_buttons()

/obj/item/clothing/head/costume/foilhat/proc/call_suicide(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(suicide_act), source) //SIGNAL_HANDLER doesn't like things waiting; INVOKE_ASYNC bypasses that
	return OXYLOSS

/obj/item/clothing/head/costume/foilhat/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] gets a crazed look in [user.p_their()] eyes! [capitalize(user.p_they())] [user.p_have()] witnessed the truth, and try to commit suicide!"))
	var/static/list/conspiracy_line = list(
		";THEY'RE HIDING CAMERAS IN THE CEILINGS! THEY WITNESS EVERYTHING WE DO!!",
		";HOW CAN I LIVE IN A WORLD WHERE MY FATE AND EXISTENCE IS DECIDED BY A GROUP OF INDIVIDUALS?!!",
		";THEY'RE TOYING WITH ALL OF YOUR MINDS AND TREATING YOU AS EXPERIMENTS!!",
		";THEY HIRE ASSISTANTS WITHOUT DOING BACKGROUND CHECKS!!",
		";WE LIVE IN A ZOO AND WE ARE THE ONES BEING OBSERVED!!",
		";WE REPEAT OUR LIVES DAILY WITHOUT FURTHER QUESTIONS!!"
	)
	user.say(pick(conspiracy_line), forced=type)
	var/obj/item/organ/brain/brain = user.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain)
		brain.damage = BRAIN_DAMAGE_DEATH
	return OXYLOSS
