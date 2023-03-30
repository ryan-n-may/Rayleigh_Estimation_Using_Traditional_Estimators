clear all;

% Channel Transmission Flow Diagram
% +--------------+    +--------+    +--=-------+    +----+    +--+
% |[0, M-1] input| => |Modulate| => | + Pilots | => |IDFT| => |CP| => TX
% +--------------+    +--------+    +----------+    +----+    +--+
%
%       +--+    +---+    +----------+    +----------+    +---------------+
% RX => |CP| => |DFT| => | - Pilots | => |Demodulate| => |[0, M-1] output| 
%       +--+    +---+    +----------+    +----------+    +---------------+
TRIALS = 100;
SNR_MAX = 50;

LS_ber_SNR_average = [];
XX_ber_SNR_average = [];
for t = 1:1:TRIALS
    LS_ber_SNR = [];
    XX_ber_SNR = [];
    for SNR = 1:1:SNR_MAX
        a = channel;
        a = a.create_channel(0);
        a = a.create_gaussian_noise(SNR); % SNR of 90
        
        a = a.GenerateInput();
        a = a.modulateQAM4();
        
        a = a.InsertPilots();
        a = a.IDFT();
    
        a = a.passThroughChannel();  
    
        a = a.DFT();    
        a = a.RemovePilots();
        a = a.demodulateQAM4();
        
        y = a.demodulated_data;
        x = a.input_data;
                   
        LS_a = equalisers.LS_Estimator(a);
        LS_ber = tools.calculate_ber(x, LS_a.demodulated_data);
        LS_ber_SNR = cat(1, LS_ber_SNR, LS_ber);

        XX_ber = tools.calculate_ber(x, y);
        XX_ber_SNR = cat(1, XX_ber_SNR, XX_ber);
    end
    LS_ber_SNR_average = cat(2, LS_ber_SNR_average, LS_ber_SNR);
    XX_ber_SNR_average = cat(2, XX_ber_SNR_average, XX_ber_SNR);
end
LS_SNR = sum(LS_ber_SNR_average, 2);
LS_SNR = LS_SNR ./ TRIALS;

XX_SNR = sum(XX_ber_SNR_average, 2);
XX_SNR = XX_SNR ./ TRIALS;

plot(1:1:SNR_MAX, LS_SNR);
hold on;
plot(1:1:SNR_MAX, XX_SNR);
hold off;