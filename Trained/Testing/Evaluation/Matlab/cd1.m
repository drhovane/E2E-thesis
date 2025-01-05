%Function CD1: Cepstral distance between two spectra using cepstral coefficients.
%              !!!    WITHOUT coefficient c[0]    !!!
%
%Usage: D=cd1(c1,c2,p);
%  c1  - vector of cepstral coefficients of the first spectrum (WITHOUT c[0])
%  c2  - vector of cepstral coefficients of the second spectrum (WITHOUT c[0])
%  p   - number of cepstral coefficients         <minimum of length(c1),length(c2)>

%                 Made by Petr Pollak, 28.4.1994

function D=cd1(c1,c2,p);

if nargin<3,
  p=min([length(c1) length(c2)]);
elseif  p<min([length(c1) length(c2)]),
  p=min([length(c1) length(c2)]);
end;

c1=c1(1:p);
c2=c2(1:p);

D=4.3429*sqrt(2*sum((c1-c2).^2));
