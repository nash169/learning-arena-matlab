function x = optimize(obj, params, fun, cstr, options)
obj.check;

if nargin < 3
    fun = @(x) obj.max_likelihood(x, params{:});
end

% Get initial state
x0 = obj.h_params_.kernel.v_params(params{:});

if nargin < 4
    options = optimoptions('fminunc', ...
                      'Algorithm', 'quasi-newton', ...
                      'SpecifyObjectiveGradient', true);
    x = fminunc(fun,x0,options);
else
    if nargin < 5
        options = optimoptions('fmincon', ...
                              'Algorithm', 'interior-point', ...
                              'SpecifyObjectiveGradient', true, ...
                              'SpecifyConstraintGradient', true);
    end
    x = fmincon(fun,x0,[],[],[],[],[],[], cstr, options);
end

obj.h_params_.kernel.set_v_params(x, params{:});
obj.reset;
end
