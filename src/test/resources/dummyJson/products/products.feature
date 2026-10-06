Feature: Servicio para tratamiento de productos
  Background:
    Given url "https://dummyjson.com"
    And header Content-Type = 'application/json'

  Scenario:
      And param q = 'phone'
      And param limit = '2'
      And method get
      Then status 200

    Scenario:
      When path "/products/add"
      And request
      """
      {
      title: 'Lapicero'
      }
      """
      And method post
      Then status 201
      And match response.id == '#number'
      And match response.title == '#notnull'

Scenario: Crear un producto usando archivo externo
  When path "/products/add"
  * def productData = read('data/body-data.json')
  * def schemaResponse = read('data/schema-response.json')
  And request productData
  Then method post
  And match response == schemaResponse






