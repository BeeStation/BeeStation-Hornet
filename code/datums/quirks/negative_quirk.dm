//These traits primarily present a disadvantage to the players, some worse than others.

/datum/quirk/badback
	name = "Bad Back"
	desc = "Thanks to your poor posture, backpacks and other bags never sit right on your back. More evently weighted objects are fine, though."
	icon = "hiking"
	quirk_value = -1
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	medical_record_text = "Patient scans indicate severe and chronic back pain."
	gain_text = span_danger("Your back REALLY hurts!")
	lose_text = span_notice("Your back feels better.")
	mail_goodies = list(/obj/item/cane)
	var/datum/weakref/backpack

/datum/quirk/badback/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_target
	var/obj/item/storage/backpack/equipped_backpack = human_holder.back
	if(istype(equipped_backpack))
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "back_pain", /datum/mood_event/back_pain)
		RegisterSignal(human_holder.back, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(on_unequipped_backpack))
	else
		RegisterSignal(quirk_target, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equipped_item))

/datum/quirk/badback/remove()
	UnregisterSignal(quirk_target, COMSIG_MOB_EQUIPPED_ITEM)

	var/obj/item/storage/equipped_backpack = backpack?.resolve()
	if(equipped_backpack)
		UnregisterSignal(equipped_backpack, COMSIG_ITEM_PRE_UNEQUIP)
		SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "back_pain")

/// Signal handler for when the quirk_target equips an item. If it's a backpack, adds the back_pain mood event.
/datum/quirk/badback/proc/on_equipped_item(mob/living/source, obj/item/equipped_item, slot)
	SIGNAL_HANDLER

	if((slot != ITEM_SLOT_BACK) || !istype(equipped_item, /obj/item/storage/backpack))
		return

	SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "back_pain", /datum/mood_event/back_pain)
	RegisterSignal(equipped_item, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(on_unequipped_backpack))
	UnregisterSignal(quirk_target, COMSIG_MOB_EQUIPPED_ITEM)
	backpack = WEAKREF(equipped_item)

/// Signal handler for when the quirk_target unequips an equipped backpack. Removes the back_pain mood event.
/datum/quirk/badback/proc/on_unequipped_backpack(obj/item/source, force, atom/newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_ITEM_PRE_UNEQUIP)
	SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "back_pain")
	backpack = null
	RegisterSignal(quirk_target, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equipped_item))

/datum/quirk/blooddeficiency
	name = "Blood Deficiency"
	desc = "Your body can't produce enough blood to sustain itself."
	icon = "tint"
	quirk_value = -1
	gain_text = span_danger("You feel your vigor slowly fading away.")
	lose_text = span_notice("You feel vigorous again.")
	medical_record_text = "Patient requires regular treatment for blood loss due to low production of blood."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/item/reagent_containers/blood/OMinus) // universal blood type that is safe for all
	var/min_blood = BLOOD_VOLUME_SAFE - 25 // just barely survivable without treatment
	var/drain_rate = 0.275

/datum/quirk/blooddeficiency/process(delta_time)
	if(quirk_target.stat == DEAD)
		return

	var/mob/living/carbon/human/carbon_target = quirk_target
	if(HAS_TRAIT(carbon_target, TRAIT_NOBLOOD) || HAS_TRAIT(carbon_target, TRAIT_NO_BLOOD)) //can't lose blood if your species doesn't have any
		return

	if (carbon_target.blood_volume <= min_blood)
		return
	// Ensures that we don't reduce total blood volume below min_blood.
	carbon_target.blood_volume = max(min_blood, carbon_target.blood_volume - drain_rate * delta_time)

/datum/quirk/item_quirk/blindness
	name = "Blind"
	desc = "You are completely blind, nothing can counteract this."
	icon = "eye-slash"
	quirk_value = -1
	gain_text = span_danger("You can't see anything.")
	lose_text = span_notice("You miraculously gain back your vision.")
	medical_record_text = "Patient has permanent blindness."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/clothing/glasses/sunglasses, /obj/item/cane)

