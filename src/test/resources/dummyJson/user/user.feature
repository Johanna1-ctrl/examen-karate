Feature: Servicio para tratamiento de usuarios
  Background:
    Given url "https://dummyjson.com"
    And header Content-Type = 'application/json'

Scenario: Creación de usuario
  When path "/users/add"
  And request
  """
  {
    "firstName":"Johanna",
    "lastName":"Arenas",
    "age":"44"
  }
  """
  And method post
  Then status 201
  And match response.firstName == 'Johanna'
  And match response.role == 'user'

  Scenario Outline: Creación de varios usuarios
    When path "/users/add"
    And request
  """
  {
    "firstName":<firstName>>,
    "lastName":<lastName>,
    "age":<age>>
  }
  """
    And method post
    Then status <statusCode>
    Examples:
      | firstName | lastName | age  | statusCode |
      | Pepito    | Sanchez  | 25   | 201        |
      | Maria     | Luque    | 23   | 201        |

    Scenario: Inicio de sesión
      When path '/user/login'
      And request
      """
      {
    username: 'emilys',
    password: 'emilyspass',
    expiresInMins: 30,
      }
      """
      And method post
      Then status 200
      * def tokenLogin = response.accessToken
      * print tokenLogin
      When path '/user/me'
      And header Authorization = 'Bearer ' + tokenLogin
      And method GET
      Then status 200
