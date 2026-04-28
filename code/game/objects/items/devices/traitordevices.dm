/**
 *	The radioactive microlaser, a device disguised as a health analyzer used to irradiate people.
 *
 *	The strength of the radiation is determined by the 'intensity' setting, while the delay between
 *	the scan and the irradiation kicking in is determined by the wavelength.
 *
 *	Each scan will cause the microlaser to have a brief cooldown period. Higher intensity will increase
 *	the cooldown, while higher wavelength will decrease it.
 *
 *	Wavelength is also slightly increased by the intensity as well.
**/

/obj/item/healthanalyzer/rad_laser
	custom_materials = list(/datum/material/iron = 400)

	/// Whether or not we're set to irradiate mode
	var/irradiate = TRUE
	/// stealthy
	var/stealth = FALSE
	/// How much damage the radiation does
	var/intensity = 10
	/// Time it takes for the radiation to kick in, in seconds
	var/wavelength = 1 SECONDS

	COOLDOWN_DECLARE(cooldown)

/obj/item/healthanalyzer/rad_laser/attack(mob/living/target_mob, mob/living/user, params)
	if(!stealth || !irradiate)
		. = ..()

	if(!ishuman(target_mob) || !irradiate)
		return

	if(!COOLDOWN_FINISHED(src, cooldown))
		user.balloon_alert(user, "on cooldown!")
		return

	var/mob/living/carbon/human/human_target = target_mob

	// Intentionally not checking for TRAIT_RADIMMUNE here so that tatortot can still fuck up and waste their cooldown.
	if(SSradiation.wearing_rad_protected_clothing(human_target))
		to_chat(user, span_warning("[human_target]'s clothing is protecting [human_target.p_them()] from irradiation!"))
		return

	COOLDOWN_START(src, cooldown, get_cooldown())

	if(HAS_TRAIT(human_target, TRAIT_RADIMMUNE)) // lul
		return

	human_target.balloon_alert(user, "successfully irradiated")
	log_combat(user, human_target, "irradiated", src)

	addtimer(CALLBACK(src, PROC_REF(radiation_aftereffect), human_target, intensity), (wavelength + intensity*4)*5)

/obj/item/healthanalyzer/rad_laser/proc/radiation_aftereffect(mob/living/carbon/human/target, passed_intensity)
	if(QDELETED(target) || !ishuman(target) || HAS_TRAIT(target, TRAIT_RADIMMUNE))
		return

	if(passed_intensity >= 5)
		//to save you some math, this is a round(intensity * (4/3)) second long knockout
		target.apply_effect(round(passed_intensity / 0.075), EFFECT_UNCONSCIOUS)

/obj/item/healthanalyzer/rad_laser/proc/get_cooldown()
	return round(max(10, (stealth*30 + intensity*5 - wavelength/4)))

/obj/item/healthanalyzer/rad_laser/attack_self(mob/user)
	ui_interact(user)

/obj/item/healthanalyzer/rad_laser/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/healthanalyzer/rad_laser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RadioactiveMicrolaser")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/item/healthanalyzer/rad_laser/ui_data(mob/user)
	var/list/data = list()
	data["irradiate"] = irradiate
	data["stealth"] = stealth
	data["scanmode"] = scanmode
	data["intensity"] = intensity
	data["wavelength"] = wavelength
	data["on_cooldown"] = !COOLDOWN_FINISHED(src, cooldown)
	data["cooldown"] = COOLDOWN_TIMELEFT(src, cooldown) SECONDS
	return data

/obj/item/healthanalyzer/rad_laser/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("irradiate")
			irradiate = !irradiate
			. = TRUE
		if("stealth")
			stealth = !stealth
			. = TRUE
		if("scanmode")
			scanmode = !scanmode
			. = TRUE
		if("radintensity")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 1
				. = TRUE
			else if(target == "max")
				target = 20
				. = TRUE
			else if(adjust)
				target = intensity + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target = round(target)
				intensity = clamp(target, 1, 20)
		if("radwavelength")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = 120
				. = TRUE
			else if(adjust)
				target = wavelength + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target = round(target)
				wavelength = clamp(target, 0, 120)

