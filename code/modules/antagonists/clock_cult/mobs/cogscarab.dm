#define CLOCKDRONE	"drone_clock"

//====Cogscarab====

/mob/living/simple_animal/drone/cogscarab
	name = "Cogscarab"
	desc = "A mechanical device, filled with twisting cogs and mechanical parts, built to maintain Reebe."
	icon_state = "drone_clock"
	icon_living = "drone_clock"
	icon_dead = "drone_clock_dead"
	health = 60
	maxHealth = 60
	faction = list("neutral","silicon","turret", "ratvar")
	default_storage = /obj/item/storage/belt/utility/servant
	visualAppearence = CLOCKDRONE
	bubble_icon = "clock"
	picked = TRUE
	flavortext = ""

//====Shell====

/obj/item/drone_shell/cogscarab
	name = "cogscarab construct"
	desc = "The shell of an ancient construction drone, loyal to Ratvar."
	icon_state = "drone_clock_hat"
	drone_type = /mob/living/simple_animal/drone/cogscarab

/obj/item/drone_shell/cogscarab/attack_ghost(mob/user)
	if(is_banned_from(user.ckey, ROLE_SERVANT_OF_RATVAR) || QDELETED(src) || QDELETED(user))
		return
	if(CONFIG_GET(flag/use_age_restriction_for_jobs))
		if(!isnum(user.client.player_age)) //apparently what happens when there's no DB connected. just don't let anybody be a drone without admin intervention
			return
		if(user.client.player_age < 14)
			to_chat(user, "<span class='danger'>You're too new to play as a drone! Please try again in [14 - user.client.player_age] days.</span>")
			return
	if(!SSticker.mode)
		to_chat(user, "Can't become a cogscarab before the game has started.")
		return
	var/be_drone = alert("Become a cogscarab? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_drone == "No" || QDELETED(src) || !isobserver(user))
		return
	var/mob/living/simple_animal/drone/D = new drone_type(get_turf(loc))
	if(!D.default_hatmask && seasonal_hats && possible_seasonal_hats.len)
		var/hat_type = pick(possible_seasonal_hats)
		var/obj/item/new_hat = new hat_type(D)
		D.equip_to_slot_or_del(new_hat, SLOT_HEAD)
	D.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)
	D.key = user.key
	message_admins("[ADMIN_LOOKUPFLW(user)] has taken possession of \a [src] in [AREACOORD(src)].")
	log_game("[key_name(user)] has taken possession of \a [src] in [AREACOORD(src)].")
	qdel(src)
