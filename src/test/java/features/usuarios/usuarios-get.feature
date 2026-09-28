@usuarios @get
Feature: GET /usuarios - Listar usuarios y buscar por ID

  Background:
    * url baseUrl
    * def schemas = call read('classpath:schemas/usuario-schema.js')
    * def usuarioSchema = schemas.usuario

  @smoke @positivo
  Scenario: Obtener la lista completa de usuarios
    Given path 'usuarios'
    When method get
    Then status 200
    And match response.quantidade == '#number'
    And match response.usuarios == '#array'
    And match response.usuarios == '#[] usuarioSchema'

  @positivo
  Scenario: La cantidad reportada coincide con el tamaño del arreglo de usuarios
    Given path 'usuarios'
    When method get
    Then status 200
    And match response.quantidade == response.usuarios.length

  @positivo
  Scenario: Buscar un usuario específico por su ID
    # Se crea un usuario para tener un ID determinístico que consultar
    * def nuevo = DataGenerator.usuarioValido()
    Given path 'usuarios'
    And request nuevo
    When method post
    Then status 201
    * def idCreado = response._id

    Given path 'usuarios', idCreado
    When method get
    Then status 200
    And match response == usuarioSchema
    And match response._id == idCreado
    And match response.email == nuevo.email

    # Limpieza
    Given path 'usuarios', idCreado
    When method delete
    Then status 200

  @negativo
  Scenario: Buscar un usuario con un ID inexistente retorna 400 y mensaje
    # ID con formato válido (16 caracteres alfanuméricos) pero inexistente
    Given path 'usuarios', '0123456789abcdef'
    When method get
    Then status 400
    And match response == schemas.soloMensaje
    And match response.message == 'Usuário não encontrado'
