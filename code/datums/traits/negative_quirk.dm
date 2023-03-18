//predominantly negative traits

/datum/quirk/badback
	name = "Bad Back"
	desc = "Thanks to your poor posture, backpacks and other bags never sit right on your back. More evently weighted objects are fine, though."
	value = -2
	mood_quirk = TRUE
	gain_text = "<span class='danger'>Your back REALLY hurts!</span>"
	lose_text = "<span class='notice'>Your back feels better.</span>"
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
	value = -2
	gain_text = "<span class='danger'>You feel your vigor slowly fading away.</span>"
	lose_text = "<span class='notice'>You feel vigorous again.</span>"
	medical_record_text = "Patient requires regular treatment for blood loss due to low production of blood."
	process = TRUE

/datum/quirk/blooddeficiency/on_process(delta_time)
	var/mob/living/carbon/human/H = quirk_target
	if(NOBLOOD in H.dna.species.species_traits) //can't lose blood if your species doesn't have any
		return
	else if(H.blood_volume > (BLOOD_VOLUME_SAFE - 25)) // just barely survivable without treatment
		H.blood_volume -= 0.275 * delta_time

/datum/quirk/blindness
	name = "Blind"
	desc = "You are completely blind, nothing can counteract this."
	value = -4
	gain_text = "<span class='danger'>You can't see anything.</span>"
	lose_text = "<span class='notice'>You miraculously gain back your vision.</span>"
	medical_record_text = "Subject has permanent blindness."

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
	mob_trait = TRAIT_BRAIN_TUMOR
	value = -3
	gain_text = "<span class='danger'>You feel smooth.</span>"
	lose_text = "<span class='notice'>You feel wrinkled again.</span>"
	medical_record_text = "Patient has a tumor in their brain that is slowly driving them to brain death."
	process = TRUE
	var/where = "at your feet"
	var/notified = FALSE

/datum/quirk/brainproblems/on_process(delta_time)
	if(!quirk_target.reagents.has_reagent(/datum/reagent/medicine/mannitol))
		if(prob(80))
			quirk_target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.1 * delta_time)
	var/obj/item/organ/brain/B = quirk_target.getorgan(/obj/item/organ/brain)
	if(B)
		if(B.damage>BRAIN_DAMAGE_MILD-1 && !notified)
			to_chat(quirk_target, "<span class='danger'>You sense your brain is getting beyond your control...</span>")
			notified = TRUE
		if(B.damage<1 && notified)
			to_chat(quirk_target, "<span class='notice'>You feel your brain is quite well.</span>")
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
		to_chat(quirk_target, "<span class='boldnotice'>There is a bottle of mannitol [where]. You're going to need it.</span>")
	else
		to_chat(quirk_target, "<span class='boldnotice'>You dropped your bottle of mannitol on the floor. Better pick it up, you are going to need it.</span>")

/datum/quirk/deafness
	name = "Deaf"
	desc = "You are incurably deaf."
	value = -2
	mob_trait = TRAIT_DEAF
	gain_text = "<span class='danger'>You can't hear anything.</span>"
	lose_text = "<span class='notice'>You're able to hear again!</span>"
	medical_record_text = "Subject's cochlear nerve is incurably damaged."

/datum/quirk/depression
	name = "Depression"
	desc = "You sometimes just hate life."
	mob_trait = TRAIT_DEPRESSION
	value = -1
	gain_text = "<span class='danger'>You start feeling depressed.</span>"
	lose_text = "<span class='notice'>You no longer feel depressed.</span>" //if only it were that easy!
	medical_record_text = "Patient has a severe mood disorder causing them to experience sudden moments of sadness."
	mood_quirk = TRUE
	process = TRUE

/datum/quirk/depression/on_process(delta_time)
	if(DT_PROB(0.05, delta_time))
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "depression", /datum/mood_event/depression)

/datum/quirk/family_heirloom
	name = "Family Heirloom"
	desc = "You are the current owner of an heirloom, passed down for generations. You have to keep it safe!"
	value = -1
	mood_quirk = TRUE
	process = TRUE
	var/obj/item/heirloom
	var/where

