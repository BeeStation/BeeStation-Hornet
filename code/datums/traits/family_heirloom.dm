
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
	var/list/heirloom_table = list()

	if(prob(99))
		heirloom_table += H.dna.species.get_heirloom_list() // 1-A. Species specific table
	else
		heirloom_table += get_heirloom_list_species()       // 1-B. 1% chance for all species table
	heirloom_table += J.get_heirloom_list()                 // 2. Job specific table
	heirloom_table += get_department_items(quirk_holder)    // 3. Department specific table (job based)
	heirloom_table += get_heirloom_list_general()           // 4. For everyone
	if(prob(5))
		heirloom_table += get_heirloom_list_suspicious()    // 5. For everyone: suspicious items

	heirloom_type = pick(heirloom_table)

	if(!heirloom_type) //fail to load
		heirloom_type = /obj/item/toy/plush/heirloom_dummy
	heirloom = new heirloom_type(get_turf(quirk_holder))
	var/list/slots = list(
		"in your left pocket" = ITEM_SLOT_LPOCKET,
		"in your right pocket" = ITEM_SLOT_RPOCKET,
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
/datum/species/proc/get_heirloom_list() //species items
/datum/job/proc/get_heirloom_list() //Job items

//-----------------------SPECIES-----------------------
/datum/species/human/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/clothing/head/kitty), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/species/human/felinid/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/clothing/head/kitty), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/species/ipc/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/disk/data), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/species/ethereal/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/coin/plasma), only_root_path=TRUE)
			//I am not sure what to give them
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/species/plasmaman/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/coin/plasma), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/species/apid/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/toy/plush/beeplushie), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/species/moth/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/flashlight/lantern/heirloom_moth,
			/obj/item/toy/plush/moth), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/species/lizard/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/toy/plush/lizardplushie), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/species/oozeling/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/toy/plush/slimeplushie), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/species/fly/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

//a rare chance to roll everything
/datum/quirk/family_heirloom/proc/get_heirloom_list_species()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/clothing/head/kitty,
			/obj/item/toy/plush/lizardplushie,
			/obj/item/toy/plush/slimeplushie,
			/obj/item/flashlight/lantern/heirloom_moth,
			/obj/item/toy/plush/moth,
			/obj/item/toy/plush/beeplushie,
			/obj/item/coin/plasma,
			/obj/item/disk/data,
			/obj/item/reagent_containers/food/drinks/bottle/virusfood,
			/obj/item/toy/eldrich_book
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

//-------------------------JOBS-------------------------
//SERVICE
/datum/job/assistant/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	var/static/list/heirloom_items_base_random
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/storage/toolbox/mechanical/old/heirloom,
			/obj/item/clothing/gloves/cut/heirloom,
			/obj/item/multitool
		), only_root_path=TRUE)
	if(!heirloom_items_base_random)
		heirloom_items_base_random = typecacheof(list(
			/obj/item/clothing/under/color/grey/glorf
		), only_root_path=TRUE)
	if(prob(99.9))
		heirloom_items = heirloom_items_base
	else // 0.1% chance to add ancient jumpsuit
		heirloom_items = heirloom_items_base + heirloom_items_base_random
	return heirloom_items

