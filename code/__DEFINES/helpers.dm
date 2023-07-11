/// subtypesof(), typesof() without the parent path
#define subtypesof(typepath) ( typesof(typepath) - typepath )

/// writing typepath twice is too long.
#define DECLARE_LOCATE(varname, typepath, container) var##typepath/##varname = (locate(##typepath) in container)
