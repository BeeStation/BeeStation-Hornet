/*
 * To target ships, we need to be able to see which turf is being targetted.
 * The problem with this is that ByondUI doesn't have an onclick function.
 * However, the turf you click on, counts as being a turf even if you click on the ByondUI.
 * This is cool, because we can give a weapon target spell,
 * get the turf that was clicked on, check if its on the ship selected and then boom, weapon targetted.
 *
 * Honestly, this is super janky and it kind of triggers me a little that I haven't figured out a better way to do it.
 * Perhaps just overlay another screen that intercepts all clicks over the top of the displayed map?
*/

/obj/effect/proc_holder/spell/set_weapon_target
	name = "Set target"
	desc = "Set the weapon's target"
	panel = ""
	ranged_mousepointer = 'icons/effects/cult_target.dmi'
	//Technology don't care about your stupid magic
	has_action = FALSE
	clothes_req = FALSE
	antimagic_allowed = TRUE
	var/obj/machinery/computer/weapons/linked_console

/obj/effect/proc_holder/spell/set_weapon_target/InterceptClickOn(mob/living/caller, params, atom/target)
	if(!linked_console)
		to_chat(caller, "<span class='warning'>No linked console.</span>")
		caller.RemoveSpell(/obj/effect/proc_holder/spell/set_weapon_target)
		return FALSE
	if(..())
		caller.RemoveSpell(/obj/effect/proc_holder/spell/set_weapon_target)
		return FALSE
	if(!linked_console.can_interact(caller))
		to_chat(caller, "<span class='warning'>You are too far away!</span>")
		caller.RemoveSpell(/obj/effect/proc_holder/spell/set_weapon_target)
		return FALSE
	if(!cast_check(FALSE, ranged_ability_user))
		caller.RemoveSpell(/obj/effect/proc_holder/spell/set_weapon_target)
		return FALSE
	var/turf/T = get_turf(target)
	if(!T)
		caller.RemoveSpell(/obj/effect/proc_holder/spell/set_weapon_target)
		return FALSE
	to_chat(caller, "<span class='notice'>Weapon targetted.</span>")
	if(prob(2))
		caller.say("FIRE!!!!", forced = "Shuttle weapon firing")
	var/obj/machinery/shuttle_weapon/weapon = linked_console.selected_weapon_system.resolve()
	caller.log_message("fired [weapon ? "[weapon] " : ""] at [AREACOORD(T)]", LOG_ATTACK, color="purple")
	log_shuttle_attack("fired [weapon ? "[weapon] " : ""] at [AREACOORD(T)]")
	linked_console.on_target_location(T)
	caller.RemoveSpell(/obj/effect/proc_holder/spell/set_weapon_target)
	return TRUE