/datum/job/janitor/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/mop,
			/obj/item/clothing/suit/caution,
			/obj/item/reagent_containers/glass/bucket
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/job/bartender/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/reagent_containers/glass/rag,
			/obj/item/clothing/head/that,
			/obj/item/reagent_containers/food/drinks/shaker
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/job/cook/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/reagent_containers/food/condiment/saltshaker,
			/obj/item/kitchen/rollingpin,
			/obj/item/clothing/head/chefhat
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// botanist
/datum/job/hydro/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/seeds/random //Would you dare to plant your heirloom?
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/job/curator/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/pen/fountain,
			/obj/item/storage/pill_bottle/dice
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/job/chaplain/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/toy/windupToolbox,
			/obj/item/reagent_containers/food/drinks/bottle/holywater
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// barber
/datum/job/gimmick/barber/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/handmirror
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// VIP
/datum/job/gimmick/celebrity/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/handmirror, //so narcissistic
			/obj/item/modular_computer/laptop/preset/civillian //for business.
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// debtor, aka hobo
/datum/job/gimmick/hobo/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_random
	if(!heirloom_random)
		heirloom_random = typecacheof(
			subtypesof(/obj/item/trash), only_root_path=TRUE)
	heirloom_items = list(
			pick(heirloom_random),
			pick(heirloom_random),
			pick(heirloom_random),
			pick(heirloom_random),
			pick(heirloom_random)
		)
	return heirloom_items

/datum/job/lawyer/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/gavelhammer,
			/obj/item/book/manual/wiki/security_space_law
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// Entertainers
/datum/job/clown/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/bikehorn/golden,
			/obj/item/bikehorn/golden,
			/obj/item/bikehorn/golden,
			/obj/item/bikehorn/golden,
			/obj/item/bikehorn/golden	//high chance of spawning them
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/job/mime/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/reagent_containers/food/snacks/baguette/mime,
			/obj/item/reagent_containers/food/snacks/baguette/mime,
			/obj/item/reagent_containers/food/snacks/baguette/mime,
			/obj/item/reagent_containers/food/snacks/baguette/mime,
			/obj/item/reagent_containers/food/snacks/baguette/mime	//high chance of spawning them
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// stage magician
/datum/job/gimmick/magician/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/gun/magic/wand,
			/obj/item/gun/magic/wand,
			/obj/item/gun/magic/wand,
			/obj/item/gun/magic/wand,
			/obj/item/gun/magic/wand	//high chance of spawning them
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

//SECURITY
// head of security
/datum/job/hos/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/job/warden/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/restraints/handcuffs
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// security officer
/datum/job/officer/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/clothing/head/beret/sec
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/job/detective/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/reagent_containers/food/drinks/bottle/whiskey
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/job/deputy/get_heirloom_list() //It won't happen, but coded just in case
	return

//Science
// research director
/datum/job/rd/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/nanite_remote
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/job/scientist/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/nanite_remote
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// exploration crew
/datum/job/exploration/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/nanite_remote
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/job/roboticist/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_random
	var/static/list/heirloom_items_base
	if(!heirloom_random)
		heirloom_random = typecacheof(
			subtypesof(/obj/item/toy/prize), only_root_path=TRUE)
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/book/manual/wiki/medicine
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base + pick(heirloom_random)
	return heirloom_items

//MEDICAL
// chief medical officer
/datum/job/cmo/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/book/manual/wiki/chemistry,
			/obj/item/book/manual/wiki/infections,
			/obj/item/reagent_containers/dropper,
			/obj/item/healthanalyzer
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// brig physician
/datum/job/brig_phys/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/healthanalyzer
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// medical doctor
/datum/job/doctor/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/healthanalyzer
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// paramedic
/datum/job/emt/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/healthanalyzer
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// psychiatrist
/datum/job/gimmick/shrink/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/healthanalyzer
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/job/chemist/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/book/manual/wiki/chemistry,
			/obj/item/storage/bag/chemistry,
			/obj/item/reagent_containers/dropper
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/job/virologist/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/book/manual/wiki/infections,
			/obj/item/book/manual/wiki/chemistry,
			/obj/item/storage/bag/bio,
			/obj/item/reagent_containers/food/drinks/bottle/virusfood,
			/obj/item/reagent_containers/dropper
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

/datum/job/geneticist/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/nanite_remote
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

//ENGINEERING
/datum/job/chief_engineer/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/clothing/head/hardhat/white
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// station engineer
/datum/job/engineer/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/clothing/head/hardhat
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// atmospheric technician
/datum/job/atmos/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/lighter,
			/obj/item/lighter/greyscale,
			/obj/item/storage/box/matches,
			/obj/item/tank/internals/emergency_oxygen/empty
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

