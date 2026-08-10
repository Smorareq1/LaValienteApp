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

// Kotlin y Java apuntando al mismo objetivo dentro de cada plugin.
//
// Un módulo Android compila dos mitades —Javac y Kotlin— y Gradle aborta si no
// coinciden. Entre los plugins del proyecto se dan los dos desajustes posibles:
//
//   receive_sharing_intent  no declara nada  → Javac 1.8, Kotlin 21 (el del JDK)
//   image_picker_android    declara Java 17  → Javac 17,  Kotlin 21
//
// Por eso esto no fija un número fijo: bajarlos a todos a 11 arregla el primero
// y rompe el segundo, que es exactamente lo que pasó al intentarlo. Lo que se
// hace es leer el `targetCompatibility` que cada plugin ya declaró y poner su
// Kotlin ahí mismo; el que no declara nada cae en 11, que es lo que usa `:app`.
//
// Va en el gradle raíz porque el problema es de subproyectos ajenos: `:app` ya
// fija 11 en ambos lados y no necesita nada de esto.
// El `afterEvaluate` es necesario: leer la extensión de Android antes de que el
// plugin termine de configurarse la fuerza a existir a medias y tumba a otros
// (`connectivity_plus` falla ahí con un NullPointerException y un
// "does not specify compileSdk" que no tiene nada que ver con el problema real).
subprojects {
    plugins.withId("com.android.library") {
        afterEvaluate {
            val android =
                extensions.findByType<com.android.build.gradle.LibraryExtension>()
                    ?: return@afterEvaluate

            // Solo se toca Kotlin, nunca el Java del plugin: para cuando este
            // bloque corre, `compileOptions` ya está finalizado y escribirlo
            // falla con "sourceCompatibility has been finalized". Da igual —
            // alinear una mitad con la otra es todo lo que Gradle pide, y el
            // Java que eligió cada plugin es el que sus autores probaron.
            val target =
                org.jetbrains.kotlin.gradle.dsl.JvmTarget.fromTarget(
                    android.compileOptions.targetCompatibility.toString(),
                )
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>()
                .configureEach { compilerOptions.jvmTarget.set(target) }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
