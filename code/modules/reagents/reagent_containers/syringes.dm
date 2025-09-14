/obj/item/reagent_containers/syringe
	name = "syringe"
	desc = "A syringe that can hold up to 15 units."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	base_icon_state = "syringe"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	icon_state = "syringe_0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5, 10, 15)
	volume = 15
	/// needed for delayed drawing of blood
	var/busy = FALSE
	/// does it pierce through thick clothes when shot with syringe gun
	var/proj_piercing = FALSE
	/// standard flag (this var exists so we can inherit projectile penetration if parent is set to it)
	var/proj_var = INJECT_TRY_SHOW_ERROR_MESSAGE
	custom_materials = list(/datum/material/iron=10, /datum/material/glass=20)
	reagent_flags = TRANSPARENT
	var/list/datum/disease/syringe_diseases = list()
	var/units_per_tick = 1.5
	var/initial_inject = 5
	fill_icon_state = "syringe"
	fill_icon_thresholds = list(1, 5, 10, 15)

/obj/item/reagent_containers/syringe/attackby(obj/item/I, mob/user, params)
	return

/obj/item/reagent_containers/syringe/extrapolator_act(mob/living/user, obj/item/extrapolator/extrapolator, dry_run = FALSE)
	. = ..()
	EXTRAPOLATOR_ACT_ADD_DISEASES(., syringe_diseases)

/obj/item/reagent_containers/syringe/proc/transfer_diseases(mob/living/L)
	for(var/datum/disease/D in syringe_diseases)
		if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
			continue
		L.ForceContractDisease(D)
	for(var/datum/disease/D in L.diseases)
		if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
			continue
		syringe_diseases += D

/obj/item/reagent_containers/syringe/proc/try_syringe(atom/target, mob/user, proximity)
	if(busy)
		return FALSE
	if(!proximity)
		return FALSE
	if(!target.reagents)
		return FALSE

	if(isliving(target))
		var/mob/living/living_target = target
		//if(proj_piercing)
		//	proj_var = INJECT_TRY_SHOW_ERROR_MESSAGE
		if(!living_target.can_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE | (proj_piercing ? INJECT_CHECK_PENETRATE_THICK : 0)))
			return FALSE

	SEND_SIGNAL(target, COMSIG_LIVING_TRY_SYRINGE, user)
	return TRUE

/obj/item/reagent_containers/syringe/afterattack(atom/target, mob/user, proximity)
	. = ..()

	if (!try_syringe(target, user, proximity))
		return

	var/contained = reagents.log_list()
	log_combat(user, target, "attempted to inject", src, addition="which had [contained]")

	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty! Right-click to draw.</span>")
		return

	if(!isliving(target) && !target.is_injectable(user))
		to_chat(user, "<span class='warning'>You cannot directly fill [target]!</span>")
		return

	if(target.reagents.total_volume >= target.reagents.maximum_volume)
		to_chat(user, "<span class='notice'>[target] is full.</span>")
		return

	if(isliving(target))
		var/mob/living/living_target = target
		if(!living_target.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))
			return
		if(living_target != user)
			living_target.visible_message("<span class='danger'>[user] is trying to inject [living_target]!</span>", \
									"<span class='userdanger'>[user] is trying to inject you!</span>")
			if(!do_after(user, 3 SECONDS, living_target, extra_checks = CALLBACK(living_target, TYPE_PROC_REF(/mob/living, try_inject), user, null, INJECT_TRY_SHOW_ERROR_MESSAGE)))
				return
			if(!reagents.total_volume)
				return
			if(living_target.reagents.total_volume >= living_target.reagents.maximum_volume)
				return
			living_target.visible_message("<span class='danger'>[user] injects [living_target] with the syringe!</span>", \
							"<span class='userdanger'>[user] injects you with the syringe!</span>")

		if (living_target == user)
			living_target.log_message("injected themselves ([contained]) with [name]", LOG_ATTACK, color="orange")
		else
			log_combat(user, living_target, "injected", src, addition="which had [contained]")
	reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user, method = INJECT)
	to_chat(user, "<span class='notice'>You inject [amount_per_transfer_from_this] units of the solution. The syringe now contains [reagents.total_volume] units.</span>")
	target.update_appearance()