/datum/quirk/item_quirk/blindness/add_unique(client/client_source)
	give_item_to_holder(/obj/item/clothing/glasses/blindfold/white, list(LOCATION_EYES = ITEM_SLOT_EYES, LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/blindness/add(client/client_source)
	quirk_target.become_blind(QUIRK_TRAIT)

/datum/quirk/item_quirk/blindness/remove()
	quirk_target.cure_blind(QUIRK_TRAIT)

/datum/quirk/item_quirk/brainproblems
	name = "Brain Tumor"
	desc = "You have a little friend in your brain that is slowly destroying it. Thankfully, you start with a bottle of mannitol pills."
	icon = "brain"
	quirk_value = -1
	mob_trait = TRAIT_BRAIN_TUMOR
	gain_text = span_danger("You feel smooth.")
	lose_text = span_notice("You feel wrinkled again.")
	medical_record_text = "Patient has a tumor in their brain that is slowly driving them to brain death."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/item/storage/pill_bottle/mannitol/braintumor)
	var/notified = FALSE

/datum/quirk/item_quirk/brainproblems/add_unique(client/client_source)
	give_item_to_holder(
		/obj/item/storage/pill_bottle/mannitol/braintumor,
		list(
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS,
		),
		flavour_text = "These will keep you alive until you can secure a supply of medication. Don't rely on them too much!",
	)

/datum/quirk/item_quirk/brainproblems/process(delta_time)
	if(quirk_target.stat == DEAD)
		return

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

/datum/quirk/deafness
	name = "Deaf"
	desc = "You are incurably deaf."
	icon = "deaf"
	quirk_value = -1
	mob_trait = TRAIT_DEAF
	gain_text = span_danger("You can't hear anything.")
	lose_text = span_notice("You're able to hear again!")
	medical_record_text = "Patient's cochlear nerve is incurably damaged."
	//mail_goodies = list(/obj/item/clothing/mask/whistle)

/datum/quirk/depression
	name = "Depression"
	desc = "You sometimes just hate life."
	icon = "frown"
	quirk_value = -1
	mob_trait = TRAIT_DEPRESSION
	gain_text = span_danger("You start feeling depressed.")
	lose_text = span_notice("You no longer feel depressed.") //if only it were that easy!
	medical_record_text = "Patient has a severe mood disorder causing them to experience sudden moments of sadness."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	mail_goodies = list(/obj/item/storage/pill_bottle/happinesspsych)

/datum/quirk/item_quirk/family_heirloom
	name = "Family Heirloom"
	desc = "You are the current owner of an heirloom, passed down for generations. You have to keep it safe!"
	icon = "toolbox"
	quirk_value = -1
	medical_record_text = "Patient demonstrates an unnatural attachment to a family heirloom."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES|QUIRK_MOODLET_BASED
	/// A weak reference to our heirloom.
	var/datum/weakref/heirloom
	mail_goodies = list(/obj/item/storage/secure/briefcase)

/datum/quirk/item_quirk/family_heirloom/add_unique(client/client_source)
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/heirloom_type

	var/list/slots = list(
		LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
		LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
		LOCATION_BACKPACK = ITEM_SLOT_BACKPACK
	)

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
	var/obj/item/heirloom_item = new heirloom_type(get_turf(quirk_target))
	heirloom = WEAKREF(heirloom_item)
	give_item_to_holder(heirloom_item, slots, notify_player = FALSE)

/datum/quirk/item_quirk/family_heirloom/post_add()
	var/obj/item/heirloom_item = heirloom?.resolve()
	if(isnull(heirloom_item))
		return

	if(open_backpack)
		var/mob/living/carbon/human/H = quirk_target
		if(H.back?.atom_storage)
			H.back.atom_storage.show_contents(H)

	to_chat(quirk_target, span_boldnotice("There is a precious family [heirloom_item.name], passed down from generation to generation. Keep it safe!"))

	var/list/names = splittext(quirk_target.real_name, " ")
	var/family_name = names[names.len]

	heirloom_item.AddComponent(/datum/component/heirloom, quirk_holder, family_name)
	if(istype(heirloom_item, /obj/item/reagent_containers/cup/chem_heirloom)) //Edge case for chem_heirloom. Solution to component not being present on init.
		var/obj/item/reagent_containers/cup/chem_heirloom/H = heirloom_item
		H.update_name()

/datum/quirk/item_quirk/family_heirloom/process()
	if(quirk_target.stat == DEAD)
		return

	var/obj/item/heirloom_item = heirloom?.resolve()
	if(isnull(heirloom_item))
		return

	if(heirloom_item in quirk_target.GetAllContents())
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
	//mail_goodies = list(/obj/effect/spawner/random/medical/minor_healing)

/datum/quirk/foreigner
	name = "Foreigner"
	desc = "You're not from around here. You don't know Galactic Common!"
	icon = "question-circle"
	quirk_value = -1
	gain_text = span_notice("The words being spoken around you don't make any sense.")
	lose_text = span_notice("You've developed fluency in Galactic Common.")
	medical_record_text = "Patient does not speak Galactic Common and may require an interpreter."
	mail_goodies = list(/obj/item/taperecorder) // for translation

/datum/quirk/foreigner/add(client/client_source)
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
	mail_goodies = list(
		/obj/item/clothing/glasses/blindfold,
		/obj/item/bedsheet/random,
		/obj/item/clothing/under/misc/pj/red,
		/obj/item/clothing/under/misc/pj/blue,
	)

/datum/quirk/hypersensitive
	name = "Hypersensitive"
	desc = "Bad things affect your mood more than they should."
	icon = "flushed"
	quirk_value = -1
	gain_text = span_danger("You seem to make a big deal out of everything.")
	lose_text = span_notice("You don't seem to make a big deal out of everything anymore.")
	medical_record_text = "Patient demonstrates a high level of emotional volatility."
	//mail_goodies = list(/obj/effect/spawner/random/entertainment/plushie_delux)

/datum/quirk/item_quirk/nearsighted //t. errorage
	name = "Nearsighted"
	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	icon = "glasses"
	quirk_value = -1
	gain_text = span_danger("Things far away from you start looking blurry.")
	lose_text = span_notice("You start seeing faraway things normally again.")
	medical_record_text = "Patient requires prescription glasses in order to counteract nearsightedness."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/clothing/glasses/regular) // extra pair if orginal one gets broken by somebody mean

