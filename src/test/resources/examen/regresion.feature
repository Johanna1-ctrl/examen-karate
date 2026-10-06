Feature: Regresión de transferencia de saldo

  Scenario: Ejecutar registro y transferencia
    * def registro = call read('registro.feature')
    * def transferencia = call read('transferencia.feature') registro
    * def receptor = call read('receptor.feature') transferencia
    * def administrador = call read('administrador.feature') transferencia