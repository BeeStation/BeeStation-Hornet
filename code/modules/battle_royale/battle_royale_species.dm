/datum/species/human/battleroyale
	name = "Battle Royale Soldier" //inherited from the real species, for health scanners and things
	id = "battleroyale"
	limbs_id = "human"
	species_traits = list(NOTRANSSTING) //all of these + whatever we inherit from the real species
	inherent_traits = list(TRAIT_NOHUNGER,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER,TRAIT_VIRUSIMMUNE,TRAIT_NODISMEMBER,TRAIT_ALWAYS_CLEAN,TRAIT_FEARLESS)
	changesource_flags = MIRROR_BADMIN
	liked_food = ALL
	punchdamage = 12
	//bullets do less damage in battle royale
	var/bullet_mod = 0.6

/datum/species/human/battleroyale/spec_death(gibbed, mob/living/carbon/human/H)
	//Contents get thrown
	var/list/contents = H.get_contents()
	var/list/turfs_to_throw = view(2, H)
	for(var/item/I in contents)
		I.forceMove(get_turf(I))
		I.throw_at(pick(turfs_to_throw), 3, 1, spin = FALSE)
		I.pixel_x = rand(-10, 10)
		I.pixel_y = rand(-10, 10)
	//Death
	H.dust(TRUE)

//Reduce bullet damage, ignores sleeping carp
/datum/species/human/battleroyale/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	var/armor = run_armor_check(def_zone, P.flag, "","",P.armour_penetration)
	if(!P.nodamage)
		apply_damage(P.damage * bullet_mod, P.damage_type, def_zone, armor)
	return P.on_hit(src, armor)? BULLET_ACT_HIT : BULLET_ACT_BLOCK
