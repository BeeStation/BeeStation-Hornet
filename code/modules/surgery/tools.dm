/obj/item/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	inhand_icon_state = "clamps"
	custom_materials = list(/datum/material/iron=6000, /datum/material/glass=3000)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	w_class = WEIGHT_CLASS_TINY
	tool_behaviour = TOOL_RETRACTOR
	toolspeed = 1


/obj/item/retractor/augment
	name = "retractor"
	desc = "Micro-mechanical manipulator for retracting stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	custom_materials = list(/datum/material/iron=6000, /datum/material/glass=3000)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5


/obj/item/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	inhand_icon_state = "clamps"
	custom_materials = list(/datum/material/iron=5000, /datum/material/glass=2500)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	w_class = WEIGHT_CLASS_TINY
	attack_verb_continuous = list("attacks", "pinches")
	attack_verb_simple = list("attack", "pinch")
	tool_behaviour = TOOL_HEMOSTAT
	toolspeed = 1


/obj/item/hemostat/augment
	name = "hemostat"
	desc = "Tiny servos power a pair of pincers to stop bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	custom_materials = list(/datum/material/iron=5000, /datum/material/glass=2500)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5
	attack_verb_continuous = list("attacks", "pinches")
	attack_verb_simple = list("attack", "pinch")


/obj/item/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	inhand_icon_state = "cautery"
	custom_materials = list(/datum/material/iron=2500, /datum/material/glass=750)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	w_class = WEIGHT_CLASS_TINY
	attack_verb_continuous = list("burns")
	attack_verb_simple = list("burn")
	tool_behaviour = TOOL_CAUTERY
	toolspeed = 1


/obj/item/cautery/augment
	name = "cautery"
	desc = "A heated element that cauterizes wounds."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	custom_materials = list(/datum/material/iron=2500, /datum/material/glass=750)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5
	attack_verb_continuous = list("burns")
	attack_verb_simple = list("burn")

/obj/item/cautery/advanced
	name = "searing tool"
	desc = "It projects a high power laser used for medical applications."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "e_cautery"
	hitsound = 'sound/items/welder.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	toolspeed = 0.7
	light_system = MOVABLE_LIGHT
	light_range = 1
	light_color = COLOR_SOFT_RED

/obj/item/cautery/advanced/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, \
		force_on = force, \
		throwforce_on = throwforce, \
		hitsound_on = hitsound, \
		w_class_on = w_class, \
		clumsy_check = FALSE)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Toggles between drill and cautery and gives feedback to the user.
 */
/obj/item/cautery/advanced/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	tool_behaviour = (active ? TOOL_DRILL : TOOL_CAUTERY)
	balloon_alert(user, "lenses set to [active ? "drill" : "mend"]")
	playsound(user ? user : src, 'sound/weapons/tap.ogg', 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/cautery/advanced/examine()
	. = ..()
	. += "It's set to [tool_behaviour == TOOL_CAUTERY ? "mending" : "drilling"] mode."

/obj/item/blood_filter
	name = "blood filter"
	desc = "For filtering the blood."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bloodfilter"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	custom_materials = list(/datum/material/iron=2000, /datum/material/glass=1500, /datum/material/silver=500)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("pumps", "siphons")
	attack_verb_simple = list("pump", "siphon")
	tool_behaviour = TOOL_BLOODFILTER
	toolspeed = 1

/obj/item/blood_filter/augment
	name = "integrated blood filter"
	desc = "For filtering the blood, now inside your arm."
	toolspeed = 0.5


/obj/item/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	hitsound = 'sound/weapons/circsawhit.ogg'
	custom_materials = list(/datum/material/iron=10000, /datum/material/glass=6000)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	force = 15
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("drills")
	attack_verb_simple = list("drill")
	tool_behaviour = TOOL_DRILL
	toolspeed = 1

/obj/item/surgicaldrill/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] rams [src] into [user.p_their()] chest! It looks like [user.p_theyre()] trying to commit suicide!"))
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living/carbon, gib), null, null, TRUE, TRUE), 25)
	user.SpinAnimation(3, 10)
	playsound(user, 'sound/machines/juicer.ogg', 20, TRUE)
	return MANUAL_SUICIDE

/obj/item/surgicaldrill/augment
	name = "surgical drill"
	desc = "Effectively a small power drill contained within your arm, edges dulled to prevent tissue damage. May or may not pierce the heavens."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	hitsound = 'sound/weapons/circsawhit.ogg'
	custom_materials = list(/datum/material/iron=10000, /datum/material/glass=6000)
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5
	attack_verb_continuous = list("drills")
	attack_verb_simple = list("drill")


