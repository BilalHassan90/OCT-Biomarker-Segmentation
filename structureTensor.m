% I: image
% si: inner (differetiation) scale,
% so: outer (integration) scale
function [Sxx, Sxy, Syy] = structureTensor(I,si,so)
I = double(I);
[m n] = size(I);

Sxx = NaN(m,n);
Sxy = NaN(m,n);
Syy = NaN(m,n);

% Robust differentiation by convolution with derivative of Gaussian:
x  = -2*si:2*si;
g  = exp(-0.5*(x/si).^2);
g  = g/sum(g);
gd = -x.*g/(si^2); % is this normalized?

Ix = conv2( g',conv2(gd,I) );
Iy = conv2( g,conv2(gd',I) );

Ixx = Ix.^2;
Ixy = Ix.*Iy;
Iyy = Iy.^2;
% 
% Sxx = Ixx;
% Sxy = Ixy;
% Syy = Iyy;

% Smoothing:
x  = -2*so:2*so;
g  = exp(-0.5*(x/so).^2);
Sxx = conv2( g',conv2(g,Ixx) ); 
Sxy = conv2( g',conv2(g,Ixy) );
Syy = conv2( g',conv2(g,Iyy) );