/datum/quirk/family_heirloom/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/heirloom_type

	if(is_species(H, /datum/species/moth) && prob(50))
		heirloom_type = /obj/item/flashlight/lantern/heirloom_moth
	else
		switch(quirk_holder.assigned_role)
			//Service jobs
			if(JOB_NAME_CLOWN)
				heirloom_type = /obj/item/bikehorn/golden
			if(JOB_NAME_MIME)
				heirloom_type = /obj/item/reagent_containers/food/snacks/baguette/mime
			if(JOB_NAME_JANITOR)
				heirloom_type = pick(/obj/item/mop, /obj/item/clothing/suit/caution, /obj/item/reagent_containers/glass/bucket)
			if(JOB_NAME_COOK)
				heirloom_type = pick(/obj/item/reagent_containers/food/condiment/saltshaker, /obj/item/kitchen/rollingpin, /obj/item/clothing/head/chefhat)
			if(JOB_NAME_BOTANIST)
				heirloom_type = pick(/obj/item/cultivator, /obj/item/reagent_containers/glass/bucket, /obj/item/storage/bag/plants, /obj/item/toy/plush/beeplushie)
			if(JOB_NAME_BARTENDER)
				heirloom_type = pick(/obj/item/reagent_containers/glass/rag, /obj/item/clothing/head/that, /obj/item/reagent_containers/food/drinks/shaker)
			if(JOB_NAME_CURATOR)
				heirloom_type = pick(/obj/item/pen/fountain, /obj/item/storage/pill_bottle/dice)
			if(JOB_NAME_CHAPLAIN)
				heirloom_type = pick(/obj/item/toy/windupToolbox, /obj/item/reagent_containers/food/drinks/bottle/holywater)
			if(JOB_NAME_ASSISTANT)
				heirloom_type = pick(/obj/item/heirloomtoolbox, /obj/item/clothing/gloves/cut/heirloom)
			if(JOB_NAME_BARBER)
				heirloom_type = /obj/item/handmirror
			if(JOB_NAME_STAGEMAGICIAN)
				heirloom_type = /obj/item/gun/magic/wand
			//Security/Command
			if(JOB_NAME_CAPTAIN)
				heirloom_type = /obj/item/reagent_containers/food/drinks/flask/gold
			if(JOB_NAME_HEADOFSECURITY)
				heirloom_type = /obj/item/book/manual/wiki/security_space_law
			if(JOB_NAME_WARDEN)
				heirloom_type = /obj/item/book/manual/wiki/security_space_law
			if(JOB_NAME_SECURITYOFFICER)
				heirloom_type = pick(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
			if(JOB_NAME_DETECTIVE)
				heirloom_type = /obj/item/reagent_containers/food/drinks/bottle/whiskey
			if(JOB_NAME_LAWYER)
				heirloom_type = pick(/obj/item/gavelhammer, /obj/item/book/manual/wiki/security_space_law)
			if(JOB_NAME_BRIGPHYSICIAN)
				heirloom_type = pick(/obj/item/clothing/neck/stethoscope, /obj/item/book/manual/wiki/security_space_law)
			//RnD
			if(JOB_NAME_RESEARCHDIRECTOR)
				heirloom_type = /obj/item/toy/plush/slimeplushie
			if(JOB_NAME_SCIENTIST)
				heirloom_type = /obj/item/toy/plush/slimeplushie
			if(JOB_NAME_ROBOTICIST)
				heirloom_type = pick(subtypesof(/obj/item/toy/prize)) //look at this nerd
			//Medical
			if(JOB_NAME_CHIEFMEDICALOFFICER)
				heirloom_type = pick(/obj/item/clothing/neck/stethoscope, /obj/item/bodybag)
			if(JOB_NAME_MEDICALDOCTOR)
				heirloom_type = pick(/obj/item/clothing/neck/stethoscope, /obj/item/bodybag)
			if(JOB_NAME_PARAMEDIC)
				heirloom_type = pick(/obj/item/bodybag)
			if(JOB_NAME_CHEMIST)
				heirloom_type = /obj/item/reagent_containers/glass/chem_heirloom
			if(JOB_NAME_VIROLOGIST)
				heirloom_type = /obj/item/reagent_containers/dropper
			if(JOB_NAME_GENETICIST)
				heirloom_type = /obj/item/clothing/under/shorts/purple
			//Engineering
			if(JOB_NAME_CHIEFENGINEER)
				heirloom_type = pick(/obj/item/clothing/head/hardhat/white, /obj/item/screwdriver, /obj/item/wrench, /obj/item/weldingtool, /obj/item/crowbar, /obj/item/wirecutters)
			if(JOB_NAME_STATIONENGINEER)
				heirloom_type = pick(/obj/item/clothing/head/hardhat, /obj/item/screwdriver, /obj/item/wrench, /obj/item/weldingtool, /obj/item/crowbar, /obj/item/wirecutters)
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
		SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)

	to_chat(quirk_target, "<span class='boldnotice'>There is a precious family [heirloom.name] [where], passed down from generation to generation. Keep it safe!</span>")

	var/list/names = splittext(quirk_target.real_name, " ")
	var/family_name = names[names.len]

	heirloom.AddComponent(/datum/component/heirloom, quirk_holder, family_name)
	if(istype(heirloom, /obj/item/reagent_containers/glass/chem_heirloom)) //Edge case for chem_heirloom. Solution to component not being present on init.
		var/obj/item/reagent_containers/glass/chem_heirloom/H = heirloom
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
	value = -2
	mob_trait = TRAIT_EASYLIMBDISABLE
	gain_text = "<span class='danger'>You feel frail.</span>"
	lose_text = "<span class='notice'>You feel sturdy again.</span>"
	medical_record_text = "Patient has unusually frail bones, recommend calcium-rich diet."

