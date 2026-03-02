//Glasses
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = GLASSESCOVERSEYES
	slot_flags = ITEM_SLOT_EYES
	strip_delay = 20
	equip_delay_other = 25
	resistance_flags = NONE
	custom_materials = list(/datum/material/glass = 250)
	var/vision_flags = 0
	var/darkness_view = 2//Base human is 2
	var/invis_view = SEE_INVISIBLE_LIVING	//admin only for now
	var/invis_override = 0 //Override to allow glasses to set higher than normal see_invis
	var/lighting_alpha
	var/list/icon/current = list() //the current hud icons
	var/vision_correction = 0 //does wearing these glasses correct some of our vision defects?
	var/glass_colour_type //colors your vision when worn
	var/force_glass_colour = FALSE	//Should the user be forced to see the colour?
	var/emissive_state = null

/obj/item/clothing/glasses/Initialize(mapload)
	. = ..()
	// Glasses with emissive states should not block emissives themselves
	if(emissive_state)
		blocks_emissive = EMISSIVE_BLOCK_NONE
	update_appearance(UPDATE_OVERLAYS)

/obj/item/clothing/glasses/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is stabbing \the [src] into [user.p_their()] eyes! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/clothing/glasses/examine(mob/user)
	. = ..()
	if(glass_colour_type && ishuman(user))
		. += span_notice("Alt-click to toggle [p_their()] colors.")

/obj/item/clothing/glasses/update_overlays()
	. = ..()
	if (emissive_state)
		. += emissive_appearance(icon, emissive_state, layer, 100)
		ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)

/obj/item/clothing/glasses/visor_toggling()
	. = ..()
	alternate_worn_layer = up ? ABOVE_BODY_FRONT_HEAD_LAYER : null
	if(visor_vars_to_toggle & VISOR_VISIONFLAGS)
		vision_flags ^= initial(vision_flags)
	if(visor_vars_to_toggle & VISOR_DARKNESSVIEW)
		darkness_view ^= initial(darkness_view)
	if(visor_vars_to_toggle & VISOR_INVISVIEW)
		invis_view ^= initial(invis_view)

/obj/item/clothing/glasses/adjust_visor(mob/living/user)
	. = ..()
	if(. && !user.is_holding(src) && (visor_vars_to_toggle & (VISOR_VISIONFLAGS|VISOR_INVISVIEW)))
		user.update_sight()

//called when thermal glasses are emped.
/obj/item/clothing/glasses/proc/thermal_overload()
	if(ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		var/obj/item/organ/eyes/eyes = H.get_organ_slot(ORGAN_SLOT_EYES)
		if(!H.is_blind())
			if(H.glasses == src)
				to_chat(H, span_danger("[src] overloads and blinds you!"))
				H.flash_act(visual = 1)
				H.adjust_blindness(3)
				H.set_eye_blur_if_lower(10 SECONDS)
				eyes.apply_organ_damage(5)

/obj/item/clothing/glasses/meson
	name = "optical meson scanner"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting conditions."
	icon_state = "meson"
	inhand_icon_state = "meson"
	emissive_state = "meson_emissive"
	clothing_traits = list(TRAIT_MADNESS_IMMUNE)
	darkness_view = 2
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	glass_colour_type = /datum/client_colour/glass_colour/lightgreen

/obj/item/clothing/glasses/meson/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is putting \the [src] to [user.p_their()] eyes and overloading the brightness! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/clothing/glasses/meson/night
	name = "night vision meson scanner"
	desc = "An optical meson scanner fitted with an amplified visible light spectrum overlay, providing greater visual clarity in darkness."
	icon_state = "nvgmeson"
	inhand_icon_state = "nvgmeson"
	emissive_state = "nvgmeson_emissive"
	darkness_view = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	glass_colour_type = /datum/client_colour/glass_colour/green

/obj/item/clothing/glasses/meson/gar
	name = "gar mesons"
	icon_state = "garm"
	inhand_icon_state = "garm"
	desc = "Do the impossible, see the invisible!"
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb_continuous = list("slices")
	attack_verb_simple = list("slice")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP
	bleed_force = BLEED_SURFACE

/obj/item/clothing/glasses/meson/prescription
	name = "prescription meson scanner"
	desc = "A crude combination between a pair of prescription glasses and the electronics of a meson scanner."
	icon_state = "prescmeson"
	inhand_icon_state = "glasses"
	emissive_state = "prehud_emissive"
	vision_correction = 1

/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "A pair of snazzy goggles used to protect against chemical spills. Fitted with an analyzer for scanning items and reagents."
	icon_state = "purple"
	inhand_icon_state = "glasses"
	emissive_state = "meson_emissive"
	actions_types = list(/datum/action/item_action/toggle_research_scanner)
	glass_colour_type = /datum/client_colour/glass_colour/purple
	resistance_flags = ACID_PROOF
	armor_type = /datum/armor/glasses_science
	clothing_traits = list(TRAIT_REAGENT_SCANNER)


/datum/armor/glasses_science
	fire = 80
	acid = 100

/obj/item/clothing/glasses/science/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_EYES)
		return 1

