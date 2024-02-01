/mob/living/carbon/human
	name = "Unknown"
	real_name = "Unknown"
	icon = 'icons/mob/human.dmi'
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE
	COOLDOWN_DECLARE(special_emote_cooldown)

/mob/living/carbon/human/Initialize(mapload)
	add_verb(/mob/living/proc/mob_sleep)
	add_verb(/mob/living/proc/lay_down)

	icon_state = ""		//Remove the inherent human icon that is visible on the map editor. We're rendering ourselves limb by limb, having it still be there results in a bug where the basic human icon appears below as south in all directions and generally looks nasty.

	//initialize limbs first
	create_bodyparts()

	setup_human_dna()


	prepare_huds() //Prevents a nasty runtime on human init

	if(dna.species)
		set_species(dna.species.type) //This generates new limbs based on the species, beware.

	//initialise organs
	create_internal_organs() //most of it is done in set_species now, this is only for parent call
	physiology = new()

	. = ..()

	AddComponent(/datum/component/personal_crafting)
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_FACE_ACT, PROC_REF(clean_face))
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/strippable, GLOB.strippable_human_items, TYPE_PROC_REF(/mob/living/carbon/human, should_strip), GLOB.strippable_human_layout)
	AddElement(/datum/element/mechanical_repair)

/mob/living/carbon/human/proc/setup_human_dna()
	//initialize dna. for spawned humans; overwritten by other code
	create_dna(src)
	randomize_human(src)
	dna.initialize_dna()

/mob/living/carbon/human/ComponentInitialize()
	. = ..()
	if(!CONFIG_GET(flag/disable_human_mood))
		AddComponent(/datum/component/mood)

/mob/living/carbon/human/Destroy()
	QDEL_NULL(physiology)
	QDEL_LIST(bioware)
	GLOB.suit_sensors_list -= src
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

/mob/living/carbon/human/get_stat_tabs()
	var/list/tabs = ..()
	if(istype(wear_suit, /obj/item/clothing/suit/space/space_ninja))
		tabs.Insert(1, "SpiderOS")
	return tabs

//Ninja Code
/mob/living/carbon/human/get_stat(selected_tab)
	if(selected_tab == "SpiderOS")
		var/list/tab_data = list()
		var/obj/item/clothing/suit/space/space_ninja/SN = wear_suit
		if(!SN)
			return
		tab_data["SpiderOS Status"] = GENERATE_STAT_TEXT("[SN.s_initialized ? "Initialized" : "Disabled"]")
		tab_data["Current Time"] = GENERATE_STAT_TEXT("[station_time_timestamp()]")
		tab_data["divider_spideros"] = GENERATE_STAT_DIVIDER
		if(SN.s_initialized)
			//Suit gear
			tab_data["Energy Charge"] = GENERATE_STAT_TEXT("[round(SN.cell.charge/100)]%")
			tab_data["Smoke Bombs"] = GENERATE_STAT_TEXT("[SN.s_bombs]")
			//Ninja status
			tab_data["Fingerprints"] = GENERATE_STAT_TEXT("[rustg_hash_string(RUSTG_HASH_MD5, dna.uni_identity)]")
			tab_data["Unique Identity"] = GENERATE_STAT_TEXT("[dna.unique_enzymes]")
			tab_data["Overall Status"] = GENERATE_STAT_TEXT("[stat > 1 ? "dead" : "[health]% healthy"]")
			tab_data["Nutrition Status"] = GENERATE_STAT_TEXT("[nutrition]")
			tab_data["Oxygen Loss"] = GENERATE_STAT_TEXT("[getOxyLoss()]")
			tab_data["Toxin Levels"] = GENERATE_STAT_TEXT("[getToxLoss()]")
			tab_data["Burn Severity"] = GENERATE_STAT_TEXT("[getFireLoss()]")
			tab_data["Brute Trauma"] = GENERATE_STAT_TEXT("[getBruteLoss()]")
			tab_data["Radiation Levels"] = GENERATE_STAT_TEXT("[radiation] rad")
			tab_data["Body Temperature"] = GENERATE_STAT_TEXT("[bodytemperature-T0C] degrees C ([bodytemperature*1.8-459.67] degrees F)")

			//Diseases
			if(diseases.len)
				tab_data["DivSpiderOs2"] = GENERATE_STAT_DIVIDER
				tab_data["Viruses"] = GENERATE_STAT_TEXT("")
				for(var/thing in diseases)
					var/datum/disease/D = thing
					tab_data["* [D.name]"] = GENERATE_STAT_TEXT("Type: [D.spread_text], Stage: [D.stage]/[D.max_stages], Possible Cure: [D.cure_text]")
		return tab_data
	return ..()

/mob/living/carbon/human/get_stat_tab_status()
	var/list/tab_data = ..()
	var/obj/item/tank/target_tank = internal || external
	if(target_tank)
		tab_data["Internal Atmosphere Info"] = GENERATE_STAT_TEXT("[target_tank.name]")
		tab_data["Tank Pressure"] = GENERATE_STAT_TEXT("[target_tank.air_contents.return_pressure()]")
		tab_data["Distribution Pressure"] = GENERATE_STAT_TEXT("[target_tank.distribute_pressure]")

	if(mind)
		var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			tab_data["Chemical Storage"] = GENERATE_STAT_TEXT("[changeling.chem_charges]/[changeling.chem_storage]")
			tab_data["Absorbed DNA"] = GENERATE_STAT_TEXT("[changeling.absorbedcount]")
	return tab_data