/obj/item/reagent_containers/syringe/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	if (!try_syringe(target, user, proximity_flag))
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	if(reagents.total_volume >= reagents.maximum_volume)
		to_chat(user, "<span class='notice'>[src] is full.</span>")
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	if(isliving(target))
		var/mob/living/living_target = target
		var/drawn_amount = reagents.maximum_volume - reagents.total_volume
		if(target != user)
			target.visible_message("<span class='danger'>[user] is trying to take a blood sample from [target]!</span>", \
							"<span class='userdanger'>[user] is trying to take a blood sample from you!</span>")
			busy = TRUE
			if(!do_after(user, 3 SECONDS, target, extra_checks = CALLBACK(living_target, TYPE_PROC_REF(/mob/living, try_inject), user, null, INJECT_TRY_SHOW_ERROR_MESSAGE)))
				busy = FALSE
				return SECONDARY_ATTACK_CONTINUE_CHAIN
			if(reagents.total_volume >= reagents.maximum_volume)
				return SECONDARY_ATTACK_CONTINUE_CHAIN
		busy = FALSE
		if(living_target.transfer_blood_to(src, drawn_amount))
			user.visible_message("<span class='notice'>[user] takes a blood sample from [living_target].</span>")
		else
			to_chat(user, "<span class='warning'>You are unable to draw any blood from [living_target]!</span>")
	else
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty!</span>")
			return SECONDARY_ATTACK_CONTINUE_CHAIN

		if(!target.is_drawable(user))
			to_chat(user, "<span class='warning'>You cannot directly remove reagents from [target]!</span>")
			return SECONDARY_ATTACK_CONTINUE_CHAIN

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user) // transfer from, transfer to - who cares?

		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the solution. It now contains [reagents.total_volume] units.</span>")

	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/item/reagent_containers/syringe/update_icon()
	cut_overlays()
	var/rounded_vol
	if(reagents?.total_volume)
		rounded_vol = clamp(round((reagents.total_volume / volume * 15),5), 1, 15)
		var/image/filling_overlay = mutable_appearance('icons/obj/reagentfillings.dmi', "syringe[rounded_vol]")
		filling_overlay.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling_overlay)
	else
		rounded_vol = 0
	icon_state = "[base_icon_state]_[rounded_vol]"
	item_state = "[base_icon_state]_[rounded_vol]"

/obj/item/reagent_containers/syringe/proc/embed(mob/living/carbon/C, injectmult = 1)
	C.apply_status_effect(/datum/status_effect/syringe, src, injectmult)
	forceMove(C)

/obj/item/reagent_containers/syringe/used
	name = "used syringe"
	desc = "A syringe that can hold up to 15 units. This one is old, and it's probably a bad idea to use it."

/obj/item/reagent_containers/syringe/used/Initialize(mapload)
	. = ..()
	if(prob(75))
		var/datum/disease/advance/R = new /datum/disease/advance/random(rand(3, 6), rand(7, 9), rand(3,4), infected = src)
		syringe_diseases += R

/obj/item/reagent_containers/syringe/epinephrine
	name = "syringe (epinephrine)"
	desc = "Contains epinephrine - used to stabilize patients."
	list_reagents = list(/datum/reagent/medicine/epinephrine = 15)

/obj/item/reagent_containers/syringe/charcoal
	name = "syringe (charcoal)"
	desc = "Contains charcoal."
	list_reagents = list(/datum/reagent/medicine/charcoal = 15)

/obj/item/reagent_containers/syringe/antitoxin
	name = "syringe (antitoxin)"
	desc = "Contains antitoxin."
	list_reagents = list(/datum/reagent/medicine/antitoxin = 15)

/obj/item/reagent_containers/syringe/diphenhydramine
	name = "syringe (diphenhydramine)"
	desc = "Contains diphenhydramine, an antihistamine agent."
	list_reagents = list(/datum/reagent/medicine/diphenhydramine = 15)

/obj/item/reagent_containers/syringe/calomel
	name = "syringe (calomel)"
	desc = "Contains calomel."
	list_reagents = list(/datum/reagent/medicine/calomel = 15)

/obj/item/reagent_containers/syringe/antiviral
	name = "syringe (spaceacillin)"
	desc = "Contains antiviral agents."
	list_reagents = list(/datum/reagent/medicine/spaceacillin = 15)

