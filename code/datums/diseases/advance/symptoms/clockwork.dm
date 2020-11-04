/datum/symptom/robotic_adaptation
	name = "Biometallic Replication"
	desc = "The virus can manipulate metal and silicate compounds, becoming able to infect robotic beings. The virus also provides a suitable substrate for nanites in otherwise inhospitable hosts"
	stealth = 0
	resistance = 1
	stage_speed = 4 //while the reference material has low speed, this virus will take a good while to completely convert someone
	transmittable = -1
	level = 9
	severity = 0
	symptom_delay_min = 10
	symptom_delay_max = 60
	var/replaceorgans = FALSE
	var/replacebody = FALSE
	var/robustbits = FALSE
	threshold_desc = "<b>Stage Speed 4:</b>The virus will replace the host's organic organs with mundane, biometallic versions. +1 severity.<br>\
                      <b>Stage Speed 10:</b>The virus will eventually convert the host's entire body to biometallic materials, and maintain its cellular integrity. +1 severity.<br>\
                      <b>Stage Speed 13:</b>Biometallic mass created by the virus will be superior to typical organic mass. -3 severity."

/datum/symptom/robotic_adaptation/OnAdd(datum/disease/advance/A)
	A.infectable_biotypes |= MOB_ROBOTIC

/datum/symptom/robotic_adaptation/severityset(datum/disease/advance/A)
	. = ..()
	if(A.properties["stage_rate"] >= 5) //at base level, robotic organs are purely a liability
		severity += 1
	if(A.properties["stage_rate"] >= 10)//at base level, robotic bodyparts have very few bonuses, mostly being a liability in the case of EMPS
		severity += 1 //at this stage, even one EMP will hurt, a lot.
	if(A.properties["stage_rate"] >= 13)//but at this threshold, it all becomes worthwhile, though getting augged is a better choice
		severity -= 3//net benefits: 2 damage reduction, flight if you have wings, filter out low amounts of gas, durable ears, flash protection, a liver half as good as an upgraded cyberliver, and flight if you are a winged species

/datum/symptom/robotic_adaptation/Start(datum/disease/advance/A)
	. = ..()
	if(A.properties["stage_rate"] >= 4)
		replaceorgans = TRUE
	if(A.properties["stage_rate"] >= 10)
		replacebody = TRUE
	if(A.properties["stage_rate"] >= 14)
		robustbits = TRUE //note that having this symptom means most healing symptoms won't work on you

/datum/symptom/robotic_adaptation/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/human/H = A.affected_mob
	switch(A.stage)
		if(3, 4)
			if(replaceorgans)
				to_chat(H, "<span class='warning'><b>[pick("You feel a grinding pain in your abdomen.", "You exhale a jet of steam.")]</span>")
		if(5)
			if(replaceorgans)
				if(Replace(H))
					return
				else if(replacebody)
					H.adjustCloneLoss(-30) //we're fully mechanical, repair integrity. This symptom has a soft synergy with overclocked pituitary, so we want that to be useable. OFI is obviously out
					ADD_TRAIT(H, TRAIT_NANITECOMPATIBLE, DISEASE_TRAIT)
	return

