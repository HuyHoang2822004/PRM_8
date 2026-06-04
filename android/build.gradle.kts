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
    tasks.configureEach {
        if (name.contains("Kotlin", ignoreCase = true)) {
            try {
                val kotlinOptions = property("kotlinOptions")
                val getArgs = kotlinOptions!!.javaClass.getMethod("getFreeCompilerArgs")
                val setArgs = kotlinOptions!!.javaClass.getMethod("setFreeCompilerArgs", List::class.java)
                val current = getArgs.invoke(kotlinOptions) as List<*>
                setArgs.invoke(kotlinOptions, current + "-Xskip-metadata-version-check")
            } catch (e: Exception) {
                // Ignore
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
