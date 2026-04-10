#define ASSET_CROSS_ROUND_CACHE_DIRECTORY "data/spritesheets/legacy_cache"
#define ASSET_CROSS_ROUND_SMART_CACHE_DIRECTORY "data/spritesheets/smart_cache"

/// When sending mutiple assets, how many before we give the client a quaint little sending resources message
#define ASSET_CACHE_TELL_CLIENT_AMOUNT 8

/// How many assets can be sent at once during legacy asset transport
#define SLOW_ASSET_SEND_RATE 6

/// Constructs a universal icon. This is done in the same manner as the icon() BYOND proc.
/// Do note that transforms are NOT COPIED, and are internally lists. So take care not to re-use transforms.
/// This is a DEFINE for performance reasons.
/// Parameters (in order):
/// icon_file, icon_state, dir, frame
#define uni_icon(I, icon_state, rest...) new /datum/universal_icon(I, icon_state, ##rest)
