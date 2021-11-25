/datum/quirk/jailbird
	name = "Jailbird"
	desc = "You're a wanted criminal! You start the round set to arrest for a random crime."
	value = -1

/datum/quirk/jailbird/post_add()
	. = ..()
	spawn(3 SECONDS) //Deliberately delayed a while to allow for the actual data_core entry to be created
		var/mob/living/carbon/human/H = quirk_holder
		var/quirk_crime	= pick(world.file2list("monkestation/strings/random_crimes.txt"))
		to_chat(H, "<span class='boldnotice'>You are on the run for your crime of: [quirk_crime]!</span>")
		var/crime = GLOB.data_core.createCrimeEntry(quirk_crime, "Galactic Crime Broadcast", "[pick(world.file2list("monkestation/strings/random_police.txt"))]", "[(rand(9)+1)] [pick("days", "weeks", "months", "years")] ago", 0)
		var/perpname = H.name
		var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
		GLOB.data_core.addCrime(R.fields["id"], crime)
		R.fields["criminal"] = "Arrest"
		H.sec_hud_set_security_status()