/datum/quirk/foreigner
	name = "Foreigner"
	desc = "You're not from around here. You don't know Galactic Common!"
	value = -1
	gain_text = "<span class='notice'>The words being spoken around you don't make any sense."
	lose_text = "<span class='notice'>You've developed fluency in Galactic Common."
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
	value = -1
	mob_trait = TRAIT_HEAVY_SLEEPER
	gain_text = "<span class='danger'>You feel sleepy.</span>"
	lose_text = "<span class='notice'>You feel awake again.</span>"
	medical_record_text = "Patient has abnormal sleep study results and is difficult to wake up."

/datum/quirk/hypersensitive
	name = "Hypersensitive"
	desc = "For better or worse, everything seems to affect your mood more than it should."
	value = -1
	gain_text = "<span class='danger'>You seem to make a big deal out of everything.</span>"
	lose_text = "<span class='notice'>You don't seem to make a big deal out of everything anymore.</span>"

/datum/quirk/hypersensitive/add()
	var/datum/component/mood/mood = quirk_target.GetComponent(/datum/component/mood)
	if(mood)
		mood.mood_modifier += 0.5

/datum/quirk/hypersensitive/remove()
	var/datum/component/mood/mood = quirk_target.GetComponent(/datum/component/mood)
	if(mood)
		mood.mood_modifier -= 0.5

/datum/quirk/light_drinker
	name = "Light Drinker"
	desc = "You just can't handle your drinks and get drunk very quickly."
	value = -1
	mob_trait = TRAIT_LIGHT_DRINKER
	gain_text = "<span class='notice'>Just the thought of drinking alcohol makes your head spin.</span>"
	lose_text = "<span class='danger'>You're no longer severely affected by alcohol.</span>"

/datum/quirk/nearsighted //t. errorage
	name = "Nearsighted"
	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	value = -1
	gain_text = "<span class='danger'>Things far away from you start looking blurry.</span>"
	lose_text = "<span class='notice'>You start seeing faraway things normally again.</span>"
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
	value = -1
	process = TRUE

/datum/quirk/nyctophobia/on_process()
	var/mob/living/carbon/human/H = quirk_target
	if(H.dna.species.id in list("shadow", "nightmare"))
		return //we're tied with the dark, so we don't get scared of it; don't cleanse outright to avoid cheese
	var/turf/T = get_turf(quirk_target)
	if(T.get_lumcount() <= 0.2)
		if(quirk_target.m_intent == MOVE_INTENT_RUN)
			to_chat(quirk_target, "<span class='warning'>Easy, easy, take it slow... you're in the dark...</span>")
			quirk_target.toggle_move_intent()
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "nyctophobia", /datum/mood_event/nyctophobia)
	else
		SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "nyctophobia")

