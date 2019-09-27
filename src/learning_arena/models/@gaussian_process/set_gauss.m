function set_gauss(obj)
% Get a normal distribution object in order to compute the
% likelihood and its gradient of the GP
% obj.gauss_.set_params( ...
%         'mean', zeros(1,obj.m_), ...
%         'sigma', obj.h_params_.kernel.gramian(obj.params_.reference, obj.params_.reference) ...
% );

obj.gauss_.set_params('sigma', obj.h_params_.kernel.gramian(obj.params_.reference, obj.params_.reference));

obj.is_input_ = false; % Create kernel input
obj.is_gauss_ = true;
end

