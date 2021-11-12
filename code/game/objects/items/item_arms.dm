/obj/item/item_arm
	name = "prosthetic item template"
	desc = "A piece of equipment that replaced your arm"
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	var/obj/droped_object

/obj/item/item_arm/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/item_arm/Destroy()
	var/obj/item/bodypart/part
	new droped_object(get_turf(src))
	if(iscarbon(loc))
		var/mob/living/carbon/holder = loc
		var/index = holder.get_held_index_of_item(src)
		if(index)
			part = holder.hand_bodyparts[index]
	. = ..()
	if(part)
		part.drop_limb()

/obj/item/shock_arm_unattached
	name = "Unattached Shock Arm"
	desc = "Shock arm ready to be surgicaly attached"
	icon = 'icons/obj/item_arms.dmi'
	icon_state = "shock_arm"

/obj/item/item_arm/shock_arm
	name = "Shock Arm"
	desc = "Device capable of incapiciating oponents at range using low intensity electricity arcs."
	force = 0
	reach = 5
	icon = 'icons/obj/item_arms.dmi'
	icon_state = "shock_arm"
	item_state = "shock_arm"
	lefthand_file = 'icons/mob/inhands/weapons/item_arm_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/item_arm_righthand.dmi'
	droped_object = /obj/item/shock_arm_unattached
	var/shock_range = 5
	var/shock_stamina = 15
	var/mob/living/shock_target
	var/mob/living/shock_instigator
	var/is_shocking = TRUE

/obj/item/item_arm/shock_arm/attack(mob/living/target, mob/living/user)
	. = ..()
	if(!ishuman(target))
		return
	is_shocking = TRUE
	shock_target = target
	shock_instigator = user
	START_PROCESSING(SSobj, src)
    
/obj/item/item_arm/shock_arm/process()
	if(isInSight(get_turf(src), shock_target) && get_dist(get_turf(src), shock_target) <= shock_range )
		shock_instigator.Beam(shock_target, icon_state="lightning[rand(1,12)]", time=5, maxdistance = 7)
		var/obj/item/bodypart/affecting = shock_target.get_bodypart(ran_zone(BODY_ZONE_CHEST))
		var/armor_block = shock_target.run_armor_check(affecting, "stamina")
		shock_target.apply_damage(shock_stamina, STAMINA, affecting, armor_block)
		shock_target.electrocute_act(0, shock_instigator, 1, FALSE, FALSE, FALSE, FALSE, FALSE)
		playsound(src, 'sound/weapons/zapbang.ogg', 50)
	else
		is_shocking = FALSE
		STOP_PROCESSING(SSobj, src)

/obj/item/item_arm/shock_arm/attack_self(mob/user)
	is_shocking = TRUE
	STOP_PROCESSING(SSobj, src)

/obj/item/item_arm/mounted_chainsaw
	name = "mounted chainsaw template"
	desc = "A chainsaw that has replaced your arm."
	icon_state = "chainsaw_on"
	item_state = "mounted_chainsaw"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	block_upgrade_walk = 2
	block_power = 20
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	force = 24
	attack_weight = 2
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	sharpness = IS_SHARP
	attack_verb = list("sawed", "tore", "cut", "chopped", "diced")
	hitsound = 'sound/weapons/chainsawhit.ogg'
	tool_behaviour = TOOL_SAW
	toolspeed = 1
	droped_object = /obj/item/chainsaw

/obj/item/item_arm/mounted_chainsaw/normal
	name = "mounted chainsaw"

/obj/item/item_arm/mounted_chainsaw/energy
	name = "mounted energy chainsaw"
	desc = "An energy chainsaw that has replaced your arm."
	force = 40
	armour_penetration = 50
	hitsound = 'sound/weapons/echainsawhit1.ogg'
	droped_object = /obj/item/chainsaw/energy

/obj/item/item_arm/mounted_chainsaw/super
	name = "mounted super energy chainsaw"
	desc = "A super energy chainsaw that has replaced your arm."
	force = 60
	armour_penetration = 75
	hitsound = 'sound/weapons/echainsawhit1.ogg'
	droped_object = /obj/item/chainsaw/energy/doom

/obj/item/item_arm/mounted_chainsaw/super/attack(mob/living/target)
	..()
	target.Knockdown(4)