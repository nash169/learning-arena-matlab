function set_options(obj, varargin)
    % Set the parameters of the kernel. Set the parameters
    % that you like. Every time you set a parameters the kernel will be
    % recalculated
    for i = 1:2:length(varargin)

        if logical(sum(strcmp(obj.options_list_, varargin{i})))
            obj.options_.(varargin{i}) = varargin{i + 1};
        else
            error('"%s" parameter not present', varargin{i})
        end

    end
    
    obj.reset;
end

