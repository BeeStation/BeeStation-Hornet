// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj/projectile signals (sent to the firer)
#define COMSIG_PROJECTILE_SELF_ON_HIT "projectile_self_on_hit"			// from base of /obj/projectile/proc/on_hit(): (atom/movable/firer, atom/target, Angle)
#define COMSIG_PROJECTILE_ON_HIT "projectile_on_hit"			// from base of /obj/projectile/proc/on_hit(): (atom/movable/firer, atom/target, Angle)
#define COMSIG_PROJECTILE_BEFORE_FIRE "projectile_before_fire" 			// from base of /obj/projectile/proc/fire(): (obj/projectile, atom/original_target)
#define COMSIG_PROJECTILE_PREHIT "com_proj_prehit"				// sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_RANGE_OUT "projectile_range_out"				// sent to targets during the process_hit proc of projectiles
#define COMSIG_EMBED_TRY_FORCE "item_try_embed"					// sent when trying to force an embed (mainly for projectiles, only used in the embed element)
	#define COMPONENT_EMBED_SUCCESS (1<<1)						// returned when the embed is successful

#define COMSIG_PELLET_CLOUD_INIT "pellet_cloud_init"				// sent to targets during the process_hit proc of projectiles