/datum/symptom/robotic_adaptation/proc/Replace(mob/living/carbon/human/H)
	for(var/obj/item/organ/O in H.internal_organs)
		if(O.status == ORGAN_ROBOTIC) //they are either part robotic or we already converted them!
			continue
		switch(O.slot) //i hate doing it this way, but the cleaner way runtimes and does not work
			if(ORGAN_SLOT_BRAIN)
				var/datum/mind/ownermind = H.mind
				var/obj/item/organ/brain/clockwork/organ = new()
				organ.Insert(H, TRUE, FALSE)
				to_chat(H, "<span class='userdanger'>Your head throbs with pain for a moment, and then goes numb.</span>")
				H.emote("scream")
				ownermind.transfer_to(H)
				H.grab_ghost()
				return TRUE
			if(ORGAN_SLOT_STOMACH)
				var/obj/item/organ/stomach/clockwork/organ = new()
				organ.Insert(H, TRUE, FALSE)
				if(prob(40))
					to_chat(H, "<span class='userdanger'>You feel a stabbing pain in your abdomen!</span>")
					H.emote("scream")
				return TRUE
			if(ORGAN_SLOT_EARS)
				var/obj/item/organ/ears/robot/clockwork/organ = new()
				if(robustbits)
					organ.damage_multiplier = 0.5
				organ.Insert(H, TRUE, FALSE)
				to_chat(H, "<span class='warning'>Your ears pop.</span>")
				return TRUE
			if(ORGAN_SLOT_EYES)
				var/obj/item/organ/eyes/robotic/clockwork/organ = new()
				if(robustbits)
					organ.flash_protect = 1
				organ.Insert(H, TRUE, FALSE)
				if(prob(40))
					to_chat(H, "<span class='userdanger'>You feel a stabbing pain in your eyeballs!</span>")
					H.emote("scream")
				return TRUE
			if(ORGAN_SLOT_LUNGS)
				var/obj/item/organ/lungs/clockwork/organ = new()
				if(robustbits)
					organ.safe_toxins_max = 15
					organ.safe_co2_max = 15
					organ.SA_para_min = 15
					organ.SA_sleep_min = 15
					organ.BZ_trip_balls_min = 15
					organ.gas_stimulation_min = 15
				organ.Insert(H, TRUE, FALSE)
				if(prob(40))
					to_chat(H, "<span class='userdanger'>You feel a stabbing pain in your chest!</span>")
					H.emote("scream")
				return TRUE
			if(ORGAN_SLOT_HEART)
				var/obj/item/organ/heart/clockwork/organ = new()
				organ.Insert(H, TRUE, FALSE)
				to_chat(H, "<span class='userdanger'>You feel a stabbing pain in your chest!</span>")
				H.emote("scream")
				return TRUE
			if(ORGAN_SLOT_LIVER)
				var/obj/item/organ/liver/clockwork/organ = new()
				if(robustbits)
					organ.toxTolerance = 7
				organ.Insert(H, TRUE, FALSE)
				if(prob(40))
					to_chat(H, "<span class='userdanger'>You feel a stabbing pain in your abdomen!</span>")
					H.emote("scream")
				return TRUE
			if(ORGAN_SLOT_TONGUE)
				if(robustbits)
					var/obj/item/organ/tongue/robot/clockwork/better/organ = new()
					organ.Insert(H, TRUE, FALSE)
					return TRUE
				else
					var/obj/item/organ/tongue/robot/clockwork/organ = new()
					organ.Insert(H, TRUE, FALSE)
					return TRUE
			if(ORGAN_SLOT_TAIL)
				var/obj/item/organ/tail/clockwork/organ = new()
				organ.Insert(H, TRUE, FALSE)
				return TRUE
			if(ORGAN_SLOT_WINGS)
				var/obj/item/organ/wings/cybernetic/clockwork/organ = new()
				if(robustbits)
					organ.flight_level = WINGS_FLYING
				organ.Insert(H, TRUE, FALSE)
				to_chat(H, "<span class='warning'>Your wings feel stiff.</span>")
				return TRUE
	if(replacebody)
		for(var/obj/item/bodypart/O in H.bodyparts)
			if(O.status == BODYPART_ROBOTIC)
				if(robustbits && O.brute_reduction < 3 || O.burn_reduction < 2)
					O.burn_reduction = max(2, O.burn_reduction)
					O.brute_reduction = max(3, O.brute_reduction)
				continue
			switch(O.body_zone) 
				if(BODY_ZONE_HEAD)
					var/obj/item/bodypart/head/robot/clockwork/B = new()
					if(robustbits) 
						B.brute_reduction = 3 //this is just below the amount that lets augs ignore space damage.
						B.burn_reduction = 2
					B.replace_limb(H, TRUE)
					H.visible_message("<span class='notice'>[H]'s head shifts, and becomes metal before your very eyes", "<span_class='userdanger'>Your head feels numb, and cold.</span>")
					qdel(O)
					return TRUE
				if(BODY_ZONE_CHEST)
					var/obj/item/bodypart/chest/robot/clockwork/B = new()
					if(robustbits)
						B.brute_reduction = 3
						B.burn_reduction = 2
					B.replace_limb(H, TRUE)
					H.visible_message("<span class='notice'>[H]'s [O] shifts, and becomes metal before your very eyes", "<span_class='userdanger'>Your [O] feels numb, and cold.</span>")
					qdel(O)
					return TRUE
				if(BODY_ZONE_L_ARM)
					var/obj/item/bodypart/l_arm/robot/clockwork/B = new()
					if(robustbits)
						B.brute_reduction = 3
						B.burn_reduction = 2
					B.replace_limb(H, TRUE)
					H.visible_message("<span class='notice'>[H]'s [O] shifts, and becomes metal before your very eyes", "<span_class='userdanger'>Your [O] feels numb, and cold.</span>")
					qdel(O)
					return TRUE
				if(BODY_ZONE_R_ARM)
					var/obj/item/bodypart/r_arm/robot/clockwork/B = new()
					if(robustbits)
						B.brute_reduction = 3
						B.burn_reduction = 2
					B.replace_limb(H, TRUE)
					H.visible_message("<span class='notice'>[H]'s [O] shifts, and becomes metal before your very eyes", "<span_class='userdanger'>Your [O] feels numb, and cold.</span>")
					qdel(O)
					return TRUE
				if(BODY_ZONE_L_LEG)
					var/obj/item/bodypart/l_leg/robot/clockwork/B = new()
					if(robustbits)
						B.brute_reduction = 3
						B.burn_reduction = 2
					B.replace_limb(H, TRUE)
					H.visible_message("<span class='notice'>[H]'s [O] shifts, and becomes metal before your very eyes", "<span_class='userdanger'>Your [O] feels numb, and cold.</span>")
					qdel(O)
					return TRUE
				if(BODY_ZONE_R_LEG)
					var/obj/item/bodypart/r_leg/robot/clockwork/B = new()
					if(robustbits)
						B.brute_reduction = 3
						B.burn_reduction = 2
					B.replace_limb(H, TRUE)
					H.visible_message("<span class='notice'>[H]'s [O] shifts, and becomes metal before your very eyes", "<span_class='userdanger'>Your [O] feels numb, and cold.</span>")
					qdel(O)
					return TRUE
	return FALSE