/obj/item/clothing/glasses/science/prescription
	name = "prescription science goggles"
	desc = "A crude combination between a pair of prescription glasses and the electronics of science goggles."
	icon_state = "prescscihud"
	emissive_state = "prehud_emissive"
	resistance_flags = NONE
	armor_type = /datum/armor/science_prescription
	vision_correction = 1


/datum/armor/science_prescription
	fire = 20
	acid = 40

/obj/item/clothing/glasses/science/sciencesun
	name = "science sunglasses"
	desc = "A pair of sunglasses outfitted with apparatus to scan reagents, as well as providing an innate understanding of liquid viscosity while in motion. Has enhanced shielding which blocks flashes."
	icon_state = "sunhudscience"
	inhand_icon_state = "sunhudscience"
	emissive_state = "sun_emissive"
	flash_protect = FLASH_PROTECTION_FLASH

/obj/item/clothing/glasses/science/sciencesun/degraded
	name = "degraded science sunglasses"
	desc = "A pair of sunglasses outfitted with apparatus to scan reagents, as well as providing an innate understanding of liquid viscosity while in motion."
	flash_protect = FLASH_PROTECTION_NONE

/obj/item/clothing/glasses/science/night
	name = "night vision science goggles"
	desc = "A pair of snazzy goggles to protect against chemical spills, AND your fear of the dark! Fitted with an analyzer for scanning items and reagents."
	icon_state = "purplenight"
	inhand_icon_state = "purplenight"
	emissive_state = "nvgmeson_emissive"
	darkness_view = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/obj/item/clothing/glasses/night
	name = "night vision goggles"
	desc = "You can totally see in the dark now!"
	icon_state = "night"
	inhand_icon_state = "glasses"
	emissive_state = "nvg_emissive"
	darkness_view = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	glass_colour_type = /datum/client_colour/glass_colour/green

/obj/item/clothing/glasses/science/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is tightening \the [src]'s straps around [user.p_their()] neck! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Yarr."
	icon_state = "eyepatch"
	inhand_icon_state = "eyepatch"

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	inhand_icon_state = "headset" // lol
	vision_correction = 1

/obj/item/clothing/glasses/material
	name = "optical material scanner"
	desc = "Very confusing glasses."
	icon_state = "material"
	inhand_icon_state = "glasses"
	vision_flags = SEE_OBJS
	glass_colour_type = /datum/client_colour/glass_colour/lightblue

/obj/item/clothing/glasses/material/mining
	name = "optical material scanner"
	desc = "Used by miners to detect ores deep within the rock."
	icon_state = "material"
	inhand_icon_state = "glasses"
	darkness_view = 0

/obj/item/clothing/glasses/material/mining/gar
	name = "gar material scanner"
	icon_state = "garm"
	inhand_icon_state = "garm"
	desc = "Do the impossible, see the invisible!"
	force = 10
	throwforce = 20
	throw_speed = 4
	attack_verb_continuous = list("slices")
	attack_verb_simple = list("slice")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP
	bleed_force = BLEED_SURFACE
	glass_colour_type = /datum/client_colour/glass_colour/lightgreen