//CARGO
// quartermaster
/datum/job/qm/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/stamp,
			/obj/item/stamp/denied
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// cargo technician
/datum/job/cargo_tech/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/clipboard
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// shaft miner
/datum/job/mining/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/pickaxe/mini,
			/obj/item/shovel
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

//COMMANDERS
/datum/job/captain/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/reagent_containers/food/drinks/flask/gold,
			/obj/item/reagent_containers/food/drinks/flask/gold,
			/obj/item/reagent_containers/food/drinks/flask/gold
			//hich chance of spawning captain's flask
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items

// head of personnel
/datum/job/hop/get_heirloom_list()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/toy/plush/ian
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items


//------------------DEPARTMENT ROLLS SET UP-----------------------
/datum/quirk/family_heirloom/proc/get_department_items(var/mob/living/carbon/human/H)
	var/list/heirloom_department = list()
	var/DEPARTMENT_FLAG = 0 // Bitflag for department shared items

	// This IF checks your job then turn on the bitflag
	// It's to get multiple departments from a mob rather than to get their 'real department'
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
		))
		DEPARTMENT_FLAG |= DEPARTMENT_SERVICE

	//SECURITY
	if(H.mind.assigned_role in list(
		    JOB_HOS,
		    JOB_WARDEN,
			JOB_SECURITY_OFFICER,
			JOB_DETECTIVE,
			JOB_DEPUTY,
			JOB_BRIG_PHYSICIAN
		))
		DEPARTMENT_FLAG |= DEPARTMENT_SECURITY

	//SCIENCE
	if(H.mind.assigned_role in list(
		    JOB_RD,
		    JOB_SCIENTIST,
			JOB_EXPLORATION_CREW,
			JOB_ROBOTICIST
		))
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
		))
		DEPARTMENT_FLAG |= DEPARTMENT_MEDICAL

	//ENGINEERING
	if(H.mind.assigned_role in list(
		    JOB_CE,
			JOB_STATION_ENGINEER,
			JOB_ATMOSPHERIC_TECHNICIAN
		))
		DEPARTMENT_FLAG |= DEPARTMENT_ENGINEERING

	//CARGO
	if(H.mind.assigned_role in list(
		    JOB_QM,
		    JOB_CARGO_TECHNICIAN,
			JOB_SHAFT_MINER
		))
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
		))
		DEPARTMENT_FLAG |= DEPARTMENT_COMMAND

	// Get items, and 1% chance to get items from other departments
	if(DEPARTMENT_FLAG & DEPARTMENT_SERVICE) //  || prob(1))
		heirloom_department += get_heirloom_list_d_service()
	if(DEPARTMENT_FLAG & DEPARTMENT_SECURITY) //  || prob(1))
		heirloom_department += get_heirloom_list_d_security()
	if(DEPARTMENT_FLAG & DEPARTMENT_SCIENCE) //  || prob(1))
		heirloom_department += get_heirloom_list_d_science()
	if(DEPARTMENT_FLAG & DEPARTMENT_MEDICAL) //  || prob(1))
		heirloom_department += get_heirloom_list_d_medical()
	if(DEPARTMENT_FLAG & DEPARTMENT_ENGINEERING) //  || prob(1))
		heirloom_department += get_heirloom_list_d_engineering()
	if(DEPARTMENT_FLAG & DEPARTMENT_CARGO) //  || prob(1))
		heirloom_department += get_heirloom_list_d_cargo()
	if(DEPARTMENT_FLAG & DEPARTMENT_COMMAND) //  || prob(1))
		heirloom_department += get_heirloom_list_d_command()

	return heirloom_department

