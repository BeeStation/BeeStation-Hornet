/obj/item/gun/magic/staff
	slot_flags = ITEM_SLOT_BACK
	worn_icon_state = null
	icon_state = "staff"
	inhand_icon_state = "staff"
	item_flags = NEEDS_PERMIT | NO_MAT_REDEMPTION
	weapon_weight = WEAPON_MEDIUM
	fire_rate = 1.5
	max_charges = 10

	canblock = TRUE
	block_power = 50
	block_flags = BLOCKING_ACTIVE | BLOCKING_UNBALANCE

/obj/item/gun/magic/staff/change
	name = "staff of change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "staffofchange"
	inhand_icon_state = "staffofchange"

/obj/item/gun/magic/staff/dismember
	name = "staff of dismemberment"
	desc = "An artefact that spits bolts of malefic energy which causes arms and legs to fly right off of its victimse."
	fire_sound = 'sound/magic/staff_animation.ogg'
	ammo_type = /obj/item/ammo_casing/magic/dismember
	icon_state = "staffofdismember"
	inhand_icon_state = "staffofdismember"

/obj/item/gun/magic/staff/potential
	name = "staff of latent potential"
	desc = "An artefact that will unlock someone's greatest potential, or take it away again. Not everyone is destined for greatness."
	fire_sound = 'sound/magic/staff_healing.ogg'
	ammo_type = /obj/item/ammo_casing/magic/potential
	icon_state = "staffofpotential"
	inhand_icon_state = "staffofpotential"

/obj/item/gun/magic/staff/potential/handle_suicide() //Stops people trying to commit suicide to heal themselves
	return

/obj/item/gun/magic/staff/chaos
	name = "staff of chaos"
	desc = "An artefact that spits bolts of chaotic magic that can potentially do anything."
	fire_sound = 'sound/magic/staff_chaos.ogg'
	ammo_type = /obj/item/ammo_casing/magic/chaos
	icon_state = "staffofchaos"
	inhand_icon_state = "staffofchaos"
	recharge_rate = 2
	no_den_usage = 1
	/// Static list of all projectiles we can fire from our staff.
	/// Doesn't contain all subtypes of magic projectiles, unlike what it looks like
	var/static/list/allowed_projectile_types = list(
		/obj/projectile/magic/animate,
		/obj/projectile/magic/antimagic,
		/obj/projectile/magic/arcane_barrage,
		/obj/projectile/magic/bounty,
		/obj/projectile/magic/change,
		/obj/projectile/magic/death,
		/obj/projectile/magic/door,
		/obj/projectile/magic/fetch,
		/obj/projectile/magic/fireball,
		/obj/projectile/magic/flying,
		/obj/projectile/magic/locker,
		/obj/projectile/magic/necropotence,
		/obj/projectile/magic/healing,
		/obj/projectile/magic/sapping,
		/obj/projectile/magic/spellblade,
		/obj/projectile/magic/teleport,
		/obj/projectile/magic/wipe,
		/obj/projectile/temp/chill,
	)

/obj/item/gun/magic/staff/chaos/fire_shot_at(mob/living/user, atom/target, message, params, zone_override, aimed)
	chambered.projectile_type = pick(allowed_projectile_types)
	return ..()

/obj/item/gun/magic/staff/door
	name = "staff of door creation"
	desc = "An artefact that spits bolts of transformative magic that can create doors in walls."
	fire_sound = 'sound/magic/staff_door.ogg'
	ammo_type = /obj/item/ammo_casing/magic/door
	icon_state = "staffofdoor"
	inhand_icon_state = "staffofdoor"
	recharge_rate = 2
	no_den_usage = 1

/obj/item/gun/magic/staff/honk
	name = "staff of the honkmother"
	desc = "Honk."
	fire_sound = 'sound/items/airhorn.ogg'
	ammo_type = /obj/item/ammo_casing/magic/honk
	icon_state = "honker"
	inhand_icon_state = "honker"
	max_charges = 4
	custom_price = 10000
	max_demand = 10

/obj/item/gun/magic/staff/spellblade
	name = "spellblade"
	desc = "A deadly combination of laziness and boodlust, this blade allows the user to dismember their enemies without all the hard work of actually swinging the sword."
	fire_sound = 'sound/magic/fireball.ogg'
	ammo_type = /obj/item/ammo_casing/magic/spellblade
	icon_state = "spellblade"
	inhand_icon_state = "spellblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/rapierhit.ogg'
	force = 20
	armour_penetration = 75
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_DEEP_WOUND
	max_charges = 4
	custom_price = 40000
	max_demand = 2

/obj/item/gun/magic/staff/spellblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 15, 125, 0, hitsound)

/obj/item/gun/magic/staff/locker
	name = "staff of the locker"
	desc = "An artefact that expells encapsulating bolts, for incapacitating thy enemy."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/locker
	icon_state = "locker"
	inhand_icon_state = "locker"
	worn_icon_state = "lockerstaff"
	recharge_rate = 4

//yes, they don't have sounds. they're admin staves, and their projectiles will play the chaos bolt sound anyway so why bother?

/obj/item/gun/magic/staff/flying
	name = "staff of flying"
	desc = "An artefact that spits bolts of graceful magic that can make something fly."
	fire_sound = 'sound/magic/staff_healing.ogg'
	ammo_type = /obj/item/ammo_casing/magic/flying
	icon_state = "staffofflight"
	inhand_icon_state = "staffofflight"
	worn_icon_state = "flightstaff"

/obj/item/gun/magic/staff/sapping
	name = "staff of sapping"
	desc = "An artefact that spits bolts of sapping magic that can make something sad."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/sapping
	icon_state = "staffofsapping"
	inhand_icon_state = "staffofsapping"
	worn_icon_state = "staff"

/obj/item/gun/magic/staff/necropotence
	name = "staff of necropotence"
	desc = "An artefact that spits bolts of death magic that can repurpose the soul."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/necropotence
	icon_state = "staffofnecropotence"
	inhand_icon_state = "staffofnecropotence"
	worn_icon_state = "necrostaff"

/obj/item/gun/magic/staff/wipe
	name = "staff of possession"
	desc = "An artefact that spits bolts of mind-unlocking magic that can let ghosts invade the victim's mind."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/wipe
	icon_state = "staffofwipe"
	inhand_icon_state = "staffofwipe"
	worn_icon_state = "wipestaff"
