function fig = plot_field(obj, options, fig, varargin)
%PLOT_EMBEDDING Summary of this function goes here
%   Detailed explanation goes here
if nargin < 3; fig = figure; else; figure(fig); hold on; end

if nargin < 2; options = struct; end
obj.fig_options(options);

if ~obj.is_grid_; obj.set_data(obj.fig_options_.res, obj.fig_options_.grid{:}); end

X = obj.vector_field;

switch obj.d_
   case 1
       error('error')
   case 2
       streamslice(obj.grid_{1}, obj.grid_{2}, ...
           reshape(X(:,1),size(obj.grid_{1},1),size(obj.grid_{1},2)), ...
           reshape(X(:,2),size(obj.grid_{1},1),size(obj.grid_{1},2)))
   otherwise
       
end

if isfield(obj.fig_options_, 'grid'); axis([obj.fig_options_.grid{:}]); end
end

