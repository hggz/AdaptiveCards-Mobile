/*
 * smjs.c — Duktape-backed implementation of the swiftmaestro JS shim (see smjs.h).
 * Part of swiftmaestro (Apache-2.0). Bundles Duktape (MIT) — see ../../NOTICE.
 */
#include "smjs.h"
#include "duktape.h"

#include <stdlib.h>
#include <string.h>

struct smjs_context {
    duk_context *duk;
    smjs_http_fn http_fn;
    void *http_user;
};

static char *smjs_strdup(const char *s) {
    if (!s) s = "";
    size_t n = strlen(s) + 1;
    char *p = (char *)malloc(n);
    if (p) memcpy(p, s, n);
    return p;
}

/* Native `http.request(obj)`: JSON-encode the arg, call the Swift binding, and
 * JSON-decode the response back into a JS object. */
static duk_ret_t smjs_native_http_request(duk_context *d) {
    duk_push_heap_stash(d);
    duk_get_prop_string(d, -1, "smjs_self");
    smjs_context *ctx = (smjs_context *)duk_get_pointer(d, -1);
    duk_pop_2(d);

    if (!ctx || !ctx->http_fn) {
        duk_push_string(d, "{\"status\":-1,\"body\":\"http binding not configured\"}");
        duk_json_decode(d, -1);
        return 1;
    }

    if (duk_get_top(d) < 1) {
        duk_push_object(d);
    }
    duk_dup(d, 0);
    const char *request_json = duk_json_encode(d, -1); /* replaces dup with a string */
    char *response = ctx->http_fn(ctx->http_user, request_json ? request_json : "{}");
    duk_pop(d); /* encoded request string */

    if (!response) {
        duk_push_string(d, "{\"status\":-1,\"body\":\"http request failed\"}");
    } else {
        duk_push_string(d, response);
        free(response);
    }
    duk_json_decode(d, -1); /* parse response JSON into an object */
    return 1;
}

/* Protected JSON.parse of the string on top of the stack. */
static duk_ret_t smjs_json_decode_raw(duk_context *d, void *udata) {
    (void)udata;
    duk_json_decode(d, -1);
    return 1;
}

smjs_context *smjs_new(void) {
    smjs_context *ctx = (smjs_context *)calloc(1, sizeof(smjs_context));
    if (!ctx) return NULL;
    ctx->duk = duk_create_heap_default();
    if (!ctx->duk) {
        free(ctx);
        return NULL;
    }

    /* Stash self so native callbacks can find the smjs_context. */
    duk_push_heap_stash(ctx->duk);
    duk_push_pointer(ctx->duk, ctx);
    duk_put_prop_string(ctx->duk, -2, "smjs_self");
    duk_pop(ctx->duk);

    /* http = { request: <native> } */
    duk_push_object(ctx->duk);
    duk_push_c_function(ctx->duk, smjs_native_http_request, DUK_VARARGS);
    duk_put_prop_string(ctx->duk, -2, "request");
    duk_put_global_string(ctx->duk, "http");

    /* Bootstrap: persistent `output` object + http.get/post convenience wrappers.
     * Non-strict eval, so an assignment to an undeclared name creates a global. */
    duk_peval_string_noresult(ctx->duk,
        "if (typeof output === 'undefined') { output = {}; }\n"
        "http.get = function (u, h) { return http.request({ method: 'GET', url: u, headers: h || {} }); };\n"
        "http.post = function (u, b, h) { return http.request({ method: 'POST', url: u, body: (typeof b === 'string' ? b : JSON.stringify(b)), headers: h || {} }); };\n");

    return ctx;
}

void smjs_free(smjs_context *ctx) {
    if (!ctx) return;
    if (ctx->duk) duk_destroy_heap(ctx->duk);
    free(ctx);
}

void smjs_set_http(smjs_context *ctx, smjs_http_fn fn, void *user) {
    if (!ctx) return;
    ctx->http_fn = fn;
    ctx->http_user = user;
}

int smjs_eval(smjs_context *ctx, const char *src, char **out, int *out_undefined) {
    if (out) *out = NULL;
    if (out_undefined) *out_undefined = 0;
    if (!ctx || !ctx->duk) {
        if (out) *out = smjs_strdup("engine not initialized");
        return 1;
    }
    duk_context *d = ctx->duk;

    if (duk_peval_string(d, src) != 0) {
        const char *msg = duk_safe_to_string(d, -1);
        if (out) *out = smjs_strdup(msg ? msg : "eval error");
        duk_pop(d);
        return 1;
    }

    if (duk_is_undefined(d, -1)) {
        if (out_undefined) *out_undefined = 1;
        if (out) *out = smjs_strdup("");
        duk_pop(d);
        return 0;
    }

    /* JSON-encode a copy of the result; fall back to string coercion. */
    duk_dup(d, -1);
    const char *json = duk_json_encode(d, -1);
    if (json && duk_is_string(d, -1)) {
        if (out) *out = smjs_strdup(json);
    } else {
        const char *s = duk_safe_to_string(d, -2);
        if (out) *out = smjs_strdup(s ? s : "");
    }
    duk_pop(d); /* encoded copy */
    duk_pop(d); /* original result */
    return 0;
}

int smjs_set_global_json(smjs_context *ctx, const char *name, const char *json) {
    if (!ctx || !ctx->duk || !name) return 1;
    duk_context *d = ctx->duk;
    duk_push_string(d, json ? json : "null");
    if (duk_safe_call(d, smjs_json_decode_raw, NULL, 1, 1) != 0) {
        duk_pop(d);
        return 1;
    }
    duk_put_global_string(d, name);
    return 0;
}

int smjs_get_global_json(smjs_context *ctx, const char *name, char **out) {
    if (out) *out = NULL;
    if (!ctx || !ctx->duk || !name) {
        if (out) *out = smjs_strdup("undefined");
        return 1;
    }
    duk_context *d = ctx->duk;
    duk_get_global_string(d, name);
    if (duk_is_undefined(d, -1)) {
        if (out) *out = smjs_strdup("undefined");
        duk_pop(d);
        return 0;
    }
    duk_dup(d, -1);
    const char *json = duk_json_encode(d, -1);
    if (out) *out = smjs_strdup(json ? json : "null");
    duk_pop_2(d);
    return 0;
}

void smjs_free_cstr(char *s) {
    if (s) free(s);
}

char *smjs_dup_cstr(const char *s) {
    return smjs_strdup(s);
}
