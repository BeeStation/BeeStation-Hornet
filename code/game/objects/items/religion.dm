/obj/item/banner
	name = "banner"
	desc = "A banner with Nanotrasen's logo on it."
	icon = 'icons/obj/banner.dmi'
	icon_state = "banner"
	inhand_icon_state = "banner"
	force = 8
	attack_verb_continuous = list("forcefully inspires", "violently encourages", "relentlessly galvanizes")
	attack_verb_simple = list("forcefully inspire", "violently encourage", "relentlessly galvanize")
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	var/inspiration_available = TRUE //If this banner can be used to inspire crew
	var/morale_time = 0
	var/morale_cooldown = 600 //How many deciseconds between uses
	var/list/job_loyalties //Mobs with any of these assigned roles will be inspired
	var/list/role_loyalties //Mobs with any of these special roles will be inspired
	var/warcry

/obj/item/banner/examine(mob/user)
	. = ..()
	if(inspiration_available)
		. += span_notice("Activate it in your hand to inspire nearby allies of this banner's allegiance!")

/obj/item/banner/attack_self(mob/living/carbon/human/user)
	if(!inspiration_available)
		return
	if(morale_time > world.time)
		to_chat(user, span_warning("You aren't feeling inspired enough to flourish [src] again yet."))
		return
	user.visible_message(span_bignotice("[user] flourishes [src]!"), \
	span_notice("You raise [src] skywards, inspiring your allies!"))
	playsound(src, "rustle", 100, FALSE)
	if(warcry)
		user.say("[warcry]", forced="banner")
	var/old_transform = user.transform
	user.transform *= 1.2
	animate(user, transform = old_transform, time = 10)
	morale_time = world.time + morale_cooldown

	var/list/inspired = list()
	var/has_job_loyalties = LAZYLEN(job_loyalties)
	var/has_role_loyalties = LAZYLEN(role_loyalties)
	inspired += user //The user is always inspired, regardless of loyalties
	for(var/mob/living/carbon/human/H in viewers(4, get_turf(src)))
		if(H.stat == DEAD || H == user)
			continue
		if(H.mind && (has_job_loyalties || has_role_loyalties))
			if(has_job_loyalties && (H.mind.assigned_role in job_loyalties))
				inspired += H
			else if(has_role_loyalties && (H.mind.special_role in role_loyalties))
				inspired += H
		else if(check_inspiration(H))
			inspired += H

	for(var/V in inspired)
		var/mob/living/carbon/human/H = V
		if(H != user)
			to_chat(H, span_notice("Your confidence surges as [user] flourishes [user.p_their()] [name]!"))
		inspiration(H)
		special_inspiration(H)

/obj/item/banner/proc/check_inspiration(mob/living/carbon/human/H) //Banner-specific conditions for being eligible
	return

/obj/item/banner/proc/inspiration(mob/living/carbon/human/H)
	H.adjustBruteLoss(-15)
	H.adjustFireLoss(-15)
	H.AdjustStun(-40)
	H.AdjustKnockdown(-40)
	H.AdjustImmobilized(-40)
	H.AdjustParalyzed(-40)
	H.AdjustUnconscious(-40)
	playsound(H, 'sound/magic/staff_healing.ogg', 25, FALSE)

/obj/item/banner/proc/special_inspiration(mob/living/carbon/human/H) //Any banner-specific inspiration effects go here
	return

/obj/item/banner/security
	name = "securistan banner"
	desc = "The banner of Securistan, ruling the station with an iron fist."
	icon_state = "banner_security"
	inhand_icon_state = "banner_security"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_BRIGPHYSICIAN, JOB_NAME_DEPUTY)
	warcry = "EVERYONE DOWN ON THE GROUND!!"

/obj/item/banner/security/mundane
	inspiration_available = FALSE