/obj/item/reagent_containers/syringe/bioterror
	name = "bioterror syringe"
	desc = "Contains several paralyzing reagents."
	list_reagents = list(/datum/reagent/consumable/ethanol/neurotoxin = 5, /datum/reagent/toxin/mutetoxin = 5, /datum/reagent/toxin/sodium_thiopental = 5)

/obj/item/reagent_containers/syringe/calomel
	name = "syringe (calomel)"
	desc = "Contains calomel."
	list_reagents = list(/datum/reagent/medicine/calomel = 15)

/obj/item/reagent_containers/syringe/plasma
	name = "syringe (plasma)"
	desc = "Contains plasma."
	list_reagents = list(/datum/reagent/toxin/plasma = 15)

/obj/item/reagent_containers/syringe/lethal
	name = "lethal injection syringe"
	desc = "A syringe used for lethal injections. It can hold up to 50 units."
	amount_per_transfer_from_this = 50
	has_variable_transfer_amount = FALSE
	volume = 50

/obj/item/reagent_containers/syringe/lethal/choral
	list_reagents = list(/datum/reagent/toxin/chloralhydrate = 50)

/obj/item/reagent_containers/syringe/lethal/execution
	list_reagents = list(/datum/reagent/toxin/plasma = 15, /datum/reagent/toxin/formaldehyde = 15, /datum/reagent/toxin/cyanide = 10, /datum/reagent/toxin/acid/fluacid = 10)

/obj/item/reagent_containers/syringe/mulligan
	name = "Mulligan"
	desc = "A syringe used to completely change the users identity."
	amount_per_transfer_from_this = 1
	has_variable_transfer_amount = FALSE
	volume = 1
	list_reagents = list(/datum/reagent/mulligan = 1)

/obj/item/reagent_containers/syringe/gluttony
	name = "Gluttony's Blessing"
	desc = "A syringe recovered from a dread place. It probably isn't wise to use."
	amount_per_transfer_from_this = 1
	has_variable_transfer_amount = FALSE
	volume = 1
	list_reagents = list(/datum/reagent/gluttonytoxin = 1)

/obj/item/reagent_containers/syringe/bluespace
	name = "bluespace syringe"
	desc = "An advanced syringe that can hold 60 units of chemicals."
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10, 20, 30, 40, 50, 60)
	icon_state = "bluespace_0"
	base_icon_state = "bluespace"
	volume = 60
	units_per_tick = 2
	initial_inject = 8

/obj/item/reagent_containers/syringe/cryo
	name = "cryo syringe"
	desc = "An advanced syringe that freezes reagents close to absolute 0. It can hold up to 20 units."
	icon_state = "cryo_0"
	base_icon_state = "cryo"
	volume = 20
	var/processing = FALSE
	fill_icon_state = null
	fill_icon_thresholds = null

/obj/item/reagent_containers/syringe/cryo/Destroy()
	if(processing)
		STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/item/reagent_containers/syringe/cryo/process(delta_time)
	reagents.chem_temp = 20

//Reactions are handled after this call.
/obj/item/reagent_containers/syringe/cryo/on_reagent_change()
	. = ..()
	if(reagents)
		if(reagents.total_volume)
			reagents.chem_temp = 20
			if(!processing)
				START_PROCESSING(SSfastprocess, src)
				processing = TRUE
			return
	if(processing)
		STOP_PROCESSING(SSfastprocess, src)
		processing = FALSE

/obj/item/reagent_containers/syringe/piercing
	name = "piercing syringe"
	desc = "A diamond-tipped syringe that pierces armor. It can hold up to 10 units."
	icon_state = "piercing_0"
	base_icon_state = "piercing"
	volume = 10
	possible_transfer_amounts = list(5, 10)
	proj_piercing = TRUE
	units_per_tick = 1
	initial_inject = 3

/obj/item/reagent_containers/syringe/crude
	name = "crude syringe"
	desc = "A crudely made syringe. The flimsy wooden construction makes it hold a minimal amount of reagents."
	icon_state = "crude_0"
	base_icon_state = "crude"
	volume = 5
	fill_icon_state = "syringe_crude"
	fill_icon_thresholds = list(5, 10, 15)
