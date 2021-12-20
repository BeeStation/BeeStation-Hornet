
/datum/quirk/family_heirloom
	name = "Family Heirloom"
	desc = "You are the current owner of an heirloom, passed down for generations. You have to keep it safe!"
	value = -1
	mood_quirk = TRUE
	var/obj/item/heirloom
	var/where


/datum/quirk/family_heirloom/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/datum/job/J = SSjob.GetJob(H.mind.assigned_role)
	var/obj/item/heirloom_type
	var/list/tablesize = list()
	var/weightvalue = 0

	//Calculate the table size before picking up
	if(prob(99))
		tablesize += H.dna.species.get_heirloom_list(TRUE)                // 1-A. Species specific table
	else
		tablesize += get_heirloom_list_species(TRUE)                      // 1-B. 1% chance for all species table
	tablesize += J.get_heirloom_list(TRUE)+tablesize[1]                   // 2. Job specific table
	tablesize += get_department_items(TRUE, quirk_holder)+tablesize[2]    // 3. Department specific table (job based)
	tablesize += get_heirloom_list_general(TRUE)+tablesize[3]             // 4. For everyone
	if(prob(3))
		tablesize += get_heirloom_list_suspicious(TRUE)+tablesize[4]      // 5. For everyone: 3% chance suspicious items
	else
		tablesize += tablesize[4]  // still need to calculate the size

	weightvalue = rand(1, tablesize[5])
	if(weightvalue <= tablesize[1])
		if(tablesize[1] < 9) // less then 9 means it's not a roll for all racial heirlooms. there's no species having 9 items in their heirloom table.
			heirloom_type = H.dna.species.get_heirloom_list()
		else
			heirloom_type = get_heirloom_list_species()
	else if(weightvalue > tablesize[1] && weightvalue <= tablesize[2])
		heirloom_type = J.get_heirloom_list()
	else if(weightvalue > tablesize[2] && weightvalue <= tablesize[3])
		heirloom_type = get_department_items(FALSE, quirk_holder)
	else if(weightvalue > tablesize[3] && weightvalue <= tablesize[4])
		heirloom_type = get_heirloom_list_general()
	else if(weightvalue > tablesize[4] && weightvalue <= tablesize[5])
		heirloom_type = get_heirloom_list_suspicious()
	else
		heirloom_type = /obj/item/toy/plush/heirloom_dummy // something weird value happened

<<<<<<< HEAD
=======
	world.log << "0:1 / 1: [tablesize[1]] / 2: [tablesize[2]] / 3: [tablesize[3]] / 4: [tablesize[4]] / 5: [tablesize[5]] / rand: [weightvalue]"
>>>>>>> family

	//fail to pick an item from table
	if(!heirloom_type)
		heirloom_type = /obj/item/toy/plush/heirloom_dummy

	heirloom = new heirloom_type(get_turf(quirk_holder))
	var/list/slots = list(
		//"in your left pocket" = ITEM_SLOT_LPOCKET,
		//"in your right pocket" = ITEM_SLOT_RPOCKET, //since they're buggy, I comentized them. Maybe a better way someday.
		"in your backpack" = ITEM_SLOT_BACKPACK
	)
	where = H.equip_in_one_of_slots(heirloom, slots, FALSE) || "at your feet"



/datum/quirk/family_heirloom/post_add()
	if(where == "in your backpack")
		var/mob/living/carbon/human/H = quirk_holder
		SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)

	to_chat(quirk_holder, "<span class='boldnotice'>There is a precious family [heirloom.name] [where], passed down from generation to generation. Keep it safe!</span>")

	var/list/names = splittext(quirk_holder.real_name, " ")
	var/family_name = names[names.len]

	heirloom.AddComponent(/datum/component/heirloom, quirk_holder.mind, family_name)

/datum/quirk/family_heirloom/on_process()
	if(heirloom in quirk_holder.GetAllContents())
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom_missing")
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "family_heirloom", /datum/mood_event/family_heirloom)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom")
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "family_heirloom_missing", /datum/mood_event/family_heirloom_missing)

/datum/quirk/family_heirloom/clone_data()
	return heirloom

/datum/quirk/family_heirloom/on_clone(data)
	heirloom = data

//procs for heirloom trait
/datum/species/proc/get_heirloom_list(var/lencheck) //species items
/datum/job/proc/get_heirloom_list(var/lencheck) //Job items

