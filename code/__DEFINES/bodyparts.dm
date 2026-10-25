#define BODYZONE_STYLE_DEFAULT 0
#define BODYZONE_STYLE_MEDICAL 1

#define BODYZONE_CONTEXT_COMBAT 0
#define BODYZONE_CONTEXT_INJECTION 1
#define BODYZONE_CONTEXT_ROBOTIC_LIMB_HEALING 2

///The standard amount of bodyparts a carbon has. Currently 6, HEAD/L_ARM/R_ARM/CHEST/L_LEG/R_LEG
#define BODYPARTS_DEFAULT_MAXIMUM 6

// Overlay priorities
#define BODYPART_OVERLAY_FISH_INFUSION 1
#define BODYPART_OVERLAY_CARP_INFUSION 2
#define BODYPART_OVERLAY_CSS_SUICIDE 3
#define BODYPART_OVERLAY_VOIDWALKER_CURSE 4
#define BODYPART_OVERLAY_MESH 5

/// Do not draw this bodypart overlay on husks
#define HUSK_OVERLAY_NONE 0
/// Draw this overlay on husks but grayscale it
#define HUSK_OVERLAY_GRAYSCALE 1
/// Draw this overlay on husks as normal
#define HUSK_OVERLAY_NORMAL 2

// Flag associatd with specific overlays on bodyparts
// Used to determine how the overlay is handled in rendering
/// Apply bodypart textures to this
#define LIMB_OVERLAY_TEXTURED (1<<0)
/// Contains meta-info used for rendering (i.e. emissives)
#define LIMB_OVERLAY_META (1<<1)
/// Overlay is chonky, at least 48 pixels wide
#define LIMB_OVERLAY_WIDE_ICON (1<<2)
/// Overlay is toll, at least 48 pixels tall
#define LIMB_OVERLAY_TALL_ICON (1<<3)
/// Core part of the bodypart, like the actual bodypart icon
#define LIMB_OVERLAY_CORE (1<<4)
