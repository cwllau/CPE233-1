library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rat_cpu is
    Port ( in_port: in STD_LOGIC_VECTOR (7 downto 0);
           reset: in STD_LOGIC;
           int: in STD_LOGIC;
           clk: in STD_LOGIC;
           out_port: out STD_LOGIC_VECTOR (7 downto 0);
           port_id: out STD_LOGIC_VECTOR (7 downto 0);
           io_strb: out STD_LOGIC);
end rat_cpu;

architecture Behavioral of rat_cpu is

component control_unit
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
end component control_unit;
    
component register_file
    port (din: in std_logic_vector(7 downto 0);
          adrx, adry: in std_logic_vector(4 downto 0);
          wr, clk: in std_logic;
          dx_out, dy_out: out std_logic_vector(7 downto 0));
end component register_file;    

component alu
    Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           SEL : in STD_LOGIC_VECTOR (3 downto 0);
           Cin : in STD_LOGIC;
           C : out STD_LOGIC;
           Z : out STD_LOGIC;
           Result : out STD_LOGIC_VECTOR (7 downto 0));
end component ALU;

component program_counter_top
    port (MUX_SEL: in std_logic_vector(1 downto 0);
          TOP_RST, TOP_PC_LD, TOP_PC_INC, top_clk: in std_logic;
          FROM_STACK: in std_logic_vector(9 downto 0);
          FROM_IMMED: in std_logic_vector(9 downto 0);
          PC_COUNT_INSIDE: out std_logic_vector(9 downto 0);
          INSTR: out std_logic_vector(17 downto 0));       
end component Program_counter_top;

component flags
    port ( FLG_C_SET : in STD_LOGIC;
           FLG_C_CLR : in STD_LOGIC;
           FLG_C_LD : in STD_LOGIC;
           FLG_Z_LD : in STD_LOGIC;
           FLG_LD_SEL : in STD_LOGIC;
           FLG_SHAD_LD : in STD_LOGIC;
           C_FLAG_IN : in STD_LOGIC;
           Z_FLAG_IN : in STD_LOGIC;
           C_FLAG_OUT: out STD_LOGIC;
           Z_FLAG_OUT : out STD_LOGIC;
           CLK : in STD_LOGIC);
end component flags;

component scratch_ram
    port (  SCR_ADDR : in STD_LOGIC_VECTOR (7 downto 0);
            SCR_WR : in STD_LOGIC;
            SCR_DATA_in : in STD_LOGIC_VECTOR (9 downto 0);
            SCR_DATA_out : out STD_LOGIC_VECTOR (9 downto 0);
            CLK : in STD_LOGIC);
end component;

component stack_pointer
    port ( rst : in STD_LOGIC;
           sp_ld : in STD_LOGIC;
           sp_incr: in STD_LOGIC;
           sp_decr: in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR (7 downto 0);
           clk : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (7 downto 0));
end component;           

-- Control unit output signals
signal s_rst, s_i_set, s_i_clr, s_pc_ld, s_pc_inc, s_alu_opy_sel, s_io_strb: std_logic; 
signal s_sp_ld, s_sp_incr, s_sp_decr, s_scr_we, s_scr_data_sel, s_rf_wr: std_logic;
signal s_flg_c_set, s_flg_c_clr, s_flg_c_ld, s_flg_z_ld, s_flg_ld_sel, s_flg_shad_ld: std_logic;
signal s_pc_mux_sel, s_rf_wr_sel, s_scr_addr_sel: std_logic_vector(1 downto 0);
signal s_alu_sel: std_logic_vector(3 downto 0);

-- Control unit input signals
signal s_reset, s_int, s_clk: std_logic;
signal s_opcode_hi_5: std_logic_vector(4 downto 0);
signal s_opcode_lo_2: std_logic_vector(1 downto 0);
signal s_c_flag, s_z_flag: std_logic := '0';
signal s_out: std_logic := '0';

-- ALU signals
signal s_a, s_b, s_result: std_logic_vector(7 downto 0);
signal s_cin, s_c, s_z: std_logic;

-- Register signals
signal s_din, s_dx_out, s_dy_out: std_logic_vector(7 downto 0);

signal s_pc_count: std_logic_vector(9 downto 0);
signal s_instruction: std_logic_vector(17 downto 0);
signal s_data: std_logic_vector(9 downto 0);
signal s_sp_data_out: std_logic_vector(7 downto 0);
signal s_temp_sp_data_out: std_logic_vector(8 downto 0);

-- Scratch memory signals
signal s_scr_data_in, s_scr_data_out: std_logic_vector(9 downto 0);
signal s_scr_addr: std_logic_vector(7 downto 0);

begin

process (clk)
    begin 
    if rising_edge(clk) then
        if (s_i_set = '1') then 
            s_out <= '1';
        elsif (s_i_clr = '1') then
            s_out <= '0';
        end if;
    end if;
end process;
          
s_int <= s_out AND int;
            
