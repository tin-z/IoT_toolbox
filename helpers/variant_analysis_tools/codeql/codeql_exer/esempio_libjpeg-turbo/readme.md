
 - do git clone of https://github.com/libjpeg-turbo/libjpeg-turbo

 - setup_codeql.sh file
```
cat <<EOF > setup_codeql.sh
#!/bin/bash

mkdir build && cd build
cmake -G"Unix Makefiles" ../
make

EOF

```

 - run `chmod +x setup_codeql.sh`


 - now create the database like
```
codeql database create ~/codeql-home/codeql-dbs/turbojpg_src --command="${PWD}/setup_codeql.sh" --language=cpp --overwrite

```


