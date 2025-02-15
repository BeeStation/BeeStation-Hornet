/datum/vampire_clan/tremere
	name = CLAN_TREMERE
	description = "The Tremere Clan is extremely weak to True Faith, and will burn when entering areas considered such, like the Chapel. \n\
		Additionally, a whole new moveset is learned, built on Blood magic rather than Blood abilities, which are upgraded overtime. \n\
		More ranks can be gained by Vassalizing crewmembers. \n\
		The Favorite Vassal gains the ability to morph themselves into a bat at will."
	clan_objective = /datum/objective/vampire/tremere_power
	join_icon_state = "tremere"
	join_description = "You will burn if you enter the Chapel, lose all default powers, \
		but gain Blood Magic instead, powers you level up overtime."

/datum/vampire_clan/tremere/New(mob/living/carbon/user)
	. = ..()
	vampiredatum.remove_nondefault_powers(return_levels = TRUE)
	for(var/datum/action/cooldown/vampire/power as anything in vampiredatum.all_vampire_powers)
		if((initial(power.purchase_flags) & TREMERE_CAN_BUY) && initial(power.level_current) == 1)
			vampiredatum.BuyPower(new power)

/datum/vampire_clan/tremere/Destroy(force)
	for(var/datum/action/cooldown/vampire/power in vampiredatum.powers)
		if(power.purchase_flags & TREMERE_CAN_BUY)
			vampiredatum.RemovePower(power)
	return ..()

/datum/vampire_clan/tremere/handle_clan_life(datum/antagonist/vampire/source)
	. = ..()
	var/area/current_area = get_area(vampiredatum.owner.current)
	if(istype(current_area, /area/chapel))
		to_chat(vampiredatum.owner.current, span_warning("You don't belong in holy areas! The Faith burns you!"))
		vampiredatum.owner.current.adjustFireLoss(10)
		vampiredatum.owner.current.adjust_fire_stacks(2)
		vampiredatum.owner.current.IgniteMob()

/datum/vampire_clan/tremere/spend_rank(datum/antagonist/vampire/source, mob/living/carbon/target, cost_rank = TRUE, blood_cost)
	// Purchase Power Prompt
	var/list/options = list()
	for(var/datum/action/cooldown/vampire/targeted/tremere/power as anything in vampiredatum.powers)
		if(!(power.purchase_flags & TREMERE_CAN_BUY))
			continue
		if(isnull(power.upgraded_power))
			continue
		options[initial(power.name)] = power

	if(options.len < 1)
		to_chat(vampiredatum.owner.current, span_notice("You grow more ancient by the night!"))
	else
		// Give them the UI to purchase a power.
		var/choice = tgui_input_list(vampiredatum.owner.current, "You have the opportunity to grow more ancient. Select a power you wish to upgrade.", "Your Blood Thickens...", options)
		// Prevent Vampires from closing/reopning their coffin to spam Levels.
		if(cost_rank && vampiredatum.vampire_level_unspent <= 0)
			return
		// Did you choose a power?
		if(!choice || !options[choice])
			to_chat(vampiredatum.owner.current, span_notice("You prevent your blood from thickening just yet, but you may try again later."))
			return
		// Prevent Vampires from purchasing a power while outside of their Coffin.
		if(!istype(vampiredatum.owner.current.loc, /obj/structure/closet/crate/coffin))
			to_chat(vampiredatum.owner.current, span_warning("You must be in your Coffin to purchase Powers."))
			return

		// Good to go - Buy Power!
		var/datum/action/cooldown/vampire/purchased_power = options[choice]
		var/datum/action/cooldown/vampire/targeted/tremere/tremere_power = purchased_power
		if(isnull(tremere_power.upgraded_power))
			vampiredatum.owner.current.balloon_alert(vampiredatum.owner.current, "cannot upgrade [choice]!")
			to_chat(vampiredatum.owner.current, span_notice("[choice] is already at max level!"))
			return
		vampiredatum.BuyPower(new tremere_power.upgraded_power)
		vampiredatum.RemovePower(tremere_power)
		vampiredatum.owner.current.balloon_alert(vampiredatum.owner.current, "upgraded [choice]!")
		to_chat(vampiredatum.owner.current, span_notice("You have upgraded [choice]!"))

	finalize_spend_rank(vampiredatum, cost_rank, blood_cost)

/datum/vampire_clan/tremere/on_favorite_vassal(datum/antagonist/vampire/source, datum/antagonist/vassal/vassaldatum)
	var/datum/action/spell/shapeshift/bat/batform = new
	batform.Grant(vassaldatum.owner.current)

/datum/vampire_clan/tremere/on_vassal_made(datum/antagonist/vampire/source, mob/living/user, mob/living/target)
	..()
	to_chat(vampiredatum.owner.current, span_danger("You have now gained an additional Rank to spend!"))
	vampiredatum.vampire_level_unspent++

// Batform for special vassals
/datum/action/spell/shapeshift/bat
	name = "Bat Form"
	desc = "Take on the shape a space bat."
	invocation = "SQUEAAAAK!"
	cooldown_time = 5 SECONDS
	convert_damage = FALSE
	possible_shapes = list(/mob/living/simple_animal/hostile/retaliate/bat/vampire)
