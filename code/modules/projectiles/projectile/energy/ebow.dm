
/obj/projectile/energy/bolt //ebow bolts
	name = "bolt"
	icon_state = "cbbolt"
	damage = 15
	damage_type = TOX
	nodamage = FALSE
	stamina = 60
	eyeblur = 10
	knockdown = 10
	slur = 5

/obj/projectile/energy/bolt/radbolt
	name = "bolt"
	icon_state = "cbbolt"
	damage = 15
	damage_type = TOX
	nodamage = FALSE
	stamina = 35
	eyeblur = 10
	slur = 10
	knockdown = 0
	irradiate = 400

/obj/projectile/energy/bolt/radbolt/Initialize(mapload)
	. = ..()
	create_reagents(30, NO_REACT)
	reagents.add_reagent(/datum/reagent/toxin/polonium, 10)
	reagents.add_reagent(/datum/reagent/toxin/fentanyl, 5)
	reagents.add_reagent(/datum/reagent/toxin, 5)
	reagents.add_reagent(/datum/reagent/uranium/radium, 10)

/obj/projectile/energy/bolt/radbolt/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(blocked != 100) // not completely blocked
			if(M.can_inject(null, FALSE, def_zone,)) // Pass the hit zone to see if it can inject by whether it hit the head or the body.
				..()
				reagents.reaction(M, INJECT)
				reagents.trans_to(M, reagents.total_volume)
				M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 170)
				M.confused += 3
				return BULLET_ACT_HIT
			else
				blocked = 100
				target.visible_message("<span class='danger'>\The [src] was deflected!</span>", \
									   "<span class='userdanger'>You were protected against \the [src]!</span>")

	..(target, blocked)
	DISABLE_BITFIELD(reagents.flags, NO_REACT)
	reagents.handle_reactions()
	return BULLET_ACT_HIT

/obj/projectile/energy/bolt/halloween
	name = "candy corn"
	icon_state = "candy_corn"

/obj/projectile/energy/bolt/large
	damage = 20
