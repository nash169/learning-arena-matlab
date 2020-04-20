function [log_dp, n] = log_pgradient(obj, param, varargin)
    if nargin < 2; param = obj.h_params_list_; end
    if nargin > 2; obj.set_data(varargin{:}); end
    obj.check;

    for i = 1:length(param)

        if ~isfield(obj.log_dp_, param{i})

            switch param{i}
                case 'sigma_f'
                    obj.log_dp_.sigma_f = 0;
                case 'sigma_n'
                    obj.log_dp_.sigma_n = 0;
                otherwise
                    obj.log_dp_.(param{i}) = obj.h_params_.sigma_f^2 * obj.calc_log_pgradient;
            end

        end

    end

    log_dp = obj.log_dp_;
    if nargout > 1; n = obj.num_params(param); end
end
