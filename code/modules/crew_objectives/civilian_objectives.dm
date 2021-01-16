/*				CIVILIAN OBJECTIVES			*/

/datum/objective/crew/druglordbot //ported from old Hippie with adjustments
	var/targetchem = "none"
	var/datum/reagent/chempath
	explanation_text = "Have at least (somethin broke here) harvested plants containing (report this on GitHub) when the shift ends."
	jobs = "botanist"

/datum/objective/crew/druglordbot/New()
	. = ..()
	target_amount = rand(3,20)
	var/blacklist = list(/datum/reagent/drug, /datum/reagent/consumable/menthol, /datum/reagent/medicine, /datum/reagent/medicine/adminordrazine, /datum/reagent/medicine/mine_salve, /datum/reagent/medicine/syndicate_nanites, /datum/reagent/medicine/strange_reagent, /datum/reagent/medicine/changelingadrenaline)
	var/drugs = typesof(/datum/reagent/drug) - blacklist
	var/meds = typesof(/datum/reagent/medicine) - blacklist
	var/chemlist = drugs + meds
	chempath = pick(chemlist)
	targetchem = chempath
	update_explanation_text()

/datum/objective/crew/druglordbot/update_explanation_text()
	. = ..()
	explanation_text = "Have at least [target_amount] harvested plants containing [initial(chempath.name)] when the shift ends."

/datum/objective/crew/druglordbot/check_completion()
	var/pillcount = target_amount
	if(owner?.current)
		if(owner.current.contents)
			for(var/obj/item/reagent_containers/food/snacks/grown/P in owner.current.get_contents())
				if(P.reagents.has_reagent(targetchem))
					pillcount--
	if(pillcount <= 0)
		return TRUE
	else
		return FALSE

/datum/objective/crew/foodhoard
	var/datum/crafting_recipe/food/targetfood
	var/obj/item/reagent_containers/food/foodpath
	explanation_text = "Personally deliver at least (Something broke, yell on GitHub) to CentCom."
	jobs = "cook"

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
	if(owner.current && owner.current.check_contents_for(foodpath) && SSshuttle.emergency.shuttle_areas[get_area(owner.current)])
		return TRUE
	else
		return FALSE

/datum/objective/crew/responsibility
	explanation_text = "Make sure nobody dies with alcohol poisoning."
	jobs = "bartender"

/datum/objective/crew/responsibility/check_completion()
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.stat == DEAD && H.drunkenness >= 80)
			if((H.z in SSmapping.levels_by_trait(ZTRAIT_STATION)) || SSshuttle.emergency.shuttle_areas[get_area(H)])
				return FALSE
	return TRUE

/datum/objective/crew/clean //ported from old Hippie
	var/list/areas = list()
	var/hardmode = FALSE
	explanation_text = "Ensure sure that (Yo, something broke. Yell about this on GitHub.) remain spotless at the end of the shift."
	jobs = "janitor"

/datum/objective/crew/clean/New()
	. = ..()
	if(prob(1))
		hardmode = TRUE
	var/list/blacklistnormal = list(typesof(/area/space) - typesof(/area/lavaland) - typesof(/area/mine) - typesof(/area/ai_monitored/turret_protected) - typesof(/area/tcommsat))
	var/list/blacklisthard = list(typesof(/area/lavaland) - typesof(/area/mine))
	var/list/possibleareas = list()
	if(hardmode)
		possibleareas = GLOB.teleportlocs - /area - blacklisthard
	else
		possibleareas = GLOB.teleportlocs - /area - blacklistnormal
	for(var/i in 1 to rand(1,6))
		areas |= pick_n_take(possibleareas)
	update_explanation_text()

/datum/objective/crew/clean/update_explanation_text()
	. = ..()
	explanation_text = "Ensure that the"
	for(var/i in 1 to areas.len)
		var/area/A = areas[i]
		explanation_text += " [A]"
		if(i != areas.len && areas.len >= 3)
			explanation_text += ","
		if(i == areas.len - 1)
			explanation_text += "and"
	explanation_text += " [(areas.len ==1) ? "is completely" : "are [(areas.len == 2) ? "completely" : "all"]"] clean at the end of the shift."
	if(hardmode)
		explanation_text += " Chop-chop."