// called when something steps onto a human
/mob/living/carbon/human/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	var/obj/vehicle/sealed/car/C = AM
	if(istype(C))
		INVOKE_ASYNC(C, TYPE_PROC_REF(/obj/vehicle/sealed/car, RunOver), src)
	spreadFire(AM)

/mob/living/carbon/human/Topic(href, href_list)
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
			to_chat(usr, "<span class='warning'>You can't reach that! Something is covering it.</span>")
			return

///////HUDs///////
	if(href_list["hud"])
		if(!ishuman(usr))
			return
		var/mob/living/carbon/human/human_user = usr
		var/perpname = get_face_name(get_id_name(""))
		if(!HAS_TRAIT(human_user, TRAIT_SECURITY_HUD) && !HAS_TRAIT(human_user, TRAIT_MEDICAL_HUD))
			return
		if((text2num(href_list["examine_time"]) + 1 MINUTES) < world.time)
			to_chat(human_user, "<span class='notice'>It's too late to use this now!</span>")
			return
		var/datum/data/record/target_record = find_record("name", perpname, GLOB.data_core.general)
		if(href_list["photo_front"] || href_list["photo_side"])
			if(!target_record)
				return
			if(!human_user.canUseHUD())
				return
			if(!HAS_TRAIT(human_user, TRAIT_SECURITY_HUD) && !HAS_TRAIT(human_user, TRAIT_MEDICAL_HUD))
				return
			var/obj/item/photo/photo_from_record = null
			if(href_list["photo_front"])
				photo_from_record = target_record.fields["photo_front"]
			else if(href_list["photo_side"])
				photo_from_record = target_record.fields["photo_side"]
			if(photo_from_record)
				photo_from_record.show(human_user)
			return

		if(href_list["hud"] == "m")
			if(!HAS_TRAIT(human_user, TRAIT_MEDICAL_HUD))
				return
			if(href_list["evaluation"])
				if(!getBruteLoss() && !getFireLoss() && !getOxyLoss() && getToxLoss() < 20)
					to_chat(human_user, "<span class='notice'>No external injuries detected.</span><br>")
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
					to_chat(human_user, "<span class='danger'>Patient has signs of suffocation, emergency treatment may be required!</span>")
				if(getToxLoss() > 20)
					to_chat(human_user, "<span class='danger'>Gathered data is inconsistent with the analysis, possible cause: poisoning.</span>")
			if(!human_user.wear_id) //You require access from here on out.
				to_chat(human_user, "<span class='warning'>ERROR: Invalid access</span>")
				return
			var/list/access = human_user.wear_id.GetAccess()
			if(!(ACCESS_MEDICAL in access))
				to_chat(human_user, "<span class='warning'>ERROR: Invalid access</span>")
				return
			if(href_list["p_stat"])
				var/health_status = input(human_user, "Specify a new physical status for this person.", "Medical HUD", target_record.fields["p_stat"]) in list("Active", "Physically Unfit", "*Unconscious*", "*Deceased*", "Cancel")
				if(!target_record)
					return
				if(!human_user.canUseHUD())
					return
				if(!HAS_TRAIT(human_user, TRAIT_MEDICAL_HUD))
					return
				if(health_status && health_status != "Cancel")
					target_record.fields["p_stat"] = health_status
				return
			if(href_list["m_stat"])
				var/health_status = input(human_user, "Specify a new mental status for this person.", "Medical HUD", target_record.fields["m_stat"]) in list("Stable", "*Watch*", "*Unstable*", "*Insane*", "Cancel")
				if(!target_record)
					return
				if(!human_user.canUseHUD())
					return
				if(!HAS_TRAIT(human_user, TRAIT_MEDICAL_HUD))
					return
				if(health_status && health_status != "Cancel")
					target_record.fields["m_stat"] = health_status
				return
			return //Medical HUD ends here.

		if(href_list["hud"] == "s")
			if(!HAS_TRAIT(human_user, TRAIT_SECURITY_HUD))
				return
			if(human_user.stat || human_user == src) //|| !human_user.canmove || human_user.restrained()) Fluff: Sechuds have eye-tracking technology and sets 'arrest' to people that the wearer looks and blinks at.
				return													  //Non-fluff: This allows sec to set people to arrest as they get disarmed or beaten
			// Checks the user has security clearence before allowing them to change arrest status via hud, comment out to enable all access
			var/allowed_access = null
			var/obj/item/clothing/glasses/hud/security/user_glasses = human_user.glasses
			if(istype(user_glasses) && (user_glasses.obj_flags & EMAGGED))
				allowed_access = "@%&ERROR_%$*"
			else //Implant and standard glasses check access
				if(human_user.wear_id)
					var/list/access = human_user.wear_id.GetAccess()
					if(ACCESS_SEC_RECORDS in access)
						allowed_access = human_user.get_authentification_name()

			if(!allowed_access)
				to_chat(human_user, "<span class='warning'>ERROR: Invalid access.</span>")
				return

			if(!perpname)
				to_chat(human_user, "<span class='warning'>ERROR: Can not identify target.</span>")
				return
			target_record = find_record("name", perpname, GLOB.data_core.security)
			if(!target_record)
				to_chat(human_user, "<span class='warning'>ERROR: Unable to locate data core entry for target.</span>")
				return
			if(href_list["status"])
				var/setcriminal = input(human_user, "Specify a new criminal status for this person.", "Security HUD", target_record.fields["criminal"]) in list("None", "Arrest", "Search", "Monitor", "Incarcerated", "Paroled", "Discharged", "Cancel")
				if(setcriminal != "Cancel")
					if(!target_record)
						return
					if(!human_user.canUseHUD())
						return
					if(!HAS_TRAIT(human_user, TRAIT_SECURITY_HUD))
						return
					investigate_log("[key_name(src)] has been set from <strong>[target_record.fields["criminal"]]</strong> to <strong>[setcriminal]</strong> by [key_name(human_user)]'s security records (via SecHUDs).", INVESTIGATE_RECORDS)
					target_record.fields["criminal"] = setcriminal
					sec_hud_set_security_status()
				return

			if(href_list["view"])
				if(!human_user.canUseHUD())
					return
				if(!HAS_TRAIT(human_user, TRAIT_SECURITY_HUD))
					return
				to_chat(human_user, "<b>Name:</b> [target_record.fields["name"]]	<b>Criminal Status:</b> [target_record.fields["criminal"]]")
				for(var/datum/data/crime/c in target_record.fields["crim"])
					to_chat(human_user, "<b>Crime:</b> [c.crimeName]")
					if (c.crimeDetails)
						to_chat(human_user, "<b>Details:</b> [c.crimeDetails]")
					else
						to_chat(human_user, "<b>Details:</b> <A href='?src=[REF(src)];hud=s;add_details=1;cdataid=[c.dataId]'>\[Add details]</A>")
					to_chat(human_user, "Added by [c.author] at [c.time]")
					to_chat(human_user, "----------")
				to_chat(human_user, "<b>Notes:</b> [target_record.fields["notes"]]")
				return

			if(href_list["add_citation"])
				var/maxFine = CONFIG_GET(number/maxfine)
				var/t1 = stripped_input("Please input citation crime:", "Security HUD", "", null)
				var/fine = FLOOR(input("Please input citation fine, up to [maxFine]:", "Security HUD", 50) as num|null, 1)
				if(!target_record || !t1 || !fine || !allowed_access)
					return
				if(!human_user.canUseHUD())
					return
				if(!HAS_TRAIT(human_user, TRAIT_SECURITY_HUD))
					return
				if(fine < 0)
					to_chat(human_user, "<span class='warning'>You're pretty sure that's not how money works.</span>")
					return
				fine = min(fine, maxFine)

				var/datum/data/crime/crime = GLOB.data_core.createCrimeEntry(t1, "", allowed_access, station_time_timestamp(), fine)
				for (var/obj/item/modular_computer/tablet in GLOB.TabletMessengers)
					if(tablet.saved_identification == target_record.fields["name"])
						var/message = "You have been fined [fine] credits for '[t1]'. Fines may be paid at security."
						var/datum/signal/subspace/messaging/tablet_msg/signal = new(src, list(
							"name" = "Security Citation",
							"job" = "Citation Server",
							"message" = message,
							"targets" = list(tablet),
							"automated" = TRUE
						))
						signal.send_to_receivers()
						human_user.log_message("(PDA: Citation Server) sent \"[message]\" to [signal.format_target()]", LOG_PDA)
				GLOB.data_core.addCitation(target_record.fields["id"], crime)
				investigate_log("[key_name(human_user)] has added a citation '<strong>[t1]</strong>' ([fine] credits) to [target_record.fields["name"]]'s security records (via SecHUDs).", INVESTIGATE_RECORDS)
				return

			if(href_list["add_crime"])
				var/t1 = stripped_input("Please input crime name:", "Security HUD", "", null)
				if(!target_record || !t1 || !allowed_access)
					return
				if(!human_user.canUseHUD())
					return
				if(!HAS_TRAIT(human_user, TRAIT_SECURITY_HUD))
					return
				var/crime = GLOB.data_core.createCrimeEntry(t1, null, allowed_access, station_time_timestamp())
				GLOB.data_core.addCrime(target_record.fields["id"], crime)
				investigate_log("[key_name(human_user)] has added a crime '<strong>[t1]</strong>' to [target_record.fields["name"]]'s security records (via SecHUDs).", INVESTIGATE_RECORDS)
				to_chat(human_user, "<span class='notice'>Successfully added a crime.</span>")
				return

			if(href_list["add_details"])
				var/t1 = stripped_input(human_user, "Please input crime details:", "Secure. records", "", null)
				if(!target_record || !t1 || !allowed_access)
					return
				if(!human_user.canUseHUD())
					return
				if(!HAS_TRAIT(human_user, TRAIT_SECURITY_HUD))
					return
				if(href_list["cdataid"])
					GLOB.data_core.addCrimeDetails(target_record.fields["id"], href_list["cdataid"], t1)
					investigate_log("[key_name(human_user)] has set crime details '[t1]' to [target_record.fields["name"]]'s security records (via SecHUDs).", INVESTIGATE_RECORDS)
					to_chat(human_user, "<span class='notice'>Successfully added details.</span>")
				return

			if(href_list["view_comment"])
				if(!human_user.canUseHUD())
					return
				if(!HAS_TRAIT(human_user, TRAIT_SECURITY_HUD))
					return
				to_chat(human_user, "<b>Comments/Log:</b>")
				var/counter = 1
				while(target_record.fields["com_[counter]"])
					to_chat(human_user, target_record.fields["com_[counter]"])
					to_chat(human_user, "----------")
					counter++
				return

			if(href_list["add_comment"])
				var/t1 = stripped_multiline_input("Add Comment:", "Secure. records", null, null)
				if (!target_record || !t1 || !allowed_access)
					return
				if(!human_user.canUseHUD())
					return
				if(!HAS_TRAIT(human_user, TRAIT_SECURITY_HUD))
					return
				var/counter = 1
				while(target_record.fields["com_[counter]"])
					counter++
				target_record.fields["com_[counter]"] = "Made by [allowed_access] on [station_time_timestamp()] [time2text(world.realtime, "MMM DD")], [GLOB.year_integer+YEAR_OFFSET]<BR>[t1]"
				to_chat(human_user, "<span class='notice'>Successfully added comment.</span>")
				return
	..() //end of this massive fucking chain. TODO: make the hud chain not spooky.


