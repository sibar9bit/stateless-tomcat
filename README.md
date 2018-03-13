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

Tests
=====

zero-downtime deployment
------------------------

1. have a few clients access the site to create sessions
1. Check the logs that various CleanupObject instances have been created
1. Variously stop and restart `app_x` instances
1. client sessions aren't interupted
1. wait for a minute or two for the sessions to expire
1. you should see valueUnbound events in the logs as CleanupObjects are purged

extended downtime
-----------------

1. have a few clients access the site to create sessions
1. Check the logs that various CleanupObject instances have been created
1. stop all of the `app_x` instances to simulate extended downtime of the application / segfaults
1. wait for a 3 minutes (session timeout is 1 minute)
1. start one or more of the `app_x` instances
1. after a minute or so, you should see valueUnbound events in the logs as CleanupObjects are purged 
