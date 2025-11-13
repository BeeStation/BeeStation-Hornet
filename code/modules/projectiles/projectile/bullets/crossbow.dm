/obj/projectile/bullet/rebar
	name = "rebar"
	icon_state = "rebar"
	damage = 30
	speed = 2.5
	dismemberment = 1 //because a 1 in 100 chance to just blow someones arm off is enough to be cool but also not enough to be reliable
	shrapnel_type = /obj/item/ammo_casing/rebar

/obj/projectile/bullet/rebar/syndie
	damage = 45
	dismemberment = 2 //It's a budget sniper rifle.
	armour_penetration = 20 //A bit better versus armor. Gets past anti laser armor or a vest, but doesnt wound proc on sec armor.
	shrapnel_type = /obj/item/ammo_casing/rebar/syndie

/obj/projectile/bullet/rebar/zaukerite
	name = "zaukerite shard"
	icon_state = "rebar_zaukerite"
	damage = 60
	speed = 1.6
	dismemberment = 10
	damage_type = TOX
	eyeblur = 5
	armour_penetration = 20 // not nearly as good, as its not as sharp.
	shrapnel_type = /obj/item/ammo_casing/rebar/zaukerite

/obj/projectile/bullet/rebar/hydrogen
	name = "metallic hydrogen bolt"
	icon_state = "rebar_hydrogen"
	damage = 35
	speed = 1.6
	projectile_piercing = PASSMOB | PASSMACHINE
	projectile_phasing = ~(PASSMOB|PASSMACHINE)
	phasing_ignore_direct_target = TRUE
	dismemberment = 0 //goes through clean.
	damage_type = BRUTE
	armour_penetration = 30 //very pointy.
	shrapnel_type = /obj/item/ammo_casing/rebar/hydrogen

/obj/projectile/bullet/rebar/hydrogen/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	def_zone = ran_zone(def_zone, clamp(205-(7*get_dist(get_turf(target), starting)), 5, 100))

/obj/projectile/bullet/rebar/healium
	name = "healium bolt"
	icon_state = "rebar_healium"
	damage = 0
	dismemberment = 0
	damage_type = BRUTE
	armour_penetration = 100
	shrapnel_type = /obj/item/ammo_casing/rebar/healium

/obj/projectile/bullet/rebar/healium/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!isliving(target))
		return BULLET_ACT_HIT

	var/mob/living/breather = target
	breather.SetSleeping(3 SECONDS)
	breather.adjustFireLoss(-30)
	breather.adjustToxLoss(-30)
	breather.adjustBruteLoss(-30)
	breather.adjustOxyLoss(-30)

	return BULLET_ACT_HIT

/obj/projectile/bullet/rebar/supermatter
	name = "supermatter bolt"
	icon_state = "rebar_supermatter"
	damage = 0
	dismemberment = 0
	damage_type = TOX
	armour_penetration = 100
	shrapnel_type = /obj/item/ammo_casing/rebar/supermatter

/obj/projectile/bullet/rebar/supermatter/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/victim = target
		victim.investigate_log("has been dusted by [src].", INVESTIGATE_DEATHS)
		dust_feedback(target)
		victim.dust()
	else if(!isturf(target))
		dust_feedback(target)
		qdel(target)

	return BULLET_ACT_HIT

/obj/projectile/bullet/rebar/supermatter/proc/dust_feedback(atom/target)
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 10, TRUE)
	visible_message(span_danger("[target] is hit by [src], turning [target.p_them()] to dust in a brilliant flash of light!"))
