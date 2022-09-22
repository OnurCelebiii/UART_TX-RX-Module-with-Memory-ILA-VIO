----------------------------------------------------------------------------------
-- Engineer: Onur CELEBI
-- Create Date: 09.09.2022 14:21:47
-- Design Name: Transceiver Module with UART RX & UART TX & Block Memory Generator & ILA & VIO  
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-------------------------top module in / out port define----------------------
entity top_new is

    Port (top_i_rst               :    in       std_logic                         ;
          top_i_start_byte        :    in       std_logic                         ;
          top_clk                 :    in       std_logic)                        ;
         
end top_new;
------------------------------------------------------------------------------


architecture Behavioral of top_new is


----------------------------------signal assignment---------------------------

signal clk_slow                          :       std_logic                                       ;
signal clk_fast                          :       std_logic                                       ;
signal s_top_i_tx_data                   :       std_logic_vector(7 downto 0)                    ;
signal wea                               :       std_logic                          :='1'        ; -- transmitter memory wea pin
signal ena                               :       std_logic                          :='1'        ; -- transmitter memory ena pin
signal address                           :       std_logic_vector (3 downto 0)      := "1111"    ; -- memory transmitter address 
signal address_receiver_memory           :       std_logic_vector (3 downto 0)      := "0000"    ; -- memory receiver address
signal writea                            :       std_logic                          := '1'       ; -- receiver wea pin
signal top_o_tx_reg                      :       std_logic_vector (7 downto 0)                   ; 
signal top_o_tx_reg_block_out            :       std_logic_vector (7 downto 0)                   ;
signal memory_out                        :       std_logic_vector (7 downto 0)                   ; -- transmitter memory output input ila probe 0
signal memory_out_receiver               :       std_logic_vector (9 downto 0)                   ; -- receiver memory out port for input probe ila probe 2
signal top_o_tx                          :       std_logic                                       ; -- receiver output vector start and stop bit include     
signal outp_received_data                :       std_logic_vector (9 downto 0)                   ;

------------------------------------------------------------------------------


--------------------------------------uart tx---------------------------------
component uart_tx is

    Port (i_clk             :               in std_logic                            ;
          i_tx_data         :               in std_logic_vector (7 downto 0)        ;
          i_rst             :               in std_logic                            ;
          i_start_byte      :               in std_logic                            ;
          o_tx_reg          :               out std_logic_vector (7 downto 0)       ;
          o_tx              :               out std_logic)                          ;
          
end component;
-------------------------------------------------------------------------------


---------------------------------vio-------------------------------------------
COMPONENT vio_0 PORT (
    clk 		: 	IN STD_LOGIC					;
    probe_out0 		: 	OUT STD_LOGIC_VECTOR(7 DOWNTO 0))		;
END COMPONENT;
------------------------------------------------------------------------------


---------------------------------clk wizard-----------------------------------
component clk_wiz_1 port(
  -- Clock in ports
  -- Clock out ports
  clk_out1_8MHz             :               out    std_logic                        ;
  clk_out2_40MHz            :               out    std_logic                        ;
  clk_in1                   :               in     std_logic)                       ;
end component;
------------------------------------------------------------------------------


------------------------------memory transmitter------------------------------
COMPONENT blk_mem_gen_0 PORT (
    clka                    :               IN STD_LOGIC                            ;
    ena                     :               IN STD_LOGIC                            ;
    wea                     :               IN STD_LOGIC_VECTOR(0 DOWNTO 0)         ;
    addra                   :               IN STD_LOGIC_VECTOR(3 DOWNTO 0)         ;
    dina                    :               IN STD_LOGIC_VECTOR(7 DOWNTO 0)         ;
    douta                   :               OUT STD_LOGIC_VECTOR(7 DOWNTO 0))       ;
END COMPONENT;
------------------------------------------------------------------------------