/mob/living/carbon/human/proc/canUseHUD()
	return (mobility_flags & MOBILITY_USE)

/mob/living/carbon/human/can_inject(mob/user, error_msg, target_zone, penetrate_thick = FALSE)
	if(HAS_TRAIT(src, TRAIT_PIERCEIMMUNE))
		return FALSE
	if(penetrate_thick)
		return TRUE

	if(!target_zone)
		if(user)
			target_zone = user.get_combat_bodyzone(src, FALSE, BODYZONE_CONTEXT_INJECTION)
		else
			target_zone = BODY_ZONE_CHEST
	// If targeting the head, see if the head item is thin enough.
	// If targeting anything else, see if the wear suit is thin enough.
	if(above_neck(target_zone))
		if(!head || !isclothing(head))
			return TRUE
		var/obj/item/clothing/head/CH = head
		if(CH.clothing_flags & THICKMATERIAL)
			balloon_alert(user, "There is no exposed flesh on [p_their()] head.")
			return FALSE
		return TRUE
	if(!wear_suit || !isclothing(wear_suit))
		return TRUE
	var/obj/item/clothing/suit/CS = wear_suit
	if(CS.clothing_flags & THICKMATERIAL)
		switch(target_zone)
			if(BODY_ZONE_CHEST)
				if(CS.body_parts_covered & CHEST)
					balloon_alert(user, "There is no exposed flesh on [p_their()] chest.")
					return FALSE
			if(BODY_ZONE_PRECISE_GROIN)
				if(CS.body_parts_covered & GROIN)
					balloon_alert(user, "There is no exposed flesh on [p_their()] groin.")
					return FALSE
			if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
				if(CS.body_parts_covered & ARMS)
					balloon_alert(user, "There is no exposed flesh on [p_their()] arms.")
					return FALSE
			if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
				if(CS.body_parts_covered & LEGS)
					balloon_alert(user, "There is no exposed flesh on [p_their()] legs.")
					return FALSE
	return TRUE

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
		var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
		if(R && R.fields["criminal"])
			switch(R.fields["criminal"])
				if("Arrest")
					threatcount += 5
				if("Incarcerated")
					threatcount += 2
				if("Paroled")
					threatcount += 2
				if("Monitor")
					threatcount += 1
				if("Search")
					threatcount += 2

	//Check for dresscode violations
	if(istype(head, /obj/item/clothing/head/wizard) || istype(head, /obj/item/clothing/head/helmet/space/hardsuit/wizard))
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
	if(istype(get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/foilhat))
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

