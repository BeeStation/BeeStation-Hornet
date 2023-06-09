
// CHAINSAW
/obj/item/chainsaw
	name = "chainsaw"
	desc = "A versatile power tool. Useful for limbing trees and delimbing humans."
	icon_state = "chainsaw_off"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 13
	block_power = 20
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	attack_weight = 2
	var/force_on = 24
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 13
	throw_speed = 2
	throw_range = 4
	materials = list(/datum/material/iron=13000)
	attack_verb = list("sawed", "tore", "cut", "chopped", "diced")
	hitsound = "swing_hit"
	sharpness = IS_SHARP
	actions_types = list(/datum/action/item_action/startchainsaw)
	var/on = FALSE
	tool_behaviour = TOOL_SAW
	toolspeed = 0.5
	item_flags = ISWEAPON

/obj/item/chainsaw/Initialize(mapload)
	. = ..()

/obj/item/chainsaw/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/butchering, 30, 100, 0, 'sound/weapons/chainsawhit.ogg', TRUE)
	AddComponent(/datum/component/two_handed, require_twohands=TRUE, block_power_unwielded=block_power, block_power_wielded=block_power)

/obj/item/chainsaw/suicide_act(mob/living/carbon/user)
	if(on)
		user.visible_message("<span class='suicide'>[user] begins to tear [user.p_their()] head off with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		playsound(src, 'sound/weapons/chainsawhit.ogg', 100, TRUE)
		var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
		if(myhead)
			myhead.dismember()
	else
		user.visible_message("<span class='suicide'>[user] smashes [src] into [user.p_their()] neck, destroying [user.p_their()] esophagus! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		playsound(src, 'sound/weapons/genhit1.ogg', 100, TRUE)
	return(BRUTELOSS)

/obj/item/chainsaw/attack_self(mob/user)
	on = !on
	to_chat(user, "As you pull the starting cord dangling from [src], [on ? "it begins to whirr." : "the chain stops moving."]")
	force = on ? force_on : initial(force)
	throwforce = on ? force_on : initial(force)
	icon_state = "chainsaw_[on ? "on" : "off"]"
	var/datum/component/butchering/butchering = src.GetComponent(/datum/component/butchering)
	butchering.butchering_enabled = on

	if(on)
		hitsound = 'sound/weapons/chainsawhit.ogg'
	else
		hitsound = "swing_hit"

	if(src == user.get_active_held_item()) //update inhands
		user.update_inv_hands()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

// DOOMGUY CHAINSAW
/obj/item/chainsaw/doomslayer
	name = "THE GREAT COMMUNICATOR"
	desc = "<span class='warning'>VRRRRRRR!!!</span>"
	armour_penetration = 100
	force_on = 30

/obj/item/chainsaw/doomslayer/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		owner.visible_message("<span class='danger'>Ranged attacks just make [owner] angrier!</span>")
		playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, TRUE)
		return 1
	return 0

// ENERGY CHAINSAW
/obj/item/chainsaw/energy
	name = "energy chainsaw"
	desc = "Become Leatherspace."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "echainsaw_off"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	force_on = 40
	w_class = WEIGHT_CLASS_HUGE
	attack_verb = list("sawed", "shred", "rended", "gutted", "eviscerated")
	actions_types = list(/datum/action/item_action/startchainsaw)
	block_power = 50
	armour_penetration = 50
	light_color = "#ff0000"
	var/onsound
	var/offsound
	onsound = 'sound/weapons/echainsawon.ogg'
	offsound = 'sound/weapons/echainsawoff.ogg'
	on = FALSE
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 1
	light_on = TRUE

/obj/item/chainsaw/energy/attack_self(mob/user)
	on = !on
	to_chat(user, "As you pull the starting cord dangling from [src], [on ? "it begins to whirr intimidatingly." : "the plasma microblades stop moving."]")
	force = on ? force_on : initial(force)
	playsound(user, on ? onsound : offsound , 50, 1)
	if(on)
		set_light(TRUE)
	else
		set_light(FALSE)
	throwforce = on ? force_on : initial(force)
	icon_state = "echainsaw_[on ? "on" : "off"]"

	if(hitsound == "swing_hit")
		hitsound = pick('sound/weapons/echainsawhit1.ogg','sound/weapons/echainsawhit2.ogg')
	else
		hitsound = "swing_hit"

	if(src == user.get_active_held_item())
		user.update_inv_hands()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

// DOOMGUY ENERGY CHAINSAW
/obj/item/chainsaw/energy/doom
	name = "super energy chainsaw"
	desc = "The chainsaw you want when you need to kill every damn thing in the room."
	force_on = 60
	w_class = WEIGHT_CLASS_NORMAL
	block_power = 75
	block_level = 1
	attack_weight = 3 //fear him
	armour_penetration = 75
	var/knockdown = 1
	light_range = 6

/obj/item/chainsaw/energy/doom/attack(mob/living/target)
	..()
	target.Knockdown(4)
