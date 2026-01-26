//These traits primarily present a disadvantage to the players, some worse than others.

/datum/quirk/badback
	name = "Bad Back"
	desc = "Thanks to your poor posture, backpacks and other bags never sit right on your back. More evently weighted objects are fine, though."
	icon = "hiking"
	quirk_value = -1
	mood_quirk = TRUE
	medical_record_text = "Patient scans indicate severe and chronic back pain."
	gain_text = span_danger("Your back REALLY hurts!")
	lose_text = span_notice("Your back feels better.")
	process = TRUE

/datum/quirk/badback/on_process()
	var/mob/living/carbon/human/H = quirk_target
	if(H.back && istype(H.back, /obj/item/storage/backpack))
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "back_pain", /datum/mood_event/back_pain)
	else
		SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "back_pain")

/datum/quirk/blooddeficiency
	name = "Blood Deficiency"
	desc = "Your body can't produce enough blood to sustain itself."
	icon = "tint"
	quirk_value = -1
	gain_text = span_danger("You feel your vigor slowly fading away.")
	lose_text = span_notice("You feel vigorous again.")
	medical_record_text = "Patient requires regular treatment for blood loss due to low production of blood."
	process = TRUE

/datum/quirk/blooddeficiency/on_process(delta_time)
	var/mob/living/carbon/human/H = quirk_target
	if(HAS_TRAIT(H, TRAIT_NOBLOOD) || HAS_TRAIT(H, TRAIT_NO_BLOOD)) //can't lose blood if your species doesn't have any
		return
	if(H.blood_volume > (BLOOD_VOLUME_SAFE - 25)) // just barely survivable without treatment
		H.blood_volume -= 0.275 * delta_time

/datum/quirk/blindness
	name = "Blind"
	desc = "You are completely blind, nothing can counteract this."
	icon = "eye-slash"
	quirk_value = -1
	gain_text = span_danger("You can't see anything.")
	lose_text = span_notice("You miraculously gain back your vision.")
	medical_record_text = "Patient has permanent blindness."

/datum/quirk/blindness/add()
	quirk_target.become_blind(ROUNDSTART_TRAIT)

/datum/quirk/blindness/remove()
	quirk_target.cure_blind(ROUNDSTART_TRAIT)

/datum/quirk/blindness/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/clothing/glasses/blindfold/white/B = new(get_turf(H))
	if(!H.equip_to_slot_if_possible(B, ITEM_SLOT_EYES, bypass_equip_delay_self = TRUE)) //if you can't put it on the user's eyes, put it in their hands, otherwise put it on their eyes
		H.put_in_hands(B)
	H.regenerate_icons()

/datum/quirk/brainproblems
	name = "Brain Tumor"
	desc = "You have a little friend in your brain that is slowly destroying it. Thankfully, you start with a bottle of mannitol pills."
	icon = "brain"
	quirk_value = -1
	mob_trait = TRAIT_BRAIN_TUMOR
	gain_text = span_danger("You feel smooth.")
	lose_text = span_notice("You feel wrinkled again.")
	medical_record_text = "Patient has a tumor in their brain that is slowly driving them to brain death."
	process = TRUE
	var/where = "at your feet"
	var/notified = FALSE

/datum/quirk/brainproblems/on_process(delta_time)
	if(!quirk_target.reagents.has_reagent(/datum/reagent/medicine/mannitol))
		if(prob(80))
			quirk_target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.1 * delta_time)
	var/obj/item/organ/brain/B = quirk_target.get_organ_by_type(/obj/item/organ/brain)
	if(B)
		if(B.damage>BRAIN_DAMAGE_MILD-1 && !notified)
			to_chat(quirk_target, span_danger("You sense your brain is getting beyond your control..."))
			notified = TRUE
		if(B.damage<1 && notified)
			to_chat(quirk_target, span_notice("You feel your brain is quite well."))
			notified = FALSE



/datum/quirk/brainproblems/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/storage/pill_bottle/mannitol/braintumor/P = new(get_turf(H))

	var/list/slots = list(
		"in your left pocket" = ITEM_SLOT_LPOCKET,
		"in your right pocket" = ITEM_SLOT_RPOCKET,
		"in your backpack" = ITEM_SLOT_BACKPACK
	)
	where = H.equip_in_one_of_slots(P, slots, FALSE)

/datum/quirk/brainproblems/post_spawn()
	if(where)
		to_chat(quirk_target, span_boldnotice("There is a bottle of mannitol [where]. You're going to need it."))
	else
		to_chat(quirk_target, span_boldnotice("You dropped your bottle of mannitol on the floor. Better pick it up, you are going to need it."))

