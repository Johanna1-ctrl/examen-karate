Feature: Registro de usuarios y preparación de saldos

  Background:
    * def baseAuth = 'http://134.209.211.10:4001'
    * def baseWallet = 'http://134.209.211.10:4002'
    * configure headers = { 'Content-Type': 'application/json', 'x-channel': 'POSTMAN' }

  Scenario: Crear emisor y receptor y asignar saldo

    # Generar datos
    * def generarCelular =
    """
    function() {
      return '9' + Math.floor(10000000 + Math.random() * 90000000);
    }
    """
    * def celularEmisor = generarCelular()
    * def celularReceptor = generarCelular()
    * assert celularEmisor != celularReceptor
    * def pin = '123456'
    * def montoTransferencia = 450
    * def notaTransferencia = 'Pago de Servicios'
    * def montoRecarga = 1000

    # Registrar emisor
    Given url baseAuth
    And path '/auth/v1/register'
    And request
    """
    {
      "phone": "#(celularEmisor)",
      "fullName": "Emisor Johanna",
      "email": "#('emisor.' + celularEmisor + '@test.com')",
      "pin": "#(pin)"
    }
    """
    When method post
    Then status 201
    And match response.user.id == '#string'
    And match response.user.status == 'ACTIVE'
    * def idEmisor = response.user.id

    # Registrar receptor
    Given url baseAuth
    And path '/auth/v1/register'
    And request
    """
    {
      "phone": "#(celularReceptor)",
      "fullName": "Receptor Johanna",
      "email": "#('receptor.' + celularReceptor + '@test.com')",
      "pin": "#(pin)"
    }
    """
    When method post
    Then status 201
    And match response.user.id == '#string'
    And match response.user.status == 'ACTIVE'
    * def idReceptor = response.user.id
    * assert idEmisor != idReceptor

    # Login emisor
    Given url baseAuth
    And path '/auth/v1/login'
    And request { phone: '#(celularEmisor)', pin: '#(pin)' }
    When method post
    Then status 200
    And match response.token == '#string'
    And match response.user.id == idEmisor
    * def tokenEmisor = response.token

    # Saldo del emisor antes de recargar
    Given url baseWallet
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenEmisor
    When method get
    Then status 200
    And match response.balance == '#number'
    * def saldoAntesEmisor = response.balance

    # Recargar emisor
    Given url baseWallet
    And path '/wallet/v1/deposit'
    And header Authorization = 'Bearer ' + tokenEmisor
    And request { amount: '#(montoRecarga)' }
    When method post
    Then status 200
    And match response.success == true
    And match response.newBalance == (saldoAntesEmisor + montoRecarga)

    # Validar y guardar saldo inicial del emisor
    Given url baseWallet
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenEmisor
    When method get
    Then status 200
    And match response.balance == (saldoAntesEmisor + montoRecarga)
    * def saldoInicialEmisor = response.balance
    * assert saldoInicialEmisor >= montoTransferencia

    # Login receptor
    Given url baseAuth
    And path '/auth/v1/login'
    And request { phone: '#(celularReceptor)', pin: '#(pin)' }
    When method post
    Then status 200
    And match response.token == '#string'
    And match response.user.id == idReceptor
    * def tokenReceptor = response.token

    # Saldo del receptor antes de recargar
    Given url baseWallet
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenReceptor
    When method get
    Then status 200
    And match response.balance == '#number'
    * def saldoAntesReceptor = response.balance

    # Recargar receptor
    Given url baseWallet
    And path '/wallet/v1/deposit'
    And header Authorization = 'Bearer ' + tokenReceptor
    And request { amount: '#(montoRecarga)' }
    When method post
    Then status 200
    And match response.success == true
    And match response.newBalance == (saldoAntesReceptor + montoRecarga)

    # Validar y guardar saldo inicial del receptor
    Given url baseWallet
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenReceptor
    When method get
    Then status 200
    And match response.balance == (saldoAntesReceptor + montoRecarga)
    * def saldoInicialReceptor = response.balance

    * print 'Emisor:', idEmisor, celularEmisor
    * print 'Receptor:', idReceptor, celularReceptor
    * print 'Saldo inicial emisor:', saldoInicialEmisor
    * print 'Saldo inicial receptor:', saldoInicialReceptor