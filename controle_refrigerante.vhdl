library ieee;
use ieee.std_logic_1164.all;

entity controle_refrigerante is
  port (
    Clock, Reset : in std_logic;
    moeda : in std_logic_vector(1 downto 0); -- '00' sem moedas, '01' moeda 50 cent, '10' moeda 1 real, '11' qualquer outra moeda
    seletorRefrigerante : in std_logic_vector(1 downto 0); -- '00' sem refrigerante, '01' coca, '10' pepsi, '11' sprite
    refrigerante : out std_logic_vector(1 downto 0) -- fazer exibir na fpga o refrigerante selecionado
  );
end controle_refrigerante;

architecture controle_refrigerante_architecture of controle_refrigerante is
  -- tipagem da maquina de estados
  type estado is (q_00, q_05, q_10, q_15);
  -- estado atual da maquina de estados
  signal estadoAtual : estado;
  begin
    -- detecção do clock e reset
    process(Reset, Clock)
      if(Reset = '1') then
        -- se reset entao estado atual inicial
        estadoAtual <= q_00;
      elsif(Clock'event and Clock = '1') then
        -- senao verifica o estado atual
        case estadoAtual is
          -- se for q_00
          when q_00 =>
            if(moeda = "10") then
              -- 1 real inserido
              estadoAtual <= q_10;
            elsif(moeda = "01") then
              -- 50 centavos inserido
              estadoAtual <= q_05;
            end if;

          -- se for q_05
          when q_05 =>
            if(moeda = "10") then
              -- 1 real inserido
              estadoAtual <= q_15;
            elsif(moeda = "01") then
              -- 50 centavos inserido             
              estadoAtual <= q_10;
            end if;

          -- se for q_10
          when q_10 =>
            if(moeda = "01" or moeda = "10") then
              -- 50 centavos inserido ou 1 real inserido
              estadoAtual <= q_15;
            end if;  

          -- se for q_15
          when q_15 =>
            -- volta para o estado atual independente da moeda
            estadoAtual <= q_00;  
        end case;
      end if;  
    end process;

    process(estadoAtual, seletorRefrigerante)
      case estadoAtual is
        -- se for q_15 exibe o refrigerante
        when q_15 =>
          refrigerante <= seletorRefrigerante;
        
          -- se for qualquer outro estado
         when others =>
          refrigerante <= "00";
      end case;
    end process;

  end controle_refrigerante_architecture;