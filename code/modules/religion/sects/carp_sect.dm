/datum/religion_sect/carp_sect
	name = "Followers of the Great Carp"
	desc = "A sect dedicated to the space carp and carp'sie, Offer the gods meat for favor."
	quote = "Drown the station in fish and water."
	tgui_icon = "fish"
	alignment = ALIGNMENT_NEUT
	max_favor = 10000
	desired_items = list(
		/obj/item/food/meat/slab)
	rites_list = list(
		/datum/religion_rites/summon_carp,
		/datum/religion_rites/flood_area,
		/datum/religion_rites/summon_carpsuit)
	altar_icon_state = "convertaltar-blue"

//Carp bibles give people the carp faction!
/datum/religion_sect/carp_sect/sect_bless(mob/living/L, mob/living/user)
	if(!isliving(L))
		return FALSE
	L.faction |= FACTION_CARP
	user.visible_message(span_notice("[user] blessed [L] with the power of [GLOB.deity]! They are now protected from Space Carps, Although carps will still fight back if attacked."))
	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return TRUE

/datum/religion_sect/carp_sect/on_sacrifice(obj/item/N, mob/living/L) //and this
	var/obj/item/food/meat/meat = N
	if(!istype(meat)) //how...
		return
	adjust_favor(20, L)
	to_chat(L, span_notice("You offer [meat] to [GLOB.deity], pleasing them and gaining 20 favor in the process."))
	qdel(N)
	return TRUE


/**** Carp rites ****/
/datum/religion_rites/summon_carp
	name = "Summon Carp"
	desc = "Creates a Sentient Space Carp, if a soul is willing to take it. If not, the favor is refunded."
	ritual_length = 50 SECONDS
	ritual_invocations = list(
		"Grant us a new follower ...",
		"... let them enter our realm ...",
		"... become one with our world ...",
		"... to swim in our space ...",
		"... and help our cause ...")
	invoke_msg = "... We summon thee, Holy Carp!"
	favor_cost = 500

/datum/religion_rites/summon_carp/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	new /obj/effect/temp_visual/bluespace_fissure/long(altar_turf)
	user.visible_message(span_notice("A tear in reality appears above the altar!"))
	var/datum/poll_config/config = new()
	config.check_jobban = ROLE_HOLY_SUMMONED
	config.poll_time = 10 SECONDS
	config.ignore_category = POLL_IGNORE_HOLYCARP
	config.jump_target = religious_tool
	config.role_name_text = "holy carp"
	config.alert_pic = /mob/living/simple_animal/hostile/carp
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(config)
	if(!candidate)
		new /obj/effect/gibspawner/generic(altar_turf)
		user.visible_message(span_warning("The carp pool was not strong enough to bring forth a space carp."))
		GLOB.religious_sect?.adjust_favor(400, user)
		return NOT_ENOUGH_PLAYERS
	var/datum/mind/M = new /datum/mind(candidate.key)
	var/carp_species = pick(/mob/living/simple_animal/hostile/carp/megacarp, /mob/living/simple_animal/hostile/carp)
	var/mob/living/simple_animal/hostile/carp = new carp_species(altar_turf)
	carp.name = "Holy Space-Carp ([rand(1,999)])"
	carp.key = candidate.key
	carp.sentience_act()
	carp.maxHealth += 100
	carp.health += 100
	M.transfer_to(carp)
	if(GLOB.religion)
		carp.mind?.holy_role = HOLY_ROLE_PRIEST
		to_chat(carp, "There is already an established religion onboard the station. You are an acolyte of [GLOB.deity]. Defer to the Chaplain.")
		GLOB.religious_sect?.on_conversion(carp)
	if(is_special_character(user))
		to_chat(carp, span_userdanger("You are grateful to have been summoned into this word by [user]. Serve [user.real_name], and assist [user.p_them()] in completing [user.p_their()] goals at any cost."))
	else
		to_chat(carp, span_bignotice("You are grateful to have been summoned into this world. You are now a member of this station's crew, Try not to cause any trouble."))
	playsound(altar_turf, 'sound/effects/slosh.ogg', 50, TRUE)
	return ..()

/datum/religion_rites/summon_carpsuit
	name = "Summon Carp-Suit"
	desc = "Summons a Space-Carp Suit"
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"We shall become one ...",
		"... we shall blend in ...",
		"... we shall join in the ways of the carp ...",
		"... grant us new clothing ...")
	invoke_msg = "So we can swim."
	favor_cost = 300
	var/obj/item/clothing/suit/chosen_clothing

/datum/religion_rites/summon_carpsuit/perform_rite(mob/living/user, atom/religious_tool)
	var/turf/T = get_turf(religious_tool)
	var/list/L = T.contents
	if(!locate(/obj/item/clothing/suit) in L)
		to_chat(user, span_warning("There is no suit clothing on the altar!"))
		return FALSE
	for(var/obj/item/clothing/suit/apparel in L)
		chosen_clothing = apparel //the apparel has been chosen by our lord and savior
		return ..()
	return FALSE

/datum/religion_rites/summon_carpsuit/invoke_effect(mob/living/user, atom/religious_tool)
	if(!QDELETED(chosen_clothing) && get_turf(religious_tool) == chosen_clothing.loc) //check if the same clothing is still there
		user.visible_message(span_notice("The [chosen_clothing] transforms!"))
		chosen_clothing.atom_destruction()
		chosen_clothing = null
		new /obj/item/clothing/suit/hooded/carp_costume/spaceproof/old(get_turf(religious_tool))
		playsound(get_turf(religious_tool), 'sound/effects/slosh.ogg', 50, TRUE)
		return ..()
	chosen_clothing = null
	to_chat(user, span_warning("The clothing that was chosen for the rite is no longer on the altar!"))
	return FALSE

/datum/religion_rites/flood_area
	name = "Flood Area"
	desc = "Flood the area with water vapor, great for learning to swim!"
	ritual_length = 25 SECONDS
	ritual_invocations = list(
		"We must swim ...",
		"... but to do so, we need water ...",
		"... grant us a great flood ...",
		"... soak us in your glory ...",
		"... we shall swim forever ...")
	invoke_msg = "... in our own personal ocean."
	favor_cost = 200

/datum/religion_rites/flood_area/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/open/T = get_turf(religious_tool)
	if(istype(T))
		T.atmos_spawn_air("water_vapor=5000;TEMP=255")
	return ..()