/obj/item/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	inhand_icon_state = "scalpel"
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	force = 10
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=4000, /datum/material/glass=1000)
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP
	bleed_force = BLEED_CUT
	tool_behaviour = TOOL_SCALPEL
	toolspeed = 1

/obj/item/scalpel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 80 * toolspeed, 100, 0)

/obj/item/scalpel/augment
	name = "scalpel"
	desc = "Ultra-sharp blade attached directly to your bone for extra-accuracy."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=4000, /datum/material/glass=1000)
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	toolspeed = 0.5
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP
	bleed_force = BLEED_CUT

/obj/item/scalpel/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] [pick("wrists", "throat", "stomach")] with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	hitsound = 'sound/weapons/circsawhit.ogg'
	throwhitsound =  'sound/weapons/pierce.ogg'
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	force = 15
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 9
	throw_speed = 2
	throw_range = 5
	custom_materials = list(/datum/material/iron=10000, /datum/material/glass=6000)
	attack_verb_continuous = list("attacks", "slashes", "saws", "cuts")
	attack_verb_simple = list("attack", "slash", "saw", "cut")
	sharpness = SHARP
	bleed_force = BLEED_DEEP_WOUND
	tool_behaviour = TOOL_SAW
	toolspeed = 1

/obj/item/circular_saw/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 40 * toolspeed, 100, 5, 'sound/weapons/circsawhit.ogg') //saws are very accurate and fast at butchering

/obj/item/circular_saw/augment
	name = "circular saw"
	desc = "A small but very fast spinning saw. Edges dulled to prevent accidental cutting inside of the surgeon."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw"
	hitsound = 'sound/weapons/circsawhit.ogg'
	throwhitsound =  'sound/weapons/pierce.ogg'
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 9
	throw_speed = 2
	throw_range = 5
	custom_materials = list(/datum/material/iron=10000, /datum/material/glass=6000)
	toolspeed = 0.5
	attack_verb_continuous = list("attacks", "slashes", "saws", "cuts")
	attack_verb_simple = list("attack", "slash", "saw", "cut")
	sharpness = SHARP
	bleed_force = BLEED_DEEP_WOUND

/obj/item/hacksaw
	name = "hacksaw"
	desc = "A hacksaw with a metal-cutting blade attached. You could use it as a regular saw in a pinch."
	icon = 'icons/obj/tools.dmi'
	icon_state = "hacksaw"
	hitsound = 'sound/weapons/bladeslice.ogg'
	throwhitsound =  'sound/weapons/pierce.ogg'
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	inhand_icon_state = "wrench"
	flags_1 = CONDUCT_1
	force = 7
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=12000)
	attack_verb_continuous = list("attacks", "slashes", "saws", "cuts")
	attack_verb_simple = list("attack", "slash", "saw", "cut")
	sharpness = SHARP
	tool_behaviour = TOOL_SAW
	toolspeed = 2

/obj/item/hacksaw/Initialize(mapload)
	. = ..() //Much worse than a circular saw for butchering. Slower, less efficient, better chance for bonus items however.
	AddComponent(/datum/component/butchering, 40 * toolspeed, 80, 10, 'sound/items/hacksaw.ogg')

/obj/item/surgical_drapes
	name = "surgical drapes"
	desc = "Nanotrasen brand surgical drapes provide optimal safety and infection control."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical_drapes"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	inhand_icon_state = "drapes"
	w_class = WEIGHT_CLASS_TINY
	attack_verb_continuous = list("slaps")
	attack_verb_simple = list("slap")

/obj/item/surgical_drapes/attack(mob/living/M, mob/user)
	attempt_initiate_surgery(src, M, user)

/obj/item/organ_storage //allows medical cyborgs to manipulate organs without hands
	name = "organ storage bag"
	desc = "A container for holding body parts."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "evidenceobj"

