GLOBAL_LIST_EMPTY(scp529s)

/mob/living/simple_animal/cat/friendly/SCP529
	name = "SCP-529"
	desc = "A friendly tabby cat that seems to be missing half of her body."
	icon = 'icons/SCP/josie.dmi'
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	speak = list("Meow!","Esp!","Purr!","HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows","mews")
	emote_see = list("shakes her head", "shivers")
	response_help = "strokes"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"
	health = 50 //Josie is slightly more robust than most cats for anomalous reasons.
	maxHealth = 50
	gender = FEMALE

/mob/living/simple_animal/cat/friendly/SCP529/examine(mob/user)
	user << "<b><span class = 'safe'><big>SCP-529</big></span></b> - [desc]"
