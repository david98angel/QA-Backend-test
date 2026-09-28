/**
 * Esquemas JSON reutilizables para validar las respuestas de la API de Usuarios.
 * Se importan desde los feature files:
 *   * def schemas = call read('classpath:schemas/usuario-schema.js')
 * y luego:
 *   * match response == schemas.usuario
 */
function fn() {

  // Un usuario individual (respuesta de GET /usuarios/{_id} y items de la lista).
  // La contraseña se devuelve en texto plano por diseño de ServeRest.
  var usuario = {
    nome: '#string',
    email: '#string',
    password: '#string',
    administrador: '#regex (true|false)',
    _id: '#string'
  };

  // Respuesta de GET /usuarios (colección paginada simple).
  var listaUsuarios = {
    quantidade: '#number',
    usuarios: '#[] usuarioRef'
  };

  // Respuesta estándar de creación exitosa (POST) en ServeRest.
  var registroExitoso = {
    message: '#string',
    _id: '#string'
  };

  // Respuesta genérica que solo contiene message (PUT actualiza / DELETE / errores).
  var soloMensaje = {
    message: '#string'
  };

  return {
    usuario: usuario,
    usuarioRef: usuario,
    listaUsuarios: listaUsuarios,
    registroExitoso: registroExitoso,
    soloMensaje: soloMensaje
  };
}