/datum/symptom/robotic_adaptation/End(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/human/H = A.affected_mob
	REMOVE_TRAIT(H, TRAIT_NANITECOMPATIBLE, DISEASE_TRAIT)

/datum/symptom/robotic_adaptation/OnRemove(datum/disease/advance/A)
	A.infectable_biotypes -= MOB_ROBOTIC

//below this point lies all clockwork bits that make this symptom tick. no pun intended.
/obj/item/organ/ears/robot/clockwork
	name = "biometallic recorder"
	desc = "An odd sort of microphone that looks grown, rather than built."
	icon_state = "ears-clock"

/obj/item/organ/eyes/robotic/clockwork
	name = "biometallic receptors"
	desc = "A fragile set of small, mechanical cameras."
	icon_state = "clockwork_eyeballs"

/obj/item/organ/heart/clockwork //this heart doesnt have the fancy bits normal cyberhearts do. However, it also doesnt fucking kill you when EMPd
	name = "biomechanical pump"
	desc = "A complex, multi-valved hydraulic pump, which fits perfectly where a heart normally would."
	icon_state = "heart-clock"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC

/obj/item/organ/stomach/clockwork
	name = "nutriment refinery"
	icon_state = "stomach-clock"
	desc = "A biomechanical furnace, which turns calories into mechanical energy."
	icon_state = "liver-clock"
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/stomach/cell/emp_act(severity)
	owner.nutrition -= 100 * severity

/obj/item/organ/tongue/robot/clockwork
	name = "dynamic micro-phonograph"
	desc = "an old-timey looking device connected to an odd, shifting cylinder."
	icon_state = "tongueclock"

/obj/item/organ/tongue/robot/clockwork/better
	name = "amplified dynamic micro-phonograph"

/obj/item/organ/tongue/robot/clockwork/better/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT
	speech_args[SPEECH_SPANS] |= SPAN_REALLYBIG  //yes, this is a really really good idea, trust me

/obj/item/organ/brain/clockwork
	name = "enigmatic gearbox"
	desc ="An engineer would call this inconcievable wonder of gears and metal a 'black box'"
	icon_state = "posibrain-occupied"
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	icon_state = "brain-clock"

/obj/item/organ/brain/clockwork/emp_act(severity)
	switch(severity)
		if(1)
			owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 75)
		if(2)
			owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25)

