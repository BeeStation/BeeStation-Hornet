/mob/living/carbon/human
	name = "Unknown"
	real_name = "Unknown"
	icon = 'icons/mob/human.dmi'
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE|LONG_GLIDE
	COOLDOWN_DECLARE(special_emote_cooldown)
	COOLDOWN_DECLARE(block_cooldown)

/mob/living/carbon/human/Initialize(mapload)
	add_verb(/mob/living/proc/mob_sleep)
	add_verb(/mob/living/proc/toggle_resting)

	icon_state = "" //Remove the inherent human icon that is visible on the map editor. We're rendering ourselves limb by limb, having it still be there results in a bug where the basic human icon appears below as south in all directions and generally looks nasty.

	//initialize limbs first
	create_bodyparts()

	// This needs to be called very very early in human init (before organs / species are created at the minimum)
	setup_organless_effects()

	setup_human_dna()


	prepare_huds() //Prevents a nasty runtime on human init

	if(dna.species)
		set_species(dna.species.type) //This generates new limbs based on the species, beware.

	//initialise organs
	create_internal_organs() //most of it is done in set_species now, this is only for parent call
	physiology = new()

	. = ..()

	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_FACE_ACT, PROC_REF(clean_face))
	AddComponent(/datum/component/personal_crafting)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_HUMAN, 1, -6)
	AddComponent(/datum/component/bloodysoles/feet)
	AddElement(/datum/element/ridable, /datum/component/riding/creature/human)
	AddElement(/datum/element/strippable, GLOB.strippable_human_items, TYPE_PROC_REF(/mob/living/carbon/human, should_strip), GLOB.strippable_human_layout)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/mechanical_repair)
	if(!CONFIG_GET(flag/disable_human_mood))
		AddComponent(/datum/component/mood)

	GLOB.human_list += src

/// This proc is for holding effects applied when a mob is missing certain organs
/// It is called very, very early in human init because all humans innately spawn with no organs and gain them during init
/// Gaining said organs removes these effects
/mob/living/carbon/human/proc/setup_organless_effects()
	// All start without eyes, and get them via set species
	//become_blind(NO_EYES)
	// Mobs cannot taste anything without a tongue; the tongue organ removes this on Insert
	ADD_TRAIT(src, TRAIT_AGEUSIA, NO_TONGUE_TRAIT)

/mob/living/carbon/human/proc/setup_human_dna()
	//initialize dna. for spawned humans; overwritten by other code
	create_dna(src)
	randomize_human(src)
	dna.initialize_dna()

/mob/living/carbon/human/Destroy()
	QDEL_NULL(physiology)
	GLOB.suit_sensors_list -= src
	GLOB.human_list -= src
	return ..()

/mob/living/carbon/human/prepare_data_huds()
	//Update med hud images...
	..()
	//...sec hud images...
	sec_hud_set_ID()
	sec_hud_set_implants()
	sec_hud_set_security_status()
	//...and display them.
	add_to_all_human_data_huds()

/mob/living/carbon/human/get_stat_tab_status()
	var/list/tab_data = ..()
	var/obj/item/tank/target_tank = internal || external
	if(target_tank)
		var/datum/gas_mixture/target_tank_air = target_tank.return_air()
		tab_data["Internal Atmosphere Info"] = GENERATE_STAT_TEXT("[target_tank.name]")
		tab_data["Tank Pressure"] = GENERATE_STAT_TEXT("[target_tank_air.return_pressure()]")
		tab_data["Distribution Pressure"] = GENERATE_STAT_TEXT("[target_tank.distribute_pressure]")
	if(istype(wear_suit, /obj/item/clothing/suit/space))
		var/obj/item/clothing/suit/space/S = wear_suit
		tab_data["Thermal Regulator"] = GENERATE_STAT_TEXT("[S.thermal_on ? "on" : "off"]")
		tab_data["Cell Charge"] = GENERATE_STAT_TEXT("[S.cell ? "[round(S.cell.percent(), 0.1)]%" : "!invalid!"]")

	if(mind)
		var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			tab_data["Chemical Storage"] = GENERATE_STAT_TEXT("[changeling.chem_charges]/[changeling.total_chem_storage]")
			tab_data["Absorbed DNA"] = GENERATE_STAT_TEXT("[changeling.absorbed_count]")
	return tab_data

// called when something steps onto a human
/mob/living/carbon/human/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	var/obj/vehicle/sealed/car/C = AM
	if(istype(C))
		INVOKE_ASYNC(C, TYPE_PROC_REF(/obj/vehicle/sealed/car, RunOver), src)
	spreadFire(AM)

/mob/living/carbon/human/reset_perspective(atom/new_eye, force_reset = FALSE)
	if(dna?.species?.prevent_perspective_change && !force_reset) // This is in case a species needs to prevent perspective changes in certain cases
		update_fullscreen()
		return
	return ..()

