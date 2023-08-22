
## Docker guide

 - git clone https://github.com/KeenSecurityLab/BinAbsInspector
 - Comment lines 1,5,18 of the Dockerfile

 - build docker image
```
docker build . -t bai
```

 - run docker container
```
docker run -it --rm -v <folder-host-share>:<folder-guest-share> --entrypoint /bin/bash bai
```

 - On the docker container install
```
apt-get install tmux vim file
```


