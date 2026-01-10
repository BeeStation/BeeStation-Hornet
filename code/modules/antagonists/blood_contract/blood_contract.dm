/datum/antagonist/blood_contract
	name = "Blood Contract Target"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	var/duration = 2 MINUTES
	banning_key = UNBANNABLE_ANTAGONIST
	leave_behaviour = ANTAGONIST_LEAVE_DESPAWN

/datum/antagonist/blood_contract/on_gain()
	. = ..()
	give_objective()
	start_the_hunt()

/datum/antagonist/blood_contract/proc/give_objective()
	var/datum/objective/survive/survive = new
	survive.owner = owner
	objectives += survive
	log_objective(owner, survive.explanation_text)

/datum/antagonist/blood_contract/greet()
	. = ..()
	to_chat(owner, span_userdanger("You've been marked for death! Don't let the demons get you! KILL THEM ALL!"))
	owner.current.client?.tgui_panel?.give_antagonist_popup("Blood Contract",
		"You have been marked for death, the demons thirst for your blood. KILL THEM ALL.")

/datum/antagonist/blood_contract/proc/start_the_hunt()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return

	H.add_atom_colour("#FF0000", ADMIN_COLOUR_PRIORITY)

	var/obj/effect/mine/pickup/bloodbath/B = new(H)
	B.duration = duration

	INVOKE_ASYNC(B, TYPE_PROC_REF(/obj/effect/mine/pickup/bloodbath, mineEffect), H) //could use moving out from the mine

	for(var/mob/living/carbon/human/P in GLOB.player_list)
		if(P == H)
			continue
		log_game("[key_name(P)] was selected to kill [key_name(H)] by blood contract") // holy shit why is there no antag datum. I'm doing a huge refactor so I don't have time for one but I had to add this log here
		to_chat(P, span_userdanger("You have an overwhelming desire to kill [H]. [H.p_Theyve()] been marked red! Whoever [H.p_they()] [H.p_were()], friend or foe, go kill [H.p_them()]!"))

		var/obj/item/I = new /obj/item/knife/butcher(get_turf(P))
		P.put_in_hands(I, del_on_fail=TRUE)
		QDEL_IN(I, duration)
