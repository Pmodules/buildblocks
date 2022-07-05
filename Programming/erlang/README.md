# Erlang module

Build a Pmodule for Erlang. This module depends on wxWidgets and OpenSSL.

***Please note:***

After running the build script, the dependency files `$ERLANG_PREFIX/.dependencies` must be patched by hand. For the time being dependencies like `Libraries:wxWidgets/3.0.5` are not supported in the variant files but in the dependency file of the module. The dependency file must look like:
```
openssl/1.1.1m
Libraries:wxWidgets/3.0.5
```