/datum/quirk/item_quirk/nearsighted/add_unique(client/client_source)
	give_item_to_holder(/obj/item/clothing/glasses/regular, list(
		LOCATION_EYES = ITEM_SLOT_EYES,
		LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
		LOCATION_HANDS = ITEM_SLOT_HANDS
		)
	)

/datum/quirk/item_quirk/nearsighted/add(client/client_source)
	quirk_target.become_nearsighted(QUIRK_TRAIT)

/datum/quirk/item_quirk/nearsighted/remove()
	quirk_target.cure_nearsighted(QUIRK_TRAIT)

/datum/quirk/nyctophobia
	name = "Nyctophobia"
	desc = "As far as you can remember, you've always been afraid of the dark. While in the dark without a light source, you instinctually act careful, and constantly feel a sense of dread."
	icon = "lightbulb"
	quirk_value = -1
	medical_record_text = "Patient demonstrates a fear of the dark."
	//mail_goodies = list(/obj/effect/spawner/random/engineering/flashlight)

/datum/quirk/nyctophobia/add()
	RegisterSignal(quirk_target, COMSIG_MOVABLE_MOVED, PROC_REF(on_holder_moved))

/datum/quirk/nyctophobia/remove()
	UnregisterSignal(quirk_target, COMSIG_MOVABLE_MOVED)
	SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "nyctophobia")