/datum/quirk/nonviolent
	name = "Pacifist"
	desc = "The thought of violence makes you sick. So much so, in fact, that you can't hurt anyone."
	value = -2
	mob_trait = TRAIT_PACIFISM
	gain_text = "<span class='danger'>You feel repulsed by the thought of violence!</span>"
	lose_text = "<span class='notice'>You think you can defend yourself again.</span>"
	medical_record_text = "Patient is unusually pacifistic and cannot bring themselves to cause physical harm."

/datum/quirk/trauma/paraplegic
	name = "Paraplegic"
	desc = "Your legs do not function. Nothing will ever fix this. But hey, free wheelchair!"
	value = -3
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
	value = -1
	mob_trait = TRAIT_POOR_AIM
	medical_record_text = "Patient possesses a strong tremor in both hands."

/datum/quirk/prosopagnosia
	name = "Prosopagnosia"
	desc = "You have a mental disorder that prevents you from being able to recognize faces at all."
	value = -1
	mob_trait = TRAIT_PROSOPAGNOSIA
	medical_record_text = "Patient suffers from prosopagnosia and cannot recognize faces."

/datum/quirk/prosthetic_limb
	name = "Prosthetic Limb"
	desc = "An accident caused you to lose one of your limbs. Because of this, you now have a random prosthetic!"
	value = -1
	var/slot_string = "limb"

/datum/quirk/prosthetic_limb/on_spawn()
	var/limb_slot = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/bodypart/old_part = H.get_bodypart(limb_slot)
	var/obj/item/bodypart/prosthetic
	switch(limb_slot)
		if(BODY_ZONE_L_ARM)
			prosthetic = new/obj/item/bodypart/l_arm/robot/surplus(quirk_target)
			slot_string = "left arm"
		if(BODY_ZONE_R_ARM)
			prosthetic = new/obj/item/bodypart/r_arm/robot/surplus(quirk_target)
			slot_string = "right arm"
		if(BODY_ZONE_L_LEG)
			prosthetic = new/obj/item/bodypart/l_leg/robot/surplus(quirk_target)
			slot_string = "left leg"
		if(BODY_ZONE_R_LEG)
			prosthetic = new/obj/item/bodypart/r_leg/robot/surplus(quirk_target)
			slot_string = "right leg"
	prosthetic.replace_limb(H)
	qdel(old_part)
	H.regenerate_icons()

/datum/quirk/prosthetic_limb/post_spawn()
	to_chat(quirk_target, "<span class='boldannounce'>Your [slot_string] has been replaced with a surplus prosthetic. It is fragile and will easily come apart under duress. Additionally, \
	you need to use a welding tool and cables to repair it, instead of bruise packs and ointment.</span>")

/datum/quirk/pushover
	name = "Pushover"
	desc = "Your first instinct is always to let people push you around. Resisting out of grabs will take conscious effort."
	value = -2
	mob_trait = TRAIT_GRABWEAKNESS
	gain_text = "<span class='danger'>You feel like a pushover.</span>"
	lose_text = "<span class='notice'>You feel like standing up for yourself.</span>"
	medical_record_text = "Patient presents a notably unassertive personality and is easy to manipulate."

/datum/quirk/insanity
	name = "Reality Dissociation Syndrome"
	desc = "You suffer from a severe disorder that causes very vivid hallucinations. Mindbreaker toxin can suppress its effects, and you are immune to mindbreaker's hallucinogenic properties. <b>This is not a license to grief.</b>"
	value = -2
	//no mob trait because it's handled uniquely
	gain_text = "<span class='userdanger'>...</span>"
	lose_text = "<span class='notice'>You feel in tune with the world again.</span>"
	medical_record_text = "Patient suffers from acute Reality Dissociation Syndrome and experiences vivid hallucinations."
	process = TRUE

/datum/quirk/insanity/on_process(delta_time)
	if(quirk_target.reagents.has_reagent(/datum/reagent/toxin/mindbreaker, needs_metabolizing = TRUE))
		quirk_target.hallucination = 0
		return
	if(DT_PROB(2, delta_time)) //we'll all be mad soon enough
		madness()

