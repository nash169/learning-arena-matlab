function x = v_params(obj, varargin)
    % Get vector of hyper-parameters
    if nargin < 2; varargin = obj.h_params_list_; end

    d = length(varargin);
    x = zeros(obj.num_params(varargin), 1);
    counter = 0;

    for i = 1:d
        assert(logical(sum(strcmp(obj.h_params_list_, varargin{i}))), ...
            '"%s" parameter not present', varargin{i});

        switch varargin{i}
            case 'sigma_f'
                x(counter + 1) = obj.h_params_.sigma_f;
                counter = counter + 1;
            case 'sigma_n'
                x(counter + 1) = obj.h_params_.sigma_n;
                counter = counter + 1;
            otherwise
                [x, counter] = obj.pvec(varargin{i}, x, counter);
        end

    end

end
