package features.usuarios;

import com.intuit.karate.junit5.Karate;

/**
 * Runner de la suite completa de Usuarios.
 *
 * Ejecutar toda la suite:
 *   mvn test
 *   mvn test -Dtest=UsuariosRunner
 *
 * Ejecutar por tags:
 *   mvn test -Dtest=UsuariosRunner -Dkarate.options="--tags @negativo"
 *
 * Para ejecutar solo los smoke tests, usar SmokeRunner (ver README).
 */
class UsuariosRunner {

    @Karate.Test
    Karate todosLosFeatures() {
        return Karate.run("classpath:features/usuarios").relativeTo(getClass());
    }
}