/datum/quirk/deafness
	name = "Deaf"
	desc = "You are incurably deaf."
	icon = "deaf"
	quirk_value = -1
	mob_trait = TRAIT_DEAF
	gain_text = span_danger("You can't hear anything.")
	lose_text = span_notice("You're able to hear again!")
	medical_record_text = "Patient's cochlear nerve is incurably damaged."

/datum/quirk/depression
	name = "Depression"
	desc = "You sometimes just hate life."
	icon = "frown"
	quirk_value = -1
	gain_text = span_danger("You start feeling depressed.")
	lose_text = span_notice("You no longer feel depressed.") //if only it were that easy!
	medical_record_text = "Patient has a severe mood disorder causing them to experience sudden moments of sadness."
	mood_quirk = TRUE
	process = TRUE

/datum/quirk/depression/on_process(delta_time)
	if(DT_PROB(0.05, delta_time))
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "depression", /datum/mood_event/depression)

/datum/quirk/family_heirloom
	name = "Family Heirloom"
	desc = "You are the current owner of an heirloom, passed down for generations. You have to keep it safe!"
	icon = "toolbox"
	quirk_value = -1
	mood_quirk = TRUE
	process = TRUE
	medical_record_text = "Patient demonstrates an unnatural attachment to a family heirloom."
	var/obj/item/heirloom
	var/where

