/obj/projectile/bullet/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX

/obj/projectile/bullet/neurotoxin/on_hit(atom/target, blocked = FALSE)
	if(isalien(target))
		paralyze = 0
		nodamage = TRUE
	if(iscarbon(target))
		var/mob/living/carbon/human/H = target
		if(H.can_inject())
			H.stamina.adjust(-40)
	return ..()