/mob/living/carbon/human/Topic(href, href_list)
	if(href_list["see_id"])
		var/mob/viewer = usr
		var/can_see_still = (viewer in viewers(src))

		var/obj/item/card/id/id = wear_id?.GetID()
		if(!istype(id))
			id = get_active_held_item()
		if(!istype(id))
			id = get_inactive_held_item()

		var/same_id = istype(id) && (href_list["id_ref"] == REF(id) || href_list["id_name"] == id.registered_name)
		if(!same_id && can_see_still)
			to_chat(viewer, span_notice("[p_They()] [p_are()] no longer wearing that ID card."))
			return

		var/viable_time = can_see_still ? 3 MINUTES : 1 MINUTES // assuming 3min is the length of a hop line visit - give some leeway if they're still in sight
		if(!same_id || (text2num(href_list["examine_time"]) + viable_time) < world.time)
			to_chat(viewer, span_notice("You don't have that good of a memory. Examine [p_them()] again."))
			return
		if(HAS_TRAIT(src, TRAIT_UNKNOWN))
			to_chat(viewer, span_notice("You can't make out that ID anymore."))
			return
		if(!isobserver(viewer) && get_dist(viewer, src) > ID_EXAMINE_DISTANCE + 1) // leeway, ignored if the viewer is a ghost
			to_chat(viewer, span_notice("You can't make out that ID from here."))
			return

		var/id_name = id.registered_name
		var/id_age = id.registered_age
		var/id_job = id.assignment
		// Should probably be recorded on the ID, but this is easier (albiet more restrictive) on chameleon ID users
		var/datum/record/crew/record = find_record(id_name, GLOB.manifest.general)
		var/id_blood_type = record?.blood_type
		var/id_gender = record?.gender
		var/id_species = record?.species
		var/id_icon = jointext(id.get_id_examine_strings(viewer), "")
		// Fill in some blanks for chameleon IDs to maintain the illusion of a real ID
		if(istype(id, /obj/item/card/id/syndicate))
			id_gender ||= gender
			id_species ||= dna.species.name
			id_blood_type ||= dna.blood_type?.name

		var/id_examine = span_slightly_larger(separator_hr("This is <em>[id.get_examine_name(viewer)]</em>."))
		id_examine += "<div class='img_by_text_container'>"
		id_examine += "[id_icon]"
		id_examine += "<div class='img_text'>"
		id_examine += jointext(list(
			"&bull; Name: [id_name || "Unknown"]",
			"&bull; Job: [id_job || "Unassigned"]",
			"&bull; Age: [id_age || "Unknown"]",
			"&bull; Gender: [id_gender || "Unknown"]",
			"&bull; Blood Type: [id_blood_type || "?"]",
			"&bull; Species: [id_species || "Unknown"]",
		), "<br>")
		id_examine += "</div>" // container
		id_examine += "</div>" // text

		to_chat(viewer, examine_block(span_info(id_examine)))

	if(href_list["embedded_object"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		var/obj/item/bodypart/L = locate(href_list["embedded_limb"]) in bodyparts
		if(!L)
			return
		var/obj/item/I = locate(href_list["embedded_object"]) in L.embedded_objects
		if(!I || I.loc != src) //no item, no limb, or item is not in limb or in the person anymore
			return
		SEND_SIGNAL(src, COMSIG_CARBON_EMBED_RIP, I, L)
		return

	if(href_list["item"]) //canUseTopic check for this is handled by mob/Topic()
		var/slot = text2num(href_list["item"])
		if(check_obscured_slots(TRUE) & slot)
			to_chat(usr, span_warning("You can't reach that! Something is covering it."))
			return

///////HUDs///////
	if(href_list["hud"])
		if(!ishuman(usr) && !isobserver(usr))
			return
		var/mob/human_or_ghost_user = usr
		var/mob/living/carbon/human/human_user = usr
		var/perpname = get_face_name(get_id_name(""))
		if(!HAS_TRAIT(human_or_ghost_user, TRAIT_SECURITY_HUD) && !HAS_TRAIT(human_or_ghost_user, TRAIT_MEDICAL_HUD))
			return
		if((text2num(href_list["examine_time"]) + 1 MINUTES) < world.time)
			to_chat(human_or_ghost_user, span_notice("It's too late to use this now!"))
			return
		var/datum/record/crew/target_record = find_record(perpname, GLOB.manifest.general)
		if(href_list["photo_front"] || href_list["photo_side"])
			if(!target_record)
				return
			if(ishuman(human_or_ghost_user))
				if(!human_user.canUseHUD())
					return
			if(!HAS_TRAIT(human_or_ghost_user, TRAIT_SECURITY_HUD) && !HAS_TRAIT(human_or_ghost_user, TRAIT_MEDICAL_HUD))
				return
			var/obj/item/photo/photo_from_record = null
			if(photo_from_record)
				photo_from_record.show(human_or_ghost_user)
			return

		if(ishuman(human_user) && href_list["hud"] == "m")
			if(!HAS_TRAIT(human_user, TRAIT_MEDICAL_HUD))
				return
			if(href_list["evaluation"])
				if(!getBruteLoss() && !getFireLoss() && !getOxyLoss() && getToxLoss() < 20)
					to_chat(human_user, "[span_notice("No external injuries detected.")]<br>")
					return
				var/span = "notice"
				var/status = ""
				if(getBruteLoss())
					to_chat(human_user, "<b>Physical trauma analysis:</b>")
					for(var/obj/item/bodypart/BP as() in bodyparts)
						var/brutedamage = BP.brute_dam
						if(brutedamage > 0)
							status = "received minor physical injuries."
							span = "notice"
						if(brutedamage > 20)
							status = "been seriously damaged."
							span = "danger"
						if(brutedamage > 40)
							status = "sustained major trauma!"
							span = "userdanger"
						if(brutedamage)
							to_chat(human_user, "<span class='[span]'>[BP] appears to have [status]</span>")
				if(getFireLoss())
					to_chat(human_user, "<b>Analysis of skin burns:</b>")
					for(var/obj/item/bodypart/BP as() in bodyparts)
						var/burndamage = BP.burn_dam
						if(burndamage > 0)
							status = "signs of minor burns."
							span = "notice"
						if(burndamage > 20)
							status = "serious burns."
							span = "danger"
						if(burndamage > 40)
							status = "major burns!"
							span = "userdanger"
						if(burndamage)
							to_chat(human_user, "<span class='[span]'>[BP] appears to have [status]</span>")
				if(getOxyLoss())
					to_chat(human_user, span_danger("Patient has signs of suffocation, emergency treatment may be required!"))
				if(getToxLoss() > 20)
					to_chat(human_user, span_danger("Gathered data is inconsistent with the analysis, possible cause: poisoning."))
			if(href_list["physical_status"])
				var/physical_status = tgui_input_list(human_user, "Specify a new physical status for this person.", "Medical HUD", PHYSICAL_STATUSES(), target_record.physical_status)
				if(!physical_status || !target_record || !human_user.canUseHUD() || !HAS_TRAIT(human_user, TRAIT_MEDICAL_HUD))
					return

				target_record.physical_status = physical_status
				return

			if(href_list["mental_status"])
				var/mental_status = tgui_input_list(human_user, "Specify a new mental status for this person.", "Medical HUD", MENTAL_STATUSES(), target_record.mental_status)
				if(!mental_status || !target_record || !human_user.canUseHUD() || !HAS_TRAIT(human_user, TRAIT_MEDICAL_HUD))
					return

				target_record.mental_status = mental_status
				return
			return //Medical HUD ends here.

		if(href_list["hud"] == "s")
			var/allowed_access = null
			if(!HAS_TRAIT(human_or_ghost_user, TRAIT_SECURITY_HUD))
				return
			if(ishuman(human_or_ghost_user))
				if(human_user.stat || human_user == src) //|| !human_user.canmove || human_user.restrained()) Fluff: Sechuds have eye-tracking technology and sets 'arrest' to people that the wearer looks and blinks at.
					return   //Non-fluff: This allows sec to set people to arrest as they get disarmed or beaten
				// Checks the user has security clearence before allowing them to change arrest status via hud, comment out to enable all access
				var/obj/item/clothing/glasses/hud/security/user_glasses = human_user.glasses
				if(istype(user_glasses) && (user_glasses.obj_flags & EMAGGED))
					allowed_access = "@%&ERROR_%$*"
				else //Implant and standard glasses check access
					if(human_user.wear_id)
						var/list/access = human_user.wear_id.GetAccess()
						if(ACCESS_SEC_RECORDS in access)
							allowed_access = human_user.get_authentification_name()

				if(!allowed_access)
					to_chat(human_user, span_warning("ERROR: Invalid access."))
					return
			if(!perpname)
				to_chat(human_user, span_warning("ERROR: Can not identify target."))
				return
			target_record = find_record(perpname, GLOB.manifest.general)
			if(!target_record)
				to_chat(human_user, span_warning("ERROR: Unable to locate data core entry for target."))
				return
			if(ishuman(human_or_ghost_user) && href_list["status"])
				var/new_status = tgui_input_list(human_user, "Specify a new criminal status for this person.", "Security HUD", WANTED_STATUSES(), target_record.wanted_status)
				if(!new_status || !target_record || !human_user.canUseHUD() || !HAS_TRAIT(human_user, TRAIT_SECURITY_HUD))
					return

				if(new_status == WANTED_ARREST)
					var/datum/crime_record/new_crime = new(author = human_user, details = "Set by SecHUD.")
					target_record.crimes += new_crime
					investigate_log("SecHUD auto-crime | Added to [target_record.name] by [key_name(human_user)]", INVESTIGATE_RECORDS)

				investigate_log("has been set from [target_record.wanted_status] to [new_status] via HUD by [key_name(human_user)].", INVESTIGATE_RECORDS)
				target_record.set_wanted_status(human_user, new_status)
				update_matching_security_huds(target_record.name)
				return

			if(href_list["view"])
				if(ishuman(human_or_ghost_user))
					if(!human_user.canUseHUD())
						return
				if(!HAS_TRAIT(human_user, TRAIT_SECURITY_HUD))
					return
				var/sec_record_message = ""
				sec_record_message += "<b>Name:</b> [target_record.name]"
				sec_record_message += "\n<b>Criminal Status:</b> [target_record.wanted_status]"
				sec_record_message += "\n<b>Citations:</b> [length(target_record.citations)]"
				sec_record_message += "\n<b>Note:</b> [target_record.security_note || "None"]"
				sec_record_message += "\n<b>Rapsheet:</b> [length(target_record.crimes)] incidents"
				if(length(target_record.crimes))
					for(var/datum/crime_record/crime in target_record.crimes)
						if(!crime.valid)
							sec_record_message += span_notice("\n-- REDACTED --")
							continue

						sec_record_message += "\n<b>Crime:</b> [crime.name]"
						sec_record_message += "\n<b>Details:</b> [crime.details]"
						sec_record_message += "\nAdded by [crime.author] at [crime.time]"
						to_chat(human_user, "\n----------")
				to_chat(human_user, sec_record_message)
				return
			if(ishuman(human_or_ghost_user))
				if(href_list["add_citation"])
					var/max_fine = CONFIG_GET(number/maxfine)
					var/citation_name = sanitize_ic(tgui_input_text(human_user, "Citation crime", "Security HUD", max_length = MAX_MESSAGE_LEN))
					var/fine = tgui_input_number(human_user, "Citation fine", "Security HUD", 50, max_fine, 5)
					if(!fine || !target_record || !citation_name || !allowed_access || !isnum(fine) || fine > max_fine || fine <= 0 || !human_user.canUseHUD() || !HAS_TRAIT(human_user, TRAIT_SECURITY_HUD))
						return
					target_record.add_crime(usr, citation_name, fine, null, src)
					return

				if(href_list["add_crime"])
					var/crime_name = sanitize_ic(tgui_input_text(human_user, "Crime name", "Security HUD", max_length = MAX_MESSAGE_LEN))
					if(!target_record || !crime_name || !allowed_access || !human_user.canUseHUD() || !HAS_TRAIT(human_user, TRAIT_SECURITY_HUD))
						return
					target_record.add_crime(human_user, crime_name, 0, null, src)
					to_chat(human_user, span_notice("Successfully added a crime."))
					return

				if(href_list["add_note"])
					var/new_note = sanitize_ic(tgui_input_text(human_user, "Security note", "Security Records", max_length = MAX_MESSAGE_LEN, multiline = TRUE))
					if(!target_record || !new_note || !allowed_access || !human_user.canUseHUD() || !HAS_TRAIT(human_user, TRAIT_SECURITY_HUD))
						return

					target_record.security_note = new_note

					return
	..() //end of this massive fucking chain. TODO: make the hud chain not spooky.


/mob/living/carbon/human/proc/canUseHUD()
	return (mobility_flags & MOBILITY_USE)

/mob/living/carbon/human/can_inject(mob/user, target_zone, injection_flags)
	. = TRUE // Default to returning true.
	if(user && !target_zone)
		target_zone = user.get_combat_bodyzone(zone_context = BODYZONE_CONTEXT_INJECTION)
	var/obj/item/bodypart/the_part = get_bodypart(target_zone) || get_bodypart(BODY_ZONE_CHEST)
	// we may choose to ignore species trait pierce immunity in case we still want to check skellies for thick clothing without insta failing them (wounds)
	if(injection_flags & INJECT_CHECK_IGNORE_SPECIES)
		if(HAS_TRAIT_NOT_FROM(src, TRAIT_PIERCEIMMUNE, SPECIES_TRAIT))
			if (user && (injection_flags & INJECT_TRY_SHOW_ERROR_MESSAGE))
				to_chat(user, span_alert("The skin on [p_their()] [the_part.name] is too thick!"))
			return FALSE
	else if(HAS_TRAIT(src, TRAIT_PIERCEIMMUNE))
		if (user && (injection_flags & INJECT_TRY_SHOW_ERROR_MESSAGE))
			to_chat(user, span_alert("The skin on [p_their()] [the_part.name] is too thick!"))
		return FALSE
	// Loop through the clothing covering this bodypart and see if there's any thiccmaterials
	var/require_thickness = (injection_flags & INJECT_CHECK_PENETRATE_THICK)
	for(var/obj/item/clothing/iter_clothing in get_clothing_on_part(the_part))
		// If it has armour, it has enough thickness to block basic things
		if(!require_thickness && (iter_clothing.get_armor().get_rating(MELEE) >= 20 || iter_clothing.get_armor().get_rating(BULLET) >= 20))
			if (user && (injection_flags & INJECT_TRY_SHOW_ERROR_MESSAGE))
				to_chat(user, span_alert("The clothing on [p_their()] [the_part.name] is too thick!"))
			return FALSE
		// If it is ultra thick, then block piercing syringes
		if(iter_clothing.clothing_flags & THICKMATERIAL)
			if (user && (injection_flags & INJECT_TRY_SHOW_ERROR_MESSAGE))
				to_chat(user, span_alert("The clothing on [p_their()] [the_part.name] is too thick!"))
			return FALSE

/mob/living/carbon/human/try_inject(mob/user, target_zone, injection_flags)
	. = ..()
	if(!. && (injection_flags & INJECT_TRY_SHOW_ERROR_MESSAGE) && user)
		var/obj/item/bodypart/the_part = get_bodypart(target_zone) || get_bodypart(BODY_ZONE_CHEST)

		to_chat(user, "<span class='alert'>There is no exposed flesh or thin material on [p_their()] [the_part.name].</span>")

/mob/living/carbon/human/assess_threat(judgment_criteria, lasercolor = "", datum/callback/weaponcheck=null)
	if(judgment_criteria & JUDGE_EMAGGED)
		return 10 //Everyone is a criminal!

	var/threatcount = 0

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if(istype(wear_suit, /obj/item/clothing/suit/redtag))
				threatcount += 4
			if(is_holding_item_of_type(/obj/item/gun/energy/laser/redtag))
				threatcount += 4
			if(istype(belt, /obj/item/gun/energy/laser/redtag))
				threatcount += 2

		if(lasercolor == "r")
			if(istype(wear_suit, /obj/item/clothing/suit/bluetag))
				threatcount += 4
			if(is_holding_item_of_type(/obj/item/gun/energy/laser/bluetag))
				threatcount += 4
			if(istype(belt, /obj/item/gun/energy/laser/bluetag))
				threatcount += 2

		return threatcount

	//Check for ID
	var/obj/item/card/id/idcard = get_idcard(FALSE)
	if( (judgment_criteria & JUDGE_IDCHECK) && !idcard && name=="Unknown")
		threatcount += 4

	//Check for weapons
	if( (judgment_criteria & JUDGE_WEAPONCHECK) && weaponcheck)
		if(!idcard || !(ACCESS_WEAPONS in idcard.access))
			for(var/obj/item/I in held_items) //if they're holding a gun
				if(weaponcheck.Invoke(I))
					threatcount += 4
			if(weaponcheck.Invoke(belt) || weaponcheck.Invoke(back)) //if a weapon is present in the belt or back slot
				threatcount += 2 //not enough to trigger look_for_perp() on it's own unless they also have criminal status.

	//Check for arrest warrant
	if(judgment_criteria & JUDGE_RECORDCHECK)
		var/perpname = get_face_name(get_id_name())
		var/datum/record/crew/target = find_record(perpname, GLOB.manifest.general)
		if(target)
			switch(target.wanted_status)
				if(WANTED_ARREST)
					threatcount += 5
				if(WANTED_PRISONER)
					threatcount += 2
				if(WANTED_PAROLE)
					threatcount += 2
				if(WANTED_SUSPECT)
					threatcount += 2

	//Check for dresscode violations
	if(istype(head, /obj/item/clothing/head/wizard))
		threatcount += 2

	//Check for nonhuman scum
	if(dna && dna.species.id && dna.species.id != SPECIES_HUMAN)
		threatcount += 1

	//mindshield implants imply trustworthyness
	if(has_mindshield_hud_icon())
		threatcount -= 1

	//Agent cards lower threatlevel.
	if(istype(idcard, /obj/item/card/id/syndicate))
		threatcount -= 5

	//individuals wearing tinfoil hats are 30% more likely to be criminals
	if(istype(get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
		threatcount += 2
	return threatcount


//Used for new human mobs created by cloning/goleming/podding
/mob/living/carbon/human/proc/set_cloned_appearance()
	if(dna.features["body_model"] == MALE)
		facial_hair_style = "Full Beard"
	else
		facial_hair_style = "Shaved"
	hair_style = pick("Bedhead", "Bedhead 2", "Bedhead 3")
	underwear = "Nude"
	socks = "Nude"
	update_body()
	update_hair()

/mob/living/carbon/human/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	. = ..()
	if(current_size >= STAGE_THREE)
		for(var/obj/item/hand in held_items)
			if(prob(current_size * 5) && hand.w_class >= ((11-current_size)/2) && dropItemToGround(hand))
				step_towards(hand, src)
				to_chat(src, span_warning("\The [singularity] pulls \the [hand] from your grip!"))

#define CPR_PANIC_SPEED (0.8 SECONDS)

/// Performs CPR on the target after a delay.
/mob/living/carbon/human/proc/do_cpr(mob/living/carbon/target)
	if(target == src)
		return

	var/panicking = FALSE

	do
		CHECK_DNA_AND_SPECIES(target)

		if (DOING_INTERACTION_WITH_TARGET(src,target))
			return FALSE

		if (target.stat == DEAD || HAS_TRAIT(target, TRAIT_FAKEDEATH))
			to_chat(src, span_warning("[target.name] is dead!"))
			return FALSE

		if (is_mouth_covered())
			to_chat(src, span_warning("Remove your mask first!"))
			return FALSE

		if (target.is_mouth_covered())
			to_chat(src, span_warning("Remove [p_their()] mask first!"))
			return FALSE

		if (!get_organ_slot(ORGAN_SLOT_LUNGS))
			to_chat(src, span_warning("You have no lungs to breathe with, so you cannot perform CPR!"))
			return FALSE

		if (HAS_TRAIT(src, TRAIT_NOBREATH))
			to_chat(src, span_warning("You do not breathe, so you cannot perform CPR!"))
			return FALSE

		visible_message(span_notice("[src] is trying to perform CPR on [target.name]!"), \
						span_notice("You try to perform CPR on [target.name]... Hold still!"))

		if (!do_after(src, delay = panicking ? CPR_PANIC_SPEED : (3 SECONDS), target = target))
			to_chat(src, span_warning("You fail to perform CPR on [target]!"))
			return FALSE

		if (target.health > target.crit_threshold)
			return FALSE

		visible_message(span_notice("[src] performs CPR on [target.name]!"), span_notice("You perform CPR on [target.name]."))
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "perform_cpr", /datum/mood_event/perform_cpr)
		log_combat(src, target, "CPRed")

		if (HAS_TRAIT(target, TRAIT_NOBREATH))
			to_chat(target, span_unconscious("You feel a breath of fresh air... which is a sensation you don't recognise..."))
		else if (!target.get_organ_slot(ORGAN_SLOT_LUNGS))
			to_chat(target, span_unconscious("You feel a breath of fresh air... but you don't feel any better..."))
		else
			target.adjustOxyLoss(-min(target.getOxyLoss(), 7))
			to_chat(target, span_unconscious("You feel a breath of fresh air enter your lungs... It feels good..."))

		if (target.health <= target.crit_threshold)
			if (!panicking)
				to_chat(src, span_warning("[target] still isn't up! You try harder!"))
			panicking = TRUE
		else
			panicking = FALSE
	while (panicking)

#undef CPR_PANIC_SPEED

/mob/living/carbon/human/cuff_resist(obj/item/I)
	if(HAS_TRAIT(src, TRAIT_FAST_CUFF_REMOVAL))
		if(dna && dna.check_mutation(/datum/mutation/hulk))
			say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ), forced = "hulk")
		if(..(I, cuff_break = FAST_CUFFBREAK))
			dropItemToGround(I)
	else
		if(..())
			dropItemToGround(I)

/**
  * Wash the hands, cleaning either the gloves if equipped and not obscured, otherwise the hands themselves if they're not obscured.
  *
  * Returns false if we couldn't wash our hands due to them being obscured, otherwise true
  */
/mob/living/carbon/human/proc/wash_hands(clean_types)
	var/list/obscured = check_obscured_slots()
	if(ITEM_SLOT_GLOVES in obscured)
		return FALSE

	if(gloves)
		if(gloves.wash(clean_types))
			update_worn_gloves()
	else if((clean_types & CLEAN_TYPE_BLOOD) && blood_in_hands > 0)
		blood_in_hands = 0
		update_worn_gloves()

	return TRUE

/**
  * Cleans the lips of any lipstick. Returns TRUE if the lips had any lipstick and was thus cleaned
  */
/mob/living/carbon/human/proc/clean_lips()
	if(isnull(lip_style) && lip_color == initial(lip_color))
		return FALSE
	lip_style = null
	lip_color = initial(lip_color)
	update_body()
	return TRUE

/**
  * Called on the COMSIG_COMPONENT_CLEAN_FACE_ACT signal
  */
/mob/living/carbon/human/proc/clean_face(datum/source, clean_types)
	if(!is_mouth_covered() && clean_lips())
		. = TRUE

	if(glasses && is_eyes_covered(FALSE, TRUE, TRUE) && glasses.wash(clean_types))
		update_worn_glasses()
		. = TRUE

	var/list/obscured = check_obscured_slots()
	if(wear_mask && !(ITEM_SLOT_MASK in obscured) && wear_mask.wash(clean_types))
		update_worn_mask()
		. = TRUE

/**
  * Called when this human should be washed
  */
/mob/living/carbon/human/wash(clean_types)
	. = ..()

	// Wash equipped stuff that cannot be covered
	if(wear_suit?.wash(clean_types))
		update_worn_oversuit()
		. = TRUE

	if(belt?.wash(clean_types))
		update_worn_belt()
		. = TRUE

	// Check and wash stuff that can be covered
	var/list/obscured = check_obscured_slots()

	if(w_uniform && !(ITEM_SLOT_ICLOTHING in obscured) && w_uniform.wash(clean_types))
		update_worn_undersuit()
		. = TRUE

	if(!is_mouth_covered() && clean_lips())
		. = TRUE

	// Wash hands if exposed
	if(!gloves && (clean_types & CLEAN_TYPE_BLOOD) && blood_in_hands > 0 && !(ITEM_SLOT_GLOVES in obscured))
		blood_in_hands = 0
		update_worn_gloves()
		. = TRUE

//Turns a mob black, flashes a skeleton overlay
//Just like a cartoon!
/mob/living/carbon/human/proc/electrocution_animation(anim_duration)
	var/mutable_appearance/zap_appearance

	// If we have a species, we need to handle mutant parts and stuff
	if(dna?.species)
		add_atom_colour(COLOR_BLACK, TEMPORARY_COLOUR_PRIORITY)
		var/static/mutable_appearance/shock_animation_dna
		if(!shock_animation_dna)
			shock_animation_dna = mutable_appearance(icon, "electrocuted_base")
			shock_animation_dna.appearance_flags |= RESET_COLOR|KEEP_APART
		zap_appearance = shock_animation_dna

	// Otherwise do a generic animation
	else
		var/static/mutable_appearance/shock_animation_generic
		if(!shock_animation_generic)
			shock_animation_generic = mutable_appearance(icon, "electrocuted_generic")
			shock_animation_generic.appearance_flags |= RESET_COLOR|KEEP_APART
		zap_appearance = shock_animation_generic

	add_overlay(zap_appearance)
	addtimer(CALLBACK(src, PROC_REF(end_electrocution_animation), zap_appearance), anim_duration)

/mob/living/carbon/human/proc/end_electrocution_animation(mutable_appearance/MA)
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_BLACK)
	cut_overlay(MA)