/datum/quirk/family_heirloom/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/heirloom_type

	if((ismoth(H)) && prob(50))
		heirloom_type = /obj/item/flashlight/lantern/heirloom_moth
	else
		switch(quirk_holder.assigned_role)
			//Service jobs
			if(JOB_NAME_CLOWN)
				heirloom_type = /obj/item/bikehorn/golden
			if(JOB_NAME_MIME)
				heirloom_type = /obj/item/food/baguette/mime
			if(JOB_NAME_JANITOR)
				heirloom_type = pick(/obj/item/mop, /obj/item/clothing/suit/caution, /obj/item/reagent_containers/cup/bucket)
			if(JOB_NAME_COOK)
				heirloom_type = pick(/obj/item/reagent_containers/condiment/saltshaker, /obj/item/kitchen/rollingpin, /obj/item/clothing/head/utility/chefhat)
			if(JOB_NAME_BOTANIST)
				heirloom_type = pick(/obj/item/cultivator, /obj/item/reagent_containers/cup/bucket, /obj/item/storage/bag/plants, /obj/item/toy/plush/beeplushie)
			if(JOB_NAME_BARTENDER)
				heirloom_type = pick(/obj/item/reagent_containers/cup/rag, /obj/item/clothing/head/hats/tophat, /obj/item/reagent_containers/cup/glass/shaker)
			if(JOB_NAME_CURATOR)
				heirloom_type = pick(/obj/item/pen/fountain, /obj/item/storage/pill_bottle/dice)
			if(JOB_NAME_CHAPLAIN)
				heirloom_type = pick(/obj/item/toy/windupToolbox, /obj/item/reagent_containers/cup/glass/bottle/holywater)
			if(JOB_NAME_ASSISTANT)
				heirloom_type = pick(/obj/item/heirloomtoolbox, /obj/item/clothing/gloves/cut/heirloom)
			if(JOB_NAME_PRISONER)
				heirloom_type = pick(/obj/item/heirloomtoolbox, /obj/item/clothing/gloves/cut/heirloom)
			if(JOB_NAME_BARBER)
				heirloom_type = /obj/item/handmirror
			if(JOB_NAME_STAGEMAGICIAN)
				heirloom_type = /obj/item/gun/magic/wand
			//Security/Command
			if(JOB_NAME_CAPTAIN)
				heirloom_type = /obj/item/reagent_containers/cup/glass/flask/gold
			if(JOB_NAME_HEADOFSECURITY)
				heirloom_type = pick(/obj/item/book/manual/wiki/security_space_law, /obj/item/gun/energy/e_gun/advtaser/heirloom)
			if(JOB_NAME_WARDEN)
				heirloom_type = pick(/obj/item/book/manual/wiki/security_space_law, /obj/item/gun/energy/e_gun/advtaser/heirloom)
			if(JOB_NAME_SECURITYOFFICER)
				heirloom_type = pick(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec, /obj/item/gun/energy/e_gun/advtaser/heirloom)
			if(JOB_NAME_DETECTIVE)
				heirloom_type = /obj/item/reagent_containers/cup/glass/bottle/whiskey
			if(JOB_NAME_LAWYER)
				heirloom_type = pick(/obj/item/gavelhammer, /obj/item/book/manual/wiki/security_space_law)
			if(JOB_NAME_BRIGPHYSICIAN)
				heirloom_type = pick(/obj/item/clothing/neck/stethoscope, /obj/item/book/manual/wiki/security_space_law)
			//RnD
			if(JOB_NAME_RESEARCHDIRECTOR)
				heirloom_type = pick(typesof(/obj/item/toy/plush/slimeplushie) - /obj/item/toy/plush/slimeplushie/random)
			if(JOB_NAME_SCIENTIST)
				heirloom_type = pick(typesof(/obj/item/toy/plush/slimeplushie) - /obj/item/toy/plush/slimeplushie/random)
			if(JOB_NAME_ROBOTICIST)
				heirloom_type = pick(subtypesof(/obj/item/toy/mecha)) //look at this nerd
			//Medical
			if(JOB_NAME_CHIEFMEDICALOFFICER)
				heirloom_type = pick(/obj/item/clothing/neck/stethoscope, /obj/item/flashlight/pen)
			if(JOB_NAME_MEDICALDOCTOR)
				heirloom_type = pick(/obj/item/clothing/neck/stethoscope, /obj/item/flashlight/pen, /obj/item/scalpel)
			if(JOB_NAME_PARAMEDIC)
				heirloom_type = pick(/obj/item/flashlight/pen, /obj/item/sensor_device)
			if(JOB_NAME_CHEMIST)
				heirloom_type = /obj/item/reagent_containers/cup/chem_heirloom
			if(JOB_NAME_VIROLOGIST)
				heirloom_type = /obj/item/reagent_containers/dropper
			if(JOB_NAME_GENETICIST)
				heirloom_type = /obj/item/clothing/under/shorts/purple
			//Engineering
			if(JOB_NAME_CHIEFENGINEER)
				heirloom_type = pick(/obj/item/clothing/head/utility/hardhat/white, /obj/item/screwdriver, /obj/item/wrench, /obj/item/weldingtool, /obj/item/crowbar, /obj/item/wirecutters)
			if(JOB_NAME_STATIONENGINEER)
				heirloom_type = pick(/obj/item/clothing/head/utility/hardhat, /obj/item/screwdriver, /obj/item/wrench, /obj/item/weldingtool, /obj/item/crowbar, /obj/item/wirecutters)
			if(JOB_NAME_ATMOSPHERICTECHNICIAN)
				heirloom_type = pick(/obj/item/lighter, /obj/item/lighter/greyscale, /obj/item/storage/box/matches)
			//Supply
			if(JOB_NAME_QUARTERMASTER)
				heirloom_type = pick(/obj/item/stamp, /obj/item/stamp/denied)
			if(JOB_NAME_CARGOTECHNICIAN)
				heirloom_type = /obj/item/clipboard
			if(JOB_NAME_SHAFTMINER)
				heirloom_type = pick(/obj/item/pickaxe/mini, /obj/item/shovel)

	if(!heirloom_type)
		heirloom_type = pick(
		/obj/item/toy/cards/deck,
		/obj/item/lighter,
		/obj/item/dice/d20)
	heirloom = new heirloom_type(get_turf(quirk_target))
	var/list/slots = list(
		"in your left pocket" = ITEM_SLOT_LPOCKET,
		"in your right pocket" = ITEM_SLOT_RPOCKET,
		"in your backpack" = ITEM_SLOT_BACKPACK
	)
	where = H.equip_in_one_of_slots(heirloom, slots, FALSE) || "at your feet"

/datum/quirk/family_heirloom/post_spawn()
	if(where == "in your backpack")
		var/mob/living/carbon/human/H = quirk_target
		H.back.atom_storage.show_contents(H)

	to_chat(quirk_target, span_boldnotice("There is a precious family [heirloom.name] [where], passed down from generation to generation. Keep it safe!"))

	var/list/names = splittext(quirk_target.real_name, " ")
	var/family_name = names[names.len]

	heirloom.AddComponent(/datum/component/heirloom, quirk_holder, family_name)
	if(istype(heirloom, /obj/item/reagent_containers/cup/chem_heirloom)) //Edge case for chem_heirloom. Solution to component not being present on init.
		var/obj/item/reagent_containers/cup/chem_heirloom/H = heirloom
		H.update_name()

/datum/quirk/family_heirloom/on_process()
	if(heirloom in quirk_target.GetAllContents())
		SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom_missing")
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "family_heirloom", /datum/mood_event/family_heirloom)
	else
		SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom")
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "family_heirloom_missing", /datum/mood_event/family_heirloom_missing)

