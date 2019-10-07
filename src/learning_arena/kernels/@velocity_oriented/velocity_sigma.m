function velocity_sigma(obj)
v_field = repmat(obj.h_params_.v_field,obj.n_,1);
lambdas = obj.h_params_.weight_fun(v_field, obj.h_params_.weights(1), obj.h_params_.weights(2)); %  obj.h_params_.weight_fun
D = sparse(1:obj.m_*obj.n_*obj.d_,1:obj.m_*obj.n_*obj.d_, ...
    1./reshape(lambdas',[],1), ...
    obj.m_*obj.n_*obj.d_, obj.m_*obj.n_*obj.d_);
[U, x_i, y_i] = gs_orthogonalize(v_field);
S = U'*D*U;
obj.sigma_inv_ = c_reshape(full(S(sub2ind(size(S),x_i(:),y_i(:)))), [], obj.d_);
obj.is_sigma_inv_ = true;
obj.is_data_dep_ = true;
obj.type_cov_ = 3;
end

