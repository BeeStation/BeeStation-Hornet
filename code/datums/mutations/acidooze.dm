/datum/mutation/acidooze
	name = "Acidic Hands"
	desc = "Allows an Oozeling to metabolize some of their blood into acid, concentrated on their hands."
	quality = POSITIVE
	locked = TRUE
	instability = 30
	power_path = /datum/action/spell/touch/mutation/acidooze
	power_coeff = 1
	energy_coeff = 1
	synchronizer_coeff = 1
	species_allowed = list(SPECIES_OOZELING)

/datum/action/spell/touch/mutation/acidooze
	name = "Acidic Hands"
	desc = "Concentrate to make some of your blood become acidic."
	spell_requirements = null
	cooldown_time = 10 SECONDS
	button_icon_state = "summons"
	hand_path = /obj/item/melee/touch_attack/mutation/acidooze
	mindbound = FALSE

/obj/item/melee/touch_attack/mutation/acidooze
	name = "\improper acidic hand"
	desc = "Keep away from children, paperwork, and children doing paperwork."
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	inhand_icon_state = "fleshtostone"
	var/static/base_acid_volume = 15
	var/static/base_blood_cost = 20
	var/static/icon_left = "bloodhand_left"
	var/static/icon_right = "bloodhand_right"

/obj/item/melee/touch_attack/mutation/acidooze/equipped(mob/user, slot)
	. = ..()
	//these are intentionally inverted
	icon_state = (user.get_held_index_of_item(src) % 2) ? icon_right : icon_left
	to_chat(user, "<span class ='warning'>You secrete acid into your hand.</span>")

/obj/item/melee/touch_attack/mutation/acidooze/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || !isoozeling(user))
		return
	if(!target || user.incapacitated())
		return FALSE
	var/acid_volume = base_acid_volume
	var/blood_cost = base_blood_cost
	if(user.blood_volume < (blood_cost * 2))
		to_chat(user, "<span class='warning'>You don't have enough blood to do that!</span>")
		return FALSE
	if(target.acid_act(50, acid_volume))
		user.visible_message("<span class='warning'>[user] rubs globs of vile stuff all over [target].</span>")
		user.blood_volume = max(user.blood_volume - blood_cost, 0)
		return ..()
	else
		to_chat(user, "<span class='notice'>You cannot dissolve this object.</span>")