/datum/quirk/frail
	name = "Frail"
	desc = "Your bones might as well be made of glass! Your limbs can take less damage before they become disabled."
	icon = "skull"
	quirk_value = -1
	mob_trait = TRAIT_EASYLIMBDISABLE
	gain_text = span_danger("You feel frail.")
	lose_text = span_notice("You feel sturdy again.")
	medical_record_text = "Patient is absurdly easy to injure. Please take all due diligence to avoid possible malpractice suits."

/datum/quirk/foreigner
	name = "Foreigner"
	desc = "You're not from around here. You don't know Galactic Common!"
	icon = "question-circle"
	quirk_value = -1
	gain_text = span_notice("The words being spoken around you don't make any sense.")
	lose_text = span_notice("You've developed fluency in Galactic Common.")
	medical_record_text = "Patient does not speak Galactic Common and may require an interpreter."

/datum/quirk/foreigner/add()
	var/mob/living/carbon/human/H = quirk_target
	if(quirk_holder.assigned_role != JOB_NAME_CURATOR)
		H.add_blocked_language(/datum/language/common)
		H.grant_language(/datum/language/uncommon)

/datum/quirk/foreigner/remove()
	var/mob/living/carbon/human/H = quirk_target
	if(quirk_holder.assigned_role != JOB_NAME_CURATOR)
		H.remove_blocked_language(/datum/language/common)
		H.remove_language(/datum/language/uncommon)

/datum/quirk/heavy_sleeper
	name = "Heavy Sleeper"
	desc = "You sleep like a rock! Whenever you're put to sleep or knocked unconscious, you take a little bit longer to wake up."
	icon = "bed"
	quirk_value = -1
	mob_trait = TRAIT_HEAVY_SLEEPER
	gain_text = span_danger("You feel sleepy.")
	lose_text = span_notice("You feel awake again.")
	medical_record_text = "Patient has abnormal sleep study results and is difficult to wake up."

/datum/quirk/hypersensitive
	name = "Hypersensitive"
	desc = "Bad things affect your mood more than they should."
	icon = "flushed"
	quirk_value = -1
	gain_text = span_danger("You seem to make a big deal out of everything.")
	lose_text = span_notice("You don't seem to make a big deal out of everything anymore.")
	medical_record_text = "Patient demonstrates a high level of emotional volatility."

/datum/quirk/nearsighted //t. errorage
	name = "Nearsighted"
	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	icon = "glasses"
	quirk_value = -1
	gain_text = span_danger("Things far away from you start looking blurry.")
	lose_text = span_notice("You start seeing faraway things normally again.")
	medical_record_text = "Patient requires prescription glasses in order to counteract nearsightedness."

/datum/quirk/nearsighted/add()
	quirk_target.become_nearsighted(ROUNDSTART_TRAIT)

/datum/quirk/nearsighted/remove()
	quirk_target.cure_nearsighted(ROUNDSTART_TRAIT)

/datum/quirk/nearsighted/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/clothing/glasses/regular/glasses = new(get_turf(H))
	H.put_in_hands(glasses)
	H.equip_to_slot(glasses, ITEM_SLOT_EYES)
	H.regenerate_icons() //this is to remove the inhand icon, which persists even if it's not in their hands

/datum/quirk/nyctophobia
	name = "Nyctophobia"
	desc = "As far as you can remember, you've always been afraid of the dark. While in the dark without a light source, you instinctually act careful, and constantly feel a sense of dread."
	icon = "lightbulb"
	quirk_value = -1
	process = TRUE
	medical_record_text = "Patient demonstrates a fear of the dark."

/datum/quirk/nyctophobia/on_process()
	var/mob/living/carbon/human/H = quirk_target
	if(H.dna.species.id in list("shadow", "nightmare"))
		return //we're tied with the dark, so we don't get scared of it; don't cleanse outright to avoid cheese
	var/turf/T = get_turf(quirk_target)
	if(T.get_lumcount() <= LIGHTING_TILE_IS_DARK)
		if(quirk_target.m_intent == MOVE_INTENT_RUN)
			to_chat(quirk_target, span_warning("Easy, easy, take it slow... you're in the dark..."))
			quirk_target.toggle_move_intent()
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "nyctophobia", /datum/mood_event/nyctophobia)
	else
		SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "nyctophobia")

