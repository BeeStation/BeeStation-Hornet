/**
 * Same idea as Ian, but without the puppy phase, and we put a new name on.
 */

#define SECURITY_DOG_MEMORY_FILE "data/npc_saves/security_dog.json"

GLOBAL_LIST_INIT(security_dog_male_names, list(
	"Ace",
	"Bandit",
	"Boomer", //The equivalent of calling your pet 'cheeseburger'
	"Bruno",
	"Diesel",
	"Duke",
	"Gunner",
	"Hobbes",
	"Hunk",
	"Kaiser",
	"Magnum",
	"Nero",
	"Ranger",
	"Rex",
	"Rocco",
	"Titus",
	//"Toddlerdestroyer" //Pitbull name, but for good dogs (noncanon)
	"Tyson",
	"Walder", //Walter but ASOIAF :)
	"Walter",
	"Walther",
))

GLOBAL_LIST_INIT(security_dog_female_names, list(
	"Athena", //The coolest greek goddess, obv
	"Freya",
	"Juno",
	"Lillith",
	"Luna",
	"Maple",
	"Nyx",
	"Princess", //Pitbull name, but canon
	"Roxy",
	"Sable",
	"Scout", //Apparentely a girl's name
	"Trixie",
	"Valkyrie",
	"Vega",
))

/**
 * Typepath we can use to spawn. Technically doesn't even have to be a dog
 */
GLOBAL_LIST_INIT(security_dog_breeds, list(
	/mob/living/basic/pet/dog/bullterrier = 40,
	/mob/living/basic/pet/dog/pug = 10,
	/mob/living/basic/pet/dog/corgi = 25,
	/mob/living/basic/pet/dog/corgi/cardigan = 25,
))

/**
 * Attempt to steal last shifts dog. (This is shitty Ian code)
 */
/proc/requisition_security_dog()
	var/json_file = file(SECURITY_DOG_MEMORY_FILE)
	if(fexists(json_file))
		var/list/save_data = json_decode(rustg_file_read(json_file))
		if(islist(save_data) && save_data["name"])
			//Sanity check the breed still exists
			var/saved_breed = text2path(save_data["breed"])
			if(saved_breed in GLOB.security_dog_breeds)
				return list(
					"name" = save_data["name"],
					"gender" = save_data["gender"] == FEMALE ? FEMALE : MALE,
					"breed" = saved_breed,
					"tenure" = isnum(save_data["tenure"]) ? save_data["tenure"] : 0,
				)

	var/new_gender = prob(50) ? MALE : FEMALE
	return list(
		"name" = pick(new_gender == FEMALE ? GLOB.security_dog_female_names : GLOB.security_dog_male_names),
		"gender" = new_gender,
		"breed" = pick_weight(GLOB.security_dog_breeds),
		"tenure" = 0,
	)

/datum/component/security_dog
	///Breed name, grab from type
	var/breed
	///How many shifts this dog has survived
	var/tenure = 0
	///We make a callback if his ass survived to the end
	var/datum/callback/survival_check
	///Is your fate sealed?
	var/memory_saved = FALSE

/datum/component/security_dog/Initialize(dog_name, dog_gender, dog_tenure = 0)
	. = ..()
	if(!istype(parent, /mob/living/basic/pet/dog))
		return COMPONENT_INCOMPATIBLE

	tenure = dog_tenure
	var/mob/living/basic/pet/dog/dog = parent
	//Grab real_name before overwriting
	breed = dog.real_name
	dog.gender = dog_gender
	dog.unique_pet = TRUE
	dog.fully_replace_character_name(null, dog_name)

	claim_dogbed(dog)

	survival_check = CALLBACK(src, PROC_REF(check_survival))
	SSticker.OnRoundend(survival_check)

	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/security_dog/Destroy(force)
	LAZYREMOVE(SSticker.round_end_events, survival_check)
	survival_check = null
	return ..()

/datum/component/security_dog/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE, COMSIG_ATOM_EXAMINE))

/**
 * The dogbed is static, so we just overwrite it with the dogs name
 */
/datum/component/security_dog/proc/claim_dogbed(mob/living/dog)
	var/area/dog_area = get_area(dog)
	if(!dog_area)
		return
	for(var/turf/area_turf as anything in dog_area.get_turfs_by_zlevel(dog.z))
		for(var/obj/structure/bed/dogbed/tyson/bed in area_turf)
			bed.update_owner(dog, force = TRUE)
			return

/**
 * The security posting is described here rather than baked into desc, because the corgi
 * breeds reset their desc back to the type default every time their hat changes.
 */
/datum/component/security_dog/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("[source.p_Theyre()] Security's [breed], and [source.p_they()] take[source.p_s()] the job a good deal more seriously than most of these knuckleheads.")
	if(tenure)
		examine_list += span_notice("[source.p_They()] [source.p_have()] held the posting for [tenure] shift[tenure == 1 ? "" : "s"] running.")

/datum/component/security_dog/proc/on_death(mob/living/source, gibbed)
	SIGNAL_HANDLER
	write_memory(dead = TRUE)

/datum/component/security_dog/proc/on_revive(mob/living/source)
	SIGNAL_HANDLER
	//Back on the roster, so let the roundend check save us again.
	memory_saved = FALSE

///Roundend check: if we're still standing, we keep the posting.
/datum/component/security_dog/proc/check_survival()
	var/mob/living/dog = parent
	if(!dog.stat)
		write_memory(dead = FALSE)

///Records this dog for next shift. A dead dog leaves no save behind, which is what makes the randomiser spin.
/datum/component/security_dog/proc/write_memory(dead)
	var/mob/living/dog = parent
	if(memory_saved || !dog.write_memory(dead))
		return
	memory_saved = TRUE

	var/json_file = file(SECURITY_DOG_MEMORY_FILE)
	fdel(json_file)
	if(dead)
		return

	var/list/file_data = list(
		"name" = dog.real_name,
		"gender" = dog.gender,
		"breed" = "[dog.type]",
		"tenure" = tenure + 1,
	)
	WRITE_FILE(json_file, json_encode(file_data, JSON_PRETTY_PRINT))

/**
 * The dog. basically a map spawner we swap in at init for whatever breed/name got chosen
 */
/mob/living/basic/pet/dog/bullterrier/tyson
	name = "Tyson"
	real_name = "Tyson"
	gender = MALE
	desc = "A sturdy bull terrier with a friendly but watchful demeanour."
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/dog/bullterrier/tyson/Initialize(mapload)
	. = ..()
	if(mapload)
		return INITIALIZE_HINT_LATELOAD
	report_for_duty()

/mob/living/basic/pet/dog/bullterrier/tyson/LateInitialize()
	. = ..()
	report_for_duty()

///Swaps mr hardcoded out
/mob/living/basic/pet/dog/bullterrier/tyson/proc/report_for_duty()
	var/turf/kennel = get_turf(src)
	if(kennel)
		var/list/on_duty = requisition_security_dog()
		var/breed = on_duty["breed"]
		var/mob/living/basic/pet/dog/dog = new breed(kennel)
		dog.AddComponent(/datum/component/security_dog, on_duty["name"], on_duty["gender"], on_duty["tenure"])
	qdel(src)

#undef SECURITY_DOG_MEMORY_FILE
