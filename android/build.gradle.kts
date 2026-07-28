import org.gradle.api.plugins.ExtensionAware

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

// file_picker 11.0.2 skips self-applying the Kotlin Gradle Plugin under
// AGP 9+, assuming Flutter's built-in Kotlin support will compile its .kt
// sources instead — but that support doesn't currently reach plugin
// subprojects, only :app, so FilePickerPlugin never gets compiled and
// GeneratedPluginRegistrant.java fails with "cannot find symbol". Force the
// plugin on for this one module until an upstream file_picker release
// fixes its AGP9 detection.
subprojects {
    if (project.name == "file_picker") {
        pluginManager.withPlugin("com.android.library") {
            apply(plugin = "org.jetbrains.kotlin.android")
        }
        // Match the module's own Java 17 compileOptions — file_picker only
        // sets this itself inside the AGP9 branch we're bypassing above.
        pluginManager.withPlugin("org.jetbrains.kotlin.android") {
            (extensions.getByName("android") as ExtensionAware).withGroovyBuilder {
                "kotlinOptions" {
                    setProperty("jvmTarget", "17")
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