/mob/living/carbon/human/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_THREE)
		for(var/obj/item/hand in held_items)
			if(prob(current_size * 5) && hand.w_class >= ((11-current_size)/2)  && dropItemToGround(hand))
				step_towards(hand, src)
				to_chat(src, "<span class='warning'>\The [S] pulls \the [hand] from your grip!</span>")
	rad_act(current_size * 3)

/mob/living/carbon/human/proc/do_cpr(mob/living/carbon/C)
	CHECK_DNA_AND_SPECIES(C)

	if(C.stat == DEAD || (HAS_TRAIT(C, TRAIT_FAKEDEATH)))
		to_chat(src, "<span class='warning'>[C.name] is dead!</span>")
		return
	if(is_mouth_covered())
		to_chat(src, "<span class='warning'>Remove your mask first!</span>")
		return 0
	if(C.is_mouth_covered())
		to_chat(src, "<span class='warning'>Remove [p_their()] mask first!</span>")
		return 0

	if(C.cpr_time < world.time + 30)
		visible_message("<span class='notice'>[src] is trying to perform CPR on [C.name]!</span>", \
						"<span class='notice'>You try to perform CPR on [C.name]... Hold still!</span>")
		if(!do_after(src, target = C))
			to_chat(src, "<span class='warning'>You fail to perform CPR on [C]!</span>")
			return 0

		var/they_breathe = !HAS_TRAIT(C, TRAIT_NOBREATH)
		var/they_lung = C.getorganslot(ORGAN_SLOT_LUNGS)

		if(C.health > C.crit_threshold)
			return

		src.visible_message("[src] performs CPR on [C.name]!", "<span class='notice'>You perform CPR on [C.name].</span>")
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "perform_cpr", /datum/mood_event/perform_cpr)
		C.cpr_time = world.time
		log_combat(src, C, "CPRed")

		if(they_breathe && they_lung)
			var/suff = min(C.getOxyLoss(), 7)
			C.adjustOxyLoss(-suff)
			C.updatehealth()
			to_chat(C, "<span class='unconscious'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
		else if(they_breathe && !they_lung)
			to_chat(C, "<span class='unconscious'>You feel a breath of fresh air, but you don't feel any better.</span>")
		else
			to_chat(C, "<span class='unconscious'>You feel a breath of fresh air, which is a sensation you don't recognise.</span>")

/mob/living/carbon/human/cuff_resist(obj/item/I)
	if(dna && dna.check_mutation(HULK))
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
			update_inv_gloves()
	else if((clean_types & CLEAN_TYPE_BLOOD) && blood_in_hands > 0)
		blood_in_hands = 0
		update_inv_gloves()

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
		update_inv_glasses()
		. = TRUE

	var/list/obscured = check_obscured_slots()
	if(wear_mask && !(ITEM_SLOT_MASK in obscured) && wear_mask.wash(clean_types))
		update_inv_wear_mask()
		. = TRUE

/**
  * Called when this human should be washed
  */
/mob/living/carbon/human/wash(clean_types)
	. = ..()

	// Wash equipped stuff that cannot be covered
	if(wear_suit?.wash(clean_types))
		update_inv_wear_suit()
		. = TRUE

	if(belt?.wash(clean_types))
		update_inv_belt()
		. = TRUE

	// Check and wash stuff that can be covered
	var/list/obscured = check_obscured_slots()

	if(w_uniform && !(ITEM_SLOT_ICLOTHING in obscured) && w_uniform.wash(clean_types))
		update_inv_w_uniform()
		. = TRUE

	if(!is_mouth_covered() && clean_lips())
		. = TRUE

	// Wash hands if exposed
	if(!gloves && (clean_types & CLEAN_TYPE_BLOOD) && blood_in_hands > 0 && !(ITEM_SLOT_GLOVES in obscured))
		blood_in_hands = 0
		update_inv_gloves()
		. = TRUE

//Turns a mob black, flashes a skeleton overlay
//Just like a cartoon!
/mob/living/carbon/human/proc/electrocution_animation(anim_duration)
	//Handle mutant parts if possible
	if(dna?.species)
		add_atom_colour("#000000", TEMPORARY_COLOUR_PRIORITY)
		var/static/mutable_appearance/electrocution_skeleton_anim
		if(!electrocution_skeleton_anim)
			electrocution_skeleton_anim = mutable_appearance(icon, "electrocuted_base")
			electrocution_skeleton_anim.appearance_flags |= RESET_COLOR|KEEP_APART
		add_overlay(electrocution_skeleton_anim)
		addtimer(CALLBACK(src, PROC_REF(end_electrocution_animation), electrocution_skeleton_anim), anim_duration)

	else //or just do a generic animation
		flick_overlay_view(image(icon,src,"electrocuted_generic",ABOVE_MOB_LAYER), src, anim_duration)

/mob/living/carbon/human/proc/end_electrocution_animation(mutable_appearance/MA)
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, "#000000")
	cut_overlay(MA)