/obj/item/clothing/glasses/regular
	name = "prescription glasses"
	desc = "Made by Nerd. Co."
	icon_state = "glasses"
	inhand_icon_state = "glasses"
	vision_correction = 1 //corrects nearsightedness

/obj/item/clothing/glasses/regular/jamjar
	name = "jamjar glasses"
	desc = "Also known as Virginity Protectors."
	icon_state = "jamjar_glasses"
	inhand_icon_state = "jamjar_glasses"
	vision_correction = 1

/obj/item/clothing/glasses/regular/hipster
	name = "hipster glasses"
	desc = "Made by Uncool. Co."
	icon_state = "hipster_glasses"
	inhand_icon_state = "hipster_glasses"
	vision_correction = 1

/obj/item/clothing/glasses/regular/circle
	name = "circle glasses"
	desc = "Why would you wear something so controversial yet so brave?"
	icon_state = "circle_glasses"
	inhand_icon_state = "circle_glasses"
	vision_correction = 1

/obj/item/clothing/glasses/sunglasses/circle_sunglasses
	name = "circle sunglasses"
	desc = "Shit's pimpin'"
	icon_state = "circle_sunglasses"
	inhand_icon_state = "circle_sunglasses"

//Here lies green glasses, so ugly they died. RIP

/obj/item/clothing/glasses/sunglasses
	name = "sunglasses"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. They do not provide flash protection."
	icon_state = "sun"
	inhand_icon_state = "sunglasses"
	darkness_view = 1
	tint = 1
	glass_colour_type = /datum/client_colour/glass_colour/gray
	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/glasses/sunglasses/advanced
	name = "advanced sunglasses"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Has enhanced shielding which blocks flashes."
	flash_protect = FLASH_PROTECTION_FLASH
	custom_price = 100

/obj/item/clothing/glasses/sunglasses/advanced/reagent
	name = "beer goggles"
	desc = "A pair of sunglasses outfitted with apparatus to scan reagents, as well as providing an innate understanding of liquid viscosity while in motion. Has enhanced shielding which blocks flashes."
	clothing_traits = list(TRAIT_BOOZE_SLIDER, TRAIT_REAGENT_SCANNER)

/obj/item/clothing/glasses/sunglasses/advanced/garb
	name = "black gar glasses"
	desc = "Go beyond impossible and kick reason to the curb!  Has enhanced shielding which blocks flashes."
	icon_state = "garb"
	inhand_icon_state = "garb"
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb_continuous = list("slices")
	attack_verb_simple = list("slice")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP
	bleed_force = BLEED_SURFACE

/obj/item/clothing/glasses/sunglasses/advanced/garb/supergarb
	name = "black giga gar glasses"
	desc = "Believe in us humans.  Has enhanced shielding which blocks flashes."
	icon_state = "supergarb"
	inhand_icon_state = "garb"
	force = 12
	throwforce = 12

/obj/item/clothing/glasses/sunglasses/advanced/gar
	name = "gar glasses"
	desc = "Just who the hell do you think I am?!  Has enhanced shielding which blocks flashes."
	icon_state = "gar"
	inhand_icon_state = "gar"
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb_continuous = list("slices")
	attack_verb_simple = list("slice")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP
	bleed_force = BLEED_SURFACE
	glass_colour_type = /datum/client_colour/glass_colour/orange

/obj/item/clothing/glasses/sunglasses/advanced/gar/supergar
	name = "giga gar glasses"
	desc = "We evolve past the person we were a minute before. Little by little we advance with each turn. That's how a drill works!  Has enhanced shielding which blocks flashes."
	icon_state = "supergar"
	inhand_icon_state = "gar"
	force = 12
	throwforce = 12
	glass_colour_type = /datum/client_colour/glass_colour/red

/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Protects the eyes from welders; approved by the mad scientist association."
	icon_state = "welding-g"
	inhand_icon_state = "welding-g"
	actions_types = list(/datum/action/item_action/toggle)
	custom_materials = list(/datum/material/iron = 250)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	flags_cover = GLASSESCOVERSEYES
	glass_colour_type = /datum/client_colour/glass_colour/gray

