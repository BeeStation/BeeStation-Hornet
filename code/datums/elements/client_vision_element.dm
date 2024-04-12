/// Highly dependent on SSclient_vision.
/// This exists to simplify micro-management of SSclient_vision.
/// You need to do "SSclient_vision.cut_client_images()" but doing it on every Destroy() proc is tedious.
/// This element simplifies your duty to manage those images.
/// WARN: Avoid using this element directly. "SSclient_vision.safe_stack_client_images()" exists
/datum/element/client_vision_element
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2

	/// which key this client vision element uses.
	var/vision_key
	/// image reference that target holds.
	var/list/vision_image
	/// How this element would work?
	var/cve_flags

/// WARN: Avoid using this element directly. "SSclient_vision.safe_stack_client_images()" exists
/datum/element/client_vision_element/Attach(datum/target, vision_key, vision_image, cve_flags)
	. = ..()
	if(!istype(target) || !istext(vision_key))
		return ELEMENT_INCOMPATIBLE

	if(!CHECK_BITFIELD(cve_flags, CVE_FLAGS_CUT_IMAGE_ON_QDEL+CVE_FLAGS_NULLIFY_VISION_KEY_ON_QDEL))
		stack_trace("cve_flags is supposed to take a flag about how it will delete image.")
		cve_flags |= CVE_FLAGS_ERROR + CVE_FLAGS_CUT_IMAGE_ON_QDEL

	src.vision_key = vision_key
	src.vision_image = vision_image
	src.cve_flags = cve_flags

	SSclient_vision.manual_stack_client_images(vision_key, vision_image, is_shared_image = CHECK_BITFIELD(cve_flags, CVE_FLAGS_SHARED_IMAGE))

/datum/element/client_vision_element/Detach(atom/source)
	if(CHECK_BITFIELD(cve_flags, CVE_FLAGS_CUT_IMAGE_ON_QDEL))
		if(CHECK_BITFIELD(cve_flags, CVE_FLAGS_ERROR))
			stack_trace("client vision element with 'cve_flags=CVE_FLAGS_ERROR' cut images. Is that right? source:[source]")
		SSclient_vision.cut_client_images(vision_key, vision_image, is_shared_image = CHECK_BITFIELD(cve_flags, CVE_FLAGS_SHARED_IMAGE))
	else if(CHECK_BITFIELD(cve_flags, CVE_FLAGS_NULLIFY_VISION_KEY_ON_QDEL))
		SSclient_vision.nullify_client_vision_holder(vision_key)

	vision_key = null
	if(islist(vision_image))
		vision_image.Cut()
	vision_image = null
	return ..()
