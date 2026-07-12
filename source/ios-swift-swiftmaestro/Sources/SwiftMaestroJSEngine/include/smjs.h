/*
 * smjs.h — a thin, real-function C shim over Duktape for Swift interop.
 *
 * Duktape's public API is largely C macros, which Swift's C importer cannot see.
 * This shim wraps the small slice swiftmaestro needs (evaluate, globals as JSON,
 * and an `http` binding that calls back into Swift) in ordinary C functions the
 * Swift importer exposes cleanly. Only this header is published to Swift (see
 * module.modulemap); duktape.h stays internal to the C sources.
 *
 * Part of swiftmaestro (Apache-2.0). Bundles Duktape (MIT) — see ../../NOTICE.
 */
#ifndef SMJS_H
#define SMJS_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct smjs_context smjs_context;

/*
 * HTTP binding callback. Receives the request serialized as a JSON string
 * ({"method","url","headers","body"}) and must return a malloc'd JSON response
 * string ({"status","body"}) that the shim frees with free(), or NULL on failure.
 */
typedef char *(*smjs_http_fn)(void *user, const char *request_json);

/* Create a fresh engine (with `output` and `http` globals). NULL on failure. */
smjs_context *smjs_new(void);

/* Destroy an engine and its heap. */
void smjs_free(smjs_context *ctx);

/* Register the callback backing `http.request(...)` / `http.get` / `http.post`. */
void smjs_set_http(smjs_context *ctx, smjs_http_fn fn, void *user);

/*
 * Evaluate `src`. Returns 0 on success and sets *out (malloc'd) to the result
 * JSON-encoded (e.g. "\"abc\"", "42", "{...}"); when the result is `undefined`,
 * *out is "" and *out_undefined (if non-NULL) is set to 1. Returns 1 on error
 * and sets *out to the error message. Free *out with smjs_free_cstr.
 */
int smjs_eval(smjs_context *ctx, const char *src, char **out, int *out_undefined);

/* Set global `name` from a JSON value string. Returns 0 on success. */
int smjs_set_global_json(smjs_context *ctx, const char *name, const char *json);

/* Read global `name` as JSON into *out (malloc'd; "undefined" when absent). */
int smjs_get_global_json(smjs_context *ctx, const char *name, char **out);

/* Free a string returned by smjs_eval / smjs_get_global_json. */
void smjs_free_cstr(char *s);

/* Duplicate a C string with the C allocator (malloc). The http callback uses
 * this to return a string the shim frees with free() — portable where strdup is
 * absent (e.g. MSVC). */
char *smjs_dup_cstr(const char *s);

#ifdef __cplusplus
}
#endif

#endif /* SMJS_H */