//-----------------------SPECIES-----------------------
/datum/species/human/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/clothing/head/kitty)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/species/human/felinid/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/clothing/head/kitty)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/species/ipc/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/disk/data)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/species/ethereal/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/coin/plasma)
			//I am not sure what to give them
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/species/plasmaman/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/coin/plasma)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/species/apid/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/toy/plush/beeplushie)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/species/moth/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/flashlight/lantern/heirloom_moth,
			/obj/item/toy/plush/moth)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/species/lizard/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/toy/plush/lizardplushie)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/species/oozeling/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/toy/plush/slimeplushie)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/species/fly/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/reagent_containers/food/drinks/bottle/virusfood)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

//a rare chance to roll everything
/datum/quirk/family_heirloom/proc/get_heirloom_list_species(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/clothing/head/kitty,
			/obj/item/toy/plush/lizardplushie,
			/obj/item/toy/plush/slimeplushie,
			/obj/item/flashlight/lantern/heirloom_moth,
			/obj/item/toy/plush/moth,
			/obj/item/toy/plush/beeplushie,
			/obj/item/coin/plasma,
			/obj/item/disk/data,
			/obj/item/reagent_containers/food/drinks/bottle/virusfood,
			/obj/item/toy/eldrich_book)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

//-------------------------JOBS-------------------------
//SERVICE
/datum/job/assistant/get_heirloom_list(var/lencheck)
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	var/static/list/heirloom_items_base_random
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/storage/toolbox/mechanical/old/heirloom,
			/obj/item/clothing/gloves/cut/heirloom,
			/obj/item/multitool)
	if(!heirloom_items_base_random)
		heirloom_items_base_random = list(
			/obj/item/clothing/under/color/grey/glorf)
	if(lencheck)
		return length(heirloom_items_base) //you don't have to calculate a pickweight of the ancient jumpsuit chance
	if(prob(99.9))
		heirloom_items = heirloom_items_base
	else // 0.1% chance to add ancient jumpsuit
		heirloom_items = heirloom_items_base + heirloom_items_base_random
	return heirloom_items

/datum/job/janitor/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/mop,
			/obj/item/clothing/suit/caution,
			/obj/item/reagent_containers/glass/bucket)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/job/bartender/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/reagent_containers/glass/rag,
			/obj/item/clothing/head/that,
			/obj/item/reagent_containers/food/drinks/shaker)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/job/cook/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/reagent_containers/food/condiment/saltshaker,
			/obj/item/kitchen/rollingpin,
			/obj/item/clothing/head/chefhat)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// botanist
/datum/job/hydro/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/seeds/random) //Would you dare to plant your heirloom?
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/job/curator/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/pen/fountain,
			/obj/item/storage/pill_bottle/dice)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/job/chaplain/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/toy/windupToolbox,
			/obj/item/reagent_containers/food/drinks/bottle/holywater)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// barber
/datum/job/gimmick/barber/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/handmirror)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// VIP
/datum/job/gimmick/celebrity/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/handmirror, //so narcissistic
			/obj/item/modular_computer/laptop/preset/civillian) //for business.
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// debtor, aka hobo
/datum/job/gimmick/hobo/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_random
	if(!heirloom_random)
		heirloom_random = subtypesof(/obj/item/trash)
	if(lencheck)
		return 5 // debtor will have a high chance to get trash
	return pick(heirloom_random)

/datum/job/lawyer/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/gavelhammer,
			/obj/item/book/manual/wiki/security_space_law)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// Entertainers
/datum/job/clown/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/bikehorn/golden)
	if(lencheck)
		return 10 // clown will have a high chance to get a golden horn
	return pick(heirloom_items_base)

/datum/job/mime/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/reagent_containers/food/snacks/baguette/mime)
	if(lencheck)
		return 10 // mime will have a high chance to get a baguette
	return pick(heirloom_items_base)

// stage magician
/datum/job/gimmick/magician/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/gun/magic/wand)
	if(lencheck)
		return 10 // magician will have a high chance to get wand
	return pick(heirloom_items_base)

//SECURITY
// head of security
/datum/job/hos/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
		) // nothing
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/job/warden/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/restraints/handcuffs)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// security officer
/datum/job/officer/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/clothing/head/beret/sec)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/job/detective/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/reagent_containers/food/drinks/bottle/whiskey)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/job/deputy/get_heirloom_list() //It won't happen, but coded just in case
	return