/mob/living/carbon/human/can_interact_with(atom/A, treat_mob_as_adjacent)
	return ..() || (dna.check_mutation(/datum/mutation/telekinesis) && tkMaxRangeCheck(src, A))

/mob/living/carbon/human/resist_restraints()
	if(wear_suit && wear_suit.breakouttime)
		changeNext_move(CLICK_CD_BREAKOUT)
		last_special = world.time + CLICK_CD_BREAKOUT
		cuff_resist(wear_suit)
	else
		..()

/mob/living/carbon/human/clear_cuffs(obj/item/I, cuff_break)
	. = ..()
	if(.)
		return
	if(!I.loc || buckled)
		return FALSE
	if(I == wear_suit)
		visible_message(span_danger("[src] manages to [cuff_break ? "break" : "remove"] [I]!"))
		to_chat(src, span_notice("You successfully [cuff_break ? "break" : "remove"] [I]."))
		return TRUE

/mob/living/carbon/human/replace_records_name(oldname, newname) // Only humans have records right now, move this up if changed.
	var/datum/record/crew/crew_record = find_record(oldname, GLOB.manifest.general)
	var/datum/record/locked/locked_record = find_record(oldname, GLOB.manifest.locked)

	if(crew_record)
		crew_record.name = newname
	if(locked_record)
		locked_record.name = newname

