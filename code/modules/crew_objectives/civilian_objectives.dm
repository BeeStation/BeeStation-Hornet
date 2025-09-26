/*				CIVILIAN OBJECTIVES			*/

/datum/objective/crew/druglordbot //ported from old Hippie with adjustments
	var/targetchem = "none"
	var/datum/reagent/chempath
	explanation_text = "Have at least (somethin broke here) harvested plants containing (report this on GitHub) when the shift ends."
	jobs = JOB_NAME_BOTANIST

/datum/objective/crew/druglordbot/New()
	. = ..()
	target_amount = rand(3,20)
	chempath = get_random_reagent_id(CHEMICAL_GOAL_BOTANIST_HARVEST)
	targetchem = chempath
	update_explanation_text()

/datum/objective/crew/druglordbot/update_explanation_text()
	. = ..()
	explanation_text = "Have at least [target_amount] harvested plants containing [initial(chempath.name)] when the shift ends."

/datum/objective/crew/druglordbot/check_completion()
	if(..())
		return TRUE
	if(!owner?.current?.contents)
		return FALSE
	var/pillcount = target_amount
	for(var/obj/item/food/grown/P in owner.current.get_contents())
		if(P.reagents.has_reagent(targetchem))
			pillcount--
	return pillcount <= 0

/datum/objective/crew/foodhoard
	var/datum/crafting_recipe/food/targetfood
	var/obj/item/food/foodpath
	explanation_text = "Personally deliver at least (Something broke, yell on GitHub) to CentCom."
	jobs = JOB_NAME_COOK

/datum/objective/crew/foodhoard/New()
	. = ..()
	target_amount = rand(2,10)
	var/blacklist = list(/datum/crafting_recipe/food, /datum/crafting_recipe/food/cak)
	var/possiblefoods = typesof(/datum/crafting_recipe/food) - blacklist
	targetfood = pick(possiblefoods)
	foodpath = initial(targetfood.result)
	update_explanation_text()

/datum/objective/crew/foodhoard/update_explanation_text()
	. = ..()
	explanation_text = "Personally deliver at least [target_amount] [initial(foodpath.name)]s to CentCom."

/datum/objective/crew/foodhoard/check_completion()
	return ..() || (owner?.current?.check_contents_for(foodpath) && SSshuttle.emergency.shuttle_areas[get_area(owner.current)])

/datum/objective/crew/cocktail
	explanation_text = "Have a bottle(any type) that contains 'something' when the shift ends. Each of them must be at least 'something'u."
	jobs = JOB_NAME_BARTENDER
	var/targetchems = list()
	var/list/chemnames = list()
	var/chemsize
	var/datum/reagent/chempath

/datum/objective/crew/cocktail/New()
	. = ..()
	for(var/i in 1 to 5)
		chempath = get_random_reagent_id(CHEMICAL_GOAL_BARTENDER_SERVING)
		if(!(chempath in targetchems))
			targetchems += chempath
			chemnames += "[initial(chempath.name)]"
	// chems may reaction, but there's no reactionable recipe from CHEMICAL_GOAL_BARTENDER_SERVING. Just don't put basic chems there.
	chemsize = 4+(5-length(targetchems))
	update_explanation_text()

/datum/objective/crew/cocktail/update_explanation_text()
	. = ..()
	explanation_text = "Have a bottle(any type) that contains '[english_list(chemnames, and_text = ", and ")]' when the shift ends. Each of them must be at least [chemsize]u."

/datum/objective/crew/cocktail/check_completion()
	if(..())
		return TRUE
	if(!owner?.current?.contents)
		return FALSE
	// check every bottle in your bag.
	for(var/obj/item/reagent_containers/B in owner.current.get_contents())
		var/count = length(targetchems) // a bottle should have the all desired chems. reset the count for every try.
		for(var/each in targetchems)
			if(B.reagents.has_reagent(each, chemsize))
				count--
				if(!count) // if it is legit, it completes.
					return TRUE
	return FALSE

/datum/objective/crew/clean //ported from old Hippie
	var/list/areas = list()
	var/hardmode = FALSE
	explanation_text = "Ensure sure that (Yo, something broke. Yell about this on GitHub.) remain spotless at the end of the shift."
	jobs = JOB_NAME_JANITOR

