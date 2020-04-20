function log_dp = log_pgradient(obj, param, data)
    obj.check;
    if nargin < 2; param = obj.h_params_list_; end
    if nargin > 2; obj.set_data(data); end
    obj.input;

    for i = 1:length(param)

        if ~isfield(obj.dp_, param{i})
            obj.log_dp_.(param{i}) = obj.calc_log_pgradient(param{i});
        end

    end

    if nargout > 0; log_dp = obj.log_dp_; end
end
