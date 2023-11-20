/obj/item/organ/veins
	name = "veins"
	desc = "Basically, this is an abstract type of an organ that exists to every carbon mob... If you see this, tell any coder."
	w_class = WEIGHT_CLASS_SMALL
	zone = null
	slot = ORGAN_SLOT_VEINS

	organ_flags = ORGAN_ABSTRACT | ORGAN_VITAL | ORGAN_UNREMOVABLE

	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Hivelord_dead"
	color = "#FF0000"


/obj/item/organ/veins/Initialize(mapload)
	. = ..()
	create_reagents(1000)

// veins don't take any damage currently
/obj/item/organ/veins/applyOrganDamage(d, maximum = maxHealth)
	return

// veins don't take any damage currently
/obj/item/organ/veins/setOrganDamage(d)
	return

// veins don't do anything currently
/obj/item/organ/veins/check_damage_thresholds(M)
	return

// veins don't check ORGAN_FAILING, but also don't take damage, and no need to be healed.
/obj/item/organ/veins/on_life()
	return

// don't send a needless signal. There's no robotic veins currently.
/obj/item/organ/veins/emp_act(severity)
	return
