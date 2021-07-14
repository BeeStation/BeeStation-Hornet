/obj/item/shrapnel // frag grenades
	name = "shrapnel shard"
	embedding = list(embed_chance=70, ignore_throwspeed_threshold=TRUE, fall_chance=4)
	custom_materials = list(/datum/material/iron=50)
	armour_penetration = -20
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	w_class = WEIGHT_CLASS_TINY
	item_flags = DROPDEL

/obj/item/projectile/bullet/shrapnel
	name = "flying shrapnel shard"
	damage = 9
	range = 10
	armour_penetration = -30
	dismemberment = 5
	ricochets_max = 2
	ricochet_chance = 40
	shrapnel_type = /obj/item/shrapnel
	ricochet_incidence_leeway = 60
	hit_stunned_targets = TRUE
