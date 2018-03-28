FROM tomcat:8.5.28-jre8

# Remove these for a faster startup
RUN rm -rf /usr/local/tomcat/webapps/*

COPY ["web.xml", "context.xml", "logging.properties", "/usr/local/tomcat/conf/"]
COPY ["stateless-tomcat.war", "/usr/local/tomcat/webapps/"]
COPY ["mysql-connector-java-*.jar", "/usr/local/tomcat/lib/"]
