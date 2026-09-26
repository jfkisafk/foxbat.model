plugins {
    id("java-library")
    id("software.amazon.smithy.gradle.smithy-jar").version("1.5.0")
}

group = "dev.stelo.foxbat"
version = "1.0"

repositories {
    mavenLocal()
    mavenCentral()
}

dependencies {
    smithyBuild("software.amazon.smithy:smithy-openapi:1.+")

    implementation("software.amazon.smithy:smithy-model:1.+")
    implementation("software.amazon.smithy:smithy-aws-traits:1.+")
    implementation("software.amazon.smithy:smithy-aws-apigateway-traits:1.+")
    implementation("software.amazon.smithy:smithy-aws-apigateway-openapi:1.+")
}