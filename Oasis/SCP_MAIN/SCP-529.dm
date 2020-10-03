GLOBAL_LIST_EMPTY(scp529s)

/mob/living/simple_animal/cat/friendly/SCP529
	name = "Josie"
	icon = 'Oasis/SCP_MAIN/SCP_ICONS/josie.dmi'
	desc = "<b><span class='notice'><big>SCP-529</big></span></b> - A friendly tabby cat that seems to be missing half of her body."
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
 . = ..()

