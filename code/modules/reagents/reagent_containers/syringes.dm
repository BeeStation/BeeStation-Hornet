#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1

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
	possible_transfer_amounts = list()
	volume = 15
	var/mode = SYRINGE_DRAW
	var/busy = FALSE		// needed for delayed drawing of blood
	var/proj_piercing = 0 //does it pierce through thick clothes when shot with syringe gun
	materials = list(/datum/material/iron=10, /datum/material/glass=20)
	reagent_flags = TRANSPARENT
	var/list/datum/disease/syringe_diseases = list()
	var/units_per_tick = 1.5
	var/initial_inject = 5
	fill_icon_state = "syringe"
	fill_icon_thresholds = list(1, 5, 10, 15)

/obj/item/reagent_containers/syringe/Initialize(mapload)
	. = ..()
	if(list_reagents) //syringe starts in inject mode if its already got something inside
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/reagent_containers/syringe/on_reagent_change(changetype)
	update_icon()

/obj/item/reagent_containers/syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/syringe/attack_self(mob/user)
	mode = !mode
	update_icon()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/reagent_containers/syringe/attack_hand()
	. = ..()
	update_icon()

/obj/item/reagent_containers/syringe/attack_paw(mob/user)
	return attack_hand(user)

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

/obj/item/reagent_containers/syringe/afterattack(atom/target, mob/user , proximity)
	. = ..()
	if(busy)
		return
	if(!proximity)
		return
	if(!target.reagents)
		return

	var/mob/living/L
	if(isliving(target))
		L = target
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(!H.can_inject(user, TRUE, penetrate_thick = proj_piercing))
				return
		else if(!L.can_inject(user, TRUE))
			return

	SEND_SIGNAL(target, COMSIG_LIVING_TRY_SYRINGE, user)

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.total_volume >= reagents.maximum_volume)
				balloon_alert(user, "The [src] is full!")
				return

			if(L) //living mob
				var/drawn_amount = reagents.maximum_volume - reagents.total_volume
				if(target != user)
					target.visible_message("<span class='danger'>[user] is trying to take a blood sample from [target]!</span>", \
									"<span class='userdanger'>[user] is trying to take a blood sample from you!</span>")
					busy = TRUE
					if(!do_after(user, target = target, extra_checks=CALLBACK(L, TYPE_PROC_REF(/mob/living, can_inject), user, TRUE)))
						busy = FALSE
						return
					if(reagents.total_volume >= reagents.maximum_volume)
						return
				busy = FALSE
				if(L.transfer_blood_to(src, drawn_amount))
					user.visible_message("[user] takes a blood sample from [L].")
				else
					to_chat(user, "<span class='warning'>You are unable to draw any blood from [L]!</span>")
					balloon_alert(user, "You are unable to draw any blood from [L]!")
				transfer_diseases(L)

			else //if not mob
				if(!target.reagents.total_volume)
					balloon_alert(user, "[src] is empty.")
					return

				if(!target.is_drawable(user))
					balloon_alert(user, "You can't seem to draw reagents from this..")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user) // transfer from, transfer to - who cares?

				to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the solution. It now contains [reagents.total_volume] units.</span>")
				balloon_alert(user, "You fill [src] with [trans]u.")
			if (reagents.total_volume >= reagents.maximum_volume)
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			// Always log attemped injections for admins
			var/contained = reagents.log_list()
			log_combat(user, target, "attempted to inject", src, addition="which had [contained]")

			if(!reagents.total_volume)
				balloon_alert(user, "[src] is empty!")
				return

			if(!L && !target.is_injectable(user)) //only checks on non-living mobs, due to how can_inject() handles
				balloon_alert(user, "You cannot inject [target].")
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				balloon_alert(user, "[target] is full.")
				return

			if(L) //living mob
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					if(!H.can_inject(user, TRUE, penetrate_thick = proj_piercing))
						return
				else if(!L.can_inject(user, TRUE))
					return
				if(user.a_intent == INTENT_HARM && iscarbon(L) && iscarbon(user))
					L.visible_message("<span class='danger'>[user] lines a syringe up to [L]!", \
							"<span class='userdanger'>[user] rears their arm back, ready to stab you with [src]</span>")
					if(do_after(user, 1 SECONDS, L))
						var/mob/living/carbon/C = L
						embed(C, 0.5)
						log_combat(user, C, "injected (embedding)", src, addition="which had [contained]")
						L.visible_message("<span class='danger'>[user] stabs [L] with the syringe!", \
							"<span class='userdanger'>[user] shoves the syringe into your flesh, and it sticks!</span>")
						return
					return
				if(L != user)
					L.visible_message("<span class='danger'>[user] is trying to inject [L]!</span>", \
											"<span class='userdanger'>[user] is trying to inject you!</span>")
					if(!do_after(user, target = L, extra_checks=CALLBACK(L, TYPE_PROC_REF(/mob/living, can_inject), user, TRUE)))
						return
					if(!reagents.total_volume)
						return
					if(L.reagents.total_volume >= L.reagents.maximum_volume)
						return
					L.visible_message("<span class='danger'>[user] injects [L] with the syringe!", \
									"<span class='userdanger'>[user] injects you with the syringe!</span>")

				if(L != user)
					log_combat(user, L, "injected", src, addition="which had [contained]")
				else
					L.log_message("injected themselves ([contained]) with [src.name]", LOG_ATTACK, color="orange")
				transfer_diseases(L)
			var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
			reagents.reaction(L, INJECT, fraction)
			reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
			balloon_alert(user, "You inject [amount_per_transfer_from_this]u.")
			to_chat(user, "<span class='notice'>You inject [amount_per_transfer_from_this] units of the solution. The syringe now contains [reagents.total_volume] units.</span>")
			if (reagents.total_volume <= 0 && mode==SYRINGE_INJECT)
				mode = SYRINGE_DRAW
				update_icon()


