allprojects {
    repositories {
        google()
        mavenCentral()
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
    project.evaluationDependsOn(":app")
}

subprojects {
    if (project.name != "app") {
        afterEvaluate {
            extensions.findByName("android")?.let { androidExt ->
                if (androidExt is com.android.build.gradle.BaseExtension) {
                    val current = androidExt.compileSdkVersion?.removePrefix("android-")?.toIntOrNull()
                    if (current == null || current < 36) {
                        androidExt.compileSdkVersion("android-36")
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}