/obj/item/clothing/glasses/welding/attack_self(mob/user)
	adjust_visor(user)

/obj/item/clothing/glasses/welding/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][up ? "up" : ""]"

/obj/item/clothing/glasses/welding/up/Initialize(mapload)
	. = ..()
	visor_toggling()

/obj/item/clothing/glasses/welding/ghostbuster
	name = "optical ecto-scanner"
	desc = "A bulky pair of unwieldy glasses that lets you see things best left unseen. Obscures vision, but also has enhanced shielding which blocks flashes."
	icon_state = "bustin-g"
	inhand_icon_state = "bustin-g"
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	glass_colour_type = /datum/client_colour/glass_colour/green
	force_glass_colour = TRUE
	var/next_use_time = 0

/obj/item/clothing/glasses/welding/ghostbuster/Initialize(mapload)
	. = ..()
	//Have the HUD enabled by default, since the glasses start in the down position.
	var/datum/component/team_monitor/worn/ghost_vision = AddComponent(/datum/component/team_monitor/worn, "ghost", 1)
	ghost_vision.toggle_hud(TRUE, null)

/obj/item/clothing/glasses/welding/ghostbuster/adjust_visor(mob/living/user)
	if(next_use_time > world.time)
		return
	. = ..()

/obj/item/clothing/glasses/welding/ghostbuster/visor_toggling()
	..()
	next_use_time = world.time + 1 SECONDS
	//Set to null by default, unless we are inside of a human
	var/mob/living/carbon/C = null
	if(iscarbon(loc))
		C = loc
		//If the user isn't wearing the glasses, don't update things for them.
		if(C.glasses != src)
			C = null
	//Toggle the hud of the component
	//Pass in the wearer, or null if they are not wearing the goggles
	var/datum/component/team_monitor/worn/ghost_vision = GetComponent(/datum/component/team_monitor/worn)
	ghost_vision.toggle_hud(!ghost_vision.hud_visible, C)
	//Update the hud colour
	if(ghost_vision.hud_visible)
		change_glass_color(C, initial(glass_colour_type))
	else
		change_glass_color(C, null)

/obj/item/clothing/glasses/blindfold
	name = "blindfold"
	desc = "Covers the eyes, preventing sight."
	icon_state = "blindfold"
	inhand_icon_state = "blindfold"
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 3
	darkness_view = 1
	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/glasses/blindfold/white
	name = "blind personnel blindfold"
	desc = "Indicates that the wearer suffers from blindness."
	icon_state = "blindfoldwhite"
	inhand_icon_state = "blindfoldwhite"
	var/colored_before = FALSE

/obj/item/clothing/glasses/blindfold/white/visual_equipped(mob/living/carbon/human/user, slot)
	if(ishuman(user) && slot == ITEM_SLOT_EYES)
		update_icon(user=user)
		user.update_worn_glasses() //Color might have been changed by update_icon.
	..()

/obj/item/clothing/glasses/blindfold/white/update_icon(updates=ALL, mob/living/carbon/human/user)
	if(ishuman(user) && !colored_before)
		add_atom_colour(user.eye_color, FIXED_COLOUR_PRIORITY)
		colored_before = TRUE

/obj/item/clothing/glasses/blindfold/white/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, item_layer, atom/origin)
	. = ..()
	if(!isinhands && ishuman(loc) && !colored_before)
		var/mob/living/carbon/human/H = loc
		var/mutable_appearance/M = mutable_appearance('icons/mob/clothing/eyes.dmi', "blindfoldwhite", item_layer)
		M.appearance_flags |= RESET_COLOR
		M.color = H.eye_color
		. += M

/obj/item/clothing/glasses/sunglasses/advanced/big
	icon_state = "bigsunglasses"
	inhand_icon_state = "bigsunglasses"

/obj/item/clothing/glasses/thermal
	name = "optical thermal scanner"
	desc = "Thermals in the shape of glasses."
	icon_state = "thermal"
	inhand_icon_state = "glasses"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	glass_colour_type = /datum/client_colour/glass_colour/red