/// Called when the quirk holder moves. Updates the quirk holder's mood.
/datum/quirk/nyctophobia/proc/on_holder_moved(/mob/living/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(quirk_target.stat != CONSCIOUS || quirk_target.IsSleeping() || quirk_target.IsUnconscious())
		return

	var/mob/living/carbon/human/human_holder = quirk_target

	if(human_holder.dna?.species.id in list(SPECIES_SHADOWPERSON, SPECIES_NIGHTMARE))
		return

	if((human_holder.sight & SEE_TURFS) == SEE_TURFS)
		return

	var/turf/holder_turf = get_turf(quirk_target)

	var/lums = holder_turf.get_lumcount()

	if(lums > 0.2)
		SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "nyctophobia")
		return

	if(quirk_target.m_intent == MOVE_INTENT_RUN)
		to_chat(quirk_target, span_warning("Easy, easy, take it slow... you're in the dark..."))
		quirk_target.toggle_move_intent()
	SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "nyctophobia", /datum/mood_event/nyctophobia)

/datum/quirk/nonviolent
	name = "Pacifist"
	desc = "The thought of violence makes you sick. So much so, in fact, that you can't hurt anyone."
	icon = "peace"
	quirk_value = -1
	mob_trait = TRAIT_PACIFISM
	gain_text = span_danger("You feel repulsed by the thought of violence!")
	lose_text = span_notice("You think you can defend yourself again.")
	medical_record_text = "Patient is unusually pacifistic and cannot bring themselves to cause physical harm."
	//mail_goodies = list(/obj/effect/spawner/random/decoration/flower, /obj/effect/spawner/random/contraband/cannabis) // flower power

/datum/quirk/paraplegic
	name = "Paraplegic"
	desc = "Your legs do not function. Nothing will ever fix this. But hey, free wheelchair!"
	icon = "wheelchair"
	quirk_value = -1
	gain_text = null // Handled by trauma.
	lose_text = null
	medical_record_text = "Patient has an untreatable impairment in motor function in the lower extremities."
	mail_goodies = list(/obj/vehicle/ridden/wheelchair/motorized) //yes a fullsized unfolded motorized wheelchair does fit

/datum/quirk/paraplegic/add_unique(client/client_source)
	if(quirk_target.buckled) // Handle late joins being buckled to arrival shuttle chairs.
		quirk_target.buckled.unbuckle_mob(quirk_target)

	var/turf/holder_turf = get_turf(quirk_target)
	var/obj/structure/chair/spawn_chair = locate() in holder_turf

	var/obj/vehicle/ridden/wheelchair/wheels = new(holder_turf)
	if(spawn_chair) // Makes spawning on the arrivals shuttle more consistent looking
		wheels.setDir(spawn_chair.dir)

	wheels.buckle_mob(quirk_target)

	// During the spawning process, they may have dropped what they were holding, due to the paralysis
	// So put the things back in their hands.

	for(var/obj/item/dropped_item in holder_turf)
		if(dropped_item.fingerprintslast == quirk_target.ckey)
			quirk_target.put_in_hands(dropped_item)

