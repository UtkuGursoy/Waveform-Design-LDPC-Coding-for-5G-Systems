clear all; close all;clc;

rng(210);              % Set RNG state for repeatability
A = 10000;             % Transport block length, positive integer
rate = 449/1024;       % Target code rate, 0<R<1
rv = 0;                % Redundancy version, 0-3
modulation = 'pi/2-BPSK';   % Modulation scheme, QPSK, 16QAM, 64QAM, 256QAM
nlayers = 1;           % Number of layers, 1-4 for a transport block

M = 2;                  % Modulation alphabet size
bps = log2(M);            % Bits/symbol
custMap = [1 0];
phase_offset = 0;       % Phase offset (radians)
EbNo = 20; % (dB)

span = 2; % Filter span in symbols
rolloff = 0; % Rolloff factor
sps = 1; % Samples per symbol

pskModulator = comm.PSKModulator(M,'BitInput',true, 'SymbolMapping','Custom','CustomSymbolMapping',custMap, 'PhaseOffset', phase_offset);
pskDemodulator = comm.PSKDemodulator(M,'BitOutput',true, 'DecisionMethod', 'Log-likelihood ratio','SymbolMapping','Custom','CustomSymbolMapping',custMap);
channel = comm.AWGNChannel('EbNo',EbNo,'BitsPerSymbol',bps);
txfilter = comm.RaisedCosineTransmitFilter('RolloffFactor',rolloff, 'FilterSpanInSymbols',span,'OutputSamplesPerSymbol',sps);
rxfilter = comm.RaisedCosineReceiveFilter('RolloffFactor',rolloff, 'FilterSpanInSymbols',span,'InputSamplesPerSymbol',sps, 'DecimationFactor',sps);


% DL-SCH coding parameters
cbsInfo = nrULSCHInfo(A,rate);
disp('UL-SCH coding parameters')
disp(cbsInfo)

% Random transport block data generation
in = randi([0 1],A,1,'int8');

% Transport block CRC attachment
tbIn = nrCRCEncode(in,cbsInfo.CRC);

% Code block segmentation and CRC attachment
cbsIn = nrCodeBlockSegmentLDPC(tbIn,cbsInfo.BGN);

% LDPC encoding
enc = nrLDPCEncode(cbsIn,cbsInfo.BGN);

% Rate matching and code block concatenation
outlen = ceil(A/rate);
modIn = nrRateMatchLDPC(enc,outlen,rv,modulation,nlayers);

% Modulation
modData = pskModulator(modIn);

% Waveform Design - Tx
%chIn = txfilter(modData);

% AWGN Channel 
channelOutput = channel(modData);


% Waveform Design - Rx
demodData = rxfilter(channelOutput);

% Demodulation
demodOut = pskDemodulator(channelOutput);


% Rate recovery
raterec = nrRateRecoverLDPC(demodOut,A,rate,rv,modulation,nlayers);

% LDPC decoding
decBits = nrLDPCDecode(raterec,cbsInfo.BGN,25);

% Code block desegmentation and CRC decoding
[blk,blkErr] = nrCodeBlockDesegmentLDPC(decBits,cbsInfo.BGN,A+cbsInfo.L);

disp(['CRC error per code-block: [' num2str(blkErr) ']'])

% Transport block CRC decoding
[out,tbErr] = nrCRCDecode(blk,cbsInfo.CRC);
out = [out(3:end); 0; 1];
disp(['Transport block CRC error: ' num2str(tbErr)])
disp(['Recovered transport block with no error: ' num2str(isequal(out,in))])


% PLOTS
n = 1;                  % Plot every nth value of the signal
offset = 0;             % Plot every nth value of the signal, starting from offset+1

h = scatterplot(demodData(span+1:end-span),n,offset,'bx'); hold on
scatterplot(modData,n,offset,'r+',h)
legend('Received Signal','Ideal','location','best')

constellation(pskModulator)

eyediagram(chIn(sps*span+1:sps*span+1000),2*sps)
eyediagram(demodData(sps*span+1:sps*span+1000),2*sps)
scatterplot(modData)
title('Modulated Data');
scatterplot(channelOutput)
fvtool(txfilter,'impulse')
% channel.EbNo = 10;
% channelOutput = channel(modData);
% scatterplot(channelOutput)