/datum/objective/crew/clean/check_completion()
	for(var/area/A in areas)
		for(var/obj/effect/decal/cleanable/C in A.contents)
			return FALSE
	return TRUE

/datum/objective/crew/exterminator
	explanation_text = "Ensure that there are no more than (Yell on github, this objective broke) living mice on the station when the round ends."
	jobs = "janitor"

/datum/objective/crew/exterminator/New()
	. = ..()
	target_amount = rand(2, 5)
	update_explanation_text()

/datum/objective/crew/exterminator/update_explanation_text()
	. = ..()
	explanation_text = "Ensure that there are no more than [target_amount] living mice on the station when the round ends."

/datum/objective/crew/exterminator/check_completion()
	var/num_mice = 0
	for(var/mob/living/simple_animal/mouse/M in GLOB.alive_mob_list)
		if((M.z in SSmapping.levels_by_trait(ZTRAIT_STATION)))
			num_mice++
	if(num_mice <= target_amount)
		return TRUE
	return FALSE

/datum/objective/crew/lostkeys
	explanation_text = "Don't lose the janicart keys. Have them with you when the shift ends."
	jobs = "janitor"

/datum/objective/crew/lostkeys/check_completion()
	if(owner && owner.current && owner.current.check_contents_for(/obj/item/key/janitor))
		return TRUE
	return FALSE

/datum/objective/crew/slipster //ported from old Hippie with adjustments
	explanation_text = "Slip at least (Yell on GitHub if you see this) different people with your PDA, and have it on you at the end of the shift."
	jobs = "clown"

/datum/objective/crew/slipster/New()
	. = ..()
	target_amount = rand(5, 20)
	update_explanation_text()

/datum/objective/crew/slipster/update_explanation_text()
	. = ..()
	explanation_text = "Slip at least [target_amount] different people with your PDA, and have it on you at the end of the shift."

/datum/objective/crew/slipster/check_completion()
	var/list/uniqueslips = list()
	if(owner?.current)
		for(var/obj/item/pda/clown/PDA in owner.current.get_contents())
			for(var/mob/living/carbon/human/H in PDA.slipvictims)
				uniqueslips |= H
	if(uniqueslips.len >= target_amount)
		return TRUE
	else
		return FALSE

/datum/objective/crew/shoethief
	explanation_text = "Steal at least (Yell on github, this objective broke) pairs of shoes, and have them in your bag at the end of the shift. Bonus points if they are stolen from crewmembers instead of ClothesMates."
	jobs = "clown"

/datum/objective/crew/shoethief/New()
	. = ..()
	target_amount = rand(3, 5)
	update_explanation_text()

/datum/objective/crew/shoethief/update_explanation_text()
	. = ..()
	explanation_text = "Steal at least [target_amount] pair\s of shoes, and have them in your bag at the end of the shift. Bonus points if they are stolen from crewmembers instead of ClothesMates."

/datum/objective/crew/shoethief/check_completion()
	var/list/shoes = list()
	if(owner?.current)
		for(var/obj/item/clothing/shoes/S in owner.current.get_contents())
			if(!istype(S, /obj/item/clothing/shoes/clown_shoes))
				shoes |= S
	if(shoes.len >= target_amount)
		return TRUE
	return FALSE

/datum/objective/crew/vow //ported from old Hippie
	explanation_text = "Never break your vow of silence."
	jobs = "mime"

/datum/objective/crew/vow/check_completion()
	if(owner?.current)
		var/list/say_log = owner.current.logging[INDIVIDUAL_SAY_LOG]
		if(say_log.len > 0)
			return FALSE
	return TRUE

/datum/objective/crew/nothingreallymatterstome
	explanation_text = "Have a Bottle of Nothing with you at the end of the shift."
	jobs = "mime"

