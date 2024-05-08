plugins {
    id("java")
    id("software.amazon.smithy").version("0.6.0")
}

group = "dev.stelo.foxbat"
version = "1.0"

repositories {
    mavenLocal()
    mavenCentral()
}

buildscript {
    dependencies {
        classpath("software.amazon.smithy:smithy-openapi:1.+")
        classpath("software.amazon.smithy:smithy-aws-traits:1.+")
    }
}

dependencies {
    implementation("software.amazon.smithy:smithy-model:1.+")
    implementation("software.amazon.smithy:smithy-aws-traits:1.+")
    implementation("software.amazon.smithy:smithy-aws-apigateway-traits:1.+")
    implementation("software.amazon.smithy:smithy-aws-apigateway-openapi:1.+")
}

configure<software.amazon.smithy.gradle.SmithyExtension> {}

java.sourceSets["main"].java {
    srcDirs("model", "src/main/smithy")
}
