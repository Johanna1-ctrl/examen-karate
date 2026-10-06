Feature: Servicio para tratamiento de carts
  Background:
    Given url "https://dummyjson.com"
    And header Content-Type = 'application/json'

  Scenario: Creación de carrito
      When path "/carts/add"
      * def cartData = read('data/body-data.json')
      * def cartResponse = read('data/schema-response.json')
      And request cartData
      And method post
      Then match response == cartResponse
      And match response.id == 209
      And match response.totalProducts == 2

  Scenario: Actualizar carrito
        When path "/carts/1"
        And request
        """
        {
          merge: true,
          products: [
        {
        id: 1,
        quantity: 1,
      },
    ]
  }
        """
        And method put
        Then status 200

  Scenario: Obtener el carrito
    When path '/carts/user/5'
    And method get
    Then status 200




