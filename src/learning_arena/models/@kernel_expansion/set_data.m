function set_data(obj, varargin)
% Set the test points. The points either a matrix of points or as
% list of grid resolution and boundaries for each axes.
if length(varargin) == 1
    obj.data_ = varargin{1};
else
    assert(isscalar(varargin{1}), 'The first entry has to be the resolution.')
    d = length(varargin(2:end));
    grid = cell(1,d/2);
    counter = 1;

    for i = 2 : 2 : d
        grid{counter} = linspace(varargin{i}, varargin{i+1}, varargin{1});
        counter = counter + 1;
    end

    [obj.grid_{1:length(grid)}] =  ndgrid(grid{:});
    obj.grid_ = cellfun(@(x) permute(x, [2 1 3:ndims(x)]),obj.grid_, 'UniformOutput',false);
    obj.data_ = reshape([obj.grid_{:}], [], length(obj.grid_));
    obj.is_grid_ = true;
end

[obj.n_, ~] = size(obj.data_);
obj.is_data_ = true;
obj.is_input_ = false;
obj.is_kernel_input_ = false;
obj.reset;
end