/obj/item/shadowcloak
	name = "cloaker belt"
	desc = "Makes you invisible for short periods of time. Recharges in darkness."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	inhand_icon_state = "utility"
	worn_icon_state = "utility"
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("whips", "lashes", "disciplines")
	attack_verb_simple = list("whip", "lash", "discipline")

	var/mob/living/carbon/human/user = null
	var/charge = 300
	var/max_charge = 300
	var/on = FALSE
	var/old_alpha = 0
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/shadowcloak/ui_action_click(mob/user)
	if(user.get_item_by_slot(slot_flags) == src)
		if(!on)
			Activate(usr)
		else
			Deactivate()
	return

/obj/item/shadowcloak/item_action_slot_check(slot, mob/user)
	if(slot == slot_flags)
		return TRUE

/obj/item/shadowcloak/proc/Activate(mob/living/carbon/human/user)
	if(!user)
		return
	to_chat(user, span_notice("You activate [src]."))
	src.user = user
	START_PROCESSING(SSobj, src)
	old_alpha = user.alpha
	on = TRUE

/obj/item/shadowcloak/proc/Deactivate()
	to_chat(user, span_notice("You deactivate [src]."))
	STOP_PROCESSING(SSobj, src)
	if(user)
		user.alpha = old_alpha
	on = FALSE
	user = null

/obj/item/shadowcloak/dropped(mob/user)
	..()
	if(user && user.get_item_by_slot(slot_flags) != src)
		Deactivate()

/obj/item/shadowcloak/process(delta_time)
	if(user.get_item_by_slot(slot_flags) != src)
		Deactivate()
		return
	var/turf/T = get_turf(src)
	if(on)
		var/lumcount = T.get_lumcount()
		if(lumcount > 0.3)
			charge = max(0, charge - 12.5 * delta_time)//Quick decrease in light
		else
			charge = min(max_charge,charge + 25 * delta_time) //Charge in the dark
		animate(user,alpha = clamp(255 - charge,0,255),time = 10)

/obj/item/shadowcloak/magician
	name = "magician's cape"
	desc = "A magician never reveals his secrets."
	icon = 'icons/obj/beds_chairs/beds.dmi'
	lefthand_file = 'icons/mob/inhands/misc/bedsheet_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/bedsheet_righthand.dmi'
	icon_state = "sheetmagician"
	inhand_icon_state = "sheetmagician"
	worn_icon_state = "sheetblack"
	slot_flags = ITEM_SLOT_NECK
	layer = MOB_LAYER
	attack_verb_continuous = null
	attack_verb_simple = null

/obj/item/shadowcloak/magician/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(istype(W, /obj/item/upgradewand))
		var/obj/item/upgradewand/wand = W
		if(!wand.used && max_charge == initial(max_charge))
			wand.used = TRUE
			charge = 450
			max_charge = 450
			to_chat(user, span_notice("You upgrade the [src] with the [wand]."))
			playsound(user, 'sound/weapons/emitter2.ogg', 25, 1, -1)

/obj/item/jammer
	name = "signal jammer"
	desc = "Device used to disrupt nearby wireless communication."
	icon = 'icons/obj/device.dmi'
	icon_state = "jammer"

/obj/item/jammer/Initialize(mapload)
	. = ..()
	//Add the radio jamming component
	AddComponent(/datum/component/radio_jamming)

/obj/item/jammer/attack_self(mob/user)
	SEND_SIGNAL(src, COMSIG_TOGGLE_JAMMER, user, FALSE)

///Checks if an atom is jammed by a radio jammer
///Parameters:
/// - Protection level: The amount of protection that the atom has. See jamming_defines.dm
/atom/proc/is_jammed(protection_level)
	var/turf/position = get_turf(src)
	for(var/datum/component/radio_jamming/jammer as anything in GLOB.active_jammers)
		//Check to see if the jammer is strong enough to block this signal
		if (protection_level > jammer.intensity)
			continue
		var/turf/jammer_turf = get_turf(jammer.parent)
		if(position?.get_virtual_z_level() == jammer_turf.get_virtual_z_level() && (get_dist(position, jammer_turf) <= jammer.range))
			return TRUE
	return FALSE