/obj/item/banner/medical
	name = "meditopia banner"
	desc = "The banner of Meditopia, generous benefactors that cure wounds and shelter the weak."
	icon_state = "banner_medical"
	inhand_icon_state = "banner_medical"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = list(JOB_NAME_MEDICALDOCTOR, JOB_NAME_CHEMIST, JOB_NAME_GENETICIST, JOB_NAME_VIROLOGIST, JOB_NAME_PARAMEDIC, JOB_NAME_CHIEFMEDICALOFFICER)
	warcry = "No wounds cannot be healed!"

/obj/item/banner/medical/mundane
	inspiration_available = FALSE

/obj/item/banner/medical/check_inspiration(mob/living/carbon/human/H)
	return H.stat //Meditopia is moved to help those in need

/obj/item/banner/medical/special_inspiration(mob/living/carbon/human/H)
	H.adjustToxLoss(-15, FALSE, TRUE)
	H.setOxyLoss(0)
	H.reagents.add_reagent(/datum/reagent/medicine/inaprovaline, 5)

/obj/item/banner/science
	name = "sciencia banner"
	desc = "The banner of Sciencia, bold and daring thaumaturges and researchers that take the path less traveled."
	icon_state = "banner_science"
	inhand_icon_state = "banner_science"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = list(JOB_NAME_SCIENTIST, JOB_NAME_ROBOTICIST, JOB_NAME_RESEARCHDIRECTOR)
	warcry = "For Cuban Pete!"

/obj/item/banner/science/mundane
	inspiration_available = FALSE

/obj/item/banner/science/check_inspiration(mob/living/carbon/human/H)
	return H.on_fire //Sciencia is pleased by dedication to the art of Toxins

/obj/item/banner/cargo
	name = "cargonia banner"
	desc = "The banner of the eternal Cargonia, with the mystical power of conjuring any object into existence."
	icon_state = "banner_cargo"
	inhand_icon_state = "banner_cargo"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = list(JOB_NAME_CARGOTECHNICIAN, JOB_NAME_SHAFTMINER, JOB_NAME_QUARTERMASTER)
	warcry = "Hail Cargonia!"

/obj/item/banner/cargo/mundane
	inspiration_available = FALSE

/obj/item/banner/engineering
	name = "engitopia banner"
	desc = "The banner of Engitopia, wielders of limitless power."
	icon_state = "banner_engineering"
	inhand_icon_state = "banner_engineering"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = list(JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN, JOB_NAME_CHIEFENGINEER)
	warcry = "All hail lord Singuloth!!"

/obj/item/banner/engineering/mundane
	inspiration_available = FALSE

/obj/item/banner/engineering/special_inspiration(mob/living/carbon/human/H)
	qdel(H.GetComponent(/datum/component/irradiated))

/obj/item/banner/command
	name = "command banner"
	desc = "The banner of Command, a staunch and ancient line of bueraucratic kings and queens."
	//No icon state here since the default one is the NT banner
	job_loyalties = list(JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_CHIEFENGINEER, JOB_NAME_HEADOFSECURITY, JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CHIEFMEDICALOFFICER)
	warcry = "Hail Nanotrasen!"

/obj/item/banner/command/mundane
	inspiration_available = FALSE

/obj/item/banner/command/check_inspiration(mob/living/carbon/human/H)
	return HAS_TRAIT(H, TRAIT_MINDSHIELD) //Command is stalwart but rewards their allies.

/obj/item/banner/red
	name = "red banner"
	icon_state = "banner-red"
	inhand_icon_state = "banner-red"
	desc = "A banner with the logo of the red deity."

/obj/item/banner/blue
	name = "blue banner"
	icon_state = "banner-blue"
	inhand_icon_state = "banner-blue"
	desc = "A banner with the logo of the blue deity."

/obj/item/storage/backpack/bannerpack
	name = "nanotrasen banner backpack"
	desc = "It's a backpack with lots of extra room.  A banner with Nanotrasen's logo is attached, that can't be removed."
	icon_state = "bannerpack"