/mob/living/carbon/human/can_interact_with(atom/A, treat_mob_as_adjacent)
	return ..() || (dna.check_mutation(TK) && tkMaxRangeCheck(src, A))

/mob/living/carbon/human/canUseTopic(atom/movable/M, be_close=FALSE, no_dexterity=FALSE, no_tk=FALSE)
	if(!(mobility_flags & MOBILITY_UI))
		to_chat(src, "<span class='warning'>You can't do that right now!</span>")
		return FALSE
	if(!Adjacent(M) && (M.loc != src))
		if((be_close == FALSE) || (!no_tk && (dna.check_mutation(TK) && tkMaxRangeCheck(src, M))))
			return TRUE
		to_chat(src, "<span class='warning'>You are too far away!</span>")
		return FALSE
	return TRUE

/mob/living/carbon/human/resist_restraints()
	if(wear_suit && wear_suit.breakouttime)
		changeNext_move(CLICK_CD_BREAKOUT)
		last_special = world.time + CLICK_CD_BREAKOUT
		cuff_resist(wear_suit)
	else
		..()

/mob/living/carbon/human/replace_records_name(oldname,newname) // Only humans have records right now, move this up if changed.
	for(var/list/L in list(GLOB.data_core.general,GLOB.data_core.medical,GLOB.data_core.security,GLOB.data_core.locked))
		var/datum/data/record/R = find_record("name", oldname, L)
		if(R)
			R.fields["name"] = newname

/mob/living/carbon/human/get_total_tint()
	. = ..()
	if(glasses)
		. += glasses.tint

