function set_data(obj, varargin)
% Set the test points. The points either a matrix of points or as
% list of grid resolution and boundaries for each axes.
if length(varargin) == 1
    data = varargin{1};
    [obj.m_, d] = size(data);
    assert(d == obj.dim_, 'Dimension not correct')
    obj.data_ = cell(obj.dim_,1);
    for i = 1 : obj.dim_
        obj.data_{i} = data(:,i);
    end
else
    res = varargin{1};
    assert(isscalar(res), 'The first entry has to be the resolution.')
    
    d = length(varargin(2:end));
    assert(d/2 == obj.dim_, 'Wrong dimension for the chart input')
    
    obj.m_ = res^obj.dim_;
    
    grid = cell(1,d/2);
    counter = 1;
    for i = 2 : 2 : d
        grid{counter} = linspace(varargin{i}, varargin{i+1}, varargin{1});
        counter = counter + 1;
    end

    [obj.data_{1:length(grid)}] =  ndgrid(grid{:});
    obj.data_ = cellfun(@(x) permute(x, [2 1 3:ndims(x)]),obj.data_, 'UniformOutput',false);
    obj.is_grid_ = true;
end

obj.is_data_ = true;
obj.reset;
end