//---------------------DEPARTMENT ROLLS-----------------------
// SERVICE
/datum/quirk/family_heirloom/proc/get_heirloom_list_d_service()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	var/list/heirloom_random = list()
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/reagent_containers/glass/bucket,
			/obj/item/storage/toolbox/mechanical/old/heirloom,
			/obj/item/storage/box/matches
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items+heirloom_random

// SECURITY
/datum/quirk/family_heirloom/proc/get_heirloom_list_d_security()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	var/list/heirloom_random = list()
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/book/manual/wiki/security_space_law,
			/obj/item/radio/off
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items+heirloom_random

/datum/quirk/family_heirloom/proc/get_heirloom_list_d_science()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	var/list/heirloom_random = list()
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/toy/plush/slimeplushie,
			/obj/item/reagent_containers/food/snacks/monkeycube,
			/obj/item/screwdriver,
			/obj/item/wrench,
			/obj/item/multitool
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items+heirloom_random

// MEDICAL
/datum/quirk/family_heirloom/proc/get_heirloom_list_d_medical()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	var/list/heirloom_random = list()
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/clothing/neck/stethoscope,
			/obj/item/book/manual/wiki/medicine,
			/obj/item/bodybag,
			/obj/item/surgical_drapes,
			/obj/item/scalpel,
			/obj/item/hemostat,
			/obj/item/retractor,
			/obj/item/cautery,
			/obj/item/bedsheet/medical
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items+heirloom_random

// ENGINEERING
/datum/quirk/family_heirloom/proc/get_heirloom_list_d_engineering()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	var/list/heirloom_random = list()
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/screwdriver,
			/obj/item/wrench,
			/obj/item/weldingtool,
			/obj/item/crowbar,
			/obj/item/wirecutters
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items+heirloom_random

// CARGO
/datum/quirk/family_heirloom/proc/get_heirloom_list_d_cargo()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	var/list/heirloom_random = list()
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/hand_labeler,
			/obj/item/shovel
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items+heirloom_random

// COMMAND
/datum/quirk/family_heirloom/proc/get_heirloom_list_d_command()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	var/list/heirloom_random = list()
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/reagent_containers/food/drinks/flask/gold,
			/obj/item/book/manual/wiki/security_space_law,
			/obj/item/clothing/glasses/sunglasses/advanced/gar/supergar,
			/obj/item/stamp,
			/obj/item/stamp/denied
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items+heirloom_random



//-------------------------FOR EVERYONE----------------------------/
//General items
/datum/quirk/family_heirloom/proc/get_heirloom_list_general()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	var/static/list/heirloom_random
	if(!heirloom_random)
		heirloom_random = typecacheof(subtypesof(/obj/item/bedsheet) - /obj/item/bedsheet/random, only_root_path=TRUE)
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/toy/cards/deck,
			/obj/item/lighter,
			/obj/item/dice/d20,
			/obj/item/book/manual/wiki/security_space_law //1984. all crews are encouraged to hold this book all times. giving higher chance for sec.
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base + pick(heirloom_random)
	return heirloom_items

//Suspicious items
/datum/quirk/family_heirloom/proc/get_heirloom_list_suspicious()
	var/list/heirloom_items = list()
	var/static/list/heirloom_items_base
	//var/list/heirloom_random = list()
	if(!heirloom_items_base)
		heirloom_items_base = typecacheof(list(
			/obj/item/storage/toolbox/mechanical/old/heirloom/syndicate,
			/obj/item/toy/cards/deck/heirloom,
			/obj/item/soap/syndie,
			/obj/item/reagent_containers/food/drinks/syndicatebeer/heirloom,
			/obj/item/book/manual/wiki/traitor,
			/obj/item/scalpel/heirloom_fake,
			/obj/item/heirloom_hypermatter_bin
		), only_root_path=TRUE)
	heirloom_items = heirloom_items_base
	return heirloom_items


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
	//You get this when Family Heirloom fail to load an item, but this is still functional as a toy plushie.
