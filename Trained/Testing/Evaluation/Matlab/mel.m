function melf=mel(f);
%
% MEL: Conversion from linear frequency into mel-frequency scale
%
% Usage: melf=mel(f) ;
%
% Input parameter:
%   f         .... frequency in Hz (vector or scalar)
% Output parameter:
%   melf      .... frequency in mel (vector or scalar)

melf=2595*log10(1+f/700);