/obj/item/clothing/glasses/thermal/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	thermal_overload()

/obj/item/clothing/glasses/thermal/xray
	name = "syndicate xray goggles"
	desc = "A pair of xray goggles manufactured by the Syndicate."
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS
	tint = -INFINITY

/obj/item/clothing/glasses/thermal/syndi	//These are now a traitor item, concealed as mesons.	-Pete
	name = "chameleon thermals"
	desc = "A pair of thermal optic goggles with an onboard chameleon generator."
	flash_protect = FLASH_PROTECTION_SENSITIVE

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/glasses/thermal/syndi/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/glasses
	chameleon_action.chameleon_name = "Glasses"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/glasses/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/glasses/thermal/syndi/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/glasses/thermal/monocle
	name = "thermoncle"
	desc = "Never before has seeing through walls felt so gentlepersonly."
	icon_state = "thermoncle"
	flags_1 = null //doesn't protect eyes because it's a monocle, duh

/obj/item/clothing/glasses/thermal/monocle/examine(mob/user) //Different examiners see a different description!
	if(user.gender == MALE)
		desc = replacetext(desc, "person", "man")
	else if(user.gender == FEMALE)
		desc = replacetext(desc, "person", "woman")
	. = ..()
	desc = initial(desc)

/obj/item/clothing/glasses/thermal/eyepatch
	name = "optical thermal eyepatch"
	desc = "An eyepatch with built-in thermal optics."
	icon_state = "eyepatch"
	inhand_icon_state = "eyepatch"

/obj/item/clothing/glasses/cold
	name = "cold goggles"
	desc = "A pair of goggles meant for low temperatures."
	icon_state = "cold"
	inhand_icon_state = "cold"

/obj/item/clothing/glasses/heat
	name = "heat goggles"
	desc = "A pair of goggles meant for high temperatures."
	icon_state = "heat"
	inhand_icon_state = "heat"

/obj/item/clothing/glasses/orange
	name = "orange glasses"
	desc = "A sweet pair of orange shades."
	icon_state = "orangeglasses"
	inhand_icon_state = "orangeglasses"
	glass_colour_type = /datum/client_colour/glass_colour/lightorange

/obj/item/clothing/glasses/red
	name = "red glasses"
	desc = "Hey, you're looking good, senpai!"
	icon_state = "redglasses"
	inhand_icon_state = "redglasses"
	glass_colour_type = /datum/client_colour/glass_colour/red

/obj/item/clothing/glasses/red/wizard
	name = "glasses of truesight"
	desc = "A pair of glasses that allow you to see those that would hide from you"
	vision_flags = SEE_MOBS
	darkness_view = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/glasses/godeye
	name = "eye of god"
	desc = "A strange eye, said to have been torn from an omniscient creature that used to roam the wastes."
	icon_state = "godeye"
	inhand_icon_state = "godeye"
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS
	darkness_view = 8
	clothing_traits = list(TRAIT_BOOZE_SLIDER, TRAIT_REAGENT_SCANNER)
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	custom_price = 10000
	max_demand = 10
	vision_correction = 1  // why should the eye of a god have bad vision?
	//var/datum/action/scan/scan_ability

/obj/item/clothing/glasses/godeye/Initialize(mapload)
	. = ..()
	//scan_ability = new(src)

/obj/item/clothing/glasses/godeye/Destroy()
	//QDEL_NULL(scan_ability)
	return ..()

/obj/item/clothing/glasses/godeye/equipped(mob/living/user, slot)
	. = ..()
	if(ishuman(user) && slot == ITEM_SLOT_EYES)
		ADD_TRAIT(src, TRAIT_NODROP, EYE_OF_GOD_TRAIT)
		pain(user)
		//scan_ability.Grant(user)

/obj/item/clothing/glasses/godeye/dropped(mob/living/user)
	. = ..()
	// Behead someone, their "glasses" drop on the floor
	// and thus, the god eye should no longer be sticky
	REMOVE_TRAIT(src, TRAIT_NODROP, EYE_OF_GOD_TRAIT)
	//scan_ability.Remove(user)

