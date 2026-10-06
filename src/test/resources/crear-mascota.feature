Feature: Creación de Mascota usando karate
  #https://petstore.swagger.io/#/pet/addPet
  Scenario Outline: Creación de Mascota mediante POST
    Given url "https://petstore.swagger.io/v2"
    And path "/pet"
    And request
    """
        {
      "id": <codigo>,
      "category": {
        "id": 0,
        "name": <categoria>
      },
      "name": <nombre>,
      "photoUrls": [
        "string"
      ],
      "tags": [
        {
          "id": 0,
          "name": "string"
        }
      ],
      "status": "available"
      }
    """
    Then method post
    And status 200
    And match $.name == "firu" 
    Examples:
      |codigo     | nombre | categoria |
      |000000123  | firu  | perros    |

Scenario: Obtener información de una mascota por ID
  Given url "https://petstore.swagger.io/v2"
  When path "/pet/000000123"
  And method get
  Then status 200

  Scenario Outline: Obtener información de varias mascotas por ID
    Given url "https://petstore.swagger.io/v2"
    When path "/pet/<idPet>"
    And method get
    Then status <statusExpected>
    Examples:
    |idPet    |statusExpected    |
    |000000123|200               |
    |1        |404               |
    |456      |404               |
    |561      |404               |
    |198      |404               |




