/datum/language/terrum
	name = "Terrum"
	desc = "The language of the golems. Sounds similar to old-earth Hebrew."
	key = "g"
	space_chance = 40
	syllables = list(
		"sha", "vu", "nah", "ha", "yom", "ma", "cha", "ar", "et", "mol", "lua",
		"ch", "na", "sh", "ni", "yah", "bes", "ol", "hish", "ev", "la", "ot", "la",
		"khe", "tza", "chak", "hak", "hin", "hok", "lir", "tov", "yef", "yfe",
		"cho", "ar", "kas", "kal", "ra", "lom", "im", "bok",
		"erev", "shlo", "lo", "ta", "im", "yom"
	)
	special_characters = list("'")
	icon_state = "golem"
	default_priority = 90

/datum/language/terrum/get_random_name(
	gender = NEUTER,
	name_count = default_name_count,
	syllable_min = default_name_syllable_min,
	syllable_max = default_name_syllable_max,
	force_use_syllables = FALSE,
)
	if(force_use_syllables)
		return ..()

	var/name = pick(GLOB.golem_names)
	// 3% chance to be given a human surname
	if (prob(3))
		name += " [pick(GLOB.last_names)]"

	var/override = species_check(name)
	if(override)
		name = override
	return name



// This is the stupidest code I've ever written
// Basically, if your golem species is a certain type, it overrides the base golem random name
/datum/language/terrum/proc/species_check(name)
	if(!iscarbon(usr))
		return
	var/mob/living/carbon/carbon_user = usr

	//Cloth Golems
	if(istype(carbon_user.dna.species, /datum/species/golem/cloth))
		var/pharaoh_name = list(
			"Neferkare",
			"Hudjefa",
			"Khufu",
			"Mentuhotep",
			"Ahmose",
			"Amenhotep",
			"Thutmose",
			"Hatshepsut",
			"Tutankhamun",
			"Ramses",
			"Seti",
			"Merenptah",
			"Djer",
			"Semerkhet",
			"Nynetjer",
			"Khafre",
			"Pepi",
			"Intef",
			"Ay"
		) //yes, Ay was an actual pharaoh
		return "[pick(pharaoh_name)] \Roman[rand(1,99)]"

	//Runic Golems
	else if(istype(carbon_user.dna.species, /datum/species/golem/runic))
		var/edgy_first_name = list(
			"Razor",
			"Blood",
			"Dark",
			"Evil",
			"Cold",
			"Pale",
			"Black",
			"Silent",
			"Chaos",
			"Deadly",
			"Coldsteel"
		)
		var/edgy_last_name = list(
			"Edge",
			"Night",
			"Death",
			"Razor",
			"Blade",
			"Steel",
			"Calamity",
			"Twilight",
			"Shadow",
			"Nightmare"
		) //dammit Razor Razor
		return "[pick(edgy_first_name)] [pick(edgy_last_name)]"

	//Bananium Golems
	else if(istype(carbon_user.dna.species, /datum/species/golem/bananium))
		return "[uppertext(pick(GLOB.clown_names))]"

	return null