/datum/quirk/nonviolent
	name = "Pacifist"
	desc = "The thought of violence makes you sick. So much so, in fact, that you can't hurt anyone."
	icon = "peace"
	quirk_value = -1
	mob_trait = TRAIT_PACIFISM
	gain_text = span_danger("You feel repulsed by the thought of violence!")
	lose_text = span_notice("You think you can defend yourself again.")
	medical_record_text = "Patient is unusually pacifistic and cannot bring themselves to cause physical harm."

/datum/quirk/trauma/paraplegic
	name = "Paraplegic"
	desc = "Your legs do not function. Nothing will ever fix this. But hey, free wheelchair!"
	icon = "wheelchair"
	quirk_value = -1
	medical_record_text = "Patient has an untreatable impairment in motor function in the lower extremities."
	trauma_type = /datum/brain_trauma/severe/paralysis/paraplegic/

/datum/quirk/trauma/paraplegic/on_spawn()
	if(quirk_target.buckled) // Handle late joins being buckled to arrival shuttle chairs.
		quirk_target.buckled.unbuckle_mob(quirk_target)

	var/turf/T = get_turf(quirk_target)
	var/obj/structure/chair/spawn_chair = locate() in T

	var/obj/vehicle/ridden/wheelchair/wheels = new(T)
	if(spawn_chair) // Makes spawning on the arrivals shuttle more consistent looking
		wheels.setDir(spawn_chair.dir)

	wheels.buckle_mob(quirk_target)

	// During the spawning process, they may have dropped what they were holding, due to the paralysis
	// So put the things back in their hands.

	for(var/obj/item/I in T)
		if(I.fingerprintslast == quirk_target.ckey)
			quirk_target.put_in_hands(I)

/datum/quirk/poor_aim
	name = "Poor Aim"
	desc = "You're terrible with guns and can't line up a straight shot to save your life. Dual-wielding is right out."
	icon = "bullseye"
	quirk_value = -1
	mob_trait = TRAIT_POOR_AIM
	medical_record_text = "Patient possesses a strong tremor in both hands."

/datum/quirk/prosopagnosia
	name = "Prosopagnosia"
	desc = "You have a mental disorder that prevents you from being able to recognize faces at all."
	icon = "user-secret"
	quirk_value = -1
	medical_record_text = "Patient suffers from prosopagnosia and cannot recognize faces."

/datum/quirk/prosthetic_limb
	name = "Prosthetic Limb"
	desc = "An accident caused you to lose one of your limbs. Because of this, you now have a random prosthetic!"
	icon = "tg-prosthetic-leg"
	quirk_value = -1
	var/slot_string = "limb"

/datum/quirk/prosthetic_limb/on_spawn()
	var/limb_slot = read_choice_preference(/datum/preference/choiced/quirk/prosthetic_limb_location) || pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG) // default to random
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/bodypart/prosthetic
	switch(limb_slot)
		if(BODY_ZONE_L_ARM)
			prosthetic = new/obj/item/bodypart/arm/left/robot/surplus(quirk_target)
			slot_string = "left arm"
		if(BODY_ZONE_R_ARM)
			prosthetic = new/obj/item/bodypart/arm/right/robot/surplus(quirk_target)
			slot_string = "right arm"
		if(BODY_ZONE_L_LEG)
			prosthetic = new/obj/item/bodypart/leg/left/robot/surplus(quirk_target)
			slot_string = "left leg"
		if(BODY_ZONE_R_LEG)
			prosthetic = new/obj/item/bodypart/leg/right/robot/surplus(quirk_target)
			slot_string = "right leg"
	H.del_and_replace_bodypart(prosthetic)
	medical_record_text = "Patient uses a low-budget prosthetic on the [prosthetic.name]."

/datum/quirk/prosthetic_limb/post_spawn()
	to_chat(quirk_target, span_boldannounce("Your [slot_string] has been replaced with a surplus prosthetic. It is fragile and will easily come apart under duress. Additionally, \
	you need to use a welding tool and cables to repair it, instead of bruise packs and ointment."))

/datum/quirk/pushover
	name = "Pushover"
	desc = "Your first instinct is always to let people push you around. Resisting out of grabs will take conscious effort."
	icon = "handshake"
	quirk_value = -1
	mob_trait = TRAIT_GRABWEAKNESS
	gain_text = span_danger("You feel like a pushover.")
	lose_text = span_notice("You feel like standing up for yourself.")
	medical_record_text = "Patient presents a notably unassertive personality and is easy to manipulate."

