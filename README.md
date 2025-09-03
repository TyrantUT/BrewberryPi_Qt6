# Building project for Cross Compiled Qt 6.9.1 on Raspberry Pi using Docker
#
## Pre-built images can be found on Docker Hub
https://hub.docker.com/repository/docker/tyrantut/qt-crosscompile/general
#
## Clone the Brewberry Pi Qt project repository
```bash
git clone https://github.com/TyrantUT/BrewberryPi_Qt6.git
git checkout 6.9.1
git pull
```

## Run the pre-built image to cross compile for Raspberry Pi
```bash
cd ..
docker run --rm \
  --mount type=bind,source="$(pwd)/BrewberryPi_Qt6",target=/build/BrewberryPi_Qt6 \
  tyrantut/qt-crosscompile:post-compile-6.9.1-minimal-clean \
  bash -c "
    qt-raspi/bin/qt-cmake BrewberryPi_Qt6 &&
    cmake --build . --parallel &&
    cmake --install .
    cp BrewberryPiApp BrewberryPi_Qt6/
  "
scp BrewberryPi_Qt6/BrewberryPiApp pi@raspberrypi.local:/home/pi
```
