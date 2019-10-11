a=0.99
c=0.9
d=0.7
e=0.5
f=0.3
g=0.1
% 
% K=[a c d c d
%    c a c e f
%    d c a f g
%    c e f a c
%    d f g c a]
% 
% [V,D]=eig(K)
% 
% [V1,D1]=eig(K^2)
% 
% L=K-sum(K)
% 
% [V2,D2]=eig(L^2)
% 
% %% Second matrix with two trajectories numbered according to time with twice attractor at points 3 and 6
% 
% K=[a c d f e d
%    c a c e f c
%    d c a f c a
%    f e f a c d
%    e f c c a c
%    d c a d c a]
% 
% %% Note: there exist always one column of K that contains the cyclic pattern,
% %%        here  d c a d c a and hence one eigenvector of K will entail the attractor and linear dynamics
% 
% [V,D]=eig(K)
% 
% L=K-sum(K)
% 
% [V2,D2]=eig(L^2)
% 
% %%% Plot generated dynamics

%% Third test with matrix containing two disconnected graphs  of two DS with two trajectories each
% again numbered according to time with twice attractor at points 3 and 6
% and 9 and 12 respectively

K=[a c d f e d 0 0 0 0 0 0
   c a c e f c 0 0 0 0 0 0
   d c a f c a 0 0 0 0 0 0
   f e f a c d 0 0 0 0 0 0
   e f c c a c 0 0 0 0 0 0
   d c a d c a 0 0 0 0 0 0
   0 0 0 0 0 0 a c d f e d
   0 0 0 0 0 0 c a c e f c
   0 0 0 0 0 0 d c a f c a
   0 0 0 0 0 0 f e f a c d
   0 0 0 0 0 0 e f c c a c
   0 0 0 0 0 0 d c a d c a]

%% Note: there exist always two columns of K that contain the repetition of the DS through each trajectory,
%%        and hence the two eigenvectors of K will entail the attractors and linear dynamics for each DS


[V,D]=eigs(K)

% L=K-sum(K)
% 
% [V2,D2]=eig(L^2)