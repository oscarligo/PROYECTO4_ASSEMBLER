# PROYECTO 4 - Organización de Computadoras y Assembler

Diseñar, programar y construir un circuito controlado por el microcontrolador STM32 que utilice 8 salidas GPIO para
controlar LEDs como indicadores de estado, ejecutando una secuencia cíclica de corrimiento de bits predefinida, la
cual se activará automáticamente mediante una señal de reloj con un período base de 1.5 segundos. Además, se
deben incorporar dos botones adicionales: uno para aumentar la velocidad de activación de la secuencia y otro
para disminuirla, permitiendo al menos tres niveles distintos de tiempo entre estados. El sistema deberá incluir un
mecanismo visual que indique el nivel de velocidad actual, utilizando LEDs u otra forma clara de señalización. Cada
vez que se inicie la simulación o se reinicie el sistema, la secuencia deberá comenzar desde su primer estado,
realizando el cambio de estado en la velocidad más baja.

Estado      Arreglo de 8 LEDs
  1 ￿      🔴⚫⚫⚫⚫⚫⚫⚫
  2 ￿      🔴🔴⚫⚫⚫⚫⚫⚫
  3 ￿      🔴🔴🔴⚫⚫⚫⚫⚫￿
  4 ￿      🔴🔴🔴🔴⚫⚫⚫⚫￿￿￿
  5 ￿      🔴🔴🔴🔴🔴⚫⚫⚫￿￿￿￿
  6 ￿      🔴🔴🔴🔴🔴🔴⚫⚫￿￿￿￿￿
  7 ￿      🔴🔴🔴🔴🔴🔴🔴⚫￿￿￿￿￿￿
  8 ￿      🔴🔴🔴🔴🔴🔴🔴🔴￿￿￿￿￿￿￿
