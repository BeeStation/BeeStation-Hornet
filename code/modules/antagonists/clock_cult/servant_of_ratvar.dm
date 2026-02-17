GLOBAL_LIST_EMPTY(servants_of_ratvar)	//List of minds in the cult
GLOBAL_LIST_EMPTY(all_servants_of_ratvar)	//List of minds in the cult
GLOBAL_LIST_EMPTY(human_servants_of_ratvar)	//Humans in the cult
GLOBAL_LIST_EMPTY(cyborg_servants_of_ratvar)

GLOBAL_VAR(ratvar_arrival_tick)	//The world.time that Ratvar will arrive if the gateway is not disrupted

GLOBAL_VAR_INIT(installed_integration_cogs, 0)

GLOBAL_VAR(celestial_gateway)	//The celestial gateway
GLOBAL_VAR_INIT(ratvar_risen, FALSE)	//Has ratvar risen?
GLOBAL_VAR_INIT(gateway_opening, FALSE)	//Is the gateway currently active?

GLOBAL_VAR_INIT(clockcult_power, 2500)
GLOBAL_VAR_INIT(clockcult_vitality, 200)

GLOBAL_VAR(clockcult_eminence)

//==========================
//====  Servant antag   ====
//==========================

/datum/antagonist/servant_of_ratvar
	name = "Servant Of Ratvar"
	roundend_category = "clock cultists"
	antagpanel_category = "Clockcult"
	// TODO: ui_name = "AntagInfoClockCult"
	antag_moodlet = /datum/mood_event/cult
	banning_key = ROLE_SERVANT_OF_RATVAR
	required_living_playtime = 4

	//The class of the servant
	var/datum/action/innate/clockcult/transmit/transmit_spell
	var/datum/team/clock_cult/team

	/// Prefix used when using the hierophant transmit action
	var/prefix = CLOCKCULT_PREFIX_RECRUIT
	/// Whether or not this servant counts towards the total number of servants, think abstraction crystal projections
	var/counts_towards_total = TRUE
	/// Flavor appearance applied when the gateway is opened
	var/mutable_appearance/forbearance

/datum/antagonist/servant_of_ratvar/greet()
	if(!owner.current)
		return
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/clockcultalr.ogg', vol = 60, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE)
	to_chat(owner.current, span_heavybrass("<font size='7'>You feel a flash of light and the world spin around you!</font>"))
	to_chat(owner.current, span_brass("<font size='5'>Using your clockwork slab you can invoke a variety of powers to help you complete Ratvar's will.</font>"))
	to_chat(owner.current, span_brass("Use Rat'varian observation consoles to monitor the crew and warp to the station."))
	to_chat(owner.current, span_brass("Use your Clockwork Slab to summon integration cogs to unlock more scriptures and siphon power."))
	to_chat(owner.current, span_brass("Unlock Kindle to stun targets, Hateful Manacles to restrain them and use a sigil of submission to convert them!"))
	to_chat(owner.current, span_brass("When you are ready, gather 6 cultists around the Ark and activate it to summon Rat'var, but be prepared to fight for your life."))
	owner.current.client?.tgui_panel?.give_antagonist_popup("Servant of Rat'Var",
		"Use your clockwork slab to unlock and invoke scriptures.\n\
		Hijack APCs by placing an integration cog into them.\n\
		Convert the unfaithful to your side but above all else, protect the Gateway!")

/datum/antagonist/servant_of_ratvar/on_gain()
	. = ..()
	create_team()
	add_objectives()
	GLOB.all_servants_of_ratvar |= owner
	if(counts_towards_total)
		GLOB.servants_of_ratvar |= owner
		if(ishuman(owner.current))
			GLOB.human_servants_of_ratvar |= owner
		else if(iscyborg(owner.current))
			GLOB.cyborg_servants_of_ratvar |= owner
	check_ark_status()
	owner.announce_objectives()

/datum/antagonist/servant_of_ratvar/on_removal()
	team.remove_member(owner)
	GLOB.servants_of_ratvar -= owner
	GLOB.all_servants_of_ratvar -= owner
	GLOB.human_servants_of_ratvar -= owner
	GLOB.cyborg_servants_of_ratvar -= owner
	if(!silent)
		owner.current.visible_message("[span_deconversionmessage("[owner.current] looks like [owner.current.p_theyve()] just reverted to [owner.current.p_their()] old faith!")]", null, null, null, owner.current)
		to_chat(owner.current, span_userdanger("An unfamiliar white light flashes through your mind, cleansing the taint of the Clockwork Justicar and all your memories as his servant."))
		owner.current.log_message("has renounced the cult of Rat'var!", LOG_ATTACK, color="#960000")
	. = ..()