/mob/living/carbon/human/get_total_tint()
	. = ..()
	if(glasses)
		. += glasses.tint

/mob/living/carbon/human/update_health_hud()
	if(!client || !hud_used)
		return

	// Updates the health bar, also sends signal
	. = ..()

	// Updates the health doll
	if(!hud_used.healthdoll)
		return

	hud_used.healthdoll.cut_overlays()
	if(stat == DEAD)
		hud_used.healthdoll.icon_state = "healthdoll_DEAD"
		return

	hud_used.healthdoll.icon_state = "healthdoll_OVERLAY"
	for(var/obj/item/bodypart/body_part as anything in bodyparts)
		var/icon_num = 0

		if(SEND_SIGNAL(body_part, COMSIG_BODYPART_UPDATING_HEALTH_HUD, src) & COMPONENT_OVERRIDE_BODYPART_HEALTH_HUD)
			continue

		var/is_hallucinating = !!src.has_status_effect(/datum/status_effect/hallucination)
		var/damage = body_part.burn_dam + body_part.brute_dam + (is_hallucinating ? body_part.stamina_dam : 0)
		var/comparison = (body_part.max_damage/5)
		if(damage)
			icon_num = 1
		if(damage > (comparison))
			icon_num = 2
		if(damage > (comparison*2))
			icon_num = 3
		if(damage > (comparison*3))
			icon_num = 4
		if(damage > (comparison*4))
			icon_num = 5
		if(has_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy))
			icon_num = 0
		if(icon_num)
			hud_used.healthdoll.add_overlay(mutable_appearance('icons/hud/screen_gen.dmi', "[body_part.body_zone][icon_num]"))
		//Stamina Outline (Communicate that we have stamina damage)
		//Hallucinations will appear as regular damage
		if(body_part.stamina_dam && !is_hallucinating)
			var/mutable_appearance/MA = mutable_appearance('icons/hud/screen_gen.dmi', "[body_part.body_zone]stam")
			MA.alpha = (body_part.stamina_dam / body_part.max_stamina_damage) * 70 + 30
			hud_used.healthdoll.add_overlay(MA)
	for(var/t in get_missing_limbs()) //Missing limbs
		hud_used.healthdoll.add_overlay(mutable_appearance('icons/hud/screen_gen.dmi', "[t]6"))
	for(var/t in get_disabled_limbs()) //Disabled limbs
		hud_used.healthdoll.add_overlay(mutable_appearance('icons/hud/screen_gen.dmi', "[t]7"))

