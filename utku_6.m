clear all; close all;clc;



trBlkLen = 5120;
trBlk = randi([0 1],trBlkLen,1,'int8');

encDL = nrDLSCH;
encDL.MultipleHARQProcesses = true;

harqID = 2;
trBlkID = 0;
setTransportBlock(encDL,trBlk,trBlkID,harqID);

mod = 'QPSK';
nLayers = 3;
outlen = 10002;
rv = 3;
codedTrBlock = encDL(mod,nLayers,outlen,rv,harqID);

isequal(length(codedTrBlock),outlen)