/datum/quirk/insanity
	name = "Reality Dissociation Syndrome"
	desc = "You suffer from a severe disorder that causes very vivid hallucinations. \
		Mindbreaker toxin can suppress its effects, and you are immune to mindbreaker's hallucinogenic properties. \
		THIS IS NOT A LICENSE TO GRIEF."
	icon = "grin-tongue-wink"
	quirk_value = -1
	gain_text = span_userdanger("...")
	lose_text = span_notice("You feel in tune with the world again.")
	medical_record_text = "Patient suffers from acute Reality Dissociation Syndrome and experiences vivid hallucinations."

/datum/quirk/insanity/add()
	if(!iscarbon(quirk_holder))
		return
	var/mob/living/carbon/carbon_quirk_holder = quirk_holder

	// Setup our special RDS mild hallucination.
	// Not a unique subtype so not to plague subtypesof,
	// also as we inherit the names and values from our quirk.
	var/datum/brain_trauma/mild/hallucinations/added_trauma = new()
	added_trauma.resilience = TRAUMA_RESILIENCE_ABSOLUTE
	added_trauma.name = name
	added_trauma.desc = medical_record_text
	added_trauma.scan_desc = LOWER_TEXT(name)
	added_trauma.gain_text = null
	added_trauma.lose_text = null

	carbon_quirk_holder.gain_trauma(added_trauma)

/datum/quirk/insanity/post_spawn()
	if(!quirk_holder || quirk_holder.special_role)
		return
	// I don't /think/ we'll need this, but for newbies who think "roleplay as insane" = "license to kill",
	// it's probably a good thing to have.
	to_chat(quirk_holder, "<span class='big bold info'>Please note that your [LOWER_TEXT(name)] does NOT give you the right to attack people or otherwise cause any interference to \
		the round. You are not an antagonist, and the rules will treat you the same as other crewmembers.</span>")

/datum/quirk/social_anxiety
	name = "Social Anxiety"
	desc = "Talking to people is very difficult for you, and you often stutter or even lock up."
	icon = "comment-slash"
	quirk_value = -1
	gain_text = span_danger("You start worrying about what you're saying.")
	lose_text = span_notice("You feel comfortable with talking again.") //if only it were that easy!
	medical_record_text = "Patient is usually anxious in social encounters and prefers to avoid them."
	process = TRUE
	var/dumb_thing = TRUE

/datum/quirk/social_anxiety/on_process(delta_time)
	var/nearby_people = 0
	for(var/mob/living/carbon/human/stranger in oview(3, quirk_target))
		if(stranger.client)
			nearby_people++
	var/mob/living/carbon/human/H = quirk_target
	if(DT_PROB(2 + nearby_people, delta_time))
		H.set_silence_if_lower(6 SECONDS)
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "anxiety", /datum/mood_event/anxiety)
	else if(DT_PROB(min(3, nearby_people), delta_time) && !H.has_status_effect(/datum/status_effect/silenced))
		to_chat(H, span_danger("You retreat into yourself. You <i>really</i> don't feel up to talking."))
		H.set_silence_if_lower(10 SECONDS)
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "anxiety_mute", /datum/mood_event/anxiety_mute)
	else if(DT_PROB(0.5, delta_time) && dumb_thing)
		to_chat(H, span_userdanger("You think of a dumb thing you said a long time ago and scream internally."))
		dumb_thing = FALSE //only once per life
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "anxiety_dumb", /datum/mood_event/anxiety_dumb)
		if(prob(1))
			new/obj/item/food/spaghetti/pastatomato(get_turf(H)) //now that's what I call spaghetti code

//If you want to make some kind of junkie variant, just extend this quirk.
/datum/quirk/junkie
	name = "Junkie"
	desc = "You can't get enough of hard drugs."
	icon = "pills"
	quirk_value = -1
	gain_text = span_danger("You suddenly feel the craving for drugs.")
	lose_text = span_notice("You feel like you should kick your drug habit.")
	medical_record_text = "Patient has a history of hard drugs."
	process = TRUE
	var/list/drug_list = list(/datum/reagent/drug/crank, /datum/reagent/drug/krokodil, /datum/reagent/medicine/morphine, /datum/reagent/drug/happiness, /datum/reagent/drug/methamphetamine, /datum/reagent/drug/ketamine) //List of possible IDs
	var/datum/reagent/reagent_type //!If this is defined, reagent_id will be unused and the defined reagent type will be instead.
	var/datum/reagent/reagent_instance //! actual instanced version of the reagent
	var/where_drug //! Where the drug spawned
	var/obj/item/drug_container_type //! If this is defined before pill generation, pill generation will be skipped. This is the type of the pill bottle.
	var/where_accessory //! where the accessory spawned
	var/obj/item/accessory_type //! If this is null, an accessory won't be spawned.
	var/process_interval = 30 SECONDS //! how frequently the quirk processes
	var/next_process = 0 //! ticker for processing

