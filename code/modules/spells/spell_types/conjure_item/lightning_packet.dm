/datum/action/spell/conjure_item/spellpacket
	name = "Thrown Lightning"
	desc = "Forged from eldrich energies, a packet of pure power, \
		known as a spell packet will appear in your hand, that - when thrown - will stun the target."
	button_icon_state = "thrownlightning"

	cooldown_time = 4 SECONDS
	spell_max_level = 1

	item_type = /obj/item/spellpacket/lightningbolt

/datum/action/spell/conjure_item/spellpacket/is_valid_spell(mob/user, atom/target)
	return ..() && istype(user, /mob/living/carbon)

/datum/action/spell/conjure_item/spellpacket/on_cast(mob/living/carbon/user, atom/target)
	. = ..()
	user.throw_mode_on(THROW_MODE_TOGGLE)

/obj/item/spellpacket/lightningbolt
	name = "\improper Lightning bolt Spell Packet"
	desc = "Some birdseed wrapped in cloth that crackles with electricity."
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = WEIGHT_CLASS_TINY

/obj/item/spellpacket/lightningbolt/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(.)
		return

	if(isliving(hit_atom))
		var/mob/living/hit_living = hit_atom
		if(!hit_living.can_block_magic())
			hit_living.electrocute_act(80, src, flags = SHOCK_ILLUSION)
	qdel(src)

/obj/item/spellpacket/lightningbolt/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = INFINITY, quickstart = TRUE)
	. = ..()
	if(ishuman(thrower))
		var/mob/living/carbon/human/human_thrower = thrower
		human_thrower.say("LIGHTNINGBOLT!!", forced = "spell")
