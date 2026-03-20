/obj/projectile/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX
	nodamage = FALSE
	armor_flag = BIO
	impact_effect_type = /obj/effect/temp_visual/impact_effect/neurotoxin

/obj/projectile/neurotoxin/on_hit(atom/target, blocked = FALSE)
	if(isalien(target))
		paralyze = 0
		nodamage = TRUE
	if(iscarbon(target))
		var/mob/living/carbon/human/H = target
		if(H.can_inject())
			H.adjustStaminaLoss(40)
	return ..()

/obj/projectile/neurotoxin/damaging //for ai controlled aliums
	damage = 30
