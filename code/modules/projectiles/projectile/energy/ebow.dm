/obj/item/projectile/energy/bolt //ebow bolts
	name = "bolt"
	icon_state = "cbbolt"
	damage = 10
	damage_type = TOX
	nodamage = FALSE
	stamina = 40
	eyeblur = 10
	slur = 10
	irradiate = 400
	armour_penetration = 100
	var/piercing = TRUE
	
	/obj/item/projectile/energy/bolt/Initialize()
	. = ..()
	create_reagents(25, NO_REACT)
	reagents.add_reagent(/datum/reagent/toxin/polonium, 10)
	reagents.add_reagent(/datum/reagent/toxin/fentanyl,5)
	reagents.add_reagent(/datum/reagent/uranium/radium,10)

/obj/item/projectile/energy/bolt/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(blocked != 100) // not completely blocked
			if(M.can_inject(null, FALSE, def_zone))
				..()
				reagents.reaction(M, INJECT)
				reagents.trans_to(M, reagents.total_volume)
				M.adjustBrainLoss(12.5)
				M.confused += 3
				return BULLET_ACT_HIT
			else
				blocked = 100
				target.visible_message("<span class='danger'>\The [src] was deflected!</span>", \
				 "<span class='userdanger'>You were protected against \the [src]!</span>")
				 
	..(target, blocked)
	DISABLE_BITFIELD(reagents.flags, NO_REACT)
	reagents.handle_reactions()
	

/obj/item/projectile/energy/bolt/halloween
	name = "candy corn"
	icon_state = "candy_corn"

/obj/item/projectile/energy/bolt/large
	damage = 20
	irradiate = 600
