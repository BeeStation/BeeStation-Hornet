// /datum/component/container_item
/// (atom/container, mob/user) - returns bool
#define COMSIG_CONTAINER_TRY_ATTACH "container_try_attach"
/// Sent when the amount of materials in material_container changes
#define COMSIG_MATERIAL_CONTAINER_CHANGED "material_container_changed"
/// Sent when the amount of materials in silo connected to remote_materials changes. Does not apply when remote_materials is not connected to a silo.
#define COMSIG_REMOTE_MATERIALS_CHANGED "remote_materials_changed"

