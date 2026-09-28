function fn() {
  // Entorno por defecto; se puede sobrescribir con -Dkarate.env=qa
  var env = karate.env;
  karate.log('karate.env seleccionado:', env);
  if (!env) {
    env = 'dev';
  }

  var config = {
    env: env,
    baseUrl: 'https://serverest.dev'
  };

  // Configuración por ambiente
  if (env === 'dev') {
    config.baseUrl = 'https://serverest.dev';
  } else if (env === 'qa') {
    config.baseUrl = 'https://serverest.dev';
  }

  // Timeouts razonables para una API pública compartida
  karate.configure('connectTimeout', 10000);
  karate.configure('readTimeout', 20000);

  // Header por defecto para todas las peticiones
  karate.configure('headers', { 'Content-Type': 'application/json' });

  // Helper de generación de datos (Java Faker) disponible en todos los features
  config.DataGenerator = Java.type('helpers.DataGenerator');

  return config;
}
