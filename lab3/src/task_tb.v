 `timescale 1ns / 1ps

module task_tb();

reg           clk_i;
reg    [9:0]  switches_i;
reg           reset;

wire   [6:0]  hex1_o;
wire   [6:0]  hex2_o;

localparam CLK_FREQ_MHZ  = 5;                  // 100 MHz
localparam CLK_SEMI      = CLK_FREQ_MHZ / 2;   // 50  MHz

processor proc(
	.clk_i(clk_i),
	.switches_i(switches_i),
	.reset(reset),
	.hex1_o(hex1_o),
	.hex2_o(hex2_o)
);

task factorialTest;
	input integer factorialNumber;

	begin
	
	switches_i = factorialNumber;
	#70;

   $display("##################################");
   $display("Switches: %b", switches_i);
   $display("First display o  = %d / %b ", hex1_o, hex1_o);
   $display("Second display o = %d / %b ", hex2_o, hex2_o);
   $display("##################################");
	end
endtask
/*

* B – выполнить безусловный переход;
* C – выполнить условный переход;
* WE – разрешение на запись в регистровый файл;
* WS[1:0] – источник данных для записи в регистровый файл (0 – константа
из инструкции, 1 – данные с переключателей, 2 – результат операции АЛУ;
* ALUop[3:0] – код операции, которую надо выполнить АЛУ;
* RA1[4:0] – адрес первого операнда для АЛУ;
* RA2[4:0] – адрес второго операнда для АЛУ;
* WA[4:0] – адрес регистра в регистровом файле, куда будет производиться
запись;
* const[7:0] – 8-битное значение константы.
|31|30|29|28 27|26 25 24 23|22 21 20 19 18|17 16 15 14 13|12 11 10 9 8|7 6 5 4 3 2 1 0|
 B  C  WE  WS     ALUop          RA1            RA2           WA             CONST

Обработка данных на АЛУ.
0_0_1_10_dddd_ddddd_ddddd_ddddd_xxxxxxxx

Загрузка константы из инструкции в регистровый файл по адресу WA.
0_0_1_00_xxxx_xxxxx_xxxxx_ddddd_dddddddd

Загрузка константы, выставленной на переключателях (switches) в регистровый файл по адресу WA.
0_0_1_01_xxxx_xxxxx_xxxxx_ddddd_xxxxxxxx

Безусловный переход.
1_0_0_xx_xxxx_xxxxx_xxxxx_xxxxx_dddddddd

Инструкция условного перехода.
0_1_0_xx_dddd_ddddd_ddddd_xxxxx_dddddddd

Описание человеко-читаемое:
0_0_1_01_0000_00000_00000_00001_00000000// reg[1] <- switches || для хранения промежуточных сложений/number_to_return.
0_0_1_01_0000_00000_00000_00010_00000000// reg[2] <- switches || через task передаём число, факториал которого нужно вычислить.
0_0_1_00_0000_00000_00000_00011_00000001// reg[3] <- 1 || будет использоваться для движения циклов и временных операций.
0_0_1_10_0001_00010_00011_00100_00000000// reg[4] <- reg[2] - reg[3] || стартовая точка первого цикла.
0_1_0_00_1100_00100_00000_00000_00001010// if reg[4] == reg[0] PC <- PC + (10 * 4) || если остался 0, выходим из программы.
0_0_1_00_0000_00000_00000_00101_00000000// reg[5] <- 0 || переменная для имитации умножения двух чисел через суммирование.
0_0_1_10_0000_00100_00000_00110_00000000// reg[6] <- reg[4] + reg[0] || инициализация стартовой точки второго цикла.
0_1_0_00_1100_00110_00000_00000_00000100// if reg[6] == reg[0] PC <- PC + (4 * 4) || выходим из второго цикла.
0_0_1_10_0000_00101_00001_00101_00000000// reg[5] <- reg[5] + reg[1] || типо умножаем первое число на второе.
0_0_1_10_0001_00110_00011_00110_00000000// reg[6] <- reg[6] - reg[3] || уменьшаем счётчик второго цикла.
1_0_0_00_0000_00000_00000_00000_11111101// PC <- PC + (-3 * 4) || возвращаемся на новую итерацию второго цикла.
0_0_1_10_0000_00101_00000_00001_00000000// reg[1] <- reg[5] + reg[0] || number_to_return = sum.
0_0_1_10_0001_00100_00011_00100_00000000// reg[4] <- reg[4] - reg[3]
1_0_0_00_0000_00000_00000_00000_11110111// PC <- PC + (-9 * 4) || переходим на первую итерацию цикла.
1_0_0_00_0000_00001_00000_00000_00000000// PC <- PC + (0 * 4) || завершаемся.


Пример на Си:
int factorial(int number) {
    int number_to_return = number;
    int sum;
    for (int i = number - 1; i > 0; i--) {
        sum = 0;
        for (int j = i; j > 0; j--) {
            sum += number_to_return;
        }
        number_to_return = sum;
    }
    return number_to_return;
}

Описание не человеко-читаемое :):
00100000000000000000001100000001
00101000000000000000000100000000
00101000000000000000001000000000
00110000100010000110010000000000
01000110000100000000000000001010
00100000000000000000010100000000
00110000000100000000011000000000
01000110000110000000000000000100
00110000000101000010010100000000
00110000100110000110011000000000
10000000000000000000000011111101
00110000000101000000000100000000
00110000100100000110010000000000
10000000000000000000000011110111
10000000000001000000000000000000
*/

initial begin
	reset = 0;
	#6
	reset = 1;
	#6
	reset = 0;
	factorialTest(10'd5);
end

initial begin
  clk_i = 1'b1;
  forever begin
    #CLK_SEMI;
	 clk_i = ~clk_i;
  end
end
endmodule
