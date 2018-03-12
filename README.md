Showing how externalisising the HTTP Servlet session into a database can work.

Getting started
===============

```sh
pushd app
./gradlew docker
popd
docker-compose up
```

This should build the application, and create a docker environment with 3
instances of the application talking to a single MySQL database, and
haproxy as a load-balancer in front of the apps.

http://localhost/ should give you the same session ID each time.

Kill an instance of the tomcat application; the session should continue to
work.
