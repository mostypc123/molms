# molms

A (VERY WORK IN PROGRESS) LMS (learning managment system) made with D (vibe.d), HTML, CSS and SQLite3.

## Running molms

### Build instructions

Because some Linux distros have updated to OpenSSL 4.0 and vibe.d expects 3.0, you will
have to compile OpenSSL 3 yourself and point your `LD_LIBRARY_PATH` and `LIBRARY_PATH`
at it. You can copy this script and run it to compile OpenSSL:

```sh
cd ~
curl -LO https://github.com/openssl/openssl/releases/download/openssl-3.5.4/openssl-3.5.4.tar.gz
tar xf openssl-3.5.4.tar.gz
cd openssl-3.5.4

./Configure --prefix=$HOME/openssl-3 --openssldir=$HOME/openssl-3/ssl --libdir=lib
make -j$(nproc)
make install_sw

cd ~
rm -rf openssl-3.5.4
```

After this is done, run these commands to make your current terminal session use OpenSSL 3:

```sh
export LIBRARY_PATH=$HOME/openssl-3/lib
export LD_LIBRARY_PATH=$HOME/openssl-3/lib
```

Now you can use dub to compile the server:

```sh
dub build
```

and run it:

```sh
./molms
```

### Configuration

For configuring the server, we use the `example_config.json` file. You can rename it to
whatever you want, and use `--config-path` to point molms at your le config.

The options are mostly straightforward. For hosting, please, PLEASE, disable `devmode`:

```json
{
  "host": {
    "devmode": false
  }
}
```

### Logs

Logs are written to the `log.json` file. You can disable writing logs to the file in the config:

```json
{
  "log": {
    "write": false
  }
}
```

### Starting the server

Simply run `./molms` as mentioned above.
