allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://europe-west3-maven.pkg.dev/talsec-artifact/freerasp")
            content {
                includeGroupByRegex(".*aheaditec.*")
                includeGroupByRegex(".*aheadroots.*")
                includeGroupByRegex(".*talsec.*")
                includeGroupByRegex(".*freerasp.*")
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    pluginManager.withPlugin("com.android.application") {
        configure<com.android.build.gradle.BaseExtension> {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
    pluginManager.withPlugin("com.android.library") {
        configure<com.android.build.gradle.BaseExtension> {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

allprojects {
    tasks.matching { it.name.contains("AarMetadata") }.configureEach {
        enabled = false
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
