Juego de memoria "Simón Dice" en Verilog para la tarjeta Digilent Nexys A7-100T / Nexys 4 (Artix-7), compilado con la toolchain open source Apio (Yosys + nextpnr-xilinx). Proyecto de Electrónica Digital, Universidad de San Buenaventura.
Cómo se juega
Presiona cualquier botón para empezar.
La tarjeta muestra una secuencia de 4 LEDs (LED0–LED3).
Repítela con los botones.
Son 5 rondas, cada una con su propia secuencia fija de 4 pasos.
Botón
BTNU (arriba)
BTNR (derecha)
BTND (abajo)
BTNL (izquierda)
LED
LED0
LED1
LED2
LED3
Ronda
1
2
3
4
5
Secuencia
U, D, R, L
R, L, U, D
D, U, L, R
L, R, D, U
U, L, D, R
El display de 7 segmentos muestra el puntaje (0–5).
Si completas las 5 rondas: el display escribe GANASTE y se encienden LED14 y LED15.
Si fallas un botón: el display escribe PERDISTE y se enciende LED15.
Cualquier botón reinicia el juego. CPU_RESET reinicia la tarjeta (activo en bajo).
Estructura
apio.ini          configuración de Apio
nexys4.xdc        pines de la tarjeta
top.v             módulo principal
simon_fsm.v       máquina de estados del juego
score_display.v   display de 7 segmentos (puntaje y palabras)
debounce.v        antirrebote de botones
clock_divider.v   divisor de reloj (1 Hz y 1 kHz)
Requisitos
Windows con Apio instalado
Driver WinUSB para el FTDI de la tarjeta
Compilar y subir
apio drivers install ftdi
apio build
apio upload
Si apio upload no encuentra la tarjeta, reinstala el driver (apio drivers install ftdi, o con Zadig → WinUSB) y vuelve a subir.
Autor
Sergio Castro — Universidad de San Buenaventura
Kumar perez
Andres Marin 