/datum/objective/crew/clean/New()
	. = ..()
	if(prob(1))
		hardmode = TRUE
	var/list/blacklistnormal = list(typesof(/area/space) - - typesof(/area/lavaland) - typesof(/area/mine) - typesof(/area/maintenance) - typesof(/area/ai_monitored/turret_protected) - typesof(/area/tcommsat))
	var/list/blacklisthard = list(typesof(/area/lavaland) - typesof(/area/mine))
	var/list/possibleareas = list()
	if(hardmode)
		possibleareas = GLOB.teleportlocs - /area - blacklisthard
	else
		possibleareas = GLOB.teleportlocs - /area - blacklistnormal
	for(var/i in 1 to rand(1,3))
		areas |= pick_n_take(possibleareas)
	if(hardmode)
		// this is so evil, this poor janitor does not deserve such suffering
		target_amount = rand(6 * areas.len, 14 * areas.len)
	else
		// be nice, because a lot of places start with a ton of cleanables, plus blood spreads super easily.
		target_amount = rand(12 * areas.len, 20 * areas.len)
	update_explanation_text()

/datum/objective/crew/clean/update_explanation_text()
	. = ..()
	explanation_text = "Ensure that"
	for(var/i in 1 to areas.len)
		var/area/A = areas[i]
		explanation_text += " [A]"
		if(i == areas.len - 1)
			explanation_text += " and"
		else if(areas.len >= 3 && i != areas.len)
			explanation_text += ","

	explanation_text += " [areas.len == 1 ? "has" : "have"] no more than [target_amount] cleanable feature\s (blood, ash, glitter, cobwebs, etc.) between them all at the end of the shift."
	if(hardmode)
		explanation_text += " Chop-chop."

/datum/objective/crew/clean/check_completion()
	if(..())
		return TRUE
	for(var/A in areas)
		var/area/check_area = GLOB.areas_by_type[A]
		var/cleanables = 0
		for(var/obj/effect/decal/cleanable/C in check_area.contents)
			cleanables++
		if(cleanables > target_amount)
			return FALSE
	return TRUE

/datum/objective/crew/exterminator
	explanation_text = "Ensure that there are no more than (Yell on github, this objective broke) living mice on the station when the round ends."
	jobs = JOB_NAME_JANITOR

/datum/objective/crew/exterminator/New()
	. = ..()
	target_amount = rand(2, 5)
	update_explanation_text()

/datum/objective/crew/exterminator/update_explanation_text()
	. = ..()
	explanation_text = "Ensure that there are no more than [target_amount] living mice on the station when the round ends."

/datum/objective/crew/exterminator/check_completion()
	if(..())
		return TRUE
	var/num_mice = 0
	for(var/mob/living/simple_animal/mouse/M in GLOB.alive_mob_list)
		if((M.z in SSmapping.levels_by_trait(ZTRAIT_STATION)))
			num_mice++
	return num_mice <= target_amount

/datum/objective/crew/lostkeys
	explanation_text = "Don't lose the janicart keys. Have them with you when the shift ends."
	jobs = JOB_NAME_JANITOR

/datum/objective/crew/lostkeys/check_completion()
	return ..() || owner?.current?.check_contents_for(/obj/item/key/janitor)

/datum/objective/crew/slipster //ported from old Hippie with adjustments
	explanation_text = "Slip at least (Yell on GitHub if you see this) different people with your PDA, and have it on you at the end of the shift."
	jobs = JOB_NAME_CLOWN

/datum/objective/crew/slipster/New()
	. = ..()
	target_amount = rand(5, 20)
	update_explanation_text()

/datum/objective/crew/slipster/update_explanation_text()
	. = ..()
	explanation_text = "Slip at least [target_amount] different people with your PDA, and have it on you at the end of the shift."

/datum/objective/crew/slipster/check_completion()
	if(..())
		return TRUE
	if(!owner?.current)
		return FALSE
	var/list/uniqueslips = list()
	for(var/obj/item/modular_computer/tablet/pda/preset/clown/PDA in owner.current.get_contents())
		for(var/H in PDA.slip_victims)
			uniqueslips |= H
	return length(uniqueslips) >= target_amount

/datum/objective/crew/shoethief
	explanation_text = "Steal at least (Yell on github, this objective broke) pairs of shoes, and have them in your bag at the end of the shift. Bonus points if they are stolen from crewmembers instead of ClothesMates."
	jobs = JOB_NAME_CLOWN

/datum/objective/crew/shoethief/New()
	. = ..()
	target_amount = rand(3, 5)
	update_explanation_text()

/datum/objective/crew/shoethief/update_explanation_text()
	. = ..()
	explanation_text = "Steal at least [target_amount] pair\s of shoes, and have them in your bag at the end of the shift. Bonus points if they are stolen from crewmembers instead of ClothesMates."

/datum/objective/crew/shoethief/check_completion()
	if(..())
		return TRUE
	if(!owner?.current)
		return FALSE
	var/list/shoes = list()
	for(var/obj/item/clothing/shoes/S in owner.current.get_contents())
		if(!istype(S, /obj/item/clothing/shoes/clown_shoes))
			shoes |= S
	return length(shoes) >= target_amount

