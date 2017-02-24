library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit is
    port ( C_FLAG : in STD_LOGIC;
           Z_FLAG : in STD_LOGIC;
           INT : in STD_LOGIC;
           RESET : in STD_LOGIC;
           CLK : in STD_LOGIC;
           OPCODE_HI_5 : in STD_LOGIC_VECTOR (4 downto 0);
           OPCODE_LO_2 : in STD_LOGIC_VECTOR (1 downto 0);
           I_SET : out STD_LOGIC;
           I_CLR : out STD_LOGIC;
           PC_LD : out STD_LOGIC;
           PC_INC : out STD_LOGIC;
           PC_MUX_SEL : out STD_LOGIC_VECTOR (1 downto 0);
           ALU_OPY_SEL : out STD_LOGIC;
           ALU_SEL : out STD_LOGIC_VECTOR (3 downto 0);
           RF_WR : out STD_LOGIC;
           RF_WR_SEL : out STD_LOGIC_VECTOR (1 downto 0);
           SP_LD : out STD_LOGIC;
           SP_INCR : out STD_LOGIC;
           SP_DECR : out STD_LOGIC;
           SCR_WE : out STD_LOGIC;
           SCR_ADDR_SEL : out STD_LOGIC_VECTOR (1 downto 0);
           SCR_DATA_SEL : out STD_LOGIC;
           FLG_C_SET : out STD_LOGIC;
           FLG_C_CLR : out STD_LOGIC;
           FLG_C_LD : out STD_LOGIC;
           FLG_Z_LD : out STD_LOGIC;
           FLG_LD_SEL : out STD_LOGIC;
           FLG_SHAD_LD : out STD_LOGIC;
           RST : out STD_LOGIC;
           IO_STRB : out STD_LOGIC);
end control_unit;

architecture Behavioral of control_unit is

type state_type is (st_init, st_fetch, st_exec);
signal ps, ns: state_type;
signal op_code_7: std_logic_vector(6 downto 0);

begin
op_code_7 <= opcode_hi_5 & opcode_lo_2;
state_p: process(clk, reset) begin
            if (reset = '1') then
                ps <= st_init;
            elsif rising_edge(clk) then
                ps <= ns;
            end if;
         end process state_p;
            
