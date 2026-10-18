module FSM(
    input rstn,
    input clk,
    input a,
    input b,
    output [1:0] state
);

  typedef enum logic [1:0] {
    S0 = 2'b00,
    S1 = 2'b01,
    S2 = 2'b10,
    S3 = 2'b11
} state_t;

state_t current_state;
state_t next_state;

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        current_state <= S0;
    end else begin
        current_state <= next_state;
    end
end

always_comb begin
    case(current_state)
        S0: begin
            if(a == 1'b0 && b == 1'b0) begin
                next_state = S0;
            end else if(a == 1'b1) begin
                next_state = S1;
            end else begin
                next_state = S0;
            end
        end
        S1: begin
            if(a == 1'b0 && b == 1'b0) begin
                next_state = S1;
            end else if(a == 1'b1) begin
                next_state = S2;
            end else begin
                next_state = S0;
            end
        end
        S2: begin
            if(a == 1'b0 && b == 1'b0) begin
                next_state = S2;
            end else if(a == 1'b1) begin
                next_state = S3;
            end else begin
                next_state = S0;
            end
        end
        S3: begin
            next_state = S3;
        end
        default: begin
            next_state = S0;
        end
    endcase
end

assign state = current_state;  // fill your code

endmodule