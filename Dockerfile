FROM maven:3.6.3-jdk-11-openj9 as builder

ENV GEN_DIR /opt/openapi-generator
WORKDIR ${GEN_DIR}
VOLUME  ${MAVEN_HOME}/.m2/repository

# Required from a licensing standpoint
COPY ./LICENSE ${GEN_DIR}

# Required to compile openapi-generator
COPY ./google_checkstyle.xml ${GEN_DIR}

# Modules are copied individually here to allow for caching of docker layers between major.minor versions
COPY ./modules/openapi-generator-gradle-plugin ${GEN_DIR}/modules/openapi-generator-gradle-plugin
COPY ./modules/openapi-generator-maven-plugin ${GEN_DIR}/modules/openapi-generator-maven-plugin
COPY ./modules/openapi-generator-online ${GEN_DIR}/modules/openapi-generator-online
COPY ./modules/openapi-generator-cli ${GEN_DIR}/modules/openapi-generator-cli
COPY ./modules/openapi-generator-core ${GEN_DIR}/modules/openapi-generator-core
COPY ./modules/openapi-generator ${GEN_DIR}/modules/openapi-generator
COPY ./pom.xml ${GEN_DIR}

# Pre-compile openapi-generator-cli
RUN mvn -am -pl "modules/openapi-generator-cli" package -Dmaven.test.skip

FROM gcr.io/distroless/java11-debian11

COPY --from=builder /opt/openapi-generator/modules/openapi-generator-cli/target/openapi-generator-cli.jar /

ENTRYPOINT ["java", "-Xmx1024m", "-jar", "/openapi-generator-cli.jar"]

CMD ["help"]