/mob/living/carbon/human/fully_heal(heal_flags = HEAL_ALL)
	if(heal_flags & HEAL_NEGATIVE_MUTATIONS)
		for(var/datum/mutation/human/existing_mutation in dna.mutations)
			if(existing_mutation.quality != POSITIVE)
				dna.remove_mutation(existing_mutation.name)

	if(heal_flags & HEAL_TEMP)
		coretemperature = get_body_temp_normal(apply_change = FALSE)
		heat_exposure_stacks = 0

	return ..()

/mob/living/carbon/human/is_literate()
	return TRUE

/mob/living/carbon/human/vomit(lost_nutrition = 10, blood = FALSE, stun = TRUE, distance = 1, message = TRUE, toxic = 0)
	if(blood && HAS_TRAIT(src, TRAIT_NOBLOOD))
		if(message)
			visible_message(span_warning("[src] dry heaves!"), \
							span_userdanger("You try to throw up, but there's nothing in your stomach!"))
		if(stun)
			Paralyze(200)
		return 1
	..()

/mob/living/carbon/human/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_COPY_OUTFIT, "Copy Outfit")
	VV_DROPDOWN_OPTION(VV_HK_MOD_QUIRKS, "Add/Remove Quirks")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_MONKEY, "Make Monkey")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_CYBORG, "Make Cyborg")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_SLIME, "Make Slime")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_ALIEN, "Make Alien")
	VV_DROPDOWN_OPTION(VV_HK_SET_SPECIES, "Set Species")
	VV_DROPDOWN_OPTION(VV_HK_PURRBATION, "Toggle Purrbation")
	VV_DROPDOWN_OPTION(VV_HK_RANDOM_NAME, "Randomize Name")