//Science
// research director
/datum/job/rd/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/nanite_remote)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/job/scientist/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/nanite_remote)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// exploration crew
/datum/job/exploration/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/nanite_remote)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/job/roboticist/get_heirloom_list(var/lencheck)
	var/list/heirloom_items = list()
	var/static/list/heirloom_random
	var/static/list/heirloom_items_base
	if(!heirloom_random)
		heirloom_random = subtypesof(/obj/item/toy/prize)
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/book/manual/wiki/medicine)
	if(lencheck)
		return length(heirloom_items_base)
	heirloom_items = heirloom_items_base + pick(heirloom_random)
	return pick(heirloom_items)

//MEDICAL
// chief medical officer
/datum/job/cmo/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/book/manual/wiki/chemistry,
			/obj/item/book/manual/wiki/infections,
			/obj/item/reagent_containers/dropper,
			/obj/item/healthanalyzer)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// brig physician
/datum/job/brig_phys/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/healthanalyzer)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// medical doctor
/datum/job/doctor/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/healthanalyzer)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// paramedic
/datum/job/emt/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/healthanalyzer)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// psychiatrist
/datum/job/gimmick/shrink/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/healthanalyzer)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/job/chemist/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/book/manual/wiki/chemistry,
			/obj/item/storage/bag/chemistry,
			/obj/item/reagent_containers/dropper)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/job/virologist/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/book/manual/wiki/infections,
			/obj/item/book/manual/wiki/chemistry,
			/obj/item/storage/bag/bio,
			/obj/item/reagent_containers/food/drinks/bottle/virusfood,
			/obj/item/reagent_containers/dropper)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/job/geneticist/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/nanite_remote)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

//ENGINEERING
/datum/job/chief_engineer/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/clothing/head/hardhat/white)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// station engineer
/datum/job/engineer/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/clothing/head/hardhat)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// atmospheric technician
/datum/job/atmos/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/lighter,
			/obj/item/lighter/greyscale,
			/obj/item/storage/box/matches,
			/obj/item/tank/internals/emergency_oxygen/empty)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

//CARGO
// quartermaster
/datum/job/qm/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/stamp,
			/obj/item/stamp/denied)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// cargo technician
/datum/job/cargo_tech/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/clipboard)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// shaft miner
/datum/job/mining/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/pickaxe/mini,
			/obj/item/shovel)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

//COMMANDERS
/datum/job/captain/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/reagent_containers/food/drinks/flask/gold)
	if(lencheck)
		return 4 //hich chance of spawning captain's flask
	return pick(heirloom_items_base)

// head of personnel
/datum/job/hop/get_heirloom_list(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/toy/plush/ian)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)