/obj/item/clothing/glasses/godeye/proc/pain(mob/living/victim)
	to_chat(victim, ("<span class='userdanger'>You experience blinding pain, as [src] burrows into your skull.</span>"))
	victim.emote("scream")
	victim.flash_act()

/obj/item/clothing/glasses/godeye/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, src) && W != src && W.loc == user)
		if(W.icon_state == "godeye")
			W.icon_state = "doublegodeye"
			W.inhand_icon_state = "doublegodeye"
			W.desc = "A pair of strange eyes, said to have been torn from an omniscient creature that used to roam the wastes. There's no real reason to have two, but that isn't stopping you."
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.update_worn_mask()
		else
			to_chat(user, span_notice("The eye winks at you and vanishes into the abyss, you feel really unlucky."))
		qdel(src)
	..()
/*
/datum/action/scan Given that the eye did nuffin previously I am leaving this bit of code in in case someone wants to change that
	name = "Scan"
	desc = "Scan an enemy, to get their location and stagger them, increasing their time between attacks."
	background_icon_state = "bg_clock"
	button_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "scan"

	requires_target = TRUE
	cooldown_time = 45 SECONDS
	ranged_mousepointer = 'icons/effects/mouse_pointers/scan_target.dmi'

/datum/action/scan/is_available()
	return ..() && isliving(owner)

/datum/action/scan/on_activate(atom/scanned)
	start_cooldown(15 SECONDS)

	if(owner.stat != CONSCIOUS)
		return FALSE
	if(!isliving(scanned) || scanned == owner)
		owner.balloon_alert(owner, "invalid scanned!")
		return FALSE

	var/mob/living/living_owner = owner
	var/mob/living/living_scanned = scanned
	living_scanned.apply_status_effect(/datum/status_effect/stagger)
	var/datum/status_effect/agent_pinpointer/scan_pinpointer = living_owner.apply_status_effect(/datum/status_effect/agent_pinpointer/scan)
	living_scanned.Jitter(100 SECONDS)
	to_chat(living_scanned, span_warning("You've been staggered!"))
	living_scanned.add_filter("scan", 2, list("type" = "outline", "color" = COLOR_YELLOW, "size" = 1))
	addtimer(CALLBACK(living_scanned, TYPE_PROC_REF(/atom, remove_filter), "scan"), 30 SECONDS)

	owner.playsound_local(get_turf(owner), 'sound/magic/smoke.ogg', 50, TRUE)
	owner.balloon_alert(owner, "[living_scanned] scanned")
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), owner, "scan recharged"), cooldown_time)

	start_cooldown()
	return TRUE
*/
/obj/item/clothing/glasses/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(glass_colour_type && !force_glass_colour && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.client)
			if(H.client.prefs)
				if(src == H.glasses)
					var/current_color = H.client.prefs.read_player_preference(/datum/preference/toggle/glasses_color)
					H.client.prefs.update_preference(/datum/preference/toggle/glasses_color, !current_color)
					if(!current_color)
						to_chat(H, "You will now see glasses colors.")
					else
						to_chat(H, "You will no longer see glasses colors.")
					H.update_glasses_color(src, TRUE)

/obj/item/clothing/glasses/proc/change_glass_color(mob/living/carbon/human/H, datum/client_colour/glass_colour/new_color_type)
	var/old_colour_type = glass_colour_type
	if(!new_color_type || ispath(new_color_type)) //the new glass colour type must be null or a path.
		glass_colour_type = new_color_type
		if(H && H.glasses == src)
			if(old_colour_type)
				H.remove_client_colour(old_colour_type)
			if(glass_colour_type)
				H.update_glasses_color(src, 1)


/mob/living/carbon/human/proc/update_glasses_color(obj/item/clothing/glasses/G, glasses_equipped)
	if(!client)
		return
	if((client.prefs?.read_player_preference(/datum/preference/toggle/glasses_color) || G.force_glass_colour) && glasses_equipped)
		add_client_colour(G.glass_colour_type)
	else
		remove_client_colour(G.glass_colour_type)