------------------------------memory receiver---------------------------------
COMPONENT blk_mem_gen_1
  PORT (
    clka 		: 		IN STD_LOGIC				;
    ena 		: 		IN STD_LOGIC				;
    wea 		: 		IN STD_LOGIC_VECTOR(0 DOWNTO 0)		;
    addra 		: 		IN STD_LOGIC_VECTOR(3 DOWNTO 0)		;
    dina 		: 		IN STD_LOGIC_VECTOR(9 DOWNTO 0)		;
    douta 		:	 	OUT STD_LOGIC_VECTOR(9 DOWNTO 0))	;
END COMPONENT;
------------------------------------------------------------------------------


-----------------------------------ila----------------------------------------
COMPONENT ila_0 PORT (
	clk                    :                IN STD_LOGIC                            ;
	probe0                 :                IN STD_LOGIC_VECTOR(7 DOWNTO 0)         ;
	probe1                 :                IN STD_LOGIC_VECTOR(9 DOWNTO 0)         ;
	probe2                 :                IN STD_LOGIC_VECTOR(9 DOWNTO 0))        ;
END COMPONENT  ;
------------------------------------------------------------------------------


---------------------------uart rx--------------------------------------------
component uart_rxx is
    Port (i_clk             :        in std_logic                           ;
          i_rx_data_bit     :        in std_logic                           ;
          o_rx_data         :        out std_logic_vector (9 downto 0)      ;
          i_rst             :        in std_logic)                          ;
end component;
------------------------------------------------------------------------------


begin


-------------------------------uart tx port map-------------------------------
tx : uart_tx port map (
i_clk                   =>          clk_slow                        ,
i_tx_data               =>          s_top_i_tx_data                 ,
i_rst                   =>          top_i_rst                       ,
i_start_byte            =>          top_i_start_byte                ,
o_tx_reg                =>          top_o_tx_reg                    ,
o_tx                    =>          top_o_tx)                       ;
------------------------------------------------------------------------------


---------------------------------clk wizard port map--------------------------
clk : clk_wiz_1
   port map ( 
  -- Clock out ports  
   clk_out1_8MHz        =>          clk_slow                        ,
   clk_out2_40MHz       =>          clk_fast                        ,
   -- Clock in port
   clk_in1              =>          top_clk)                        ;
-------------------------------------------------------------------------------


-------------------------------vio por map-------------------------------------
your_instance_name : vio_0
  PORT MAP (
    clk                 =>          clk_fast                        ,
    probe_out0          =>          s_top_i_tx_data)                ;
---------------------------------------------------------------------------------


-------------------------------ila port map--------------------------------------
ila : ila_0
PORT MAP (
	clk                 =>          clk_fast                        ,
	probe0              =>          memory_out                      ,  -- transmitter emory output control 
    probe1                  =>          outp_received_data              ,  -- receiver output control 
    probe2                  =>          memory_out_receiver)            ;  -- receiver memory output control
----------------------------------------------------------------------------------


-----------------------------memory transmitter port map--------------------------
memory_transmitter :  blk_mem_gen_0
  PORT MAP (
    clka                =>          clk_slow                        ,
    ena                 =>          ena                             ,
    wea(0)              =>          wea                             ,
    addra               =>          address                         ,
    dina                =>          top_o_tx_reg                    ,
    douta               =>          memory_out)                     ;
----------------------------------------------------------------------------------


------------------------memory receiver port map----------------------------------
memory_received_data : blk_mem_gen_1
  PORT MAP (
    clka 		=> 	   clk_slow                                      ,
    ena 		=> 	   ena                                           ,
    wea(0) 		=> 	   writea                                        ,
    addra 		=> 	   address_receiver_memory                       ,
    dina 		=> 	   outp_received_data                            ,
    douta 		=> 	   memory_out_receiver)                          ;
----------------------------------------------------------------------------------


--------------------------uart rx port map----------------------------------------
rx : uart_rxx port map (
i_clk                    =>          clk_slow                        ,
i_rx_data_bit            =>          top_o_tx                        ,
o_rx_data                =>          outp_received_data              ,
i_rst                    =>          top_i_rst)                      ;
----------------------------------------------------------------------------------


end Behavioral;
