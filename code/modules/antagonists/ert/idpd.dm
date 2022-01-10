////Outfit Datums////
/datum/outfit/ert/erpd
	name = "E.R.P.D. Grunt"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/ert/erpd
	suit_store = /obj/item/gun/energy/e_gun
	shoes = /obj/item/clothing/shoes/magboots/commando
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/breath
	glasses = /obj/item/clothing/glasses/hud/toggle/thermal
	back = /obj/item/tank/jetpack/oxygen
	belt = /obj/item/storage/belt/security/full
	r_hand = /obj/item/construction/rcd/combat
	id = /obj/item/card/id/ert
	ears = /obj/item/radio/headset/headset_cent/alt
	l_pocket = /obj/item/rcd_ammo/large

/datum/outfit/erpd/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	var/obj/item/implant/mindshield/L = new/obj/item/implant/mindshield(H)
	L.implant(H, null, 1)

	var/obj/item/implant/explosive/E = new/obj/item/implant/explosive(H)
	E.implant(H, null, 1)

	if(istype(H.s_store, /obj/item/gun/energy/e_gun))
		var/obj/item/gun/energy/e_gun/gun = H.s_store
		gun.selfcharge = TRUE

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_centcom_access("Death Commando")
	W.assignment = "E.R.P.D. Officer"
	W.registered_name = H.real_name
	W.update_label(W.registered_name, W.assignment)


/datum/outfit/ert/erpd/chief
	name = "E.R.P.D. Chief"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/erpd/chief
	suit_store = /obj/item/gun/energy/pulse/carbine/loyalpin
	l_pocket = /obj/item/gun/energy/pulse/pistol/loyalpin
	r_hand = null
	l_hand = null

/datum/outfit/ert/erpd/gazer
	name = "E.R.P.D. Gazer"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/erpd/gazer
	suit_store = /obj/item/gun/energy/laser/scatter
	l_pocket = /obj/item/reagent_containers/hypospray/combat
	l_hand = /obj/item/storage/firstaid/tactical
	r_hand = null

/datum/outfit/ert/erpd/gazer/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(!visualsOnly)
		H.dna.add_mutation(TK)
/datum/outfit/ert/erpd/titan
	name = "E.R.P.D. Titan"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/erpd/titan
	l_pocket = null
	l_hand = /obj/item/pickaxe/drill/jackhammer //BREACHING
	r_hand = null

/datum/outfit/ert/erpd/titan/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	var/obj/effect/proc_holder/spell/targeted/forcewall/erpd/wall = new
	H.AddSpell(wall)


////Antag Datums////
/datum/antagonist/ert/erpd
	name = "E.R.P.D. Grunt"
	role = "E.R.P.D. Grunt"
	outfit = /datum/outfit/ert/erpd

/datum/antagonist/ert/erpd/gazer
	name = "E.R.P.D. Gazer"
	role = "E.R.P.D. Gazer"
	outfit = /datum/outfit/ert/erpd/gazer

/datum/antagonist/ert/erpd/titan
	name = "E.R.P.D. Titan"
	role = "E.R.P.D. Titan"
	outfit = /datum/outfit/ert/erpd/titan

/datum/antagonist/ert/erpd/chief
	name = "E.R.P.D. Chief"
	role = "E.R.P.D. Chief"
	outfit = /datum/outfit/ert/erpd/chief

////Titan Spell
/obj/effect/proc_holder/spell/targeted/forcewall/erpd
	name = "Barrier Projector"
	desc = "Create an energy barrier to protect your team."
	charge_max = 400
	invocation = ""
	invocation_type = "none"
	wall_type = /obj/effect/forcefield/erpd

/obj/effect/forcefield/erpd

/obj/effect/forcefield/erpd/CanPass(atom/movable/mover, turf/target)
	. = ..()
	if(isliving(mover))
		return FALSE //None shall pass

////erpd Creation, handled by one_click_antag.dm
/datum/admins/proc/attemptMakeERPD(var/list/mob/dead/observer/candidates, var/num_agents, var/datum/ert/ertemplate, var/datum/team/ert/ert_team, var/datum/objective/missionobj) //They don't start at centcom (fuck you linter)
	if(num_agents > candidates.len || candidates.len == 0)
		return FALSE

	var/list/mob/dead/observer/chosen = list()
	for(var/X = 1, X <= num_agents, ++X)
		var/mob/dead/observer/chosen_one = pick_n_take(candidates)
		chosen += chosen_one //Go forth chosen one

	var/turf/spawnpoint = get_turf(pick(GLOB.blobstart)) //Ensures the portal spawns on station... for the most part.
	var/obj/effect/portal/erpd_portal = new(spawnpoint) //"Fake" portal spawns 20 seconds before the IDPD spawns in

	message_admins("E.R.P.D portal spawned at [ADMIN_VERBOSEJMP(erpd_portal)]")

	for(var/mob/dead/observer/chosen_one in chosen)
		chosen_one.orbit(erpd_portal)

	priority_announce("FLÄSHYN, ÖHU!", "Higher Dimensional Affairs", ANNOUNCER_SPANOMALIES)
	playsound(spawnpoint, 'sound/misc/erpd_portal.ogg', 100, 1)
	addtimer(CALLBACK(src, .proc/spawnIDPD, chosen, ertemplate, erpd_portal, ert_team, missionobj), 20 SECONDS)
	return TRUE

/datum/admins/proc/spawnIDPD(var/list/mob/dead/observer/chosen, var/datum/ert/ertemplate, var/obj/effect/portal/erpd_portal, var/datum/team/ert/ert_team, var/datum/objective/missionobj)
	var/spawnloc = erpd_portal.loc
	while(chosen.len)
		var/mob/dead/observer/newguy = pick_n_take(chosen)
		if(!newguy.client)
			continue

		//Spawn the body
		var/mob/living/carbon/human/ERTOperative = new ertemplate.mobtype(spawnloc)
		newguy.client.prefs.copy_to(ERTOperative)
		ERTOperative.key = newguy.key
		log_objective(ERTOperative, missionobj.explanation_text)

		ERTOperative.set_species(/datum/species/human) //Only the pure
		//Give antag datum
		var/datum/antagonist/ert/ert_antag

		if(chosen.len == 0)
			ert_antag = new ertemplate.leader_role
		else
			ert_antag = ertemplate.roles[WRAP(chosen.len,1,length(ertemplate.roles) + 1)]
			ert_antag = new ert_antag

		ERTOperative.mind.add_antag_datum(ert_antag,ert_team)
		ERTOperative.mind.assigned_role = ert_antag.name

		//Logging and cleanup
		log_game("[key_name(ERTOperative)] has been spawned as an [ert_antag.name]")

	message_admins("[ertemplate.polldesc] has spawned with the mission: [ertemplate.mission]")

	qdel(erpd_portal)
