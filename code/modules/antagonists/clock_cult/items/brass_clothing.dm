/obj/item/clothing/suit/clockwork
	name = "brass armor"
	desc = "A strong, brass suit worn by the soldiers of the Ratvarian armies."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cuirass"
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	worn_icon_state = "clockwork_cuirass"
	armor_type = /datum/armor/suit_clockwork
	slowdown = 0.6
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/clockwork, /obj/item/stack/sheet/brass, /obj/item/clockwork, /obj/item/gun/ballistic/bow/clockwork)
	var/allow_any = FALSE

/datum/armor/suit_clockwork
	melee = 50
	bullet = 60
	laser = 30
	energy = 80
	bomb = 80
	bio = 100
	fire = 100
	acid = 100
	stamina = 60
	bleed = 60

/obj/item/clothing/suit/clockwork/anyone
	allow_any = TRUE

/obj/item/clothing/suit/clockwork/equipped(mob/living/user, slot)
	. = ..()
	if((istype(user, /mob/living/carbon/human/consistent) && !user.client) || (istype(user, /mob/living/carbon/human/dummy) && !user.client))
		//Fake people need not apply (it fucks up my unit tests)
		return
	if(IS_SERVANT_OF_RATVAR(user) || allow_any)
		return
	to_chat(user, span_userdanger("You feel a shock of energy surge through your body!"))
	user.dropItemToGround(src, TRUE)
	var/mob/living/carbon/C = user
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		H.electrocution_animation(20)
	C.do_jitter_animation(300) // Maximum jitter
	C.adjust_jitter(20 SECONDS)
	C.adjust_stutter(2 SECONDS)
	spawn(20)
	if(C)
		C.remove_status_effect(/datum/status_effect/jitter)

/obj/item/clothing/suit/clockwork/speed
	name = "robes of divinity"
	desc = "A shiny suit, glowing with a vibrant energy. The wearer will be able to move quickly across battlefields, but will be able to withstand less damage before falling."
	icon_state = "clockwork_cuirass_speed"
	worn_icon_state = "clockwork_cuirass_speed"
	slowdown = -0.3
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor_type = /datum/armor/clockwork_speed

/datum/armor/clockwork_speed
	melee = 40
	bullet = 40
	laser = 10
	energy = -20
	bomb = 60
	bio = 100
	fire = 100
	acid = 100
	stamina = 30
	bleed = 40

/obj/item/clothing/suit/clockwork/cloak
	name = "shrouding cloak"
	desc = "A faltering cloak that bends light around it, distorting the user's appearance, making it hard to see them with the naked eye. However, it provides very little protection."
	icon_state = "clockwork_cloak"
	worn_icon_state = "clockwork_cloak"
	armor_type = /datum/armor/clockwork_cloak
	slowdown = 0.4
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/shroud_active = FALSE
	var/previous_alpha

/datum/armor/clockwork_cloak
	melee = 10
	bullet = 60
	laser = 40
	energy = 20
	bomb = 40
	bio = 100
	fire = 100
	acid = 100
	stamina = 20
	bleed = 20

/obj/item/clothing/suit/clockwork/cloak/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_OCLOTHING && !shroud_active)
		shroud_active = TRUE
		previous_alpha = user.alpha
		animate(user, alpha=140, time=30)
		apply_wibbly_filters(user)

/obj/item/clothing/suit/clockwork/cloak/dropped(mob/user)
	..()
	if(shroud_active)
		shroud_active = FALSE
		do_sparks(3, FALSE, user)
		remove_wibbly_filters(user)
		animate(user, alpha=previous_alpha, time=30)

/obj/item/clothing/glasses/clockwork
	name = "base clock glasses"
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cuirass"
	worn_icon_state = "wraith_specs"

/obj/item/clothing/glasses/clockwork/equipped(mob/user, slot)
	. = ..()
	if(!IS_SERVANT_OF_RATVAR(user))
		to_chat(user, span_userdanger("You feel a shock of energy surge through your body!"))
		user.dropItemToGround(src, TRUE)
		var/mob/living/carbon/C = user
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			H.electrocution_animation(20)
		C.do_jitter_animation(300) // Maximum jitter
		C.adjust_jitter(20 SECONDS)
		C.adjust_stutter(2 SECONDS)
		spawn(20)
		if(C)
			C.remove_status_effect(/datum/status_effect/jitter)

/obj/item/clothing/glasses/clockwork/wraith_spectacles
	name = "wraith spectacles"
	desc = "Mystical glasses that glow with a bright energy. Some say they can see things that shouldn't be seen."
	icon_state = "wraith_specs"
	invis_view = SEE_INVISIBLE_SPIRIT
	invis_override = null
	flash_protect = FLASH_PROTECTION_SENSITIVE
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	glass_colour_type = /datum/client_colour/glass_colour/yellow
	var/mob/living/wearer
	var/applied_eye_damage

/obj/item/clothing/glasses/clockwork/wraith_spectacles/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/glasses/clockwork/wraith_spectacles/equipped(mob/living/user, slot)
	. = ..()
	if(!isliving(user))
		return
	if(slot == ITEM_SLOT_EYES)
		wearer = user
		applied_eye_damage = 0
		START_PROCESSING(SSobj, src)
		to_chat(user, span_nezbere("You suddenly see so much more, but your eyes begin to falter..."))

/obj/item/clothing/glasses/clockwork/wraith_spectacles/process(delta_time)
	. = ..()
	if(!wearer)
		STOP_PROCESSING(SSobj, src)
		return
	//~1 damage every 2 seconds, maximum of 70 after 140 seconds
	wearer.adjustOrganLoss(ORGAN_SLOT_EYES, 0.5*delta_time, 70)
	applied_eye_damage = min(applied_eye_damage + 1, 70)

/obj/item/clothing/glasses/clockwork/wraith_spectacles/dropped(mob/user)
	..()
	if(wearer && IS_SERVANT_OF_RATVAR(wearer))
		to_chat(user, span_nezbere("You feel your eyes slowly recovering."))
		addtimer(CALLBACK(wearer, TYPE_PROC_REF(/mob/living, adjustOrganLoss), ORGAN_SLOT_EYES, -applied_eye_damage), 600)
		wearer = null
		applied_eye_damage = 0
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/head/helmet/clockcult
	name = "brass helmet"
	desc = "A strong, brass helmet worn by the soldiers of the Ratvarian armies. Includes an integrated light-dimmer for flash protection, as well as occult-grade muffling for factory based environments."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_helmet"
	armor_type = /datum/armor/helmet_clockcult
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_BULKY
	flash_protect = FLASH_PROTECTION_FLASH
	bang_protect = 3


/datum/armor/helmet_clockcult
	melee = 50
	bullet = 60
	laser = 30
	energy = 80
	bomb = 80
	bio = 100
	fire = 100
	acid = 100
	stamina = 60
	bleed = 60

/obj/item/clothing/shoes/clockcult
	name = "brass treads"
	desc = "A strong pair of brass boots worn by the soldiers of the Ratvarian armies."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_treads"

/obj/item/clothing/gloves/clockcult
	name = "brass gauntlets"
	desc = "A strong pair of brass gloves worn by the soldiers of the Ratvarian armies."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_gauntlets"
	siemens_coefficient = 0
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor_type = /datum/armor/gloves_clockcult


/datum/armor/gloves_clockcult
	bio = 90
	fire = 80
	acid = 50
	bleed = 20
