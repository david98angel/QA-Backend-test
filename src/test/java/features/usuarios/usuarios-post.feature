@usuarios @post
Feature: POST /usuarios - Registrar usuario

  Background:
    * url baseUrl
    * def schemas = call read('classpath:schemas/usuario-schema.js')

  @smoke @positivo
  Scenario: Registrar un nuevo usuario con datos válidos
    * def usuario = DataGenerator.usuarioValido()
    Given path 'usuarios'
    And request usuario
    When method post
    Then status 201
    And match response == schemas.registroExitoso
    And match response.message == 'Cadastro realizado com sucesso'
    And match response._id == '#string'

    # Limpieza del dato creado
    * def idCreado = response._id
    Given path 'usuarios', idCreado
    When method delete
    Then status 200

  @positivo
  Scenario: Registrar un usuario administrador con datos válidos
    * def admin = DataGenerator.usuarioAdmin()
    Given path 'usuarios'
    And request admin
    When method post
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
    * def idCreado = response._id

    # Verificar que se persistió como administrador
    Given path 'usuarios', idCreado
    When method get
    Then status 200
    And match response.administrador == 'true'

    Given path 'usuarios', idCreado
    When method delete
    Then status 200

  @negativo
  Scenario: No se puede registrar un usuario con email duplicado
    * def usuario = DataGenerator.usuarioValido()
    # Primer registro exitoso
    Given path 'usuarios'
    And request usuario
    When method post
    Then status 201
    * def idCreado = response._id

    # Segundo registro con el mismo email debe fallar
    Given path 'usuarios'
    And request usuario
    When method post
    Then status 400
    And match response == schemas.soloMensaje
    And match response.message == 'Este email já está sendo usado'

    # Limpieza
    Given path 'usuarios', idCreado
    When method delete
    Then status 200

  @negativo
  Scenario Outline: No se puede registrar un usuario con el campo obligatorio '<campo>' ausente
    * def usuario = DataGenerator.usuarioValido()
    * remove usuario.<campo>
    Given path 'usuarios'
    And request usuario
    When method post
    Then status 400
    And match response.<campo> == '<mensaje>'

    Examples:
      | campo         | mensaje                             |
      | nome          | nome é obrigatório                  |
      | email         | email é obrigatório                 |
      | password      | password é obrigatório              |
      | administrador | administrador é obrigatório         |

  @negativo
  Scenario: No se puede registrar un usuario con formato de email inválido
    * def usuario = DataGenerator.usuarioValido()
    * set usuario.email = 'correo-sin-formato-valido'
    Given path 'usuarios'
    And request usuario
    When method post
    Then status 400
    And match response.email == 'email deve ser um email válido'
