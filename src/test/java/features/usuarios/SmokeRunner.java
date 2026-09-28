package features.usuarios;

import com.intuit.karate.junit5.Karate;

/**
 * Runner exclusivo para los smoke tests (tag @smoke).
 *
 * Ejecutar solo smoke:
 *   mvn test -Dtest=SmokeRunner
 *
 * No se ejecuta con 'mvn test' por defecto (surefire solo incluye UsuariosRunner),
 * evitando así la ejecución duplicada de los escenarios @smoke.
 */
class SmokeRunner {

    @Karate.Test
    Karate soloSmoke() {
        return Karate.run("classpath:features/usuarios").tags("@smoke").relativeTo(getClass());
    }
}
