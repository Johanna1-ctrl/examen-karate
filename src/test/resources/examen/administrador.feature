Feature: Auditoría administrativa de la transferencia

  Background:
    * configure headers = { 'Content-Type': 'application/json', 'x-channel': 'ADMIN' }

  Scenario: Verificar la operación en el historial global

    # Login administrador
    Given url 'http://134.209.211.10:4004'
    And path '/admin/v1/login'
    And request
    """
    {
      "username": "admin",
      "password": "superpassword"
    }
    """
    When method post
    Then status 200
    And match response.token == '#string'
    * def tokenAdmin = response.token

    # Consultar transacciones
    Given url 'http://134.209.211.10:4004'
    And path '/admin/v1/transactions'
    And header Authorization = 'Bearer ' + tokenAdmin
    When method get
    Then status 200
    And match response == '#array'

   # Buscar salida del emisor por referencia y usuario
    * def salidas = karate.filter(response, function(x){ return x.referenceCode == codigoReferencia && x.userId == idEmisor && x.type == 'EXPENSE' })
    * assert salidas.length == 1
    * def salida = salidas[0]
    And match salida.amount == montoTransferencia
    And match salida.counterpartyPhone == celularReceptor
    * assert salida.description.indexOf(notaTransferencia) >= 0

    # Buscar entrada del receptor por la misma referencia
    * def entradas = karate.filter(response, function(x){ return x.referenceCode == codigoReferencia && x.userId == idReceptor && x.type == 'INCOME' })
    * assert entradas.length == 1
    * def entrada = entradas[0]
    And match entrada.amount == montoTransferencia
    And match entrada.counterpartyPhone == celularEmisor
    * assert entrada.description.indexOf(notaTransferencia) >= 0

    # Ambos movimientos deben corresponder a la misma transferencia
    And match salida.referenceCode == entrada.referenceCode

    * print 'Salida del emisor validada:', salida
    * print 'Entrada del receptor validada:', entrada