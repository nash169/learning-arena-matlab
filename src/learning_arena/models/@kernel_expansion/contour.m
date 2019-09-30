function fig = contour(obj, options, fig)
% Contour plot of the kernel expansion.
if nargin < 3; fig = figure; else; figure(fig); end
if nargin < 2; options = struct; end
obj.check;

obj.fig_options(options);

if ~obj.is_grid_
   obj.set_data(obj.fig_options_.res, obj.fig_options_.grid{:});
   obj.is_grid_ = true;
   obj.is_data_ = true;
end

obj.input;

psi = obj.expansion;

switch obj.d_
   case 1
       error('It does not make sense contour for 1D');
   case 2
      contourf(obj.grid_{1}, obj.grid_{2}, ...
          reshape(psi,size(obj.grid_{1},1),size(obj.grid_{1},2)), 20);
      hold on;
      axis equal;

      if obj.fig_options_.plot_stream
          dpsi = obj.gradient;
          h = streamslice(obj.grid_{1}, obj.grid_{2}, ...
              reshape(dpsi(:,1),size(obj.grid_{1},1),size(obj.grid_{1},2)), ...
              reshape(dpsi(:,2),size(obj.grid_{1},1),size(obj.grid_{1},2)));
          set(h,'Color','r');
          colorbar
      end

      if obj.fig_options_.plot_data
        scatter(obj.params_.reference(:,1), obj.params_.reference(:,2), ...
            40, obj.fig_options_.colors, 'filled','MarkerEdgeColor',[0 0 0])
      end

   otherwise 
       contour3(obj.grid_{1}, obj.grid_{2}, obj.grid_{3}, ...
           reshape(psi(:,1:3),size(obj.grid_{1},1),size(obj.grid_{1},2),size(obj.grid_{1},3)));
       hold on;
       axis equal;

       if obj.fig_options_.plot_stream
%                        dpsi = obj.gradient;
       end
       if obj.fig_options_.plot_data
            scatter3(obj.params_.reference(:,1), obj.params_.reference(:,2), obj.params_.reference(:,3), ...
                40, obj.fig_options_.colors, 'filled','MarkerEdgeColor',[0 0 0])
       end
end
axis([obj.fig_options_.grid{:}]) 
end
