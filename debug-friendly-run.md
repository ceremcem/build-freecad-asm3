# Debug Friendly Run 

In order to get more accurate stack traces, set 

```
build_type="Release"
```

in `config.sh` and run FreeCAD under `gdb`:

1. Add the following into `.bashrc` [[1]](https://blog.cryptomilk.org/2010/12/23/gdb-backtrace-to-file/):

    ```bash
    alias bt='echo 0 | gdb -batch-silent -ex "run" -ex "set logging overwrite on" -ex "set logging file gdb.bt" -ex "set logging on" -ex "set pagination off" -ex "handle SIG33 pass nostop noprint" -ex "echo backtrace:\n" -ex "backtrace full" -ex "echo \n\nregisters:\n" -ex "info registers" -ex "echo \n\ncurrent instructions:\n" -ex "x/16i \$pc" -ex "echo \n\nthreads backtrace:\n" -ex "thread apply all backtrace" -ex "set logging off" -ex "quit" --args'
    ```

2. Run FreeCAD:

       bt ~/fc-build/Release/bin/FreeCAD

3. After crash, debug output will be at `~/gdb.bt`

# Tips 

* You can use [`create-gist.sh`](https://github.com/ceremcem/create-gist) for uploading the dump files to Gist:

      create-gist.sh ~/gdb.bt