control_unit_part: control_unit
port map( i_set => s_i_set,
          i_clr => s_i_clr,
          pc_ld => s_pc_ld,
          pc_inc => s_pc_inc,
          pc_mux_sel => s_pc_mux_sel,
          alu_opy_sel => s_alu_opy_sel,
          alu_sel => s_alu_sel,
          rf_wr => s_rf_wr,
          rf_wr_sel => s_rf_wr_sel,
          sp_ld => s_sp_ld,
          sp_incr => s_sp_incr,
          sp_decr => s_sp_decr,
          flg_c_set => s_flg_c_set,
          flg_c_clr => s_flg_c_clr,
          flg_c_ld => s_flg_c_ld,
          flg_z_ld => s_flg_z_ld,
          flg_ld_sel => s_flg_ld_sel,
          flg_shad_ld => s_flg_shad_ld,
          scr_we => s_scr_we,
          scr_addr_sel => s_scr_addr_sel,
          scr_data_sel => s_scr_data_sel,
          rst => s_rst,
          io_strb => io_strb,
          c_flag => s_c_flag,
          z_flag => s_z_flag,
          int => s_int,
          reset => reset,
          opcode_hi_5 => s_instruction(17 downto 13),
          opcode_lo_2 => s_instruction(1 downto 0),
          clk => clk);

alu_part: alu 
port map ( a => s_dx_out,
           b => s_b,
           sel => s_alu_sel,
           cin => s_c_flag,
           result => s_result,
           c => s_c,
           z => s_z);
           
register_file_part: register_file
port map (adry => s_instruction(7 downto 3),
          adrx => s_instruction(12 downto 8),
          wr => s_rf_wr,
          clk => clk,
          din => s_din,
          dx_out => s_dx_out,
          dy_out => s_dy_out);

program_counter_part: program_counter_top
port map (top_rst => s_rst,
          top_pc_ld => s_pc_ld,
          top_pc_inc => s_pc_inc,
          mux_sel => s_pc_mux_sel,
          from_stack => s_scr_data_out,
          from_immed => s_instruction(12 downto 3),
          pc_count_inside => s_pc_count,
          top_clk => clk,
          instr => s_instruction);

flags_part: flags
port map (flg_c_set => s_flg_c_set,
          flg_c_clr => s_flg_c_clr,
          flg_c_ld => s_flg_c_ld,
          flg_z_ld => s_flg_z_ld,
          flg_ld_sel => s_flg_ld_sel,
          flg_shad_ld => s_flg_shad_ld,
          c_flag_in => s_c,
          z_flag_in => s_z,
          c_flag_out => s_c_flag,
          z_flag_out => s_z_flag,
          clk => clk);     

stack_pointer_part: stack_pointer
port map (rst => s_rst,
          sp_ld => s_sp_ld,
          sp_incr => s_sp_incr,
          sp_decr => s_sp_decr,
          data_in => s_dx_out,
          data_out => s_sp_data_out,
          clk => clk);

scratch_memory_part: scratch_ram
port map (scr_addr => s_scr_addr,
          scr_wr => s_scr_we,
          scr_data_in => s_scr_data_in,
          scr_data_out => s_scr_data_out,
          clk => clk);                    
          
scratch_data_mux: process(s_dx_out, s_pc_count, s_scr_data_sel)
            begin 
            case s_scr_data_sel is 
                when '0' => s_scr_data_in <= "00" & s_dx_out;
                when '1' => s_scr_data_in <= s_pc_count;
                when others => s_scr_data_in <= "0000000000";
            end case;
            end process scratch_data_mux;        

scratch_addr_mux: process(s_dy_out, s_instruction, s_sp_data_out, s_scr_addr_sel)
            begin 
            case s_scr_addr_sel is
                when "00" => s_scr_addr <= s_dy_out;
                when "01" => s_scr_addr <= s_instruction(7 downto 0);
                when "10" => s_scr_addr <= s_sp_data_out;
                when "11" => 
                    s_scr_addr <= std_logic_vector(unsigned(s_sp_data_out) - 1);
                when others => s_scr_addr <= "00000000";
            end case;
            end process scratch_addr_mux;            

register_file_mux: process(in_port, s_rf_wr_sel, s_result, s_scr_data_out, s_sp_data_out)
          begin
          case s_rf_wr_sel is
            when "00" => s_din <= s_result;
            when "01" => s_din <= s_scr_data_out(7 downto 0);
            when "10" => s_din <= s_sp_data_out;
            when "11" => s_din <= in_port;
            when others => s_din <= "00000000"; 
          end case; 
          end process register_file_mux;        

alu_mux: process(s_dy_out, s_instruction, s_alu_opy_sel)
            begin 
            case s_alu_opy_sel is
                when '0' => s_b <= s_dy_out;
                when '1' => s_b <= s_instruction(7 downto 0);
                when others => s_b <= "00000000"; 
            end case; 
            end process; 

out_port <= s_dx_out;
port_id <= s_instruction(7 downto 0);
               
end Behavioral;