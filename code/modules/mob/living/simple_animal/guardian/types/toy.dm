//Toy
/mob/living/simple_animal/hostile/guardian/toy
	melee_damage = 0
	obj_damage = 0
	next_move_modifier = 0.1 //attacks 90% faster
	playstyle_string = "<span class='holoparasite'>As a <b>toy</b> type you are absolutely useless in every way, and a total liability to your owner. but you look cool!</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Clown, an utterly annoying and useless liability.</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Standard combat modules locked. Holoparasite swarm online.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! You caught one! It's weak and useless. Can I have a refund?.</span>"
	var/battlecry = "HONK"

/mob/living/simple_animal/hostile/guardian/toy/verb/Battlecry()
	set name = "Set Battlecry"
	set category = "Guardian"
	set desc = "Choose what you shout as you limply slap people."
	var/input = stripped_input(src,"What do you want your battlecry to be? Max length of 6 characters.", ,"", 7)
	if(input)
		if(CHAT_FILTER_CHECK(input))
			to_chat(src, "<span class='warning'>Your battlecry may not include prohibited words! Consider rereading the server rules.</span>")
			return
		else
			battlecry = input



/mob/living/simple_animal/hostile/guardian/toy/AttackingTarget()
	. = ..()
	if(isliving(target))
		say("[battlecry]!!", ignore_spam = TRUE)
		playsound(loc, src.attack_sound, 50, 1, 1)