/datum/objective/crew/vow
	explanation_text = "Never break your vow of silence."
	jobs = JOB_NAME_MIME
	/// This is set to TRUE when the mime's vow action is used to break the vow.
	var/broken = FALSE

/datum/objective/crew/vow/check_completion()
	return !broken

/datum/objective/crew/nothingreallymatterstome
	explanation_text = "Have a Bottle of Nothing with you at the end of the shift."
	jobs = JOB_NAME_MIME

/datum/objective/crew/nothingreallymatterstome/check_completion()
	return ..() || owner?.current?.check_contents_for(/obj/item/reagent_containers/cup/glass/bottle/bottleofnothing)

/datum/objective/crew/nullrod
	explanation_text = "Don't lose your nullrod. You can still transform it into another item."
	jobs = JOB_NAME_CHAPLAIN

/datum/objective/crew/nullrod/check_completion()
	if(..())
		return TRUE
	if(!owner?.current)
		return FALSE
	for(var/nullrodtypes in typesof(/obj/item/nullrod))
		if(owner.current.check_contents_for(nullrodtypes))
			return TRUE
	return FALSE

/datum/objective/crew/reporter //ported from old hippie
	var/word_count = 10
	explanation_text = "Publish at least (Yo something broke) articles containing at least (Report this on GitHub) words."
	jobs = JOB_NAME_CURATOR

/datum/objective/crew/reporter/New()
	. = ..()
	target_amount = rand(2,8)
	word_count = rand(5,30)
	update_explanation_text()

/datum/objective/crew/reporter/update_explanation_text()
	. = ..()
	explanation_text = "Publish at least [target_amount] articles containing at least [word_count] words."

/datum/objective/crew/reporter/check_completion()
	if(..())
		return TRUE
	for(var/datum/feed_channel/channel in GLOB.news_network.network_channels)
		for(var/datum/feed_message/message in channel.messages)
			if(!istype(message.author_account, /datum/bank_account))
				continue
			if(message.author_account.account_id == owner.account_id)
				if(length(splittext(message.return_body(), " ")) >= word_count)
					target_amount--
	return target_amount <= 0

/datum/objective/crew/pwrgame //ported from Goon with adjustments
	var/obj/item/clothing/clothing_target
	explanation_text = "Get your grubby hands on a (Dear god something broke. Report this on GitHub)."
	jobs = JOB_NAME_ASSISTANT

/datum/objective/crew/pwrgame/New()
	. = ..()
	var/list/possible_targets = list(/obj/item/clothing/mask/gas, /obj/item/clothing/head/utility/welding, /obj/item/clothing/head/costume/ushanka, /obj/item/clothing/gloves/color/yellow, /obj/item/clothing/mask/gas/owl_mask)
	if(prob(10))
		possible_targets += list(/obj/item/clothing/suit/space)
	clothing_target = pick(possible_targets)
	update_explanation_text()

/datum/objective/crew/pwrgame/update_explanation_text()
	. = ..()
	explanation_text = "Get your grubby hands on a [initial(clothing_target.name)]."

/datum/objective/crew/pwrgame/check_completion()
	if(..())
		return TRUE
	if(!owner?.current)
		return FALSE
	for(var/search_subtype in typesof(clothing_target))
		if(owner.current.check_contents_for(search_subtype))
			return TRUE
	return FALSE

/datum/objective/crew/promotion //ported from Goon
	explanation_text = "Have a non-assistant ID registered to you at the end of the shift."
	jobs = JOB_NAME_ASSISTANT

/datum/objective/crew/promotion/check_completion()
	if(..())
		return TRUE
	var/mob/living/carbon/human/H = owner?.current
	if(!istype(H))
		return FALSE
	var/obj/item/card/id/theID = H.get_idcard()
	if(!istype(theID))
		return FALSE
	if(!(H.get_assignment() == JOB_NAME_ASSISTANT) && !(H.get_assignment() == "No id") && !(H.get_assignment() == "No job"))
		return TRUE
	if(theID.hud_state != JOB_HUD_ASSISTANT) // non-assistant HUD counts too
		return TRUE
	return FALSE

/datum/objective/crew/justicecrew
	explanation_text = "Ensure there are no members of security in the prison wing when the shift ends."
	jobs = JOB_NAME_LAWYER

/datum/objective/crew/justicecrew/check_completion()
	if(..())
		return TRUE
	if(!owner?.current)
		return FALSE
	for(var/datum/mind/M in SSticker.minds)
		if(!istype(M.current) || !(M.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY)))
			continue
		if(istype(get_area(M.current), /area/security/prison))
			return FALSE
	return TRUE
