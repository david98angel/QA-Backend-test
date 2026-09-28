package helpers;

import net.datafaker.Faker;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

/**
 * Helper para la generación dinámica de datos de prueba.
 * Se expone a los feature files vía karate-config.js (config.DataGenerator).
 *
 * Uso en Karate:
 *   * def usuario = DataGenerator.usuarioValido()
 *   * def admin   = DataGenerator.usuarioAdmin()
 *   * def email   = DataGenerator.emailUnico()
 */
public class DataGenerator {

    private static final Faker FAKER = new Faker(new Locale("es"));

    private DataGenerator() {
        // clase utilitaria
    }

    /**
     * Genera un email único para evitar colisiones (409/400 por duplicado)
     * en una API pública compartida.
     */
    public static String emailUnico() {
        long ts = System.currentTimeMillis();
        int rnd = FAKER.number().numberBetween(1000, 9999);
        return "qa.auto." + ts + "." + rnd + "@qa-serverest.com";
    }

    /** Usuario válido estándar (no administrador). */
    public static Map<String, Object> usuarioValido() {
        return construirUsuario("false");
    }

    /** Usuario válido con rol administrador. */
    public static Map<String, Object> usuarioAdmin() {
        return construirUsuario("true");
    }

    /**
     * Usuario base con campos parametrizables.
     * ServeRest espera administrador como string "true"/"false".
     */
    public static Map<String, Object> construirUsuario(String administrador) {
        Map<String, Object> usuario = new HashMap<>();
        usuario.put("nome", FAKER.name().fullName());
        usuario.put("email", emailUnico());
        usuario.put("password", FAKER.internet().password(8, 16));
        usuario.put("administrador", administrador);
        return usuario;
    }
}
