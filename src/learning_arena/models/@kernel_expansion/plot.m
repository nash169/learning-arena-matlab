function fig = plot(obj, options, fig, varargin)
% Surface plot of the kernel expansion.
obj.check;
if nargin < 3; fig = figure; else; figure(fig); end
if nargin < 2; options = struct; end
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
       plot(obj.grid_{1}, psi, varargin{:});
   otherwise
       surf(obj.grid_{1}, obj.grid_{2}, ...
           reshape(psi,size(obj.grid_{1},1),size(obj.grid_{1},2)))
end
end