/obj/item/organ/brain/clockwork/on_life()
	. = ..()
	if(prob(25))
		SEND_SOUND(owner, pickweight(list('sound/effects/clock_tick.ogg' = 6, 'sound/effects/smoke.ogg' = 2, 'sound/spookoween/chain_rattling.ogg' = 1, 'sound/ambience/ambiruin3.ogg' = 1)))

/obj/item/organ/liver/clockwork
	name = "biometallic alembic"
	icon_state = "liver-c"
	desc = "A series of small pumps and boilers, designed to facilitate proper metabolism."
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	alcohol_tolerance = 0
	toxLethality = 0
	toxTolerance = 1 //while the organ isn't damaged by doing its job, it doesnt do it very well

/obj/item/organ/lungs/clockwork
	name = "clockwork diaphragm"
	desc = "A utilitarian bellows which serves to pump oxygen into an automaton's body."
	icon_state = "lungs-clock"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC


/obj/item/organ/wings/cybernetic/clockwork
	name = "biometallic wings"
	desc = "A pair of thin metallic membranes."
	flight_level = WINGS_FLIGHTLESS
	wing_type = "Clockwork"
	icon_state = "clockwings"
	basewings = "moth_wings"
	canopen = FALSE

/obj/item/organ/tail/clockwork
	name = "biomechanical tail"
	desc = "A stiff tail composed of a strange alloy."
	color = null
	tail_type = "Clockwork"
	icon_state = "clocktail"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC

/obj/item/organ/tail/clockwork/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		if(!("tail_human" in H.dna.species.mutant_bodyparts))
			H.dna.features["tail_human"] = tail_type
			H.dna.species.mutant_bodyparts |= "tail_human"
		H.update_body()

/obj/item/organ/tail/clockwork/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(istype(H))
		H.dna.species.mutant_bodyparts -= "tail_human"
		H.update_body()

/obj/item/bodypart/l_arm/robot/clockwork
	name = "clockwork left arm"
	desc = "An odd metal arm with fingers driven by blood-based hydraulics."
	icon = 'icons/mob/augmentation/augments_clockwork.dmi'
	brute_reduction = 0
	burn_reduction = 0

/obj/item/bodypart/r_arm/robot/clockwork
	name = "clockwork right arm"
	desc = "An odd metal arm with fingers driven by blood-based hydraulics."
	icon = 'icons/mob/augmentation/augments_clockwork.dmi'
	brute_reduction = 0
	burn_reduction = 0

/obj/item/bodypart/l_leg/robot/clockwork
	name = "clockwork left leg"
	desc = "An odd metal leg full of intricate mechanisms."
	icon = 'icons/mob/augmentation/augments_clockwork.dmi'
	brute_reduction = 0
	burn_reduction = 0

/obj/item/bodypart/r_leg/robot/clockwork
	name = "clockwork right leg"
	desc = "An odd metal leg full of intricate mechanisms."
	icon = 'icons/mob/augmentation/augments_clockwork.dmi'
	brute_reduction = 0
	burn_reduction = 0

/obj/item/bodypart/head/robot/clockwork
	name = "clockwork head"
	desc = "An odd metal head that still feels warm to the touch."
	icon = 'icons/mob/augmentation/augments_clockwork.dmi'
	brute_reduction = 0
	burn_reduction = 0

/obj/item/bodypart/chest/robot/clockwork
	name = "clockwork torso"
	desc = "An odd metal body full of gears and pipes. It still seems alive."
	icon = 'icons/mob/augmentation/augments_clockwork.dmi'
	brute_reduction = 0
	burn_reduction = 0