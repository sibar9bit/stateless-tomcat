pushd app
./gradlew clean build docker
popd
docker-compose up