/obj/item/organ_storage/afterattack(obj/item/I, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(contents.len)
		to_chat(user, span_notice("[src] already has something inside it."))
		return
	if(!isorgan(I) && !isbodypart(I))
		to_chat(user, span_notice("[src] can only hold body parts!"))
		return

	user.visible_message("[user] puts [I] into [src].", span_notice("You put [I] inside [src]."))
	icon_state = "evidence"
	var/xx = I.pixel_x
	var/yy = I.pixel_y
	I.pixel_x = 0
	I.pixel_y = 0
	var/image/img = image("icon"=I, "layer"=FLOAT_LAYER)
	img.plane = FLOAT_PLANE
	I.pixel_x = xx
	I.pixel_y = yy
	add_overlay(img)
	add_overlay("evidence")
	desc = "An organ storage container holding [I]."
	I.forceMove(src)
	w_class = I.w_class

/obj/item/organ_storage/attack_self(mob/user)
	if(contents.len)
		var/obj/item/I = contents[1]
		user.visible_message("[user] dumps [I] from [src].", span_notice("You dump [I] from [src]."))
		cut_overlays()
		I.forceMove(get_turf(src))
		icon_state = "evidenceobj"
		desc = "A container for holding body parts."
	else
		to_chat(user, "[src] is empty.")
	return

/obj/item/surgical_processor //allows medical cyborgs to scan and initiate advanced surgeries
	name = "surgical processor"
	desc = "A device for scanning and initiating surgeries from a disk or operating computer."
	icon = 'icons/obj/device.dmi'
	icon_state = "spectrometer"
	item_flags = NOBLUDGEON
	var/list/loaded_surgeries = list()

/obj/item/surgical_processor/equipped(mob/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_HANDS)
		UnregisterSignal(user, COMSIG_SURGERY_STARTING)
		return
	RegisterSignal(user, COMSIG_SURGERY_STARTING, PROC_REF(check_surgery))

/obj/item/surgical_processor/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_SURGERY_STARTING)

/obj/item/surgical_processor/cyborg_unequip(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_SURGERY_STARTING)

/obj/item/surgical_processor/afterattack(atom/design_holder, mob/user, proximity)
	if(!proximity)
		return ..()
	if(!istype(design_holder, /obj/item/disk/surgery) && !istype(design_holder, /obj/machinery/computer/operating))
		return ..()
	balloon_alert(user, "copying designs...")
	playsound(src, 'sound/machines/terminal_processing.ogg', 25, TRUE)
	if(do_after(user, 1 SECONDS, target = design_holder))
		if(istype(design_holder, /obj/item/disk/surgery))
			var/obj/item/disk/surgery/surgery_disk = design_holder
			loaded_surgeries |= surgery_disk.surgeries
		else
			var/obj/machinery/computer/operating/surgery_computer = design_holder
			loaded_surgeries |= surgery_computer.advanced_surgeries
		playsound(src, 'sound/machines/terminal_success.ogg', 25, TRUE)
	return TRUE

/obj/item/surgical_processor/proc/check_surgery(mob/user, datum/surgery/surgery, mob/patient)
	SIGNAL_HANDLER

	if(surgery.replaced_by in loaded_surgeries)
		return COMPONENT_CANCEL_SURGERY
	if(surgery.type in loaded_surgeries)
		return COMPONENT_FORCE_SURGERY

/obj/item/scalpel/advanced
	name = "laser scalpel"
	desc = "An advanced scalpel which uses laser technology to cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "e_scalpel"
	hitsound = 'sound/weapons/blade1.ogg'
	force = 16
	toolspeed = 0.7
	light_system = MOVABLE_LIGHT
	light_range = 1
	light_color = LIGHT_COLOR_GREEN
	sharpness = SHARP
	// It cauterises the wound it causes
	bleed_force = 0

/obj/item/scalpel/advanced/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, \
		force_on = force + 1, \
		throwforce_on = throwforce, \
		throw_speed_on = throw_speed, \
		sharpness_on = sharpness, \
		hitsound_on = hitsound, \
		w_class_on = w_class, \
		clumsy_check = FALSE)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Toggles between saw and scalpel and updates the light / gives feedback to the user.
 */
/obj/item/scalpel/advanced/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(active)
		tool_behaviour = TOOL_SAW
		set_light_range(2)
	else
		tool_behaviour = TOOL_SCALPEL
		set_light_range(1)

	balloon_alert(user, "[active ? "enabled" : "disabled"] bone-cutting mode")
	playsound(user ? user : src, 'sound/machines/click.ogg', 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/scalpel/advanced/examine()
	. = ..()
	. += " It's set to [tool_behaviour == TOOL_SCALPEL ? "scalpel" : "saw"] mode."

/obj/item/retractor/advanced
	name = "mechanical pinches"
	desc = "An agglomerate of rods and gears."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "adv_retractor"
	toolspeed = 0.7

/obj/item/retractor/advanced/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, \
		force_on = force, \
		throwforce_on = throwforce, \
		hitsound_on = hitsound, \
		w_class_on = w_class, \
		clumsy_check = FALSE)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Toggles between retractor and hemostat and gives feedback to the user.
 */
/obj/item/retractor/advanced/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	tool_behaviour = (active ? TOOL_HEMOSTAT : TOOL_RETRACTOR)
	balloon_alert(user, "gears set to [active ? "clamp" : "retract"]")
	playsound(user ? user : src, 'sound/items/change_drill.ogg', 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/retractor/advanced/examine()
	. = ..()
	. += " It resembles a retractor[tool_behaviour == TOOL_RETRACTOR ? "retractor" : "hemostat"]."
