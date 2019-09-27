function x = optimize(obj, varargin)
obj.check;
x0 = obj.h_params_.kernel.v_params(varargin{:});
fun = @(x) obj.functional(x, varargin{:});
options = optimoptions('fminunc', ...
                      'Algorithm', 'quasi-newton', ...
                      'SpecifyObjectiveGradient', true);
x = fminunc(fun,x0,options);
% options = optimoptions('fmincon', ...
%                       'Algorithm', 'interior-point', ...
%                       'SpecifyObjectiveGradient', true);
% x = fmincon(fun,x0,[],[],[],[],[],[], [], options);
obj.h_params_.kernel.set_v_params(x, varargin{:});
obj.reset;
end