//------------------DEPARTMENT ROLLS SET UP-----------------------
/datum/quirk/family_heirloom/proc/get_department_items(var/lencheck, var/mob/living/carbon/human/H)
	var/static/DEPARTMENT_FLAG // Bitflag for department shared items
	var/tablesize = 0

	if(lencheck)
		DEPARTMENT_FLAG = 0 //We're going to initialize this when we calculate size

	// This IF checks your job then turn on the bitflag
	// It's to get multiple departments from a mob rather than to get their 'real department'
	// "|| prob(1)" means you get this flag at 1% chance
	//SERVICE
	if(H.mind.assigned_role in list(
		    JOB_ASSISTANT,
		    JOB_JANITOR,
		    JOB_BARTENDER,
		    JOB_COOK,
		    JOB_BOTANIST,
		    JOB_CURATOR,
		    JOB_CHAPLAIN,
		    JOB_LAWYER,
		    JOB_BARBER,
		    JOB_DEBTOR,
		    JOB_CLOWN,
		    JOB_MIME,
		    JOB_STAGE_MAGICIAN,
			JOB_PSYCHIATRIST, //this is the true nature of your job.
		    JOB_VIP
		) || prob(1))
		DEPARTMENT_FLAG |= DEPARTMENT_SERVICE

	//SECURITY
	if(H.mind.assigned_role in list(
		    JOB_HOS,
		    JOB_WARDEN,
			JOB_SECURITY_OFFICER,
			JOB_DETECTIVE,
			JOB_DEPUTY,
			JOB_BRIG_PHYSICIAN
		) || prob(1))
		DEPARTMENT_FLAG |= DEPARTMENT_SECURITY

	//SCIENCE
	if(H.mind.assigned_role in list(
		    JOB_RD,
		    JOB_SCIENTIST,
			JOB_EXPLORATION_CREW,
			JOB_ROBOTICIST
		) || prob(1))
		DEPARTMENT_FLAG |= DEPARTMENT_SCIENCE

	//MEDICAL
	if(H.mind.assigned_role in list(
		    JOB_CMO,
		    JOB_BRIG_PHYSICIAN,
			JOB_MEDICAL_DOCTOR,
			JOB_PARAMEDIC,
			JOB_PSYCHIATRIST,
			JOB_CHEMIST,
			JOB_VIROLOGIST,
			JOB_GENETICIST
		) || prob(1))
		DEPARTMENT_FLAG |= DEPARTMENT_MEDICAL

	//ENGINEERING
	if(H.mind.assigned_role in list(
		    JOB_CE,
			JOB_STATION_ENGINEER,
			JOB_ATMOSPHERIC_TECHNICIAN
		) || prob(1))
		DEPARTMENT_FLAG |= DEPARTMENT_ENGINEERING

	//CARGO
	if(H.mind.assigned_role in list(
		    JOB_QM,
		    JOB_CARGO_TECHNICIAN,
			JOB_SHAFT_MINER
		) || prob(1))
		DEPARTMENT_FLAG |= DEPARTMENT_CARGO

	//COMMAND
	if(H.mind.assigned_role in list(
			JOB_CAPTAIN,
			JOB_HOP,
		    JOB_HOS,
			JOB_RD,
			JOB_CMO,
			JOB_CE,
			JOB_VIP // just for giving annoying items
		) || prob(1))
		DEPARTMENT_FLAG |= DEPARTMENT_COMMAND

	//Do not change these into else-if
	if(lencheck)
		if(DEPARTMENT_FLAG & DEPARTMENT_SERVICE)
			tablesize += get_heirloom_list_d_service(lencheck)
		if(DEPARTMENT_FLAG & DEPARTMENT_SECURITY)
			tablesize += get_heirloom_list_d_security(lencheck)
		if(DEPARTMENT_FLAG & DEPARTMENT_SCIENCE)
			tablesize += get_heirloom_list_d_science(lencheck)
		if(DEPARTMENT_FLAG & DEPARTMENT_MEDICAL)
			tablesize += get_heirloom_list_d_medical(lencheck)
		if(DEPARTMENT_FLAG & DEPARTMENT_ENGINEERING)
			tablesize += get_heirloom_list_d_engineering(lencheck)
		if(DEPARTMENT_FLAG & DEPARTMENT_CARGO)
			tablesize += get_heirloom_list_d_cargo(lencheck)
		if(DEPARTMENT_FLAG & DEPARTMENT_COMMAND)
			tablesize += get_heirloom_list_d_command(lencheck)
		return tablesize

	// Get items
	for(var/i = 0, i<100, i++)
		var/n = rand(1,7)
		if(DEPARTMENT_FLAG & DEPARTMENT_SERVICE && n==1)
			return pick(get_heirloom_list_d_service())
		else if(DEPARTMENT_FLAG & DEPARTMENT_SECURITY && n==2)
			return pick(get_heirloom_list_d_security())
		else if(DEPARTMENT_FLAG & DEPARTMENT_SCIENCE && n==3)
			return pick(get_heirloom_list_d_science())
		else if(DEPARTMENT_FLAG & DEPARTMENT_MEDICAL && n==4)
			return pick(get_heirloom_list_d_medical())
		else if(DEPARTMENT_FLAG & DEPARTMENT_ENGINEERING && n==5)
			return pick(get_heirloom_list_d_engineering())
		else if(DEPARTMENT_FLAG & DEPARTMENT_CARGO && n==6)
			return pick(get_heirloom_list_d_cargo())
		else if(DEPARTMENT_FLAG & DEPARTMENT_COMMAND && n==7)
			return pick(get_heirloom_list_d_command())

	return pick(get_heirloom_list_d_service()) //when fail to load something

//---------------------DEPARTMENT ROLLS-----------------------
// SERVICE
/datum/quirk/family_heirloom/proc/get_heirloom_list_d_service(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/reagent_containers/glass/bucket,
			/obj/item/storage/toolbox/mechanical/old/heirloom,
			/obj/item/storage/box/matches)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)


// SECURITY
/datum/quirk/family_heirloom/proc/get_heirloom_list_d_security(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/book/manual/wiki/security_space_law,
			/obj/item/radio/off)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

/datum/quirk/family_heirloom/proc/get_heirloom_list_d_science(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/toy/plush/slimeplushie,
			/obj/item/reagent_containers/food/snacks/monkeycube,
			/obj/item/screwdriver,
			/obj/item/wrench,
			/obj/item/multitool)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// MEDICAL