/obj/item/reagent_containers/syringe/update_icon()
	cut_overlays()
	var/rounded_vol
	if(reagents?.total_volume)
		rounded_vol = CLAMP(round((reagents.total_volume / volume * 15),5), 1, 15)
		var/image/filling_overlay = mutable_appearance('icons/obj/reagentfillings.dmi', "syringe[rounded_vol]")
		filling_overlay.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling_overlay)
	else
		rounded_vol = 0
	icon_state = "[base_icon_state]_[rounded_vol]"
	item_state = "[base_icon_state]_[rounded_vol]"
	if(ismob(loc))
		var/mob/M = loc
		var/injoverlay
		switch(mode)
			if (SYRINGE_DRAW)
				injoverlay = "draw"
			if (SYRINGE_INJECT)
				injoverlay = "inject"
		add_overlay(injoverlay)
		M.update_inv_hands()

/obj/item/reagent_containers/syringe/proc/embed(mob/living/carbon/C, injectmult = 1)
	C.apply_status_effect(STATUS_EFFECT_SYRINGE, src, injectmult)
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
	volume = 50

/obj/item/reagent_containers/syringe/lethal/choral
	list_reagents = list(/datum/reagent/toxin/chloralhydrate = 50)

/obj/item/reagent_containers/syringe/lethal/execution
	list_reagents = list(/datum/reagent/toxin/plasma = 15, /datum/reagent/toxin/formaldehyde = 15, /datum/reagent/toxin/cyanide = 10, /datum/reagent/toxin/acid/fluacid = 10)

/obj/item/reagent_containers/syringe/mulligan
	name = "Mulligan"
	desc = "A syringe used to completely change the users identity."
	amount_per_transfer_from_this = 1
	volume = 1
	list_reagents = list(/datum/reagent/mulligan = 1)

/obj/item/reagent_containers/syringe/gluttony
	name = "Gluttony's Blessing"
	desc = "A syringe recovered from a dread place. It probably isn't wise to use."
	amount_per_transfer_from_this = 1
	volume = 1
	list_reagents = list(/datum/reagent/gluttonytoxin = 1)

/obj/item/reagent_containers/syringe/bluespace
	name = "bluespace syringe"
	desc = "An advanced syringe that can hold 60 units of chemicals."
	amount_per_transfer_from_this = 20
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
	proj_piercing = 1
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

#undef SYRINGE_DRAW
#undef SYRINGE_INJECT
