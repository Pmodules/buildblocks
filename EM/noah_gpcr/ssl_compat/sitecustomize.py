import ssl
import urllib3.util.ssl_ as ssl_util
import urllib3.connection as connection

_original = ssl_util.create_urllib3_context

def _create_context_compat(*args, **kwargs):
    ctx = _original(*args, **kwargs)
    if hasattr(ssl, "VERIFY_X509_STRICT"):
        ctx.verify_flags &= ~ssl.VERIFY_X509_STRICT
    return ctx

ssl_util.create_urllib3_context = _create_context_compat
connection.create_urllib3_context = _create_context_compat

print("[ssl_compat] Patched urllib3 SSL context factory", flush=True)
