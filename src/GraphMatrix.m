function fig = GraphMatrix(W, fig)
%GRAPHDRAW Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
    fig = figure;
else
    figure(fig);
end

imagesc(W)
colorbar
[nx,ny] = size(W);
set(gca,'xtick', linspace(0.5,nx+0.5,nx+1), 'ytick', linspace(0.5,ny+.5,ny+1));
set(gca,'xgrid', 'on', 'ygrid', 'on', 'gridlinestyle', '-', 'xcolor', 'k', 'ycolor', 'k');

end