/datum/quirk/paraplegic/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_target
	human_holder.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/paraplegic/remove()
	var/mob/living/carbon/human/human_holder = quirk_target
	human_holder.cure_trauma_type(/datum/brain_trauma/severe/paralysis/paraplegic, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/poor_aim
	name = "Poor Aim"
	desc = "You're terrible with guns and can't line up a straight shot to save your life. Dual-wielding is right out."
	icon = "bullseye"
	quirk_value = -1
	mob_trait = TRAIT_POOR_AIM
	medical_record_text = "Patient possesses a strong tremor in both hands."
	mail_goodies = list(/obj/item/cardboard_cutout) // for target practice

/datum/quirk/prosopagnosia
	name = "Prosopagnosia"
	desc = "You have a mental disorder that prevents you from being able to recognize faces at all."
	icon = "user-secret"
	quirk_value = -1
	mob_trait = TRAIT_PROSOPAGNOSIA
	medical_record_text = "Patient suffers from prosopagnosia and cannot recognize faces."
	//mail_goodies = list(/obj/item/skillchip/appraiser) // bad at recognizing faces but good at recognizing IDs

/datum/quirk/prosthetic_limb
	name = "Prosthetic Limb"
	desc = "An accident caused you to lose one of your limbs. Because of this, you now have a random prosthetic!"
	icon = "tg-prosthetic-leg"
	quirk_value = -1
	var/slot_string = "limb"
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/weldingtool/mini, /obj/item/stack/cable_coil/five)

/datum/quirk/prosthetic_limb/add_unique(client/client_source)
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

/datum/quirk/prosthetic_limb/post_add()
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
	//mail_goodies = list(/obj/item/clothing/gloves/cargo_gauntlet)

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
	mail_goodies = list(/obj/item/storage/pill_bottle/lsdpsych)

/datum/quirk/insanity/add(client/client_source)
	if(!iscarbon(quirk_target))
		return
	var/mob/living/carbon/carbon_quirk_holder = quirk_target

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

/datum/quirk/insanity/post_add()
	if(!quirk_target || quirk_holder.special_role)
		return
	// I don't /think/ we'll need this, but for newbies who think "roleplay as insane" = "license to kill",
	// it's probably a good thing to have.
	to_chat(quirk_target, "<span class='big bold info'>Please note that your [LOWER_TEXT(name)] does NOT give you the right to attack people or otherwise cause any interference to \
		the round. You are not an antagonist, and the rules will treat you the same as other crewmembers.</span>")

/datum/quirk/social_anxiety
	name = "Social Anxiety"
	desc = "Talking to people is very difficult for you, and you often stutter or even lock up."
	icon = "comment-slash"
	quirk_value = -1
	gain_text = span_danger("You start worrying about what you're saying.")
	lose_text = span_notice("You feel comfortable with talking again.") //if only it were that easy!
	medical_record_text = "Patient is usually anxious in social encounters and prefers to avoid them."
	mail_goodies = list(/obj/item/storage/pill_bottle/psicodine)
	var/dumb_thing = TRUE