/obj/item/storage/backpack/bannerpack/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 27 //6 more then normal, for the tradeoff of declaring yourself an antag at all times.

/obj/item/storage/backpack/bannerpack/red
	name = "red banner backpack"
	desc = "It's a backpack with lots of extra room.  A red banner is attached, that can't be removed."
	icon_state = "bannerpack-red"

/obj/item/storage/backpack/bannerpack/blue
	name = "blue banner backpack"
	desc = "It's a backpack with lots of extra room.  A blue banner is attached, that can't be removed."
	icon_state = "bannerpack-blue"

//Structure conversion staff
/obj/item/godstaff
	name = "godstaff"
	desc = "It's a stick..?"
	icon_state = "godstaff-red"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	item_flags = ISWEAPON
	var/conversion_color = "#ffffff"
	var/staffcooldown = 0
	var/staffwait = 30


/obj/item/godstaff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(staffcooldown + staffwait > world.time)
		return
	user.visible_message("[user] chants deeply and waves [user.p_their()] staff!")
	if(do_after(user, 20,src))
		target.add_atom_colour(conversion_color, WASHABLE_COLOUR_PRIORITY) //wololo
	staffcooldown = world.time

/obj/item/godstaff/red
	icon_state = "godstaff-red"
	conversion_color = "#ff0000"

/obj/item/godstaff/blue
	icon_state = "godstaff-blue"
	conversion_color = "#0000ff"

/obj/item/clothing/gloves/plate
	name = "Plate Gauntlets"
	icon_state = "crusader"
	desc = "They're like gloves, but made of metal."
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT

/obj/item/clothing/gloves/plate/red
	icon_state = "crusader-red"

/obj/item/clothing/gloves/plate/blue
	icon_state = "crusader-blue"

/obj/item/clothing/shoes/plate
	name = "Plate Boots"
	desc = "Metal boots, they look heavy."
	icon_state = "crusader"
	w_class = WEIGHT_CLASS_NORMAL
	armor_type = /datum/armor/shoes_plate
	clothing_flags = NOSLIP
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT



/datum/armor/shoes_plate
	melee = 50
	bullet = 50
	laser = 50
	energy = 40
	bomb = 60
	fire = 60
	acid = 60
	stamina = 30
	bleed = 60

/obj/item/clothing/shoes/plate/red
	icon_state = "crusader-red"

/obj/item/clothing/shoes/plate/blue
	icon_state = "crusader-blue"


/obj/item/storage/box/itemset/crusader
	name = "Crusader's Armour Set" //i can't into ck2 references
	desc = "This armour is said to be based on the armor of kings on another world thousands of years ago, who tended to assassinate, conspire, and plot against everyone who tried to do the same to them.  Some things never change."


/obj/item/storage/box/itemset/crusader/blue/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/crusader/blue(src)
	new /obj/item/clothing/head/helmet/plate/crusader/blue(src)
	new /obj/item/clothing/gloves/plate/blue(src)
	new /obj/item/clothing/shoes/plate/blue(src)


/obj/item/storage/box/itemset/crusader/red/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/crusader/red(src)
	new /obj/item/clothing/head/helmet/plate/crusader/red(src)
	new /obj/item/clothing/gloves/plate/red(src)
	new /obj/item/clothing/shoes/plate/red(src)


/obj/item/claymore/weak
	desc = "This one is rusted."
	force = 30
	canblock = TRUE

	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	armour_penetration = 15

/obj/item/claymore/weak/ceremonial
	desc = "A rusted claymore, once at the heart of a powerful scottish clan struck down and oppressed by tyrants, it has been passed down the ages as a symbol of defiance."
	force = 15
	block_power = 25
	armour_penetration = 5

/obj/item/katana/weak/curator
	desc = "An ancient Katana. Forged by... Well, it doesn't really say, but surely it's authentic! And sharp to boot!"
	force = 15
	block_power = 25

