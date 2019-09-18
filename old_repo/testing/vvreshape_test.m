% test reshape
clear; clc;
k = zeros(3,3,4);

m = size(k,1);
n = size(k,2);
d = size(k,3);

k(:,:,1) = [11 13 15; 31 33 35; 51 53 55];
k(:,:,2) = [12 14 16; 32 34 36; 52 54 56];
k(:,:,3) = [21 23 25; 41 43 45; 61 63 65];
k(:,:,4) = [22 24 26; 42 44 46; 62 64 66];

b = permute(k,[1,3,2]);
k1 = [b(:,:,1); b(:,:,2); b(:,:,3)];
% b = reshape(k,4,[],1);
% k2 = permute(reshape(k1',d,d,m*n),[2,1,3]);
% k3 = reshape(permute(k2,[1,3,2]),m*n*d,d);
% k4 = permute(reshape(k3,m*d,d,n),[1,3,2]);
% k5 = reshape(k4,m*d,n*d);

K = reshape(...
        permute(...
        reshape(...
        reshape(...
        reshape(k1',1,[]),sqrt(d),[]),sqrt(d),m*sqrt(d),[]),[2,1,3]),[],n*sqrt(d),1);