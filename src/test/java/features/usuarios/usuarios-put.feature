@usuarios @put
Feature: PUT /usuarios/{_id} - Actualizar usuario

  Background:
    * url baseUrl
    * def schemas = call read('classpath:schemas/usuario-schema.js')
    # Se crea un usuario base para actualizar
    * def usuario = DataGenerator.usuarioValido()
    Given path 'usuarios'
    And request usuario
    When method post
    Then status 201
    * def idCreado = response._id

  @smoke @positivo
  Scenario: Actualizar la información de un usuario existente
    * def actualizado = DataGenerator.usuarioValido()
    Given path 'usuarios', idCreado
    And request actualizado
    When method put
    Then status 200
    And match response == schemas.soloMensaje
    And match response.message == 'Registro alterado com sucesso'

    # Verificar la persistencia del cambio
    Given path 'usuarios', idCreado
    When method get
    Then status 200
    And match response.nome == actualizado.nome
    And match response.email == actualizado.email

    # Limpieza
    Given path 'usuarios', idCreado
    When method delete
    Then status 200

  @positivo
  Scenario: PUT con un ID inexistente crea un nuevo usuario (upsert)
    * def nuevo = DataGenerator.usuarioValido()
    # ID con formato válido (16 caracteres) pero inexistente -> ServeRest hace upsert
    Given path 'usuarios', 'abcdef0123456789'
    And request nuevo
    When method put
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
    And match response._id == '#string'

    # Limpieza del creado por upsert y del usuario base
    * def idUpsert = response._id
    Given path 'usuarios', idUpsert
    When method delete
    Then status 200
    Given path 'usuarios', idCreado
    When method delete
    Then status 200

  @negativo
  Scenario: No se puede actualizar usando un email ya registrado por otro usuario
    # Se crea un segundo usuario cuyo email intentaremos reutilizar
    * def otro = DataGenerator.usuarioValido()
    Given path 'usuarios'
    And request otro
    When method post
    Then status 201
    * def idOtro = response._id

    # Intentar actualizar el usuario base con el email del segundo usuario
    * def payload = DataGenerator.usuarioValido()
    * set payload.email = otro.email
    Given path 'usuarios', idCreado
    And request payload
    When method put
    Then status 400
    And match response.message == 'Este email já está sendo usado'

    # Limpieza
    Given path 'usuarios', idCreado
    When method delete
    Then status 200
    Given path 'usuarios', idOtro
    When method delete
    Then status 200

  @negativo
  Scenario: No se puede actualizar con un campo obligatorio ausente
    * def payload = DataGenerator.usuarioValido()
    * remove payload.password
    Given path 'usuarios', idCreado
    And request payload
    When method put
    Then status 400
    And match response.password == 'password é obrigatório'

    # Limpieza
    Given path 'usuarios', idCreado
    When method delete
    Then status 200