/mob/living/carbon/human/update_health_hud()
	if(!client || !hud_used)
		return
	if(dna.species.update_health_hud())
		return
	else
		if(hud_used.healths)
			var/health_amount = min(health, maxHealth - getStaminaLoss())
			if(..(health_amount)) //not dead
				switch(hal_screwyhud)
					if(SCREWYHUD_CRIT)
						hud_used.healths.icon_state = "health6"
					if(SCREWYHUD_DEAD)
						hud_used.healths.icon_state = "health7"
					if(SCREWYHUD_HEALTHY)
						hud_used.healths.icon_state = "health0"
		if(hud_used.healthdoll)
			hud_used.healthdoll.cut_overlays()
			if(stat != DEAD)
				hud_used.healthdoll.icon_state = "healthdoll_OVERLAY"
				for(var/obj/item/bodypart/BP as() in bodyparts)
					var/damage = BP.burn_dam + BP.brute_dam + (hallucination ? BP.stamina_dam : 0)
					var/comparison = (BP.max_damage/5)
					var/icon_num = 0
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
					if(hal_screwyhud == SCREWYHUD_HEALTHY)
						icon_num = 0
					if(icon_num)
						hud_used.healthdoll.add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[BP.body_zone][icon_num]"))
					//Stamina Outline (Communicate that we have stamina damage)
					//Hallucinations will appear as regular damage
					if(BP.stamina_dam && !hallucination)
						var/mutable_appearance/MA = mutable_appearance('icons/mob/screen_gen.dmi', "[BP.body_zone]stam")
						MA.alpha = (BP.stamina_dam / BP.max_stamina_damage) * 70 + 30
						hud_used.healthdoll.add_overlay(MA)
				for(var/t in get_missing_limbs()) //Missing limbs
					hud_used.healthdoll.add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[t]6"))
				for(var/t in get_disabled_limbs()) //Disabled limbs
					hud_used.healthdoll.add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[t]7"))
			else
				hud_used.healthdoll.icon_state = "healthdoll_DEAD"

/mob/living/carbon/human/fully_heal(admin_revive = 0)
	dna?.species.spec_fully_heal(src)
	if(admin_revive)
		regenerate_limbs()
		regenerate_organs()
		if(ismoth(src))
			REMOVE_TRAIT(src, TRAIT_MOTH_BURNT, "fire")
	remove_all_embedded_objects()
	set_heartattack(FALSE)
	drunkenness = 0
	for(var/datum/mutation/HM as() in dna.mutations)
		if(HM.quality != POSITIVE)
			dna.remove_mutation(HM.name)
	..()

/mob/living/carbon/human/check_weakness(obj/item/weapon, mob/living/attacker)
	. = ..()
	if (dna && dna.species)
		. += dna.species.check_species_weakness(weapon, attacker)

/mob/living/carbon/human/is_literate()
	return TRUE

/mob/living/carbon/human/can_hold_items()
	return TRUE

/mob/living/carbon/human/update_gravity(has_gravity,override = 0)
	if(dna && dna.species) //prevents a runtime while a human is being monkeyfied
		override = dna.species.override_float
	..()

/mob/living/carbon/human/vomit(lost_nutrition = 10, blood = 0, stun = 1, distance = 0, message = 1, toxic = 0)
	if(blood && (NOBLOOD in dna.species.species_traits))
		if(message)
			visible_message("<span class='warning'>[src] dry heaves!</span>", \
							"<span class='userdanger'>You try to throw up, but there's nothing in your stomach!</span>")
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
		var/result = input(usr, "Please choose a new species","Species") as null|anything in GLOB.species_list
		if(result)
			var/newtype = GLOB.species_list[result]
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
			var/msg = "<span class='notice'>[key_name_admin(usr)] has put [key_name(src)] on purrbation.</span>"
			message_admins(msg)
			admin_ticket_log(src, msg)

		else
			to_chat(usr, "Removed [src] from purrbation.")
			log_admin("[key_name(usr)] has removed [key_name(src)] from purrbation.")
			var/msg = "<span class='notice'>[key_name_admin(usr)] has removed [key_name(src)] from purrbation.</span>"
			message_admins(msg)
			admin_ticket_log(src, msg)
	if(href_list[VV_HK_RANDOM_NAME])
		if(!check_rights(R_ADMIN))//mods can rename people with VV so they should be able to do this too
			return
		if(isnull(dna.species))
			to_chat(usr, "The species of [src] is null, aborting.")
		var/old_name = real_name
		fully_replace_character_name(real_name, dna.species.random_name(gender))
		log_admin("[key_name(usr)] has randomly generated a new name for [key_name(src)], replacing their old name of [old_name].")
		message_admins("<span class='notice'>[key_name_admin(usr)] has randomly generated a new name for [key_name(src)], replacing their old name of [old_name].</span>")


/mob/living/carbon/human/MouseDrop_T(mob/living/target, mob/living/user)
	if(pulling != target || grab_state < GRAB_AGGRESSIVE || stat != CONSCIOUS || a_intent != INTENT_GRAB)
		return ..()

	//If they dragged themselves and we're currently aggressively grabbing them try to piggyback
	if(user == target)
		if(can_piggyback(target))
			piggyback(target)
	//If you dragged them to you and you're aggressively grabbing try to fireman carry them
	else if(can_be_firemanned(target))
		fireman_carry(target)

