// a DEFINE file that contains client_eye reltated things

/* ------------------- Summary of the system -------------------
 * BeeStation eye system works differently than other stations. The logic is:
 * 		< Standard station >
 * 			mob.reset_perspective(camera_eye)
 * 			-> client.set_eye(camera_eye)
 *
 * 		< BeeStation >
 * 			mob.set_mob_eye_to(camera_eye)
 * 			-> mob._on_setting_mob_eye(camera_eye)
 * 			-> client.set_client_eye_to(camera_eye)
 * 			-> client._on_setting_client_eye(camera_eye)
 * 		* NOTE: Do not call the procs here, except for set_mob_eye_to(). This is the only proc you are ALLOWED to use.
 *
 * From calling set_mob_eye_to() AND set_client_eye_to(), the game stores the eye data into:
 * 		(from /camera_eye)
 * 			/atom/var/list/eye_users = list(YOUR_MOB)
 * 			/atom/var/list/eye_mobs = list(YOUR_CLIENT)
 * 			/mob/var/atom/current_mob_eye = YOUR_MOB
 * 		(from /client. It is YOU)
 * 			/client/var/eye = camera_eye
 * 			/client/var/eye_weakref = (old eye that was used before camera_eye)
 *
 * 	### Why do you need this?
 * 		This system is robust to keep your eye sanely.
 *		For example, if Dullahan's head is away from their body, they should see things from their head.
 *  	This should be actively managed even if the dullahan mob is clientless.
 *  	Once the clientless dullahan becomes client-holder, the player will be able to see things of the changes that made to the head.
 * 		i.e. You are disconnected. Dullahan eye(head) is sent to another z. You login. You see things at the another z. Your body is still at the station.
*/

/// necessary for set_client_eye_to() proc. This is used to compare a value. This exists because 'null' is occupied other values, and you cannot check if that's true null.
#define CLIENT_OLD_EYE_NULL "client_eye_null_hint"

/// Sets mob eye to themselves. This exists because set_mob_eye_to(src) is a bad idea. MOB_EYE_SELF will redirect to call 'get_my_eye()' which indicates the true themselves. (i.e. Dullahan's view is not src. Their view is /obj/head.)
#define MOB_EYE_SELF "mob_eye_self"





// -----------------------------------------------------------------------------
// From this section, these exist to warn people when they use deprecated system.
// If things are warning you, it means you've been doing something wrong, and you'd need to read what's wrong from below.

// a janky code that restricts you using these DM flags. No, you shouldn't use these.
#define MOB_PERSPECTIVE __do_not_use_this__use_EYE_PERSPECTIVE() //! MOB_PERSPECTIVE is not used in this codebase. Please use "EYE_PERSPECTIVE"
#define EDGE_PERSPECTIVE __do_not_use_this__use_EYE_PERSPECTIVE() //! EDGE_PERSPECTIVE is not used in this codebase. Please use "EYE_PERSPECTIVE"
	// ------- Why do we use EYE_PERSPECTIVE only? -------
	// /client/var/perspective has three options: MOB_PERSPECTIVE, EDGE_PERSPECTIVE, EYE_PERSPECTIVE
	// If your client eye is your mob, and you use EYE_PERSPECTIVE, it is identical MOB_PERSPECTIVE
	// Instead of checking which perspective your client use, it's easy to manage to make everything is EYE_PERSPECTIVE

/// [WARNING] This is a deprecated proc in Beestation. Do not use this. Use `set_mob_eye_to(THING)` instead.
/// If you are not sure how to replace this proc, consult EvilDragon.
#define set_eye(...) __DO_NOT_USE_set_eye___USE_set_mob_eye_to()
/// [WARNING] This is a deprecated proc in Beestation. Do not use this. Use `set_mob_eye_to(THING)` instead.
/// If you are not sure how to replace this proc, consult EvilDragon.
#define reset_perspective(...) __DO_NOT_USE_reset_perspective___USE_set_mob_eye_to()

/* 	---------------- Instruction of porting ----------------
Do the things below instead of using reset_perspective() , set_eye()

--------------------------------------------------

/client/proc/makes_client_eye_different(camera_eye)
	DO NOT  :  client.eye = camera_eye               // NEVER: direct value assignment
	DO NOT  :  client.set_eye(camera_eye)            // NO: Deprecated proc
	DO NOT  :  client.set_client_eye_to(camera_eye)  // NO: Calling client proc
		*Warning:  set_client_eye_to() IS NOT a public proc, and shouldn't be used in general. Use "set_mob_eye_to(camera_eye)"


/mob/proc/makes_my_eye_different(camera_eye)
	DO NOT  :  reset_perspective()      // NO: Deprecated proc, null value
	DO NOT  :  reset_perspective(null)  // NO: Deprecated proc, null value
	DO NOT  :  reset_perspective(src)   // NO: Deprecated proc, using src
	DO NOT  :  set_mob_eye_to(src)      // NO: using src
	DO THIS :  set_mob_eye_to(MOB_EYE_SELF) // Correct

	DO NOT  :  reset_perspective(camera_eye) // NO: Deprecated proc
	DO THIS :  set_mob_eye_to(camera_eye)    // Correct

	DO NOT  :  if(client)     set_mob_eye_to(camera_eye)    // NO: Checking client
	DO THIS :  set_mob_eye_to(camera_eye)                   // Correct
		* REASON:  set_mob_eye_to() proc already manages the client side in backend. If you do "if(client)", this will break the system.

/obj/proc/some_item_proc(mob/user)
	DO NOT  :  user.client.set_eye(src)     // NO: Deprecated proc
	DO NOT  :  user.reset_perspective(src)  // NO: Deprecated proc
	DO THIS :  user.set_mob_eye_to(src)     // Correct
		* REASON: This is the only case where 'src' is allowed (because it's /obj)

	DO NOT  :  user.set_mob_eye_to(user)          // NO: "user" is yourself.
	DO THIS :  user.set_mob_eye_to(MOB_EYE_SELF)  // Correct (MOB_EYE_SELF is user)

--------------------------------------------------*/