/datum/quirk/social_anxiety/add()
	RegisterSignal(quirk_target, COMSIG_MOB_EYECONTACT, PROC_REF(eye_contact))
	RegisterSignal(quirk_target, COMSIG_MOB_EXAMINATE, PROC_REF(looks_at_floor))
	RegisterSignal(quirk_target, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/quirk/social_anxiety/remove()
	UnregisterSignal(quirk_target, list(COMSIG_MOB_EYECONTACT, COMSIG_MOB_EXAMINATE, COMSIG_MOB_SAY))

/datum/quirk/social_anxiety/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(HAS_TRAIT(quirk_target, TRAIT_FEARLESS))
		return

	var/datum/component/mood/mood = quirk_target.GetComponent(/datum/component/mood)
	var/moodmod
	if(mood)
		moodmod = (1+0.02*(50-(max(50, mood.mood_level*(7-mood.sanity_level))))) //low sanity levels are better, they max at 6
	else
		moodmod = (1+0.02*(50-(max(50, 0.1*quirk_target.nutrition))))
	var/nearby_people = 0
	for(var/mob/living/carbon/human/stranger in oview(3, quirk_target))
		if(stranger.client)
			nearby_people++
	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		var/list/message_split = splittext(message, " ")
		var/list/new_message = list()
		var/mob/living/carbon/human/quirker = quirk_target
		for(var/word in message_split)
			if(prob(max(5,(nearby_people*12.5*moodmod))) && word != message_split[1]) //Minimum 1/20 chance of filler
				new_message += pick("uh,","erm,","um,")
				if(prob(min(5,(0.05*(nearby_people*12.5)*moodmod)))) //Max 1 in 20 chance of cutoff after a succesful filler roll, for 50% odds in a 15 word sentence
					quirker.silent = max(3, quirker.silent)
					to_chat(quirker, span_danger("You feel self-conscious and stop talking. You need a moment to recover!"))
					break
			if(prob(max(5,(nearby_people*12.5*moodmod)))) //Minimum 1/20 chance of stutter
				word = html_decode(word)
				var/leng = length(word)
				var/stuttered = ""
				var/newletter = ""
				var/rawchar = ""
				var/static/regex/nostutter = regex(@@[aeiouAEIOU ""''()[\]{}.!?,:;_`~-]@)
				for(var/i = 1, i <= leng, i += length(rawchar))
					rawchar = newletter = word[i]
					if(prob(80) && !nostutter.Find(rawchar))
						if(prob(10))
							newletter = "[newletter]-[newletter]-[newletter]-[newletter]"
						else if(prob(20))
							newletter = "[newletter]-[newletter]-[newletter]"
						else
							newletter = "[newletter]-[newletter]"
					stuttered += newletter
				sanitize(stuttered)
				new_message += stuttered
			else
				new_message += word
		message = jointext(new_message, " ")
	var/mob/living/carbon/human/quirker = quirk_target
	if(prob(min(50,(0.50*(nearby_people*12.5)*moodmod)))) //Max 50% chance of not talking
		if(dumb_thing)
			to_chat(quirker, span_userdanger("You think of a dumb thing you said a long time ago and scream internally."))
			dumb_thing = FALSE //only once per life
			if(prob(1))
				new/obj/item/food/spaghetti/pastatomato(get_turf(quirker)) //now that's what I call spaghetti code
		else
			to_chat(quirk_target, span_warning("You think that wouldn't add much to the conversation and decide not to say it."))
			if(prob(min(25,(0.25*(nearby_people*12.75)*moodmod)))) //Max 25% chance of silence stacks after succesful not talking roll
				to_chat(quirker, span_danger("You retreat into yourself. You <i>really</i> don't feel up to talking."))
				quirker.silent = max(5, quirker.silent)
		speech_args[SPEECH_MESSAGE] = pick("Uh.","Erm.","Um.")
	else
		speech_args[SPEECH_MESSAGE] = message

// small chance to make eye contact with inanimate objects/mindless mobs because of nerves
/datum/quirk/social_anxiety/proc/looks_at_floor(datum/source, atom/A)
	SIGNAL_HANDLER

	var/mob/living/mind_check = A
	if(prob(85) || (istype(mind_check) && mind_check.mind))
		return

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), quirk_target, span_smallnotice("You make eye contact with [A].")), 3)

/datum/quirk/social_anxiety/proc/eye_contact(datum/source, mob/living/other_mob, triggering_examiner)
	SIGNAL_HANDLER

	if(prob(75))
		return
	var/msg
	if(triggering_examiner)
		msg = "You make eye contact with [other_mob], "
	else
		msg = "[other_mob] makes eye contact with you, "

	switch(rand(1,3))
		if(1)
			quirk_target.set_jitter_if_lower(20 SECONDS)
			msg += "causing you to start fidgeting!"
		if(2)
			quirk_target.stuttering = max(3, quirk_target.stuttering)
			msg += "causing you to start stuttering!"
		if(3)
			quirk_target.Stun(2 SECONDS)
			msg += "causing you to freeze up!"

	SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "anxiety_eyecontact", /datum/mood_event/anxiety_eyecontact)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), quirk_target, span_userdanger("[msg]")), 3) // so the examine signal has time to fire and this will print after
	return COMSIG_BLOCK_EYECONTACT

/datum/mood_event/anxiety_eyecontact
	description = "Sometimes eye contact makes me so nervous..."
	mood_change = -5
	timeout = 3 MINUTES

//If you want to make some kind of junkie variant, just extend this quirk.
/datum/quirk/item_quirk/junkie
	name = "Junkie"
	desc = "You can't get enough of hard drugs."
	icon = "pills"
	quirk_value = -1
	gain_text = span_danger("You suddenly feel the craving for drugs.")
	lose_text = span_notice("You feel like you should kick your drug habit.")
	medical_record_text = "Patient has a history of hard drugs."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	//mail_goodies = list(/obj/effect/spawner/random/contraband/narcotics)
	var/list/drug_list = list(/datum/reagent/drug/crank, /datum/reagent/drug/krokodil, /datum/reagent/medicine/morphine, /datum/reagent/drug/happiness, /datum/reagent/drug/methamphetamine, /datum/reagent/drug/ketamine) //List of possible IDs
	var/datum/reagent/reagent_type //!If this is defined, reagent_id will be unused and the defined reagent type will be instead.
	var/datum/reagent/reagent_instance //! actual instanced version of the reagent
	var/obj/item/drug_container_type //! If this is defined before pill generation, pill generation will be skipped. This is the type of the pill bottle.
	var/obj/item/accessory_type //! If this is null, an accessory won't be spawned.
	var/process_interval = 30 SECONDS //! how frequently the quirk processes
	var/next_process = 0 //! ticker for processing

/datum/quirk/item_quirk/junkie/add_unique(client/client_source)
	reagent_type = reagent_type || read_choice_preference(/datum/preference/choiced/quirk/junkie_drug)
	if (!reagent_type)
		reagent_type = pick(drug_list)
	reagent_instance = new reagent_type()
	var/mob/living/carbon/human/H = quirk_target
	H.reagents.addiction_list.Add(reagent_instance)

	if (!drug_container_type)
		drug_container_type = /obj/item/storage/pill_bottle
	var/obj/item/drug_instance = new drug_container_type(get_turf(H))
	if (istype(drug_instance, /obj/item/storage/pill_bottle))
		var/pill_state = pick(PILL_SHAPE_LIST)
		for(var/i in 1 to 7)
			var/obj/item/reagent_containers/pill/P = new(drug_instance)
			P.icon_state = pill_state
			P.reagents.add_reagent(reagent_type, 1)

	var/list/slots = list(
		LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
		LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
		LOCATION_BACKPACK = ITEM_SLOT_BACKPACK
	)
	give_item_to_holder(drug_instance, slots, flavour_text = "Better hope you don't run out...")

	if (accessory_type)
		var/obj/item/accessory_instance = new accessory_type(get_turf(H))
		give_item_to_holder(accessory_instance, slots, flavour_text = null)

/datum/quirk/item_quirk/junkie/post_add()
	..()

/datum/quirk/item_quirk/junkie/process()
	var/mob/living/carbon/human/H = quirk_target
	if(world.time > next_process)
		next_process = world.time + process_interval
		if(!H.reagents.addiction_list.Find(reagent_instance))
			if(QDELETED(reagent_instance))
				reagent_instance = new reagent_type()
			else
				reagent_instance.addiction_stage = 0
			H.reagents.addiction_list += reagent_instance
			to_chat(quirk_target, span_danger("You thought you kicked it, but you suddenly feel like you need [reagent_instance.name] again..."))

/datum/quirk/item_quirk/junkie/smoker
	name = "Smoker"
	desc = "Sometimes you just really want a smoke. Probably not great for your lungs."
	icon = "smoking"
	quirk_value = -1
	gain_text = span_danger("You could really go for a smoke right about now.")
	lose_text = span_notice("You feel like you should quit smoking.")
	medical_record_text = "Patient is a current smoker."
	reagent_type = /datum/reagent/drug/nicotine
	accessory_type = /obj/item/lighter/greyscale
	mail_goodies = list(
		//obj/effect/spawner/random/entertainment/cigarette_pack,
		//obj/effect/spawner/random/entertainment/cigar,
		//obj/effect/spawner/random/entertainment/lighter,
		/obj/item/clothing/mask/cigarette/pipe,
	)

/datum/quirk/item_quirk/junkie/smoker/add_unique(client/client_source)
	drug_container_type = read_choice_preference(/datum/preference/choiced/quirk/smoker_cigarettes)
	if(!drug_container_type)
		drug_container_type = pick(GLOB.smoker_cigarettes)
	. = ..()

/datum/quirk/item_quirk/junkie/smoker/post_add()
	..()

/datum/quirk/item_quirk/junkie/smoker/process()
	. = ..()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/I = H.get_item_by_slot(ITEM_SLOT_MASK)
	if (istype(I, /obj/item/clothing/mask/cigarette))
		var/obj/item/storage/fancy/cigarettes/C = drug_container_type
		if(istype(I, initial(C.spawn_type)))
			SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "wrong_cigs")
			return
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "wrong_cigs", /datum/mood_event/wrong_brand)

/datum/quirk/item_quirk/alcoholic
	name = "Alcoholic"
	desc = "You can't stand being sober."
	icon = "angry"
	quirk_value = -1
	gain_text = span_danger("You could really go for a drink right about now.")
	lose_text = span_notice("You feel like you should quit drinking.")
	medical_record_text = "Patient is an alcohol abuser."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	var/drink_types = list(/obj/item/reagent_containers/cup/glass/bottle/ale,
					/obj/item/reagent_containers/cup/glass/bottle/beer,
					/obj/item/reagent_containers/cup/glass/bottle/gin,
					/obj/item/reagent_containers/cup/glass/bottle/whiskey,
					/obj/item/reagent_containers/cup/glass/bottle/vodka,
					/obj/item/reagent_containers/cup/glass/bottle/rum,
					/obj/item/reagent_containers/cup/glass/bottle/applejack)
	var/need = 0 // How much they crave alcohol at the moment
	var/tick_number = 0 // Keeping track of how many ticks have passed between a check
	var/datum/weakref/drink_instance

/datum/quirk/item_quirk/alcoholic/add_unique(client/client_source)
	var/obj/item/bottle_type = read_choice_preference(/datum/preference/choiced/quirk/alcohol_type)
	if(!bottle_type)
		bottle_type = pick(drink_types)
	var/obj/item/bottle_instance = new bottle_type(get_turf(quirk_target))
	drink_instance = WEAKREF(bottle_instance)
	var/list/slots = list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK)
	give_item_to_holder(bottle_instance, slots, flavour_text = "You only have a single bottle, might have to find some more...")

/datum/quirk/item_quirk/alcoholic/post_add()
	..()

/datum/quirk/item_quirk/alcoholic/process()
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
	//mail_goodies = list(/obj/effect/spawner/random/entertainment/plushie)

/datum/quirk/phobia
	name = "Phobia"
	desc = "You are irrationally afraid of something."
	icon = "spider"
	quirk_value = -1
	medical_record_text = "Patient has an irrational fear of something."
	mail_goodies = list(/obj/item/clothing/glasses/blindfold, /obj/item/storage/pill_bottle/psicodine)

// Phobia will follow you between transfers
/datum/quirk/phobia/add(client/client_source)
	var/phobia = client_source?.prefs.read_preference(/datum/preference/choiced/quirk/phobia)
	if(!phobia)
		return

	var/mob/living/carbon/human/human_holder = quirk_target
	human_holder.gain_trauma(new /datum/brain_trauma/mild/phobia(phobia), TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/phobia/remove()
	var/mob/living/carbon/human/human_holder = quirk_target
	human_holder.cure_trauma_type(/datum/brain_trauma/mild/phobia, TRAUMA_RESILIENCE_ABSOLUTE)
