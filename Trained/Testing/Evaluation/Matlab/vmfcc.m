%Function VMFCC:   Full Mel-frequency cepstrum computation into matrix.
%
%Usage: ceps=vmfcc(s[,channels,cp,M,wlen,fs,fmin,fmax,wstep,wind]);
%
%Fixed input parameter:
%  s         - signal vector/matrix
%
%Optional parameters:                                        <Default values>
%  channels  - number of channels                               <according s>
%  cp     - number of cepstral coefficients (without c(0))               <10>
%  M      - number of band of filter bank                                <22>
%  wlen   - order of used DFT                               <length of frame>
%  fs     - sampling frequency                                         <8000>
%  fmin   - minimal frequency of filter-bank                              <0>
%  fmax   - maximal frequency of filter-bank                           <fs/2>
%  wstep     - length of segmentation step                           <wlen/2>
%  wind      - vector of weighting window            <Hamming window of wlen>                         
%   
%
%Output:
%  ceps      - matrix with values of frame MFCC cepstra ordered as
%     c1[0],c1[1],...,c1[cp],   c2[0],c2[1],...,c2[cp],  c3,    c4,      .....
%       :     :         :         :     :         :       :      :
%       :     :         :         :     :         :       :      :
% i.e.     1-st channel     ,        2-nd channel     , 3-rd, 4-th,      .....
%
%This function call:     melbf, mel, meinv
% 

%                               Made by PP
%                              29 March 2010
%                         CVUT FEL K331, Prague


function ceps=vmfcc(s,channels,cp,M,wlen,fs,fmin,fmax,wstep,wind);

ssize=size(s);

if nargin==1,
  channels=ssize(2);
  cp=10;
  M=22;
  wlen=256;
  fs=8000;
  fmin=0;
  fmax=fs/2;
  wstep=wlen/2;
  wind=hamming(wlen);
elseif nargin==2,
  cp=10;
  M=22;
  wlen=256;
  fs=8000;
  fmin=0;
  fmax=fs/2;
  wstep=wlen/2;
  wind=hamming(wlen);
elseif nargin==3,
  M=22;
  wlen=256;
  fs=8000;
  fmin=0;
  fmax=fs/2;
  wstep=wlen/2;
  wind=hamming(wlen);
elseif nargin==4,
  wlen=256;
  fs=8000;
  fmin=0;
  fmax=fs/2;
  wstep=wlen/2;
  wind=hamming(wlen);
elseif nargin==5,
  fs=8000;
  fmin=0;
  fmax=fs/2;
  wstep=wlen/2;
  wind=hamming(wlen);
elseif nargin==6,
  fmin=0;
  fmax=fs/2;
  wstep=wlen/2;
  wind=hamming(wlen);
elseif nargin==7,
  fmax=fs/2;
  wstep=wlen/2;
  wind=hamming(wlen);
elseif nargin==8,
  wstep=wlen/2;
  wind=hamming(wlen);
elseif nargin==9,
  wind=hamming(wlen);
elseif nargin>10,
  disp('??? Too many input parameters!');
end;


Wmel=melbf(M,fs,wlen,fmin,fmax);

slen=length(s(:,1)) ;
wnum=floor((slen-wlen)/wstep)+1;

for j=1:channels,

  eval(['cc' int2str(j) '=[];']);
  for i=1:wnum,
    frame=s(1+(i-1)*wstep:wlen+(i-1)*wstep,j);
    frame=frame.*wind(:);

    X=fft(frame);
    Xen=abs(X(1:wlen/2+1)).^2;
    mj=log(Wmel*Xen(:)) ;
    cj=dct(mj) ;
    % cj=sqrt(2/M)*dct(mj) ;
    % cj=2/M*dct(mj) ;

    c=cj(1:cp+1)';   
    
    eval(['cc' int2str(j) '=[cc' int2str(j) '; c];']);
  end;

end;


ceps=[];
for j=1:channels,
  eval(['ceps=[ceps cc' int2str(j) '];']);
end;


