library ieee;
use ieee.std_logic_1164.all;

entity controle_refrigerante is
  port (
    key : in std_logic_vector(3 downto 0); -- key(0) -> clock   | key(1) -> reset
    sw : in std_logic_vector(9 downto 0); -- sw(1) e sw(0) repesentam as moedas | sw(9) e sw(8) representam o seletor de refri
    -- '00' sem moedas, '01' moeda 50 cent, '10' moeda 1 real, '11' qualquer outra moeda
    -- '00' sem refrigerante, '01' coca, '10' pepsi, '11' sprite
    hex0, hex1, hex2, hex3 : out std_logic_vector(6 downto 0) -- exibe na saída o refrigerante
  );
end controle_refrigerante;

architecture controle_refrigerante_architecture of controle_refrigerante is
  -- tipagem da maquina de estados
  type estado is (q_00, q_05, q_10, q_15, q_coca, q_pepsi, q_sprite);
  -- estado atual da maquina de estados
  signal estadoAtual : estado := q_00;
  begin
    -- detecção do clock e reset
    process(key(1), key(0))
    begin
      if(key(1) = '0') then
        -- se reset entao estado atual inicial
        estadoAtual <= q_00;
      elsif(key(0)'event and key(0) = '0') then
        -- senao verifica o estado atual
        case estadoAtual is
          -- se for q_00
          when q_00 =>
            if(sw(1) = '1' AND sw(0) = '0') then
              -- 1 real inserido
              estadoAtual <= q_10;
            elsif(sw(1) = '0' AND sw(0) = '1') then
              -- 50 centavos inserido
              estadoAtual <= q_05;
            end if;

          -- se for q_05
          when q_05 =>
            if(sw(1) = '1' AND sw(0) = '0') then
              
                -- 1 real inserido vai para o estado final
              if(sw(9) = '0' and sw(8) = '0') then
                estadoAtual <= q_15;  
              elsif(sw(9) = '0' and sw(8) = '1') then
                  estadoAtual <= q_coca;
              elsif(sw(9) = '1' and sw(8) = '0') then
                  estadoAtual <= q_pepsi;      
              elsif(sw(9) = '1' and sw(8) = '1') then
                  estadoAtual <= q_sprite;
              end if;      

            elsif(sw(1) = '0' AND sw(0) = '1') then
              -- 50 centavos inserido             
              estadoAtual <= q_10;
            end if;

          -- se for q_10
          when q_10 =>
            if((sw(1) = '0' AND sw(0) = '1') or (sw(1) = '1' AND sw(0) = '0')) then
              -- 50 centavos inserido ou 1 real inserido vai para o estado final
              if(sw(9) = '0' and sw(8) = '0') then
                estadoAtual <= q_15;  
              elsif(sw(9) = '0' and sw(8) = '1') then
                  estadoAtual <= q_coca;
              elsif(sw(9) = '1' and sw(8) = '0') then
                  estadoAtual <= q_pepsi;      
              elsif(sw(9) = '1' and sw(8) = '1') then
                  estadoAtual <= q_sprite;
              end if;
            end if;  

          -- se for q_15
          when q_15 =>
            -- nesse estado é necessário escolher o refrigerante            
            if(sw(9) = '0' and sw(8) = '1') then
              estadoAtual <= q_coca;
            elsif(sw(9) = '1' and sw(8) = '0') then
              estadoAtual <= q_pepsi;      
            elsif(sw(9) = '1' and sw(8) = '1') then
              estadoAtual <= q_sprite;
            end if;     

          -- ja selecionado o refrigerante    
          when others =>
            -- volta para o estado inicial
            estadoAtual <= q_00;
        end case;
      end if;  
    end process;

    -- maquina de moore (independe da entrada para definir estado final)
    process(estadoAtual)
    begin    
      case estadoAtual is
        -- sem dinheiro
        when q_00 =>
          hex0(6) = '1';
          hex1(6) = '1';
          hex2(6) = '1';
          hex3(6) = '1';

        -- 50 centavos
        when q_05 =>
          --cinco
          hex0 = "0010010";
          
          -- ponto
          hex1 = "1101111";
          
          -- "00"
          hex2(6) = '1';
          hex3(6) = '1';

        -- 1 real
        when q_10 =>
          --0
          hex0(6) = "1";

          -- ponto
          hex1 = "1101111";

          -- 1
          hex2 = "1111000";

          -- 0
          hex3(6) = '1';

        -- 1,50 reais
        when q_15 =>
          --cinco
          hex0 = "0010010";        
        
          -- ponto
          hex1 = "1101111";

          -- 1
          hex2 = "1111001";

          -- 0
          hex3(6) = '1';

        -- coca = 01
        when q_coca =>
          -- coca
          hex3 = "1000110";
          hex2(6) = '1';
          hex1 = "1000110";
          hex0(3) = '1';

        -- pepsi = 10
        when q_pepsi =>
          -- peps
          hex3 = "0001100";
          hex2 = "0000110";
          hex1 = "0001100";
          hex0 = "0010010";

        -- sprite = 11
        when q_sprite =>
          --spri
          hex3 = "0010010";
          hex2 = "0001100";
          hex1 = "0001000";
          hex0 = "1001111";

        -- qualquer outro estado n exibe nada  
        when others =>
          -- erro
          hex3 = "0000110";
          hex2 = "0001000";
          hex1 = "0001000";
          hex0(6) = '1';
      end case;
    end process;

  end controle_refrigerante_architecture;
