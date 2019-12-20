function k = calc_kernel(obj)
%CALC_KERNEL Summary of this function goes here
%   Detailed explanation goes here
switch obj.type_weight_
    case 1
        if obj.debug; disp('Kernel - Cov 1'); end
        k = (sum(obj.Data_{1}.*obj.Data_{2}.*obj.weight_,2) + obj.h_params_.const).^obj.h_params_.degree;
    case 2
        if obj.debug; disp('Kernel - Cov 2 - Inv'); end
        k = (sum(obj.Data_{1}.*(obj.weight_*obj.Data_{2}')',2) + obj.h_params_.const).^obj.h_params_.degree;
    case 3
        if issparse(obj.weight_)
            if obj.debug; disp('Kernel - Cov 3 - Inv - Sparse'); end
            k = (sum(obj.Data_{1}.*c_reshape(obj.weight_*reshape(obj.Data_{2}',[],1), [], obj.d_),2) + obj.h_params_.const).^obj.h_params_.degree;
        else
            if obj.debug; disp('Kernel - Cov 3 - Inv'); end
            k = (sum(obj.Data_{1}.*c_reshape(sum(obj.weight_.*repelem(obj.Data_{2}, obj.d_, 1),2),[], obj.d_),2) + obj.h_params_.const).^obj.h_params_.degree;
        end
    otherwise
        error('Covariance type not found')
end
end