/datum/objective/crew/nothingreallymatterstome/check_completion()
	if(owner && owner.current && owner.current.check_contents_for(/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing))
		return TRUE
	return FALSE

/datum/objective/crew/nullrod
	explanation_text = "Don't lose your nullrod. You can still transform it into another item."
	jobs = "chaplain"

/datum/objective/crew/nullrod/check_completion()
	if(owner?.current)
		for(var/nullrodtypes in typesof(/obj/item/nullrod))
			if(owner.current.check_contents_for(nullrodtypes))
				return TRUE
	return FALSE

/datum/objective/crew/reporter //ported from old hippie
	var/charcount = 100
	explanation_text = "Publish at least (Yo something broke) articles containing at least (Report this on GitHub) characters."
	jobs = "curator"

/datum/objective/crew/reporter/New()
	. = ..()
	target_amount = rand(2,10)
	charcount = rand(20,250)
	update_explanation_text()

/datum/objective/crew/reporter/update_explanation_text()
	. = ..()
	explanation_text = "Publish at least [target_amount] articles containing at least [charcount] characters."

/datum/objective/crew/reporter/check_completion()
	if(owner?.current)
		var/ownername = "[ckey(owner.current.real_name)][ckey(owner.assigned_role)]"
		for(var/datum/newscaster/feed_channel/chan in GLOB.news_network.network_channels)
			for(var/datum/newscaster/feed_message/msg in chan.messages)
				if(ckey(msg.returnAuthor()) == ckey(ownername))
					if(length(msg.returnBody()) >= charcount)
						target_amount--
	if(target_amount <= 0)
		return TRUE
	else
		return FALSE

/datum/objective/crew/pwrgame //ported from Goon with adjustments
	var/obj/item/clothing/targettidegarb
	explanation_text = "Get your grubby hands on a (Dear god something broke. Report this on GitHub)."
	jobs = "assistant"

/datum/objective/crew/pwrgame/New()
	. = ..()
	var/list/muhvalids = list(/obj/item/clothing/mask/gas, /obj/item/clothing/head/welding, /obj/item/clothing/head/ushanka, /obj/item/clothing/gloves/color/yellow, /obj/item/clothing/mask/gas/owl_mask)
	if(prob(10))
		muhvalids += list(/obj/item/clothing/suit/space)
	targettidegarb = pick(muhvalids)
	update_explanation_text()

/datum/objective/crew/pwrgame/update_explanation_text()
	. = ..()
	explanation_text = "Get your grubby hands on a [initial(targettidegarb.name)]."

/datum/objective/crew/pwrgame/check_completion()
	if(owner?.current)
		for(var/tidegarbtypes in typesof(targettidegarb))
			if(owner.current.check_contents_for(tidegarbtypes))
				return TRUE

	return FALSE

/datum/objective/crew/promotion //ported from Goon
	explanation_text = "Have a non-assistant ID registered to you at the end of the shift."
	jobs = "assistant"

/datum/objective/crew/promotion/check_completion()
	if(owner?.current)
		var/mob/living/carbon/human/H = owner.current
		var/obj/item/card/id/theID = H.get_idcard()
		if(istype(theID))
			if(!(H.get_assignment() == "Assistant") && !(H.get_assignment() == "No id") && !(H.get_assignment() == "No job"))
				return TRUE
	return FALSE

/datum/objective/crew/justicecrew
	explanation_text = "Ensure there are no members of security in the prison wing when the shift ends."
	jobs = "lawyer"

/datum/objective/crew/justicecrew/check_completion()
	if(owner?.current)
		for(var/datum/mind/M in SSticker.minds)
			if(M.current && isliving(M.current))
				if(!M.special_role && !(M.assigned_role == "Security Officer") && !(M.assigned_role == "Detective") && !(M.assigned_role == "Head of Security") && !(M.assigned_role == "Internal Affairs Agent") && !(M.assigned_role == "Warden") && get_area(M.current) != typesof(/area/security/prison))
					return FALSE
		return TRUE
