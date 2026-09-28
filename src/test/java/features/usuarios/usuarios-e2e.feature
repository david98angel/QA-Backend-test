@usuarios @e2e
Feature: Flujo CRUD completo de Usuarios (end-to-end)

  # Valida la historia de usuario completa encadenando las operaciones:
  # crear -> buscar -> listar -> actualizar -> eliminar -> verificar eliminación.

  Background:
    * url baseUrl
    * def schemas = call read('classpath:schemas/usuario-schema.js')
    * def usuarioSchema = schemas.usuario

  @smoke
  Scenario: Ciclo de vida completo de un usuario
    # 1) Crear
    * def usuario = DataGenerator.usuarioValido()
    Given path 'usuarios'
    And request usuario
    When method post
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
    * def idCreado = response._id

    # 2) Buscar por ID
    Given path 'usuarios', idCreado
    When method get
    Then status 200
    And match response == usuarioSchema
    And match response.email == usuario.email

    # 3) Listar y verificar que aparece en la colección
    Given path 'usuarios'
    When method get
    Then status 200
    And match response.usuarios[*]._id contains idCreado

    # 4) Actualizar
    * def cambios = DataGenerator.usuarioValido()
    Given path 'usuarios', idCreado
    And request cambios
    When method put
    Then status 200
    And match response.message == 'Registro alterado com sucesso'

    # 5) Verificar la actualización
    Given path 'usuarios', idCreado
    When method get
    Then status 200
    And match response.nome == cambios.nome
    And match response.email == cambios.email

    # 6) Eliminar
    Given path 'usuarios', idCreado
    When method delete
    Then status 200
    And match response.message == 'Registro excluído com sucesso'

    # 7) Verificar que ya no existe
    Given path 'usuarios', idCreado
    When method get
    Then status 400
    And match response.message == 'Usuário não encontrado'
