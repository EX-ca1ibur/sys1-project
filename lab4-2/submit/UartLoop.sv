`include"uart_struct.vh"
module UartLoop(
    input clk,
    input rstn,
    Decoupled_ift.Slave uart_rdata,
    Decoupled_ift.Master uart_tdata,
    input UartPack::uart_t debug_data,
    input logic debug_send,
    output UartPack::uart_t debug_rdata,
    output UartPack::uart_t debug_tdata
);
    import UartPack::*;

    uart_t rdata;
    logic rdata_valid;

    uart_t tdata;
    logic tdata_valid;

    // Ready to accept data from receiver when internal buffer is empty
    assign uart_rdata.ready = ~rdata_valid;

    // Drive transmit side with buffered data
    assign tdata = rdata;
    assign tdata_valid = rdata_valid;
    assign uart_tdata.data = tdata;
    assign uart_tdata.valid = tdata_valid;

    always_ff@(posedge clk or negedge rstn) begin
        if(~rstn) begin
            rdata <= '0;
            rdata_valid <= '0;
        end else begin
            // debug_send takes priority: load debug_data for transmission
            if(debug_send) begin
                rdata <= debug_data;
                rdata_valid <= 1'b1;
            end else begin
                // Accept data from receiver (valid-ready handshake)
                if(uart_rdata.valid && uart_rdata.ready) begin
                    rdata <= uart_rdata.data;
                    rdata_valid <= 1'b1;
                // Data has been sent to transmitter, clear valid
                end else if(uart_tdata.ready && tdata_valid) begin
                    rdata_valid <= 1'b0;
                end
            end
        end
    end

    assign debug_rdata = rdata;
    assign debug_tdata = tdata;

endmodule