/mob/living/carbon/human/MouseDrop(mob/over)
	. = ..()
	if(ishuman(over))
		var/mob/living/carbon/human/T = over  // curbstomp, ported from PP with modifications
		if(!src.is_busy && (src.is_zone_selected(BODY_ZONE_HEAD) || src.is_zone_selected(BODY_ZONE_PRECISE_GROIN)) && get_turf(src) == get_turf(T) && !(T.mobility_flags & MOBILITY_STAND) && src.a_intent != INTENT_HELP && !HAS_TRAIT(src, TRAIT_PACIFISM)) //all the stars align, time to curbstomp
			src.is_busy = TRUE

			if (!do_after(src, 2.5 SECONDS, T) || get_turf(src) != get_turf(T) || (T.mobility_flags & MOBILITY_STAND) || src.a_intent == INTENT_HELP || src == T) //wait 30ds and make sure the stars still align (Body zone check removed after PR #958)
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

				T.visible_message("<span class='warning'>[src] curbstomps [T]!</span>", "<span class='warning'>[src] curbstomps you!</span>")

				log_combat(src, T, "curbstomped")

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

				T.visible_message("<span class='warning'>[src] kicks [T] in the groin!</span>", "<span class='warning'>[src] kicks you in the groin!</span")

				log_combat(src, T, "groinkicked")

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


//src is the user that will be carrying, target is the mob to be carried
/mob/living/carbon/human/proc/can_piggyback(mob/living/carbon/target)
	return (istype(target) && target.stat == CONSCIOUS && (target.mobility_flags & MOBILITY_STAND))

/mob/living/carbon/human/proc/can_be_firemanned(mob/living/carbon/target)
	return ((ishuman(target) || ismonkey(target)) && !(target.mobility_flags & MOBILITY_STAND))

/mob/living/carbon/human/proc/fireman_carry(mob/living/carbon/target)
	var/carrydelay = 50 //if you have latex you are faster at grabbing
	var/skills_space = "" //cobby told me to do this
	if(HAS_TRAIT(src, TRAIT_QUICKER_CARRY))
		carrydelay = 30
		skills_space = " expertly"
	else if(HAS_TRAIT(src, TRAIT_QUICK_CARRY))
		carrydelay = 40
		skills_space = " quickly"
	if(can_be_firemanned(target) && !incapacitated(FALSE, TRUE))
		visible_message("<span class='notice'>[src] starts[skills_space] lifting [target] onto their back..</span>",
		//Joe Medic starts quickly/expertly lifting Grey Tider onto their back..
		"<span class='notice'>[HAS_TRAIT(src, TRAIT_QUICKER_CARRY) ? "Using your gloves' nanochips, you" : "You"][skills_space] start to lift [target] onto your back[HAS_TRAIT(src, TRAIT_QUICK_CARRY) ? ", while assisted by the nanochips in your gloves..." : "..."]</span>")
		//(Using your gloves' nanochips, you/You) ( /quickly/expertly) start to lift Grey Tider onto your back(, while assisted by the nanochips in your gloves../...)
		if(do_after(src, carrydelay, target))
			//Second check to make sure they're still valid to be carried
			if(can_be_firemanned(target) && !incapacitated(FALSE, TRUE) && !target.buckled)
				buckle_mob(target, TRUE, TRUE, 90, 1, 0)
				return
		visible_message("<span class='warning'>[src] fails to fireman carry [target]!</span>")
	else
		to_chat(src, "<span class='notice'>You can't fireman carry [target] while they're standing!</span>")

/mob/living/carbon/human/proc/piggyback(mob/living/carbon/target)
	if(can_piggyback(target))
		visible_message("<span class='notice'>[target] starts to climb onto [src].</span>")
		if(do_after(target, 15, target = src))
			if(can_piggyback(target))
				if(target.incapacitated(FALSE, TRUE) || incapacitated(FALSE, TRUE))
					target.visible_message("<span class='warning'>[target] can't hang onto [src]!</span>")
					return
				buckle_mob(target, TRUE, TRUE, FALSE, 0, 2)
		else
			visible_message("<span class='warning'>[target] fails to climb onto [src]!</span>")
	else
		to_chat(target, "<span class='warning'>You can't piggyback ride [src] right now!</span>")


/mob/living/carbon/human/buckle_mob(mob/living/target, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0)
	if(!force)//humans are only meant to be ridden through piggybacking and special cases
		return
	if(!is_type_in_typecache(target, can_ride_typecache))
		target.visible_message("<span class='warning'>[target] really can't seem to mount [src].</span>")
		return
	buckle_lying = lying_buckle
	var/datum/component/riding/human/riding_datum = LoadComponent(/datum/component/riding/human)
	if(target_hands_needed)
		riding_datum.ride_check_rider_restrained = TRUE
	if(buckled_mobs && ((target in buckled_mobs) || (buckled_mobs.len >= max_buckled_mobs)) || buckled)
		return
	var/equipped_hands_self
	var/equipped_hands_target
	if(hands_needed)
		equipped_hands_self = riding_datum.equip_buckle_inhands(src, hands_needed, target)
	if(target_hands_needed)
		equipped_hands_target = riding_datum.equip_buckle_inhands(target, target_hands_needed)

	if(hands_needed || target_hands_needed)
		if(hands_needed && !equipped_hands_self)
			src.visible_message("<span class='warning'>[src] can't get a grip on [target] because their hands are full!</span>",
				"<span class='warning'>You can't get a grip on [target] because your hands are full!</span>")
			return
		else if(target_hands_needed && !equipped_hands_target)
			target.visible_message("<span class='warning'>[target] can't get a grip on [src] because their hands are full!</span>",
				"<span class='warning'>You can't get a grip on [src] because your hands are full!</span>")
			return

	stop_pulling()
	riding_datum.handle_vehicle_layer()
	. = ..(target, force, check_loc)

	//Something went wrong with buckling, remove inhands and restore target's position!
	if(!.)
		riding_datum.unequip_buckle_inhands(src)
		riding_datum.unequip_buckle_inhands(target)
		riding_datum.restore_position(target)
		to_chat(src, "<span class='warning'>You seem to be unable to carry [target]!</span>")

/mob/living/carbon/human/proc/is_shove_knockdown_blocked() //If you want to add more things that block shove knockdown, extend this
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, ears, wear_id) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/bp in body_parts)
		if(isclothing(bp))
			var/obj/item/clothing/C = bp
			if(C.blocks_shove_knockdown)
				return TRUE
	return FALSE