/datum/quirk/family_heirloom/proc/get_heirloom_list_d_medical(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/clothing/neck/stethoscope,
			/obj/item/book/manual/wiki/medicine,
			/obj/item/bodybag,
			/obj/item/surgical_drapes,
			/obj/item/scalpel,
			/obj/item/hemostat,
			/obj/item/retractor,
			/obj/item/cautery,
			/obj/item/bedsheet/medical)
	if(lencheck)
		return 5 //too much of them. Let's give a custom pickweight.
	return pick(heirloom_items_base)

// ENGINEERING
/datum/quirk/family_heirloom/proc/get_heirloom_list_d_engineering(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/screwdriver,
			/obj/item/wrench,
			/obj/item/weldingtool,
			/obj/item/crowbar,
			/obj/item/wirecutters)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// CARGO
/datum/quirk/family_heirloom/proc/get_heirloom_list_d_cargo(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/hand_labeler,
			/obj/item/shovel)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)

// COMMAND
/datum/quirk/family_heirloom/proc/get_heirloom_list_d_command(var/lencheck)
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/reagent_containers/food/drinks/flask/gold,
			/obj/item/book/manual/wiki/security_space_law,
			/obj/item/clothing/glasses/sunglasses/advanced/gar/supergar,
			/obj/item/stamp,
			/obj/item/stamp/denied)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)



//-------------------------FOR EVERYONE----------------------------/
//General items
/datum/quirk/family_heirloom/proc/get_heirloom_list_general(var/lencheck)
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	var/static/list/heirloom_random
	if(!heirloom_random)
		heirloom_random = subtypesof(/obj/item/bedsheet) - /obj/item/bedsheet/random
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/toy/cards/deck,
			/obj/item/lighter,
			/obj/item/dice/d20,
			/obj/item/book/manual/wiki/security_space_law) //1984. all crews are encouraged to hold this book all times. giving higher chance for sec.
	if(lencheck)
		return length(heirloom_items_base)+1 // +1 for random bedsheets
	heirloom_items = heirloom_items_base + pick(heirloom_random)
	return pick(heirloom_items)

//Suspicious items
/datum/quirk/family_heirloom/proc/get_heirloom_list_suspicious(var/lencheck)
	var/static/list/heirloom_items_base
	//var/list/heirloom_random = list()
	if(!heirloom_items_base)
		heirloom_items_base = list(
			/obj/item/storage/toolbox/mechanical/old/heirloom/syndicate,
			/obj/item/toy/cards/deck/heirloom,
			/obj/item/soap/syndie,
			/obj/item/reagent_containers/food/drinks/syndicatebeer/heirloom,
			/obj/item/book/manual/wiki/traitor,
			/obj/item/scalpel/heirloom_fake,
			/obj/item/heirloom_hypermatter_bin)
	if(lencheck)
		return length(heirloom_items_base)
	return pick(heirloom_items_base)


//family heirloom fakes
/obj/item/scalpel/heirloom_fake
	// Note: this should not be subtype of supermatter scalpel because it can do the actual antag operation.
	name = "hypermatter scalpel"
	desc = "A scalpel with a fragile tip of condensed unrecognizable gas mix of highly-suspicious-looking-purpose, searingly cold to the touch, that can safely shave a sliver off a hypermatter crystal... wait, what is a hypermatter?"
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "supermatter_scalpel"
	damtype = "fire"
	force = 8 //still does fire damage, but -2 less damage than normal scalpel
	throwforce = 4
	usesound = 'sound/weapons/bladeslice.ogg'

/obj/item/heirloom_hypermatter_bin
	name = "hypermatter bin"
	desc = "A tiny receptacle that releases an inert unrecognizable gas mix of highly-suspicious-looking-purpose upon sealing, allowing a sliver of a hypermatter crystal to be safely stored... wait, what is a hypermatter?"
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "core_container_empty"
	item_state = "tile"
	lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'

/obj/item/toy/plush/heirloom_dummy
	name = "???"
	desc = "Your family heirloom is something weird and you are not sure what this is. <font color = red>You'd be better to contact CentCom to check if your family heirloom is fine...</font>"
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	attack_verb = list("clutched", "hissed", "impregnated")
	squeak_override = list('sound/weapons/slash.ogg' = 1)
	//You get this when Family Heirloom fails to load an item, but this is still functional as a toy plushie.
