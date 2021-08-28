/mob/proc/create_typing_indicator()
	return

/mob/proc/remove_typing_indicator()
	return

/mob/set_stat(new_stat)
	. = ..()
	if(.)
		remove_typing_indicator()

/mob/Logout()
	remove_typing_indicator()
	. = ..()

/mob/verb/say_wrapper()
	set name = ".Say"
	set hidden = 1

	create_typing_indicator()
	var/message = input("","say (text)") as text|null
	remove_typing_indicator()
	if(message)
		say_verb(message)

/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = 1

	create_typing_indicator()
	var/message = input("","me (text)") as text|null
	remove_typing_indicator()
	if(message)
		me_verb(message)
