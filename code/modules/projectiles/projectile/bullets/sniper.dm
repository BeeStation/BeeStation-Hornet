// .50 (Sniper)

/obj/item/projectile/bullet/p50
	name =".50 bullet"
	speed = 0.2
	damage = 70
	paralyze = 100
	dismemberment = 50
	armour_penetration = 50
	// Will penetrate but damage anything not a wall
	projectile_piercing = PASSMOB | PASSMACHINE | PASSTRANSPARENT | PASSGRILLE | PASSDOORS | PASSFLAPS | PASSSTRUCTURE
	var/breakthings = TRUE

/obj/item/projectile/bullet/p50/on_hit(atom/target, blocked = 0)
	if(isobj(target) && (blocked != 100) && breakthings)
		var/obj/O = target
		O.take_damage(80, BRUTE, "bullet", FALSE)
	return ..()

/obj/item/projectile/bullet/p50/penetrator
	name =".50 penetrator bullet"
	icon_state = "gauss"
	damage = 60
	projectile_piercing = PASSMOB | PASSMACHINE | PASSTRANSPARENT | PASSGRILLE | PASSDOORS | PASSFLAPS | PASSSTRUCTURE
	// Phase directly through everything else
	projectile_phasing = (ALL & ~(PASSMOB | PASSMACHINE | PASSTRANSPARENT | PASSGRILLE | PASSDOORS | PASSFLAPS | PASSSTRUCTURE))
	dismemberment = 0 //It goes through you cleanly.
	paralyze = 0
	breakthings = FALSE

/obj/item/projectile/bullet/p50/penetrator/shuttle //Nukeop Shuttle Variety
	icon_state = "gaussstrong"
	damage = 25
	speed = 0.3
	range = 16

/obj/item/projectile/bullet/p50/utility
	armour_penetration = 0
	damage = 20
	dismemberment = 0
	paralyze = 0
	breakthings = FALSE
	// Cannot pass through things like normal rounds
	projectile_piercing = NONE

/obj/item/projectile/bullet/p50/utility/soporific
	name =".50 soporific bullet"

/obj/item/projectile/bullet/p50/utility/soporific/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && isliving(target))
		var/mob/living/L = target
		L.Sleeping(400)
	return ..()

/obj/item/projectile/bullet/p50/utility/emp
	name = ".50 emp bullet"

/obj/item/projectile/bullet/p50/utility/emp/on_hit(atom/target, blocked)
	empulse(target, 3, 4)
	return ..()

/obj/item/projectile/bullet/p50/utility/explosive
	name = ".50 explosive bullet"

/obj/item/projectile/bullet/p50/utility/explosive/on_hit(atom/target, blocked)
	if (ismob(target))
		explosion(target, 0, 1, 3)
	else
		explosion(target, 1, 1, 3)
	return ..()

/obj/item/projectile/bullet/p50/utility/inferno
	name = ".50 inferno bullet"

/obj/item/projectile/bullet/p50/utility/inferno/on_hit(atom/target, blocked)
	explosion(target, 0, 0, 0, flame_range = 5)
	return ..()

/obj/item/projectile/bullet/p50/utility/antimatter
	name = ".50 antimatter-tipped bullet"

/obj/item/projectile/bullet/p50/utility/antimatter/on_hit(atom/target, blocked)
	explosion(target, 5, 8, 8)
	return ..()
