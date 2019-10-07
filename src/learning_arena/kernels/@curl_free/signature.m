function signature(obj)
 obj.type_ = {'vector_valued'};
 obj.h_params_list_ = ['sigma', obj.h_params_list_];
 obj.params_list_ = ['sigma_inv', 'cholesky', obj.params_list_];
end


