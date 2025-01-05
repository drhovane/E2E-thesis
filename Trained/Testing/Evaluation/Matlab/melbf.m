function Wmel=melbf(M,fs,N,fmin,fmax);

%
% MELBF: Mel-filter bank weights for DFT evaluation
%
% Usage: Wmel=melbf(M,fs,N,fmin,fmax) ;
%
% Input parameters:
%   M         .... number of output bands
%   fs        .... sampling frequency
%   N         .... points of DFT
%   fmin      .... minimal frequency
%   fmax      .... maximal frequency
% Output parameter:
%   Wmel      .... M-(N/2+1) matrix with filter bank weigths

if nargin<1,
  M=22;
end

if nargin<2,
  fs=16000;
end

if nargin<3,
  N=512;
end

if nargin<4,
  fmin=0;
end

if nargin<5,
  fmax=fs/2;
end


melmin=mel(fmin);
melmax=mel(fmax);

melstep=(melmax-melmin)/(M+1);
melbank=melmin:melstep:melmax ;

fbank=700*(10.^(melbank./2595)-1);

ff=(0:N/2)./N*fs ;
Wmel=zeros(M,N/2+1);
for ii=1:M,
  
  Wmel(ii,:)=Wmel(ii,:)+(ff-fbank(ii))./(fbank(ii+1)-fbank(ii)).*( ( ff > fbank(ii) ) & ( ff < fbank(ii+1) )  ) ;
  Wmel(ii,:)=Wmel(ii,:)+(1-(ff-fbank(ii+1))./(fbank(ii+2)-fbank(ii+1))).*( ( ff > fbank(ii+1) ) & ( ff < fbank(ii+2) )  ) ;
  
end

if nargout==0,
  figure(1) ;
  plot(Wmel')
  grid
end