/datum/quirk/junkie/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	reagent_type = reagent_type || read_choice_preference(/datum/preference/choiced/quirk/junkie_drug)
	if (!reagent_type)
		reagent_type = pick(drug_list)
	reagent_instance = new reagent_type()
	for(var/addiction in reagent_instance.addiction_types)
		H.mind.add_addiction_points(addiction, 1000) ///Max that shit out
	var/current_turf = get_turf(quirk_target)
	if (!drug_container_type)
		drug_container_type = /obj/item/storage/pill_bottle
	var/obj/item/drug_instance = new drug_container_type(current_turf)
	if (istype(drug_instance, /obj/item/storage/pill_bottle))
		var/pill_state = pick(PILL_SHAPE_LIST)
		for(var/i in 1 to 7)
			var/obj/item/reagent_containers/pill/P = new(drug_instance)
			P.icon_state = pill_state
			P.reagents.add_reagent(reagent_type, 1)

	var/obj/item/accessory_instance
	if (accessory_type)
		accessory_instance = new accessory_type(current_turf)
	var/list/slots = list(
		"in your left pocket" = ITEM_SLOT_LPOCKET,
		"in your right pocket" = ITEM_SLOT_RPOCKET,
		"in your backpack" = ITEM_SLOT_BACKPACK
	)
	where_drug = H.equip_in_one_of_slots(drug_instance, slots, FALSE) || "at your feet"
	if (accessory_instance)
		where_accessory = H.equip_in_one_of_slots(accessory_instance, slots, FALSE) || "at your feet"
	announce_drugs()

/datum/quirk/junkie/post_spawn()
	if(where_drug == "in your backpack" || where_accessory == "in your backpack")
		var/mob/living/carbon/human/H = quirk_target
		H.back.atom_storage.show_contents(H)

/datum/quirk/junkie/proc/announce_drugs()
	to_chat(quirk_target, span_boldnotice("There is a [initial(drug_container_type.name)] of [initial(reagent_type.name)] [where_drug]. Better hope you don't run out..."))

/datum/quirk/junkie/on_process()
	if(!COOLDOWN_FINISHED(src, next_process))
		return
	COOLDOWN_START(src, next_process, process_interval)
	var/mob/living/carbon/human/human_holder = quirk_target
	var/deleted = QDELETED(reagent_instance)
	var/missing_addiction = FALSE
	for(var/addiction_type in reagent_instance.addiction_types)
		if(!LAZYACCESS(human_holder.mind.active_addictions, addiction_type))
			missing_addiction = TRUE
	if(deleted || missing_addiction)
		if(deleted)
			reagent_instance = new reagent_type()
		to_chat(quirk_target, span_danger("You thought you kicked it, but you feel like you're falling back onto bad habits.."))
		for(var/addiction in reagent_instance.addiction_types)
			human_holder.mind.add_addiction_points(addiction, 1000) ///Max that shit out

/datum/quirk/junkie/smoker
	name = "Smoker"
	desc = "Sometimes you just really want a smoke. Probably not great for your lungs."
	icon = "smoking"
	quirk_value = -1
	gain_text = span_danger("You could really go for a smoke right about now.")
	lose_text = span_notice("You feel like you should quit smoking.")
	medical_record_text = "Patient is a current smoker."
	reagent_type = /datum/reagent/drug/nicotine
	accessory_type = /obj/item/lighter/greyscale
	process = TRUE

/datum/quirk/junkie/smoker/on_spawn()
	drug_container_type = read_choice_preference(/datum/preference/choiced/quirk/smoker_cigarettes)
	if(!drug_container_type)
		drug_container_type = pick(GLOB.smoker_cigarettes)
	. = ..()

/datum/quirk/junkie/smoker/announce_drugs()
	to_chat(quirk_target, span_boldnotice("There is a [initial(drug_container_type.name)] [where_drug], and a lighter [where_accessory]. Make sure you get your favorite brand when you run out."))


/datum/quirk/junkie/smoker/on_process()
	. = ..()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/I = H.get_item_by_slot(ITEM_SLOT_MASK)
	if (istype(I, /obj/item/clothing/mask/cigarette))
		var/obj/item/storage/fancy/cigarettes/C = drug_container_type
		if(istype(I, initial(C.spawn_type)))
			SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "wrong_cigs")
			return
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "wrong_cigs", /datum/mood_event/wrong_brand)

