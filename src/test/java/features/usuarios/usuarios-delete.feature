@usuarios @delete
Feature: DELETE /usuarios/{_id} - Eliminar usuario

  Background:
    * url baseUrl
    * def schemas = call read('classpath:schemas/usuario-schema.js')

  @smoke @positivo
  Scenario: Eliminar un usuario existente del sistema
    * def usuario = DataGenerator.usuarioValido()
    Given path 'usuarios'
    And request usuario
    When method post
    Then status 201
    * def idCreado = response._id

    Given path 'usuarios', idCreado
    When method delete
    Then status 200
    And match response == schemas.soloMensaje
    And match response.message == 'Registro excluído com sucesso'

    # Confirmar que el usuario ya no existe
    Given path 'usuarios', idCreado
    When method get
    Then status 400
    And match response.message == 'Usuário não encontrado'

  @positivo
  Scenario: DELETE de un ID inexistente retorna 200 con mensaje de "nenhum registro"
    # ID con formato válido (16 caracteres) pero inexistente
    Given path 'usuarios', 'fedcba9876543210'
    When method delete
    Then status 200
    And match response == schemas.soloMensaje
    And match response.message == 'Nenhum registro excluído'
