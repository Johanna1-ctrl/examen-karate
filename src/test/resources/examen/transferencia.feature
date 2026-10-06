Feature: Transferencia del emisor al receptor

  Background:
    * configure headers = { 'Content-Type': 'application/json', 'x-channel': 'POSTMAN' }

  Scenario: Transferir 450 y validar saldo del emisor

    # Login del emisor
    Given url 'http://134.209.211.10:4001'
    And path '/auth/v1/login'
    And request { phone: '#(celularEmisor)', pin: '#(pin)' }
    When method post
    Then status 200
    And match response.token == '#string'
    And match response.user.id == idEmisor
    * def tokenEmisor = response.token

    # Obtener una categoría válida del catálogo
    Given url 'http://134.209.211.10:4002'
    And path '/wallet/v1/categories'
    And header Authorization = 'Bearer ' + tokenEmisor
    When method get
    Then status 200
    * def categoriasGasto = karate.filter(response, function(x){ return x.type == 'EXPENSE' })
    * assert categoriasGasto.length > 0
    * def categoriaId = categoriasGasto[0].id

    # Realizar transferencia
    Given url 'http://134.209.211.10:4003'
    And path '/transaction/v1/transfer'
    And header Authorization = 'Bearer ' + tokenEmisor
    And request
    """
    {
      "recipientId": "#(idReceptor)",
      "amount": "#(montoTransferencia)",
      "description": "#(notaTransferencia)",
      "categoryId": "#(categoriaId)"
    }
    """
    When method post
    Then status 200
    And match response.status == 'COMPLETED'
    And match response.transactionId == '#string'
    And match response.referenceCode == '#string'
    * def codigoTransaccion = response.transactionId
    * def codigoReferencia = response.referenceCode

    # Consultar y validar saldo del emisor
    Given url 'http://134.209.211.10:4002'
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenEmisor
    When method get
    Then status 200
    And match response.balance == (saldoInicialEmisor - montoTransferencia)

    * print 'Transacción:', codigoTransaccion
    * print 'Referencia:', codigoReferencia
    * print 'Saldo final emisor:', response.balance