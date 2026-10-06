Feature: Validación de saldo del receptor

  Background:
    * configure headers = { 'Content-Type': 'application/json', 'x-channel': 'POSTMAN' }

  Scenario: Verificar que el receptor recibió 450

    # Login del receptor
    Given url 'http://134.209.211.10:4001'
    And path '/auth/v1/login'
    And request { phone: '#(celularReceptor)', pin: '#(pin)' }
    When method post
    Then status 200
    And match response.token == '#string'
    And match response.user.id == idReceptor
    * def tokenReceptor = response.token

    # Consultar y validar saldo
    Given url 'http://134.209.211.10:4002'
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenReceptor
    When method get
    Then status 200
    And match response.balance == (saldoInicialReceptor + montoTransferencia)

    * print 'Saldo inicial receptor:', saldoInicialReceptor
    * print 'Monto recibido:', montoTransferencia
    * print 'Saldo final receptor:', response.balance