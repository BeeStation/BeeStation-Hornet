/datum/mutation/shock
	name = "Shock Touch"
	desc = "A mutation that allows the user to store accumulated bioelectric and static charge, consciously discharging it upon others with no harm to themselves."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	power = /obj/effect/proc_holder/spell/targeted/touch/mutation/shock
	instability = 30
	locked = TRUE
	energy_coeff = 1
	power_coeff = 1

/obj/effect/proc_holder/spell/targeted/touch/mutation/shock
	name = "Shock Touch"
	desc = "Channel electricity to your hand to shock people with."
	drawmessage = "You channel electricity into your hand."
	dropmessage = "You let the electricity from your hand dissipate."
	hand_path = /obj/item/melee/touch_attack/mutation/shock
	charge_max = 10 SECONDS
	action_icon_state = "zap"

/obj/item/melee/touch_attack/mutation/shock
	name = "\improper shock touch"
	desc = "This is kind of like when you rub your feet on a shag rug so you can zap your friends, only a lot less safe."
	on_use_sound = 'sound/weapons/zapbang.ogg'
	icon_state = "zapper"
	item_state = "zapper"

/obj/item/melee/touch_attack/mutation/shock/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(QDELETED(target) || isturf(target))
		return
	user.Beam(target, icon_state = "lightning[rand(1, 12)]", time = 5, maxdistance = 32)
	var/zap = 15 * GET_MUTATION_POWER(parent_mutation)
	if(iscarbon(target))
		var/mob/living/carbon/ctarget = target
		if(ctarget.electrocute_act(zap, user, flags = SHOCK_NOSTUN)) //doesnt stun. never let this stun
			ctarget.drop_all_held_items()
			ctarget.confused += zap
			ctarget.visible_message("<span class='danger'>[user] electrocutes [target]!</span>","<span class='userdanger'>[user] electrocutes you!</span>")
		else
			user.visible_message("<span class='warning'>[user] fails to electrocute [target]!</span>")
	else if(isliving(target))
		var/mob/living/ltarget = target
		ltarget.electrocute_act(zap, user, flags = SHOCK_NOSTUN)
		ltarget.visible_message("<span class='danger'>[user] electrocutes [target]!</span>","<span class='userdanger'>[user] electrocutes you!</span>")
	else
		to_chat(user,"<span class='warning'>The electricity doesn't seem to affect [target]...</span>")
	use_charge(user)
	return ..()

/datum/mutation/acidooze
	name = "Acidic Hands"
	desc = "Allows an Oozeling to metabolize some of their blood into acid, concentrated on their hands."
	quality = POSITIVE
	locked = TRUE
	instability = 30
	power = /obj/effect/proc_holder/spell/targeted/touch/mutation/acidooze
	power_coeff = 1
	energy_coeff = 1
	synchronizer_coeff = 1
	species_allowed = list(SPECIES_OOZELING)

/obj/effect/proc_holder/spell/targeted/touch/mutation/acidooze
	name = "Acidic Hands"
	desc = "Concentrate to make some of your blood become acidic."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 10 SECONDS
	action_icon_state = "summons"
	hand_path = /obj/item/melee/touch_attack/mutation/acidooze
	drawmessage = "You secrete acid into your hand."
	dropmessage = "You let the acid in your hand dissipate."

/obj/item/melee/touch_attack/mutation/acidooze
	name = "\improper acidic hand"
	desc = "Keep away from children, paperwork, and children doing paperwork."
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	item_state = "fleshtostone"
	var/static/base_acid_volume = 15
	var/static/base_blood_cost = 20
	var/static/icon_left = "bloodhand_left"
	var/static/icon_right = "bloodhand_right"

/obj/item/melee/touch_attack/mutation/acidooze/equipped(mob/user, slot)
	. = ..()
	//these are intentionally inverted
	icon_state = (user.get_held_index_of_item(src) % 2) ? icon_right : icon_left

/obj/item/melee/touch_attack/mutation/acidooze/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || !isoozeling(user))
		return
	if(!target || user.incapacitated())
		return FALSE
	var/acid_volume = base_acid_volume * GET_MUTATION_POWER(parent_mutation)
	var/blood_cost = base_blood_cost * GET_MUTATION_SYNCHRONIZER(parent_mutation)
	if(user.blood_volume < (blood_cost * 2))
		to_chat(user, "<span class='warning'>You don't have enough blood to do that!</span>")
		return FALSE
	if(target.acid_act(50, acid_volume))
		user.visible_message("<span class='warning'>[user] rubs globs of vile stuff all over [target].</span>")
		user.blood_volume = max(user.blood_volume - blood_cost, 0)
		return ..()
	else
		to_chat(user, "<span class='notice'>You cannot dissolve this object.</span>")
		return FALSE
