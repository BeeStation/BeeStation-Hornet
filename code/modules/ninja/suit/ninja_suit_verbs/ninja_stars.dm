//Creates a throwing star
/obj/item/clothing/suit/space/space_ninja/proc/ninjastar()
	if(!ninjacost(10))
		var/obj/item/throwing_star/ninja/N = new(suit_user)
		if(suit_user.put_in_hands(N))
			to_chat(suit_user, "<span class='notice'>A throwing star has been created in your hand!</span>")
		else
			qdel(N)
		suit_user.throw_mode_on() //So they can quickly throw it.


/obj/item/throwing_star/ninja
	name = "ninja throwing star"
	throwforce = 30
	embedding = list("pain_mult" = 6, "embed_chance" = 180, "fall_chance" = 0)