/mob/living/carbon/human/proc/clear_shove_slowdown()
	remove_movespeed_modifier(MOVESPEED_ID_SHOVE)
	var/active_item = get_active_held_item()
	if(is_type_in_typecache(active_item, GLOB.shove_disarming_types))
		visible_message("<span class='warning'>[src.name] regains their grip on \the [active_item]!</span>", "<span class='warning'>You regain your grip on \the [active_item].</span>", null, COMBAT_MESSAGE_RANGE)

/mob/living/carbon/human/updatehealth()
	. = ..()
	dna?.species.spec_updatehealth(src)
	if(HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
		remove_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN)
		remove_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN_FLYING)
		return
	var/health_deficiency = max((maxHealth - health), staminaloss)
	if(health_deficiency >= 40)
		add_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN, override = TRUE, multiplicative_slowdown = (health_deficiency / 75), blacklisted_movetypes = FLOATING|FLYING)
		add_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN_FLYING, override = TRUE, multiplicative_slowdown = (health_deficiency / 25), movetypes = FLOATING)
	else
		remove_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN)
		remove_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN_FLYING)


/mob/living/carbon/human/adjust_nutrition(var/change) //Honestly FUCK the oldcoders for putting nutrition on /mob someone else can move it up because holy hell I'd have to fix SO many typechecks
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_POWERHUNGRY))
		var/obj/item/organ/stomach/battery/battery = getorganslot(ORGAN_SLOT_STOMACH)
		if(istype(battery))
			battery.adjust_charge_scaled(change)
		return FALSE
	return ..()

/mob/living/carbon/human/set_nutrition(var/change) //Seriously fuck you oldcoders.
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_POWERHUNGRY))
		var/obj/item/organ/stomach/battery/battery = getorganslot(ORGAN_SLOT_STOMACH)
		if(istype(battery))
			battery.set_charge_scaled(change)
		return FALSE
	return ..()

/mob/living/carbon/human/proc/stub_toe(var/power)
	if(HAS_TRAIT(src, TRAIT_LIGHT_STEP))
		power *= 0.5
		src.emote("gasp")
	else
		src.emote("scream")
	src.apply_damage(power, BRUTE, def_zone = pick(BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT))
	src.Paralyze(10 * power)

/mob/living/carbon/human/monkeybrain
	ai_controller = /datum/ai_controller/monkey

/mob/living/carbon/human/species
	var/race = null

/mob/living/carbon/human/species/Initialize(mapload, specific_race)
	. = ..()
	set_species(race || specific_race)

/mob/living/carbon/human/species/abductor
	race = /datum/species/abductor

/mob/living/carbon/human/species/android
	race = /datum/species/android

/mob/living/carbon/human/species/apid
	race = /datum/species/apid

/mob/living/carbon/human/species/dullahan
	race = /datum/species/dullahan

/mob/living/carbon/human/species/ethereal
	race = /datum/species/ethereal

/mob/living/carbon/human/species/felinid
	race = /datum/species/human/felinid

/mob/living/carbon/human/species/fly
	race = /datum/species/fly

/mob/living/carbon/human/species/golem
	race = /datum/species/golem

/mob/living/carbon/human/species/golem/random
	race = /datum/species/golem/random

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

/mob/living/carbon/human/species/golem/capitalist
	race = /datum/species/golem/capitalist

/mob/living/carbon/human/species/golem/soviet
	race = /datum/species/golem/soviet

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

/mob/living/carbon/human/species/pod
	race = /datum/species/pod

/mob/living/carbon/human/species/shadow
	race = /datum/species/shadow

/mob/living/carbon/human/species/shadow/nightmare
	race = /datum/species/shadow/nightmare

/mob/living/carbon/human/species/skeleton
	race = /datum/species/skeleton

/mob/living/carbon/human/species/supersoldier
	race = /datum/species/human/supersoldier

/mob/living/carbon/human/species/vampire
	race = /datum/species/vampire

/mob/living/carbon/human/species/zombie
	race = /datum/species/zombie

/mob/living/carbon/human/species/zombie/infectious
	race = /datum/species/zombie/infectious

/mob/living/carbon/human/species/zombie/krokodil_addict
	race = /datum/species/human/krokodil_addict

/mob/living/carbon/human/species/pumpkin_man
	race = /datum/species/pod/pumpkin_man

/mob/living/carbon/human/species/psyphoza
	race = /datum/species/psyphoza
