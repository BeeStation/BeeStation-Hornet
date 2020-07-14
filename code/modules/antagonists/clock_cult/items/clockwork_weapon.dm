/obj/item/twohanded/clockwork
	name = "Clockwork Weapon"
	desc = "Something"
	icon = 'icons/obj/clockwork_objects.dmi'
	force_unwielded = 15
	force_wielded = 5
	block_power_wielded = 1
	block_power_unwielded = 0
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 20
	throw_speed = 4
	armour_penetration = 10
	materials = list(/datum/material/iron=1150, /datum/material/gold=2750)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	sharpness = IS_SHARP_ACCURATE
	max_integrity = 200
	var/clockwork_hint = ""
	var/datum/action/innate/clockcult/summon_spear/SS

/obj/item/twohanded/clockwork/Initialize()
	. = ..()
	SS = new
	SS.marked_item = src

/obj/item/twohanded/clockwork/pickup(mob/user)
	. = ..()
	if(is_servant_of_ratvar(user))
		SS.Grant(user)

/obj/item/twohanded/clockwork/examine(mob/user)
	. = ..()
	if(is_servant_of_ratvar(user) && clockwork_hint)
		. += clockwork_hint

/obj/item/twohanded/clockwork/attack(mob/living/target, mob/living/user)
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='large_brass'>You really thought you could get away with that?</span>")
		return ..(user, user)
	. = ..()
	if(!QDELETED(target) && target.stat != DEAD && !is_servant_of_ratvar(target) && !target.anti_magic_check(major=FALSE) && wielded)
		hit_effect(target, user)

/obj/item/twohanded/clockwork/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(hit_atom))
		var/mob/living/target = hit_atom
		if(!.)
			if(!target.anti_magic_check() && !is_servant_of_ratvar(target))
				hit_effect(target, throwingdatum.thrower, TRUE)

/obj/item/twohanded/clockwork/proc/hit_effect(mob/living/target, mob/living/user, thrown=FALSE)
	return

/obj/item/twohanded/clockwork/brass_spear
	name = "brassspear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	icon_state = "ratvarian_spear"
	embedding = list("embedded_impact_pain_multiplier" = 3)
	force_wielded = 25
	throwforce = 40
	armour_penetration = 18
	clockwork_hint = "Throwing the spear will deal bonus damage."

/obj/item/twohanded/clockwork/brass_battlehammer
	name = "brass battle-hammer"
	desc = "A brass hammer glowing with energy."
	icon_state = "ratvarian_hammer"
	force_wielded = 20
	throwforce = 24
	armour_penetration = 6
	sharpness = IS_BLUNT
	attack_verb = list("bashed", "smitted", "hammered", "attacked")
	clockwork_hint = "Enemies hit by this will be flung back."

/obj/item/twohanded/clockwork/brass_battlehammer/hit_effect(mob/living/target, mob/living/user, thrown=FALSE)
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, thrown ? 2 : 1, 4)

/obj/item/twohanded/clockwork/brass_sword
	name = "brass longsword"
	desc = "A large sword made of brass."
	icon_state = "ratvarian_spear"
	force_wielded = 25
	throwforce = 20
	armour_penetration = 12
	attack_verb = list("attacked", "slashed", "cut", "torn", "gored")
	clockwork_hint = "Targets will be struck with a powerful electromagnetic pulse."
	var/emp_cooldown = 0

/obj/item/twohanded/clockwork/brass_sword/hit_effect(mob/living/target, mob/living/user, thrown)
	if(world.time > emp_cooldown)
		target.emp_act(EMP_LIGHT)
		emp_cooldown = world.time + 300
		addtimer(CALLBACK(src, .proc/send_message, user), 300)
		to_chat(user, "<span class='brass'>You strike [target] with an electromagnetic pulse!</span>")
		playsound(user, 'sound/magic/lightningshock.ogg', 40)

/obj/item/twohanded/clockwork/brass_sword/proc/send_message(mob/living/target)
	to_chat(target, "<span class='brass'>[src] glows, indicating the next attack will disrupt electronics of the target.</span>")