/mob/living/carbon/human/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_COPY_OUTFIT])
		if(!check_rights(R_SPAWN))
			return
		copy_outfit()
	if(href_list[VV_HK_MOD_QUIRKS])
		if(!check_rights(R_SPAWN))
			return
		if(!mind)
			return

		var/list/options = list("Clear"="Clear")
		for(var/x in subtypesof(/datum/quirk))
			var/datum/quirk/T = x
			var/qname = initial(T.name)
			options[has_quirk(T) ? "[qname] (Remove)" : "[qname] (Add)"] = T

		var/result = input(usr, "Choose quirk to add/remove","Quirk Mod") as null|anything in options
		if(result)
			if(result == "Clear")
				for(var/datum/quirk/q in mind.quirks)
					mind.remove_quirk(q.type)
			else
				var/T = options[result]
				if(has_quirk(T))
					mind.remove_quirk(T)
				else
					mind.add_quirk(T,TRUE)
	if(href_list[VV_HK_MAKE_MONKEY])
		if(!check_rights(R_SPAWN))
			return
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		usr.client.holder.Topic("vv_override", list("monkeyone"=href_list[VV_HK_TARGET]))
	if(href_list[VV_HK_MAKE_CYBORG])
		if(!check_rights(R_SPAWN))
			return
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		usr.client.holder.Topic("vv_override", list("makerobot"=href_list[VV_HK_TARGET]))
	if(href_list[VV_HK_MAKE_ALIEN])
		if(!check_rights(R_SPAWN))
			return
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		usr.client.holder.Topic("vv_override", list("makealien"=href_list[VV_HK_TARGET]))
	if(href_list[VV_HK_MAKE_SLIME])
		if(!check_rights(R_SPAWN))
			return
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		usr.client.holder.Topic("vv_override", list("makeslime"=href_list[VV_HK_TARGET]))
	if(href_list[VV_HK_SET_SPECIES])
		if(!check_rights(R_SPAWN))
			return
		var/list/species_list = GLOB.species_list
		var/result = tgui_input_list(usr, "Please choose a new species", "Species", sort_list(species_list))
		if(isnull(result))
			return
		var/newtype = GLOB.species_list[result]
		if(isnull(newtype))
			return
		admin_ticket_log("[key_name_admin(usr)] has modified the bodyparts of [src] to [result]")
		set_species(newtype)
	if(href_list[VV_HK_PURRBATION])
		if(!check_rights(R_SPAWN))
			return
		if(!ishumanbasic(src))
			to_chat(usr, "This can only be done to the basic human species at the moment.")
			return
		var/success = purrbation_toggle(src)
		if(success)
			to_chat(usr, "Put [src] on purrbation.")
			log_admin("[key_name(usr)] has put [key_name(src)] on purrbation.")
			var/msg = span_notice("[key_name_admin(usr)] has put [key_name(src)] on purrbation.")
			message_admins(msg)
			admin_ticket_log(src, msg)

		else
			to_chat(usr, "Removed [src] from purrbation.")
			log_admin("[key_name(usr)] has removed [key_name(src)] from purrbation.")
			var/msg = span_notice("[key_name_admin(usr)] has removed [key_name(src)] from purrbation.")
			message_admins(msg)
			admin_ticket_log(src, msg)
	if(href_list[VV_HK_RANDOM_NAME])
		if(!check_rights(R_ADMIN))//mods can rename people with VV so they should be able to do this too
			return
		if(isnull(dna.species))
			to_chat(usr, "The species of [src] is null, aborting.")
		var/old_name = real_name
		fully_replace_character_name(real_name, generate_random_mob_name())
		log_admin("[key_name(usr)] has randomly generated a new name for [key_name(src)], replacing their old name of [old_name].")
		message_admins(span_notice("[key_name_admin(usr)] has randomly generated a new name for [key_name(src)], replacing their old name of [old_name]."))

