function weight_matrix(obj)
%WEIGHT_MATRIX Summary of this function goes here
%   Detailed explanation goes here
if ~issparse(obj.h_params_.weight)
    obj.num_h_params.weight = numel(obj.h_params_.weight);
elseif size(obj.h_params_.weight,1) == obj.m_*obj.n_*obj.d_
    obj.num_h_params.weight = obj.m_*obj.n_*obj.d_^2;
else
    error("Can't set non mn-points depedent weight covariance.")
end

switch obj.num_h_params_
    % Spherical covariance matrix (isotropic RBF)
    case 1
        if obj.debug; disp('Spherical'); end
        obj.type_weight_ = 1;
        obj.is_data_dep_ = false;

        obj.weight_ = obj.h_params_.weight;

    % Spherical m-points dependent
    case obj.m_
        if obj.debug; disp('Spherical - m'); end
        obj.type_weight_ = 1;
        obj.is_data_dep_ = true;

        obj.h_params_.weight = c_reshape(obj.h_params_.weight, obj.m_, 1);
        obj.weight_ = repmat(obj.h_params_.weight, obj.n_, 1);

    % Spherical m-points dependent
    case obj.n_
        if obj.debug; disp('Spherical - n'); end
        obj.type_weight_ = 1;
        obj.is_data_dep_ = true;

        obj.h_params_.weight = c_reshape(obj.h_params_.weight, obj.n_, 1);
        obj.weight_ = repelem(obj.h_params_.weight, obj.m_, 1);

    % Spherical mn-points dependent    
    case obj.m_*obj.n_
        if obj.debug; disp('Spherical - mn'); end
        obj.type_weight_ = 1;
        obj.is_data_dep_ = true;

        obj.h_params_.weight = c_reshape(obj.h_params_.weight, obj.m_*obj.n_, 1);
        obj.weight_ = obj.h_params_.weight;

    % Diagonal covariance matrix
    case obj.d_
        if obj.debug; disp('Diagonal'); end
        obj.type_weight_ = 1;
        obj.is_data_dep_ = false;

        obj.h_params_.weight = c_reshape(obj.h_params_.weight, 1, obj.d_);
        obj.weight_ = obj.h_params_.weight;

    % Diagonal m-points dependent    
    case obj.m_*obj.d_
        if obj.debug; disp('Diagonal - m'); end
        obj.type_weight_ = 1;
        obj.is_data_dep_ = true;

        obj.h_params_.weight = c_reshape(obj.h_params_.weight, obj.m_, obj.d_);
        obj.weight_ = repmat(obj.h_params_.weight, obj.n_, 1);

    % Diagonal n-points dependent
    case obj.n_*obj.d_
        if obj.debug; disp('Diagonal - n'); end
        obj.type_weight_ = 1;
        obj.is_data_dep_ = true;

        obj.h_params_.weight = c_reshape(obj.h_params_.weight, obj.n_, obj.d_);
        obj.weight_ = repelem(obj.h_params_.weight, obj.m_, 1);

    % Diagonal mn-points dependent    
    case obj.m_*obj.n_*obj.d_
        if obj.debug; disp('Diagonal - mn'); end
        obj.type_weight_ = 1;
        obj.is_data_dep_ = true;

        obj.h_params_.weight = c_reshape(obj.h_params_.weight, obj.m_*obj.n_, obj.d_);
        obj.weight_ = obj.h_params_.weight;

    % Full covariance matrix (anisotropic RBF)
    case obj.d_^2
        obj.type_weight_ = 2;
        obj.is_data_dep_ = false;
        
        if obj.debug; disp('Full'); end
        if obj.num_h_params_.weight == length(obj.h_params_.weight)
            obj.h_params_.weight = c_reshape(obj.h_params_.weight, obj.d_, obj.d_);
        end
        obj.weight_ = obj.h_params_.weight;

    % Full m-points dependent    
    case obj.m_*obj.d_^2
        obj.type_weight_ = 3;
        obj.is_data_dep_ = true;

        if obj.debug; disp('Full - m'); end
        if obj.num_h_params_.weight == length(obj.h_params_.weight)
            obj.h_params_.weight = c_reshape(obj.h_params_.weight, obj.m_*obj.d_, obj.d_);
        end
        obj.weight_ = blk_matrix(repmat(obj.h_params_.weight, obj.n_, 1));

    % Full n-points dependent
    case obj.n_*obj.d_^2
        obj.type_weight_ = 3;
        obj.is_data_dep_ = true;

        if obj.debug; disp('Full - n'); end
        if obj.num_h_params_.weight == length(obj.h_params_.weight)
            obj.h_params_.weight = c_reshape(obj.h_params_.weight, obj.n_*obj.d_, obj.d_);
        end
        obj.weight_ = blk_matrix(repelem(obj.h_params_.weight, obj.m_, 1));

    % Full mn-points dependent   
    case obj.m_*obj.n_*obj.d_^2
        obj.type_weight_ = 3;
        obj.is_data_dep_ = true;

        if obj.debug; disp('Full - mn'); end
        if obj.num_h_params_.weight == length(obj.h_params_.weight)
            obj.h_params_.weight = c_reshape(obj.h_params_.weight, obj.m_*obj.n_*obj.d_, obj.d_);
        end
        obj.sigma_ = blk_matrix(obj.h_params_.weight);

    % Unknown cases                
    otherwise
        error('Case not recognized');
end
end

