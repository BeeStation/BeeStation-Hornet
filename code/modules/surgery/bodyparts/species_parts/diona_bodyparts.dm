///Dionae Body parts, used to be podpeople
/obj/item/bodypart/head/diona
	static_icon = 'icons/mob/species/diona/bodyparts.dmi'
	icon = 'icons/mob/species/diona/bodyparts.dmi'
	limb_id = SPECIES_DIONA
	is_dimorphic = FALSE
	dismemberable = 0
	uses_mutcolor = TRUE
	is_pseudopart = TRUE

/obj/item/bodypart/head/diona/drop_organs(mob/user, violent_removal)
	. = ..()
	new /mob/living/simple_animal/hostile/retaliate/nymph(user.loc)
	qdel(src)

/obj/item/bodypart/chest/diona
	static_icon = 'icons/mob/species/diona/bodyparts.dmi'
	icon = 'icons/mob/species/diona/bodyparts.dmi'
	limb_id = SPECIES_DIONA
	is_dimorphic = FALSE
	uses_mutcolor = TRUE
	is_pseudopart = TRUE

/obj/item/bodypart/chest/diona/drop_organs(mob/user, violent_removal)
	. = ..()
	new /mob/living/simple_animal/hostile/retaliate/nymph(user.loc)
	qdel(src)

/obj/item/bodypart/l_arm/diona
	static_icon = 'icons/mob/species/diona/bodyparts.dmi'
	icon = 'icons/mob/species/diona/bodyparts.dmi'
	limb_id = SPECIES_DIONA
	uses_mutcolor = TRUE
	is_pseudopart = TRUE

/obj/item/bodypart/l_arm/diona/drop_organs(mob/user, violent_removal)
	. = ..()
	new /mob/living/simple_animal/hostile/retaliate/nymph(user.loc)
	qdel(src)

/obj/item/bodypart/r_arm/diona
	static_icon = 'icons/mob/species/diona/bodyparts.dmi'
	icon = 'icons/mob/species/diona/bodyparts.dmi'
	limb_id = SPECIES_DIONA
	uses_mutcolor = TRUE
	is_pseudopart = TRUE

/obj/item/bodypart/r_arm/diona/drop_organs(mob/user, violent_removal)
	. = ..()
	new /mob/living/simple_animal/hostile/retaliate/nymph(user.loc)
	qdel(src)

/obj/item/bodypart/l_leg/diona
	static_icon = 'icons/mob/species/diona/bodyparts.dmi'
	icon = 'icons/mob/species/diona/bodyparts.dmi'
	limb_id = SPECIES_DIONA
	uses_mutcolor = TRUE
	is_pseudopart = TRUE

/obj/item/bodypart/l_leg/diona/drop_organs(mob/user, violent_removal)
	. = ..()
	new /mob/living/simple_animal/hostile/retaliate/nymph(user.loc)
	qdel(src)

/obj/item/bodypart/r_leg/diona
	static_icon = 'icons/mob/species/diona/bodyparts.dmi'
	icon = 'icons/mob/species/diona/bodyparts.dmi'
	limb_id = SPECIES_DIONA
	uses_mutcolor = TRUE
	is_pseudopart = TRUE

/obj/item/bodypart/r_leg/diona/drop_organs(mob/user, violent_removal)
	. = ..()
	new /mob/living/simple_animal/hostile/retaliate/nymph(user.loc)
	qdel(src)
