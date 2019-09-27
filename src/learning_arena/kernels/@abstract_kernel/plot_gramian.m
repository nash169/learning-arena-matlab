function fig = plot_gramian(obj, varargin)
% This function plot the gramian a colored matrix. You can pass the data
% directly here if you want.
K = obj.gramian(varargin{:});
fig = figure;
pcolor([K, zeros(size(K,1), 1); zeros(1, size(K,2)+1)])
axis image
axis ij
colorbar
end

