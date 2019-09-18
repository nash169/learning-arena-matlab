clear; close all; clc;

% steps = 20;
% range = linspace(-1.5*pi,1.5*pi,steps);
% N = ceil(linspace(10,200,steps-1));
% 
% theta = [];
% 
% for i=1:length(range)-1
%     theta = [theta, range(i) + (range(i+1)-range(i)).*rand(1,N(i))];
% end
% height = 2.0*rand(1,sum(N));
 
% % angle = linspace(-pi,pi/2,N/2);
% % height = linspace(0,10,N);
% 
% 
% 
% angle2 = pi*(1.5*rand(1,N)-1); height2 = 10*rand(1,N);
% 
% angle = sort(angle2);
% angle_lr = fliplr(angle2);
% % dataset = [[cos(angle), -cos(angle_lr)]; height2;[ sin(angle), 2-sin(angle_lr)]]';
% dataset = [cos(angle); height2; sin(angle)]';
% 
% x = linspace(0,5,100);
% y = linspace(0,10,100);
% 
% [X,Y] = meshgrid(x,y);
% 
% scatter3(X(:),Y(:),sin(X(:)), 'r', 'filled')
% scatter3(dataset(:,1),dataset(:,2),dataset(:,3), 'r', 'filled')

% theta = 3*pi*(rand(1,N)-0.5);

% S - curve
% x = sin(theta);
% y = height;
% z = sign(theta).*(cos(theta)-1);

% Swiss roll
N = 500;
theta = 1.5*pi*(1 + 2*rand(1, N));
height = 21*rand(1, N);

x = theta.*cos(theta);
y = height;
z = theta.*sin(theta);


scatter3(x, y, z, 'r', 'filled')