/datum/quirk/insanity/proc/madness()
	quirk_target.hallucination += rand(10, 25)

/datum/quirk/insanity/post_spawn() //I don't /think/ we'll need this but for newbies who think "roleplay as insane" = "license to kill" it's probably a good thing to have
	if(quirk_holder.special_role)
		return
	to_chat(quirk_target, "<span class='big bold info'>Please note that your dissociation syndrome does NOT give you the right to attack people or otherwise cause any interference to \
	the round. You are not an antagonist, and the rules will treat you the same as other crewmembers.</span>")

/datum/quirk/social_anxiety
	name = "Social Anxiety"
	desc = "Talking to people is very difficult for you, and you often stutter or even lock up."
	value = -1
	gain_text = "<span class='danger'>You start worrying about what you're saying.</span>"
	lose_text = "<span class='notice'>You feel comfortable with talking again.</span>" //if only it were that easy!
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
		H.stuttering = max(3, H.stuttering)
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "anxiety", /datum/mood_event/anxiety)
	else if(DT_PROB(min(3, nearby_people), delta_time) && !H.silent)
		to_chat(H, "<span class='danger'>You retreat into yourself. You <i>really</i> don't feel up to talking.</span>")
		H.silent = max(10, H.silent)
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "anxiety_mute", /datum/mood_event/anxiety_mute)
	else if(DT_PROB(0.5, delta_time) && dumb_thing)
		to_chat(H, "<span class='userdanger'>You think of a dumb thing you said a long time ago and scream internally.</span>")
		dumb_thing = FALSE //only once per life
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "anxiety_dumb", /datum/mood_event/anxiety_dumb)
		if(prob(1))
			new/obj/item/reagent_containers/food/snacks/spaghetti/pastatomato(get_turf(H)) //now that's what I call spaghetti code

//If you want to make some kind of junkie variant, just extend this quirk.
/datum/quirk/junkie
	name = "Junkie"
	desc = "You can't get enough of hard drugs."
	value = -2
	gain_text = "<span class='danger'>You suddenly feel the craving for drugs.</span>"
	lose_text = "<span class='notice'>You feel like you should kick your drug habit.</span>"
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
	if (!reagent_type)
		reagent_type = pick(drug_list)
	reagent_instance = new reagent_type()
	H.reagents.addiction_list.Add(reagent_instance)
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
		SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)

/datum/quirk/junkie/proc/announce_drugs()
	to_chat(quirk_target, "<span class='boldnotice'>There is a [initial(drug_container_type.name)] of [initial(reagent_type.name)] [where_drug]. Better hope you don't run out...</span>")

/datum/quirk/junkie/on_process()
	var/mob/living/carbon/human/H = quirk_target
	if(world.time > next_process)
		next_process = world.time + process_interval
		if(!H.reagents.addiction_list.Find(reagent_instance))
			if(QDELETED(reagent_instance))
				reagent_instance = new reagent_type()
			else
				reagent_instance.addiction_stage = 0
			H.reagents.addiction_list += reagent_instance
			to_chat(quirk_target, "<span class='danger'>You thought you kicked it, but you suddenly feel like you need [reagent_instance.name] again...</span>")

/datum/quirk/junkie/smoker
	name = "Smoker"
	desc = "Sometimes you just really want a smoke. Probably not great for your lungs."
	value = -1
	gain_text = "<span class='danger'>You could really go for a smoke right about now.</span>"
	lose_text = "<span class='notice'>You feel like you should quit smoking.</span>"
	medical_record_text = "Patient is a current smoker."
	reagent_type = /datum/reagent/drug/nicotine
	accessory_type = /obj/item/lighter/greyscale
	process = TRUE

/datum/quirk/junkie/smoker/on_spawn()
	drug_container_type = pick(/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/fancy/cigarettes/cigpack_midori,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift,
		/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold,
		/obj/item/storage/fancy/cigarettes/cigpack_carp)
	. = ..()