/datum/antagonist/servant_of_ratvar/apply_innate_effects(mob/living/M)
	. = ..()
	owner.current.faction |= FACTION_RATVAR
	transmit_spell = new()
	transmit_spell.Grant(owner.current)
	if(GLOB.gateway_opening && ishuman(owner.current))
		var/mob/living/carbon/owner_mob = owner.current
		forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
		owner_mob.add_overlay(forbearance)
	owner.current.throw_alert("clockinfo", /atom/movable/screen/alert/clockwork/clocksense)
	add_antag_hud(ANTAG_HUD_CLOCKWORK, "clockwork", owner.current)
	var/datum/language_holder/LH = owner.current.get_language_holder()
	LH.grant_language(/datum/language/ratvar, source = LANGUAGE_CULTIST)

/datum/antagonist/servant_of_ratvar/remove_innate_effects(mob/living/M)
	owner.current.faction -= FACTION_RATVAR
	owner.current.clear_alert("clockinfo")
	transmit_spell.Remove(transmit_spell.owner)
	remove_antag_hud(ANTAG_HUD_CLOCKWORK, owner.current)
	if(forbearance && ishuman(owner.current))
		var/mob/living/carbon/owner_mob = owner.current
		owner_mob.remove_overlay(forbearance)
		qdel(forbearance)
	var/datum/language_holder/LH = owner.current.get_language_holder()
	LH.remove_language(/datum/language/ratvar, source = LANGUAGE_CULTIST)
	. = ..()

/datum/antagonist/servant_of_ratvar/proc/equip_servant_conversion()
	//Equipment apply
	var/mob/living/H = owner.current
	if(istype(H, /mob/living/carbon))
		equip_carbon(H)
	else if(istype(H, /mob/living/silicon))
		equip_silicon(H)

//Remove clown mutation
//Give the device
/datum/antagonist/servant_of_ratvar/proc/equip_servant()
	var/mob/living/H = owner.current
	var/datum/outfit/clockwork_outfit = new /datum/outfit/clockcult
	if(istype(H, /mob/living/carbon))
		clockwork_outfit.equip(H)

/datum/antagonist/servant_of_ratvar/proc/equip_carbon(mob/living/carbon/H)
	//Convert all items in their inventory to Ratvarian
	var/list/contents = H.get_contents()
	for(var/atom/A in contents)
		A.ratvar_act()
	//Equip them with a slab
	var/obj/item/clockwork/clockwork_slab/slab = new(get_turf(H))
	H.put_in_hands(slab)
	//Remove cuffs
	H.uncuff()
	return FALSE

/*
* Silicons can be converted to clock cultists
* AIs have all of their robots disconnected and get a flavorful overlay on their sprite
* Borgs are disconnected from their AI and get special ratvar modules
*/
/datum/antagonist/servant_of_ratvar/proc/equip_silicon(mob/living/silicon/silicon)
	if(isAI(silicon))
		var/mob/living/silicon/ai/ai = silicon

		// Disconnect borgs
		ai.disconnect_shell()
		for(var/mob/living/silicon/robot/robot in ai.connected_robots)
			robot.connected_ai = null

		// Flavor
		var/mutable_appearance/ai_clock = mutable_appearance('icons/mob/clockwork_mobs.dmi', "aiframe")
		ai.add_overlay(ai_clock)
	else if(iscyborg(silicon))
		var/mob/living/silicon/robot/robot = silicon
		robot.connected_ai = null
		robot.SetRatvar(TRUE)

	// Give laws
	silicon.laws = new /datum/ai_laws/ratvar
	silicon.laws.associate(silicon)
	silicon.show_laws()

/datum/antagonist/servant_of_ratvar/proc/add_objectives()
	objectives |= team.objectives

/datum/antagonist/servant_of_ratvar/get_team()
	return team

/datum/antagonist/servant_of_ratvar/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		. = is_convertable_to_clockcult(new_owner.current)

/datum/antagonist/servant_of_ratvar/create_team()
	for(var/datum/antagonist/servant_of_ratvar/H in GLOB.antagonists)
		if(!H.owner)
			continue
		if(H.team)
			team = H.team
			return
	team = new /datum/team/clock_cult
	team.setup_objectives()

//==========================
//==== Clock cult team  ====
//==========================

/datum/team/clock_cult
	name = "Servants Of Ratvar"

/datum/team/clock_cult/proc/setup_objectives()
	objectives = list(new /datum/objective/clockcult)
