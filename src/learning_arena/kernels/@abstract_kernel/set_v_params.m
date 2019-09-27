function set_v_params(obj, vec, varargin)
% Set hyper-parameters through vector
if nargin < 3; varargin = obj.h_params_list_; end

counter = 0;
for i = 1 : length(varargin)
    assert(logical(sum(strcmp(obj.h_params_list_, varargin{i}))), ...
        '"%s" parameter not present', varargin{i});
    switch varargin{i}
        case 'sigma_f'
            obj.set_params('sigma_f', vec(counter+1));
            counter = counter + 1;
        case 'sigma_n'
            obj.set_params('sigma_n', vec(counter+1));
            counter = counter + 1;
        otherwise
            counter = obj.set_pvec(varargin{i}, vec, counter);
    end
end

obj.reset;
end