/datum/quirk/alcoholic
	name = "Alcoholic"
	desc = "You can't stand being sober."
	icon = "angry"
	quirk_value = -1
	gain_text = span_danger("You could really go for a drink right about now.")
	lose_text = span_notice("You feel like you should quit drinking.")
	medical_record_text = "Patient is an alcohol abuser."
	process = TRUE
	var/where_drink //Where the bottle spawned
	var/drink_types = list(/obj/item/reagent_containers/cup/glass/bottle/ale,
					/obj/item/reagent_containers/cup/glass/bottle/beer,
					/obj/item/reagent_containers/cup/glass/bottle/gin,
					/obj/item/reagent_containers/cup/glass/bottle/whiskey,
					/obj/item/reagent_containers/cup/glass/bottle/vodka,
					/obj/item/reagent_containers/cup/glass/bottle/rum,
					/obj/item/reagent_containers/cup/glass/bottle/applejack)
	var/need = 0 // How much they crave alcohol at the moment
	var/tick_number = 0 // Keeping track of how many ticks have passed between a check
	var/obj/item/reagent_containers/cup/glass/bottle/drink_instance

/datum/quirk/alcoholic/on_spawn()
	drink_instance = read_choice_preference(/datum/preference/choiced/quirk/alcohol_type)
	if(!drink_instance)
		drink_instance = pick(drink_types)
	drink_instance = new drink_instance()
	var/list/slots = list("in your backpack" = ITEM_SLOT_BACKPACK)
	var/mob/living/carbon/human/H = quirk_target
	where_drink = H.equip_in_one_of_slots(drink_instance, slots, FALSE) || "at your feet"

/datum/quirk/alcoholic/post_spawn()
	to_chat(quirk_target, span_boldnotice("There is a small bottle of [drink_instance] [where_drink]. You only have a single bottle, might have to find some more..."))

/datum/quirk/alcoholic/on_process()
	if(tick_number >= 6) // how many ticks should pass between a check
		tick_number = 0
		var/mob/living/carbon/human/H = quirk_target
		if(H.get_drunk_amount() > 0) // If they're not drunk, need goes up. else they're satisfied
			need = -15
		else
			need++

		switch(need)
			if(1 to 10)
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "alcoholic", /datum/mood_event/withdrawal_light, "alcohol")
				if(prob(5))
					to_chat(H, span_notice("You could go for a drink right about now."))
			if(10 to 20)
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "alcoholic", /datum/mood_event/withdrawal_medium, "alcohol")
				if(prob(5))
					to_chat(H, span_notice("You feel like you need alcohol. You just can't stand being sober."))
			if(20 to 30)
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "alcoholic", /datum/mood_event/withdrawal_severe, "alcohol")
				if(prob(5))
					to_chat(H, span_danger("You have an intense craving for a drink."))
			if(30 to INFINITY)
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "alcoholic", /datum/mood_event/withdrawal_critical, "Alcohol")
				if(prob(5))
					to_chat(H, span_boldannounce("You're not feeling good at all! You really need some alcohol."))
			else
				SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "alcoholic")
	tick_number++

/datum/quirk/unstable
	name = "Unstable"
	desc = "Due to past troubles, you are unable to recover your sanity if you lose it. Be very careful managing your mood!"
	icon = "cloud-rain"
	quirk_value = -1
	mob_trait = TRAIT_UNSTABLE
	gain_text = span_danger("There's a lot on your mind right now.")
	lose_text = span_notice("Your mind finally feels calm.")
	medical_record_text = "Patient's mind is in a vulnerable state, and cannot recover from traumatic events."

/datum/quirk/trauma //Generic for quirks that apply a brain trauma
	name = "Phobia"
	desc = "Because of a traumatic event in your past you have developed a strong phobia."
	icon = "spider"
	quirk_value = -1
	gain_text = null // these are handled by the trauma itself
	lose_text = null
	medical_record_text = "Patient suffers from a deeply-rooted phobia."
	var/datum/brain_trauma/trauma_type = /datum/brain_trauma/mild/phobia/
	var/trauma

/datum/quirk/trauma/add()
	trauma = new trauma_type(read_choice_preference(/datum/preference/choiced/quirk/phobia))
	var/mob/living/carbon/human/H = quirk_target
	H.gain_trauma(trauma, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/trauma/remove()
	var/mob/living/carbon/human/H = quirk_target
	H.cure_trauma_type(trauma, TRAUMA_RESILIENCE_ABSOLUTE)