/mob/living/carbon/human/MouseDrop(mob/over)
	. = ..()
	if(ishuman(over))
		var/mob/living/carbon/human/T = over  // curbstomp, ported from PP with modifications
		if(!src.is_busy && (src.is_zone_selected(BODY_ZONE_HEAD) || src.is_zone_selected(BODY_ZONE_PRECISE_GROIN)) && get_turf(src) == get_turf(T) && (T.body_position == LYING_DOWN) && src.combat_mode && !HAS_TRAIT(src, TRAIT_PACIFISM)) //all the stars align, time to curbstomp
			src.is_busy = TRUE

			if (!do_after(src, 2.5 SECONDS, T) || get_turf(src) != get_turf(T) || (T.body_position == STANDING_UP) || !src.combat_mode|| src == T) //wait 30ds and make sure the stars still align (Body zone check removed after PR #958)
				src.is_busy = FALSE
				return

			T.Stun(6)

			if(src.is_zone_selected(BODY_ZONE_HEAD)) //curbstomp specific code

				var/increment = (T.lying_angle/90)-2
				setDir(increment > 0 ? WEST : EAST)
				for(var/i in 1 to 5)
					src.pixel_y += 8-i
					src.pixel_x -= increment
					sleep(0.2)
				for(var/i in 1 to 5)
					src.pixel_y -= 8-i
					src.pixel_x -= increment
					sleep(0.2)

				playsound(src, 'sound/effects/hit_kick.ogg', 80, 1, -1)
				playsound(src, 'sound/weapons/punch2.ogg', 80, 1, -1)

				var/obj/item/bodypart/BP = T.get_bodypart(BODY_ZONE_HEAD)
				if(BP)
					BP.receive_damage(36) //so 3 toolbox hits

				T.visible_message(span_warning("[src] curbstomps [T]!"), span_warning("[src] curbstomps you!"))

				log_combat(src, T, "curbstomped", "curbstomp")

			// Will be legs only on simplified mode since groin is legs
			else if(src.is_zone_selected(BODY_ZONE_PRECISE_GROIN)) //groinkick specific code

				var/increment = (T.lying_angle/90)-2
				setDir(increment > 0 ? WEST : EAST)
				for(var/i in 1 to 5)
					src.pixel_y += 2-i
					src.pixel_x -= increment
					sleep(0.2)
				for(var/i in 1 to 5)
					src.pixel_y -= 2-i
					src.pixel_x -= increment
					sleep(0.2)

				playsound(src, 'sound/effects/hit_kick.ogg', 80, 1, -1)
				playsound(src, 'sound/effects/hit_punch.ogg', 80, 1, -1)

				var/obj/item/bodypart/BP = T.get_bodypart(BODY_ZONE_CHEST)
				if(BP)
					if(T.gender == MALE)
						BP.receive_damage(25)
					else
						BP.receive_damage(15)

				T.visible_message(span_warning("[src] kicks [T] in the groin!"), "<span class='warning'>[src] kicks you in the groin!</span")

				log_combat(src, T, "groinkicked", "groinkick")

			var/increment = (T.lying_angle/90)-2
			for(var/i in 1 to 10)
				src.pixel_x = src.pixel_x + increment
				sleep(0.1)

			src.pixel_x = 0
			src.pixel_y = 0 //position reset

			src.is_busy = FALSE

/mob/living/carbon/human/limb_attack_self()
	var/obj/item/bodypart/arm = hand_bodyparts[active_hand_index]
	if(arm)
		arm.attack_self(src)
	return ..()

/mob/living/carbon/human/mouse_buckle_handling(mob/living/target, mob/living/user)
	if(pulling != target || grab_state < GRAB_AGGRESSIVE || stat != CONSCIOUS)
		return FALSE

	//If they dragged themselves and we're currently aggressively grabbing them try to piggyback
	if(user == target && can_piggyback(target))
		piggyback(target)
		return TRUE

	//If you dragged them to you and you're aggressively grabbing try to fireman carry them
	else if(can_be_firemanned(target))
		fireman_carry(target)
		return TRUE

//src is the user that will be carrying, target is the mob to be carried
/mob/living/carbon/human/proc/can_piggyback(mob/living/carbon/target)
	return (istype(target) && target.stat == CONSCIOUS && target.body_position == STANDING_UP)

/mob/living/carbon/human/proc/can_be_firemanned(mob/living/carbon/target)
	return ((ishuman(target) || ismonkey(target)) && target.body_position == LYING_DOWN)

/mob/living/carbon/human/proc/fireman_carry(mob/living/carbon/target)
	if(!can_be_firemanned(target) || INCAPACITATED_IGNORING(src, INCAPABLE_GRAB))
		to_chat(src, span_notice("You can't fireman carry [target] while they're standing!"))
		return

	var/carrydelay = 5 SECONDS //if you have latex you are faster at grabbing
	var/skills_space = "" //cobby told me to do this
	if(HAS_TRAIT(src, TRAIT_QUICKER_CARRY))
		carrydelay = 3 SECONDS
		skills_space = " expertly"
	else if(HAS_TRAIT(src, TRAIT_QUICK_CARRY))
		carrydelay = 4 SECONDS
		skills_space = " quickly"

	visible_message(span_notice("[src] starts[skills_space] lifting [target] onto their back.."),
	//Joe Medic starts quickly/expertly lifting Grey Tider onto their back..
	span_notice("[HAS_TRAIT(src, TRAIT_QUICKER_CARRY) ? "Using your gloves' nanochips, you" : "You"][skills_space] start to lift [target] onto your back[HAS_TRAIT(src, TRAIT_QUICK_CARRY) ? ", while assisted by the nanochips in your gloves..." : "..."]"))
	//(Using your gloves' nanochips, you/You) ( /quickly/expertly) start to lift Grey Tider onto your back(, while assisted by the nanochips in your gloves../...)
	if(!do_after(src, carrydelay, target))
		visible_message(span_warning("[src] fails to fireman carry [target]!"))
		return

	//Second check to make sure they're still valid to be carried
	if(!can_be_firemanned(target) || INCAPACITATED_IGNORING(src, INCAPABLE_GRAB) || target.buckled)
		target.visible_message(span_warning("[target] can't hang on to [src]!"))
		return

	return buckle_mob(target, TRUE, TRUE, CARRIER_NEEDS_ARM)

/mob/living/carbon/human/proc/piggyback(mob/living/carbon/target)
	if(!can_piggyback(target))
		to_chat(target, span_warning("You can't piggyback ride [src] right now!"))
		return

	visible_message(span_notice("[target] starts to climb onto [src]..."))
	if(!do_after(target, 1.5 SECONDS, target = src) || !can_piggyback(target))
		visible_message(span_warning("[target] fails to climb onto [src]!"))
		return

	if(INCAPACITATED_IGNORING(target, INCAPABLE_GRAB) || INCAPACITATED_IGNORING(src, INCAPABLE_GRAB))
		target.visible_message(span_warning("[target] can't hang onto [src]!"))
		return

	return buckle_mob(target, TRUE, TRUE, RIDER_NEEDS_ARMS)


/mob/living/carbon/human/buckle_mob(mob/living/target, force = FALSE, check_loc = TRUE, buckle_mob_flags= NONE)
	if(!is_type_in_typecache(target, can_ride_typecache))
		target.visible_message(span_warning("[target] really can't seem to mount [src]."))
		return

	if(!force)//humans are only meant to be ridden through piggybacking and special cases
		return

	return ..()

/mob/living/carbon/human/updatehealth()
	. = ..()
	dna?.species.spec_updatehealth(src)
	if(HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying)
		return
	var/health_deficiency = max((maxHealth - health), staminaloss)
	if(health_deficiency >= 40)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown, TRUE, multiplicative_slowdown = health_deficiency / 75)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying, TRUE, multiplicative_slowdown = health_deficiency / 25)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying)


