%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%XXXXXXXX BER performance annalysis of BPSK modulation Technique XXXXXXXXX
%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function BERR = BER(num_bit,M,data)

s=2*data-1;             %conversion of data for BPSK modulation
SNRdB=0:10;             % SNR in dB
SNR=10.^(SNRdB/10);
l = log2(M);
for k=1:length(SNRdB)        %BER (error/bit) calculation for different SNR

    channelOutput=awgn(s,SNRdB(k));
    error=0;
    for(c=1:1:num_bit)
        if (channelOutput(c)>0&&data(c)==0)||(channelOutput(c)<0&&data(c)==1)%logic acording to BPSK
            error=error+1;
        end
    end
    error=error/num_bit; %Calculate error/bit
    m(k)=error;
end
figure(1) 
%plot start
semilogy(SNRdB,m,'o','linewidth',2.5),grid on,hold on;
BER_th=(1/2)*erfc(sqrt(SNR)); 
semilogy(SNRdB,BER_th,'r','linewidth',2.5);
title(' curve for Bit Error Rate verses  SNR for Binary PSK modulation');
xlabel(' SNR(dB)');
ylabel('BER');
legend('simulation','theoretical')

axis([0 10 10^-5 1]);
%XXXXXXXXXXXXXXXXXXXX End of program XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end