----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.09.2022 15:58:29
-- Design Name: 
-- Module Name: uart_rxx - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity uart_rxx is
    Port (i_clk             :        in std_logic                           ;
          i_rx_data_bit     :        in std_logic                           ;
          o_rx_data         :        out std_logic_vector (9 downto 0)       ;
          i_rst             :        in std_logic)                          ;
end uart_rxx;

architecture Behavioral of uart_rxx is


signal clk_counter      :       integer range 0 to 105                  ;
signal d_clk            :       std_logic := '0'                        ;
signal control          :       integer   := 104                        ;
signal clk_divider      :       integer range 0 to 3                    ;
signal s_o_rx_data      :       std_logic_vector (9 downto 0)           ;  
signal s_i_rx_data_bit  :       std_logic                               ;
type state is (idle, start, data, stop)                                 ;
signal uart_rxxx        :       state                                   ;
signal i                :       integer :=  1                           ;


begin

process (i_clk) begin

    if rising_edge(i_clk) then
        if clk_divider = 3 then 

            d_clk           <=      not d_clk        ;
            clk_divider     <=      0                ;

        else 

            clk_divider     <=      clk_divider + 1  ;

        end if;
    
    end if;

end process;



process (d_clk) begin

if rising_edge(d_clk) then 

    s_i_rx_data_bit         <=          i_rx_data_bit           ;
    o_rx_data               <=          s_o_rx_data             ;

    if i_rst = '1' then

        clk_counter         <=          0                       ;
        i                   <=          0                       ;
        s_o_rx_data         <=          "0000000000"            ;

    else 


        case uart_rxxx is 

                when idle =>    if  i_rx_data_bit      =      '1'                  then 

                                    uart_rxxx           <=      start               ;
                                    clk_counter         <=      0                   ;
                                    s_o_rx_data(0)      <=      '1'                 ;

                                else

                                    s_o_rx_data         <=      "0000000000"        ;
                                    uart_rxxx           <=      idle                ;

                                end if; 


                when start =>   if  clk_counter         >=      control/2            then

                                    clk_counter         <=      0                    ;
                                    uart_rxxx           <=      data                 ;
 
                                else

                                    clk_counter         <=      clk_counter + 1     ;

                                end if; 


                when data =>    if  clk_counter      >=      control    then 

                                    if i             <       8           then

                                       i             <=      i   +   1              ;
                                       clk_counter   <=      0                      ;

                                    else

                                        i            <=      0                      ;
                                        uart_rxxx    <=      stop                   ;
                                        clk_counter  <=      0                      ;

                                    end if;

                                else

                                    s_o_rx_data(i)   <=      s_i_rx_data_bit        ;
                                    clk_counter      <=      clk_counter +1         ;

                                end if;


                when stop =>    if clk_counter       >=      control then 

                                    s_o_rx_data      <=      "0000000000"           ;   
                                    clk_counter      <=      0                      ;
                                    uart_rxxx        <=      idle                   ;

                                else

                                    clk_counter      <=      clk_counter + 1        ;
                                    s_o_rx_data(9)   <=      '1'                    ;  

                                end if;


                when others =>

       end case;
    end if;
end if;

end process;


end Behavioral;