/mob/living/carbon/human/adjust_nutrition(change) //Honestly FUCK the oldcoders for putting nutrition on /mob someone else can move it up because holy hell I'd have to fix SO many typechecks
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_POWERHUNGRY))
		var/obj/item/organ/stomach/battery/battery = get_organ_slot(ORGAN_SLOT_STOMACH)
		if(istype(battery))
			battery.adjust_charge_scaled(change)
		return FALSE
	return ..()

/mob/living/carbon/human/set_nutrition(change) //Seriously fuck you oldcoders.
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_POWERHUNGRY))
		var/obj/item/organ/stomach/battery/battery = get_organ_slot(ORGAN_SLOT_STOMACH)
		if(istype(battery))
			battery.set_charge_scaled(change)
		return FALSE
	return ..()

/mob/living/carbon/human/proc/stub_toe(power)
	if(HAS_TRAIT(src, TRAIT_LIGHT_STEP))
		power *= 0.5
		src.emote("gasp")
	else
		src.emote("scream")
	src.apply_damage(power, BRUTE, def_zone = pick(BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT))
	src.Paralyze(10 * power)

/mob/living/carbon/human/get_exp_list(minutes)
	. = ..()

	if(mind.assigned_role in SSjob.name_occupations)
		.[mind.assigned_role] = minutes

/mob/living/carbon/human/monkeybrain
	ai_controller = /datum/ai_controller/monkey

/mob/living/carbon/human/species
	var/race = null

CREATION_TEST_IGNORE_SUBTYPES(/mob/living/carbon/human/species)

/mob/living/carbon/human/species/Initialize(mapload, specific_race)
	. = ..()
	set_species(race || specific_race)

/mob/living/carbon/human/species/abductor
	race = /datum/species/abductor

/mob/living/carbon/human/species/android
	race = /datum/species/android

/mob/living/carbon/human/species/apid
	race = /datum/species/apid

/mob/living/carbon/human/species/ethereal
	race = /datum/species/ethereal

/mob/living/carbon/human/species/felinid
	race = /datum/species/human/felinid

/mob/living/carbon/human/species/fly
	race = /datum/species/fly

/mob/living/carbon/human/species/golem
	race = /datum/species/golem

/mob/living/carbon/human/species/golem/adamantine
	race = /datum/species/golem/adamantine

/mob/living/carbon/human/species/golem/plasma
	race = /datum/species/golem/plasma

/mob/living/carbon/human/species/golem/diamond
	race = /datum/species/golem/diamond

/mob/living/carbon/human/species/golem/gold
	race = /datum/species/golem/gold

/mob/living/carbon/human/species/golem/silver
	race = /datum/species/golem/silver

/mob/living/carbon/human/species/golem/plasteel
	race = /datum/species/golem/plasteel

/mob/living/carbon/human/species/golem/titanium
	race = /datum/species/golem/titanium

/mob/living/carbon/human/species/golem/plastitanium
	race = /datum/species/golem/plastitanium

/mob/living/carbon/human/species/golem/alien_alloy
	race = /datum/species/golem/alloy

/mob/living/carbon/human/species/golem/wood
	race = /datum/species/golem/wood

/mob/living/carbon/human/species/golem/uranium
	race = /datum/species/golem/uranium

/mob/living/carbon/human/species/golem/sand
	race = /datum/species/golem/sand

/mob/living/carbon/human/species/golem/glass
	race = /datum/species/golem/glass

/mob/living/carbon/human/species/golem/bluespace
	race = /datum/species/golem/bluespace

/mob/living/carbon/human/species/golem/bananium
	race = /datum/species/golem/bananium

/mob/living/carbon/human/species/golem/blood_cult
	race = /datum/species/golem/runic

/mob/living/carbon/human/species/golem/cloth
	race = /datum/species/golem/cloth

/mob/living/carbon/human/species/golem/plastic
	race = /datum/species/golem/plastic

/mob/living/carbon/human/species/golem/bronze
	race = /datum/species/golem/bronze

/mob/living/carbon/human/species/golem/cardboard
	race = /datum/species/golem/cardboard

/mob/living/carbon/human/species/golem/leather
	race = /datum/species/golem/leather

/mob/living/carbon/human/species/golem/bone
	race = /datum/species/golem/bone

/mob/living/carbon/human/species/golem/durathread
	race = /datum/species/golem/durathread

/mob/living/carbon/human/species/golem/snow
	race = /datum/species/golem/snow

/mob/living/carbon/human/species/golem/clockwork
	race = /datum/species/golem/clockwork

/mob/living/carbon/human/species/golem/clockwork/no_scrap
	race = /datum/species/golem/clockwork/no_scrap

/mob/living/carbon/human/species/ipc
	race = /datum/species/ipc

/mob/living/carbon/human/species/oozeling
	race = /datum/species/oozeling

/mob/living/carbon/human/species/oozeling/slime
	race = /datum/species/oozeling/slime

/mob/living/carbon/human/species/oozeling/stargazer
	race = /datum/species/oozeling/stargazer

/mob/living/carbon/human/species/oozeling/luminescent
	race = /datum/species/oozeling/luminescent

/mob/living/carbon/human/species/lizard
	race = /datum/species/lizard

/mob/living/carbon/human/species/lizard/ashwalker
	race = /datum/species/lizard/ashwalker

/mob/living/carbon/human/species/moth
	race = /datum/species/moth


/mob/living/carbon/human/species/plasma
	race = /datum/species/plasmaman

/mob/living/carbon/human/species/diona
	race = /datum/species/diona

/mob/living/carbon/human/species/shadow
	race = /datum/species/shadow

/mob/living/carbon/human/species/shadow/nightmare
	race = /datum/species/shadow/nightmare

/mob/living/carbon/human/species/shadow/blessed
	race = /datum/species/shadow/blessed

/mob/living/carbon/human/species/skeleton
	race = /datum/species/skeleton

/mob/living/carbon/human/species/zombie
	race = /datum/species/zombie

/mob/living/carbon/human/species/zombie/infectious
	race = /datum/species/zombie/infectious

/mob/living/carbon/human/species/zombie/krokodil_addict
	race = /datum/species/human/krokodil_addict

/mob/living/carbon/human/species/pumpkin_man
	race = /datum/species/pumpkin_man

/mob/living/carbon/human/species/psyphoza
	race = /datum/species/psyphoza
