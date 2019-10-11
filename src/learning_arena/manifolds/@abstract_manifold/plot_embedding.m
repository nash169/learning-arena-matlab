function fig = plot_embedding(obj, options, fig, varargin)
%PLOT_EMBEDDING Summary of this function goes here
%   Detailed explanation goes here
if nargin < 3; fig = figure; else; figure(fig); hold on; end

if nargin < 2; options = struct; end
obj.fig_options(options);

if ~obj.is_grid_; obj.set_data(obj.fig_options_.res, obj.fig_options_.grid{:}); end

phi = obj.embedding;

switch obj.dim_
   case 1
       plot(phi{1}, phi{2}, varargin{:});
       if isfield(obj.fig_options_, 'sample')
           x = obj.sample(obj.fig_options_.sample);
           scatter(x(:,1), x(:,2), ...
               40, obj.fig_options_.colors, 'filled','MarkerEdgeColor',[0 0 0])
       end
       
   otherwise
       surf(phi{1}, phi{2}, phi{3}, 'FaceAlpha', 0.5, varargin{:})
       shading interp
       axis equal
       if isfield(obj.fig_options_, 'sample')
           x = obj.sample(obj.fig_options_.sample);
           hold on;
           scatter3(x(:,1), x(:,2), x(:,3), ...
               40, obj.fig_options_.colors, 'filled','MarkerEdgeColor',[0 0 0])
       end
end


end

