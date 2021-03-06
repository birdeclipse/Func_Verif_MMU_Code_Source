/******************************************************************************
* (C) Copyright 2011 KALRAY SA All Rights Reserved
*
* MODULE:    mmu_proc_sfrwrites_master_seq_lib.sv
* DEVICE:    MMU_PROC_SFRWRITES VIP
* PROJECT:
* AUTHOR:
* DATE:
*
* ABSTRACT:
*
*******************************************************************************/
`ifndef MMU_PROC_SFRWRITES_MASTER_SEQ_LIB_SV
`define MMU_PROC_SFRWRITES_MASTER_SEQ_LIB_SV

typedef enum byte {MMC=42,TEL=43,TEH=44, OTHERS} mmu_sfr_t;

//------------------------------------------------------------------------------
//
// CLASS: mmu_proc_sfrwrites_master_base_sequence
//
//------------------------------------------------------------------------------

class mmu_proc_sfrwrites_master_base_sequence extends uvm_sequence #(mmu_proc_sfrwrites_transfer);

   typedef mmu_proc_sfrwrites_master_sequencer mmu_proc_sfrwrites_master_sequencer_t;
   typedef mmu_proc_sfrwrites_transfer mmu_proc_sfrwrites_transfer_t;

    `uvm_object_param_utils(mmu_proc_sfrwrites_master_base_sequence)

    string v_name;

    // new - constructor
    function new(string name="mmu_proc_sfrwrites_master_base_sequence");
        super.new(name);
    endfunction : new

    // Raise in pre_body so the objection is only raised for root sequences.
    // There is no need to raise for sub-sequences since the root sequence
    // will encapsulate the sub-sequence.
    virtual task pre_body();
        m_sequencer.uvm_report_info(get_type_name(), $psprintf("%s pre_body() raising an uvm_test_done objection", get_sequence_path()), UVM_HIGH);
        uvm_test_done.raise_objection(this);
    endtask
    // Drop the objection in the post_body so the objection is removed when
    // the root sequence is complete.
    virtual task post_body();
        m_sequencer.uvm_report_info(get_type_name(), $psprintf("%s post_body() dropping an uvm_test_done objection", get_sequence_path()), UVM_HIGH);
        uvm_test_done.drop_objection(this);
    endtask // post_body
endclass : mmu_proc_sfrwrites_master_base_sequence

//------------------------------------------------------------------------------
//
// CLASS: mmu_proc_sfrwrites_standby_seq
//
//------------------------------------------------------------------------------

class mmu_proc_sfrwrites_standby_seq extends mmu_proc_sfrwrites_master_base_sequence;

    `uvm_object_param_utils(mmu_proc_sfrwrites_standby_seq)

    // new - constructor
    function new(string name="mmu_proc_sfrwrites_standby_seq");
        super.new(name);
    endfunction : new

    // Implment behavior sequence
    virtual task body();

    endtask // body

endclass : mmu_proc_sfrwrites_standby_seq

//------------------------------------------------------------------------------
// Example sequence
// CLASS: mmu_proc_sfrwrites_trial_seq
//
//------------------------------------------------------------------------------

class sfrwrites_seq extends mmu_proc_sfrwrites_master_base_sequence;

    `uvm_object_param_utils(sfrwrites_seq)

    // Add sequence parameters

    cpu_wr_reg_cmd_t lcmd;
    int unsigned lreq_lat;
    mmu_sfr_t sfr_name;
    logic [31:0] lcpu_wr_reg_val_i;

    // new - constructor
    function new(string name="sfrwrites_seq");
        super.new(name);
    endfunction : new

    mmu_proc_sfrwrites_transfer_t mmu_proc_sfrwrites_trans;

    // Implment behavior sequence
    virtual task body();
       
      byte sfr_name_id;
        
        `uvm_info(get_type_name(), $psprintf("Start sequence mmu_proc_sfrwrites_trial_seq"), UVM_LOW)
        $cast(mmu_proc_sfrwrites_trans, create_item(mmu_proc_sfrwrites_transfer_t::type_id::get(), m_sequencer, "mmu_proc_sfrwrites_trans"));
        start_item(mmu_proc_sfrwrites_trans);
        mmu_proc_sfrwrites_trans.v_name = v_name;
        
        if (sfr_name == OTHERS) begin
	        sfr_name_id = $urandom_range('hFF,0);
	        while (sfr_name_id == MMC || sfr_name_id == TEL || sfr_name_id == TEH)
    	      sfr_name_id = $urandom_range('hFF,0);
        end
        else
	      $cast(sfr_name_id, sfr_name);
        
        if (!(mmu_proc_sfrwrites_trans.randomize() with {
                                                         // Transmit sequence paramaters

                                                         mmu_proc_sfrwrites_trans.req_lat == lreq_lat;		     
                                                         mmu_proc_sfrwrites_trans.cmd ==lcmd;
	                                                     mmu_proc_sfrwrites_trans.cpu_wr_reg_idx_i == sfr_name_id;
	                                                     mmu_proc_sfrwrites_trans.cpu_wr_reg_val_i == lcpu_wr_reg_val_i;	
						                                 
                                                         }))
          `uvm_fatal(get_type_name(), $psprintf("mmu_proc_sfrwrites_trial_seq: randomization error"))
        finish_item(mmu_proc_sfrwrites_trans);
        `uvm_info(get_type_name(), "End sequence mmu_proc_sfrwrites_trial_seq", UVM_LOW)
    endtask // body
endclass : sfrwrites_seq
`endif