comb_p: process(ps, op_code_7, z_flag, c_flag) begin
        I_SET <= '0';
        I_CLR <= '0';
        PC_LD <= '0';
        PC_INC <= '0';
        PC_MUX_SEL <= "00";
        ALU_OPY_SEL <= '0';
        ALU_SEL <= "0000";
        RF_WR <= '0';
        RF_WR_SEL <= "00";
        SP_LD <= '0';
        SP_INCR <= '0';
        SP_DECR <= '0';
        SCR_WE <= '0';
        SCR_ADDR_SEL <= "00";
        SCR_DATA_SEL <= '0';
        FLG_C_SET <= '0'; 
        FLG_C_CLR <= '0';
        FLG_C_LD <= '0';
        FLG_Z_LD <= '0';
        FLG_LD_SEL <= '0';
        FLG_SHAD_LD <= '0';
        RST <= '0';
        IO_STRB <= '0';
        
        case(ps) is 
            when st_init =>
                ns <= st_fetch;
                rst <= '1';
            when st_fetch =>
                ns <= st_exec;
                pc_inc <= '1';
            when st_exec =>
                ns <= st_fetch;
                case (op_code_7) is 
                    -- AND function
                    when "0000000" =>
                        FLG_C_CLR <= '1';
                        FLG_Z_LD <= '1';
                        rf_wr <= '1'; 
                        rf_wr_sel <= "00";  
                        alu_sel <= "0101";
                        alu_opy_sel <= '0'; 
                        
                    -- OR function
                    when "0000001" =>
                        rf_wr <= '1'; 
                        rf_wr_sel <= "00";  
                        alu_sel <= "0110";
                        alu_opy_sel <= '0';
                        FLG_C_CLR <= '1';
                        FLG_Z_LD <= '1';
                        
                    -- EXOR function
                    when "0000010" =>
                        rf_wr <= '1'; 
                        rf_wr_sel <= "00";  
                        alu_sel <= "0111";
                        alu_opy_sel <= '0';
                        FLG_C_CLR <= '1';
                        FLG_Z_LD <= '1';
                        
                    -- TEST function
                    when "0000011" =>
                        FLG_C_CLR <= '1';
                        rf_wr <= '0'; 
                        rf_wr_sel <= "00";
                        alu_sel <= "1000";
                        alu_opy_sel <= '0';
                        FLG_Z_LD <= '1';
                        
                    -- ADD function
                    when "0000100" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "00";
                        alu_sel <= "0000";
                        alu_opy_sel <= '0';
                        flg_z_ld <= '1';
                        flg_c_ld <= '1';
                        flg_c_clr <= '1';                        
                        
                    -- ADDC function
                    when "0000101" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "00";
                        alu_sel <= "0001";
                        alu_opy_sel <= '0';
                        flg_z_ld <= '1';
                        flg_c_ld <= '1';
                        flg_c_clr <= '1';     
                                           
                    -- SUB function
                    when "0000110" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "00";
                        alu_sel <= "0010";
                        alu_opy_sel <= '0';
                        flg_z_ld <= '1';
                        flg_c_ld <= '1';
                        flg_c_clr <= '1';   
                                            
                    -- SUBC function
                    when "0000111" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "00";
                        alu_sel <= "0011";
                        alu_opy_sel <= '0';
                        flg_z_ld <= '1';
                        flg_c_ld <= '1';
                        flg_c_clr <= '1';   
                                                                    
                    -- CMP function
                    when "0001000" =>
                        rf_wr <= '0';
                        rf_wr_sel <= "00";
                        alu_sel <= "0100";
                        alu_opy_sel <= '0';
                        flg_z_ld <= '1';
                        flg_c_ld <= '1';                        
                        flg_c_clr <= '1';   
                                            
                    -- MOV function
                    when "0001001" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "00";
                        alu_sel <= "1110";
                        alu_opy_sel <= '0';
                    
                    -- LD function
                    when "0001010" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "01";
                        scr_addr_sel <= "00";                     
                    
                    -- ST function 
                    when "0001011" =>
                        scr_data_sel <= '0';
                        scr_we <= '1';
                        scr_addr_sel <= "00";
                        rf_wr <= '0';
                        
                    -- AND function (reg-immed form)
                    when "1000000" |"1000001" | "1000010" | "1000011" =>
                        FLG_C_CLR <= '1';
                        FLG_Z_LD <= '1';
                        rf_wr <= '1'; 
                        rf_wr_sel <= "00";  
                        alu_sel <= "0101";
                        alu_opy_sel <= '1';                    
                        
                    
                    -- OR function (reg-immed form)
                    when "1000100" | "1000101" | "1000110" | "1000111" =>
                        rf_wr <= '1'; 
                        rf_wr_sel <= "00";  
                        alu_sel <= "0110";
                        alu_opy_sel <= '1'; 
                        FLG_C_CLR <= '1';
                        FLG_Z_LD <= '1';
                                                                  
                    -- EXOR function (reg-immed form)
                    when "1001000" | "1001001" | "1001010" | "1001011" =>
                        rf_wr <= '1'; 
                        rf_wr_sel <= "00";  
                        alu_sel <= "0111";
                        alu_opy_sel <= '1';
                        FLG_C_CLR <= '1';
                        FLG_Z_LD <= '1';
                                            
                    -- TEST funtion (reg-immed form)
                    when "1001100" | "1001101" | "1001110" | "1001111" =>
                        FLG_C_CLR <= '1';
                        flg_z_ld <= '1';
                        rf_wr <= '0'; 
                        rf_wr_sel <= "00";
                        alu_sel <= "1000";
                        alu_opy_sel <= '1';
                    
                    -- ADD function (reg-immed form)
                    when "1010000" | "1010001" | "1010010" | "1010011" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "00";
                        alu_sel <= "0000";
                        alu_opy_sel <= '1';
                        flg_z_ld <= '1';
                        flg_c_ld <= '1';  
                        flg_c_clr <= '1'; 
                                            
                    -- ADDC function (reg_immed form)
                    when "1010100" | "1010101" | "1010110" | "1010111" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "00";
                        alu_sel <= "0001";
                        alu_opy_sel <= '1';
                        flg_z_ld <= '1';
                        flg_c_ld <= '1';
                        flg_c_clr <= '1';       
                                            
                    -- SUB function (reg-immed form)
                    when "1011000" | "1011001" | "1011010" | "1011011" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "00";
                        alu_sel <= "0010";
                        alu_opy_sel <= '1';
                        flg_z_ld <= '1';
                        flg_c_ld <= '1';
                        flg_c_clr <= '1';                          
                    
                    -- SUBC function (reg-immed form)
                    when "1011100" | "1011101" | "1011110" | "1011111" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "00";
                        alu_sel <= "0011";
                        alu_opy_sel <= '1';
                        flg_z_ld <= '1';
                        flg_c_ld <= '1';
                        flg_c_clr <= '1';  
                                            
                    -- CMP function (reg-immed form)
                    when "1100000" | "1100001" | "1100010" | "1100011" =>
                        rf_wr <= '0';
                        rf_wr_sel <= "00";
                        alu_sel <= "0100";
                        alu_opy_sel <= '1';
                        flg_z_ld <= '1';
                        flg_c_ld <= '1';
                        flg_c_clr <= '1';  
                                            
                    -- IN function (reg-immed form)
                    when "1100100" | "1100101" | "1100110" | "1100111" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "11";
                        
                    -- OUT funtction (reg-immed form)
                    when "1101000" | "1101001" | "1101010" | "1101011" =>
                        rf_wr <= '0';
                        rf_wr_sel <= "00";
                        io_strb <= '1';
                        
                    -- MOV function (reg-immed form)
                    when "1101100" | "1101101" | "1101110" | "1101111" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "00";
                        alu_sel <= "1110";
                        alu_opy_sel <= '1';
                        
                        
                    -- LD function (reg_immed form)
                    when "1110000" | "1110001" | "1110010" | "1110011" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "01";
                        scr_addr_sel <= "01";
                        
                    -- ST function (reg_immed form)
                    when "1110100" | "1110101" | "1110110" | "1110111" =>
                        scr_data_sel <= '0';
                        scr_we <= '1';
                        scr_addr_sel <= "01";
                        rf_wr <= '0';
                        
                    -- BRN function
                    when "0010000" =>
                        pc_ld <= '1';
                        pc_mux_sel <= "00";
                        
                    -- CALL function
                    when "0010001" => 
                        pc_mux_sel <= "00";
                        pc_ld <= '1';
                        sp_decr <= '1';
                        scr_data_sel <= '1';
                        scr_addr_sel <= "11";
                        scr_we <= '1';    
                    
                    -- BREQ function 
                    when "0010010" =>
                        if Z_FLAG = '1' then
                        pc_ld <= '1';
                        pc_mux_sel <= "00"; 
                        end if;
                                   
                    -- BRNE function 
                    when "0010011" =>
                        if Z_FLAG = '0' then
                        pc_ld <= '1';
                        pc_mux_sel <= "00"; 
                        end if;  
                    
                    -- BRCS function 
                    when "0010100" =>
                        if C_FLAG = '1' then
                        pc_ld <= '1';
                        pc_mux_sel <= "00";
                        end if;
                        
                    -- BRCC function
                    when "0010101" =>
                        if C_FLAG = '0' then
                        pc_ld <= '1';
                        pc_mux_sel <= "00";
                        end if;  
                                          
                    -- LSL function 
                    when "0100000" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "00";
                        alu_sel <= "1001";
                        alu_opy_sel <= '0';
                        flg_z_ld <= '1';
                        flg_c_ld <= '1';  
                
                    -- LSR functon 
                    when "0100001" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "00";
                        alu_sel <= "1010";
                        alu_opy_sel <= '0';
                        flg_z_ld <= '1';
                        flg_c_ld <= '1';                      
                    
                    -- ROL function 
                    when "0100010" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "00";
                        alu_sel <= "1011";
                        alu_opy_sel <= '0';
                        flg_z_ld <= '1';
                        flg_c_ld <= '1';                      
                    
                    -- ROR function 
                    when "0100011" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "00";
                        alu_sel <= "1100";
                        alu_opy_sel <= '0';
                        flg_z_ld <= '1';
                        flg_c_ld <= '1';
                                               
                    -- ASR function 
                    when "0100100" =>
                        rf_wr <= '1';
                        rf_wr_sel <= "00";
                        alu_sel <= "1101";
                        alu_opy_sel <= '0';
                    
                    -- PUSH function 
                    when "0100101" =>
                        rf_wr <= '0';
                        scr_we <= '1';
                        scr_data_sel <= '0';
                        scr_addr_sel <= "11";
                        sp_decr <= '1';
                    
                    -- POP function
                    when "0100110" =>
                        rf_wr_sel <= "01";
                        rf_wr <= '1';
                        scr_we <= '0';
                        scr_addr_sel <= "10";
                        sp_incr <= '1';
                    
                    -- WSP function
                    when "0101000" =>
                        sp_ld <= '1';
                        rf_wr <= '0';
                        
                    -- RSP function
                    when "0101001" =>
                        rf_wr_sel <= "10";
                        rf_wr <= '1';
                   
                    -- CLC function
                    when "0110000" =>
                        flg_c_clr <= '1';
                        
                    -- SEC function
                    when "0110001" =>
                        flg_c_set <= '1';
                    
                    -- RET function
                    when "0110010" =>
                        pc_mux_sel <= "01";
                        pc_ld <= '1';
                        sp_incr <= '1';
                        scr_addr_sel <= "10";
                    
                    -- SEI function
                    when "0110100" =>
                    
                    -- CLI function
                    when "0110101" =>
                    
                    -- RETID function
                    when "0110110" =>
                    
                    -- RETIE function
                    when "0110111" =>    
                        
                    when others => 
                end case;
        when others => NS <= ST_init;
        end case;               
        end process;
            
end Behavioral;