/datum/quirk/junkie/smoker/announce_drugs()
	to_chat(quirk_target, "<span class='boldnotice'>There is a [initial(drug_container_type.name)] [where_drug], and a lighter [where_accessory]. Make sure you get your favorite brand when you run out.</span>")


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
	value = -1
	gain_text = "<span class='danger'>You could really go for a drink right about now.</span>"
	lose_text = "<span class='notice'>You feel like you should quit drinking.</span>"
	medical_record_text = "Patient is an alcohol abuser."
	process = TRUE
	var/where_drink //Where the bottle spawned
	var/drink_types = list(/obj/item/reagent_containers/food/drinks/bottle/ale,
					/obj/item/reagent_containers/food/drinks/bottle/beer,
					/obj/item/reagent_containers/food/drinks/bottle/gin,
		            /obj/item/reagent_containers/food/drinks/bottle/whiskey,
					/obj/item/reagent_containers/food/drinks/bottle/vodka,
					/obj/item/reagent_containers/food/drinks/bottle/rum,
					/obj/item/reagent_containers/food/drinks/bottle/applejack)
	var/need = 0 // How much they crave alcohol at the moment
	var/tick_number = 0 // Keeping track of how many ticks have passed between a check
	var/obj/item/reagent_containers/food/drinks/bottle/drink_instance

/datum/quirk/alcoholic/on_spawn()
	drink_instance = pick(drink_types)
	drink_instance = new drink_instance()
	var/list/slots = list("in your backpack" = ITEM_SLOT_BACKPACK)
	var/mob/living/carbon/human/H = quirk_target
	where_drink = H.equip_in_one_of_slots(drink_instance, slots, FALSE) || "at your feet"

/datum/quirk/alcoholic/post_spawn()
	to_chat(quirk_target, "<span class='boldnotice'>There is a small bottle of [drink_instance] [where_drink]. You only have a single bottle, might have to find some more...</span>")

/datum/quirk/alcoholic/on_process()
	if(tick_number >= 6) // how many ticks should pass between a check
		tick_number = 0
		var/mob/living/carbon/human/H = quirk_target
		if(H.drunkenness > 0) // If they're not drunk, need goes up. else they're satisfied
			need = -15
		else
			need++

		switch(need)
			if(1 to 10)
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "alcoholic", /datum/mood_event/withdrawal_light, "alcohol")
				if(prob(5))
					to_chat(H, "<span class='notice'>You could go for a drink right about now.</span>")
			if(10 to 20)
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "alcoholic", /datum/mood_event/withdrawal_medium, "alcohol")
				if(prob(5))
					to_chat(H, "<span class='notice'>You feel like you need alcohol. You just can't stand being sober.</span>")
			if(20 to 30)
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "alcoholic", /datum/mood_event/withdrawal_severe, "alcohol")
				if(prob(5))
					to_chat(H, "<span class='danger'>You have an intense craving for a drink.</span>")
			if(30 to INFINITY)
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "alcoholic", /datum/mood_event/withdrawal_critical, "Alcohol")
				if(prob(5))
					to_chat(H, "<span class='boldannounce'>You're not feeling good at all! You really need some alcohol.</span>")
			else
				SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "alcoholic")
	tick_number++

/datum/quirk/unstable
	name = "Unstable"
	desc = "Due to past troubles, you are unable to recover your sanity if you lose it. Be very careful managing your mood!"
	value = -2
	mob_trait = TRAIT_UNSTABLE
	gain_text = "<span class='danger'>There's a lot on your mind right now.</span>"
	lose_text = "<span class='notice'>Your mind finally feels calm.</span>"
	medical_record_text = "Patient's mind is in a vulnerable state, and cannot recover from traumatic events."

/datum/quirk/trauma //Generic for quirks that apply a brain trauma
	name = "Phobia"
	desc = "Because of a traumatic event in your past you have developed a strong phobia."
	value = -2
	gain_text = null // these are handled by the trauma itself
	lose_text = null
	medical_record_text = "Patient suffers from a deeply-rooted phobia."
	var/datum/brain_trauma/trauma_type = /datum/brain_trauma/mild/phobia/
	var/trauma

/datum/quirk/trauma/add()
	trauma = new trauma_type
	var/mob/living/carbon/human/H = quirk_target
	H.gain_trauma(trauma, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/trauma/remove()
	var/mob/living/carbon/human/H = quirk_target
	H.cure_trauma_type(trauma, TRAUMA_RESILIENCE_ABSOLUTE)
