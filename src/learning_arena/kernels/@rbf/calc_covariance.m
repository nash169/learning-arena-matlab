function calc_covariance(obj)
% Automatically establishes the type of covariace matrix depending
% on what has been as 'sigma' of the structure params_
if obj.params_.sigma_inv
    if ~issparse(obj.params_.sigma_inv)
        obj.num_h_params_ = numel(obj.params_.sigma_inv);
    elseif size(obj.params_.sigma_inv,1) == obj.m_*obj.n_*obj.d_
        obj.num_h_params_ = obj.m_*obj.n_*obj.d_^2;
    else
        error("Can't set non mn-points depedente sparse covariance.")
    end
else
    obj.num_h_params_ = numel(obj.h_params_.sigma);
end

switch obj.num_h_params_
    % Spherical covariance matrix (isotropic RBF)
    case 1
        if obj.debug; disp('Spherical'); end
        obj.type_cov_ = 1;
        obj.is_data_dep_ = false;

        obj.sigma_ = obj.h_params_.sigma^2;
        obj.sigma_inv_ = 1/obj.sigma_;

        obj.is_sigma_ = true;
        obj.is_sigma_inv_ = true;

    % Spherical m-points dependent
    case obj.m_
        if obj.debug; disp('Spherical - m'); end
        obj.type_cov_ = 1;
        obj.is_data_dep_ = true;

        obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.m_, 1);
        obj.sigma_ = repmat(obj.h_params_.sigma.^2, obj.n_, 1);
        obj.sigma_inv_ = 1./obj.sigma_;

        obj.is_sigma_ = true;
        obj.is_sigma_inv_ = true;

    % Spherical m-points dependent
    case obj.n_
        if obj.debug; disp('Spherical - n'); end
        obj.type_cov_ = 1;
        obj.is_data_dep_ = true;

        obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.n_, 1);
        obj.sigma_ = repelem(obj.h_params_.sigma.^2, obj.m_, 1);
        obj.sigma_inv_ = 1./obj.sigma_;

        obj.is_sigma_ = true;
        obj.is_sigma_inv_ = true;

    % Spherical mn-points dependent    
    case obj.m_*obj.n_
        if obj.debug; disp('Spherical - mn'); end
        obj.type_cov_ = 1;
        obj.is_data_dep_ = true;

        obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.m_*obj.n_, 1);
        obj.sigma_ = obj.h_params_.sigma.^2;
        obj.sigma_inv_ = 1./obj.sigma_;

        obj.is_sigma_ = true;
        obj.is_sigma_inv_ = true;

    % Diagonal covariance matrix
    case obj.d_
        if obj.debug; disp('Diagonal'); end
        obj.type_cov_ = 1;
        obj.is_data_dep_ = false;

        obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, 1, obj.d_);
        obj.sigma_ = obj.h_params_.sigma.^2;
        obj.sigma_inv_ = 1./obj.sigma_;

        obj.is_sigma_ = true;
        obj.is_sigma_inv_ = true;

    % Diagonal m-points dependent    
    case obj.m_*obj.d_
        if obj.debug; disp('Diagonal - m'); end
        obj.type_cov_ = 1;
        obj.is_data_dep_ = true;

        obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.m_, obj.d_);
        obj.sigma_ = repmat(obj.h_params_.sigma.^2, obj.n_, 1);
        obj.sigma_inv_ = 1./obj.sigma_;

        obj.is_sigma_ = true;
        obj.is_sigma_inv_ = true;

    % Diagonal n-points dependent
    case obj.n_*obj.d_
        if obj.debug; disp('Diagonal - n'); end
        obj.type_cov_ = 1;
        obj.is_data_dep_ = true;

        obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.n_, obj.d_);
        obj.sigma_ = repelem(obj.h_params_.sigma.^2, obj.m_, 1);
        obj.sigma_inv_ = 1./obj.sigma_;

        obj.is_sigma_ = true;
        obj.is_sigma_inv_ = true;

    % Diagonal mn-points dependent    
    case obj.m_*obj.n_*obj.d_
        if obj.debug; disp('Diagonal - mn'); end
        obj.type_cov_ = 1;
        obj.is_data_dep_ = true;

        obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.m_*obj.n_, obj.d_);
        obj.sigma_ = obj.h_params_.sigma.^2;
        obj.sigma_inv_ = 1./obj.sigma_;

        obj.is_sigma_ = true;
        obj.is_sigma_inv_ = true;

    % Full covariance matrix (anisotropic RBF)
    case obj.d_^2
        obj.type_cov_ = 2;
        obj.is_data_dep_ = false;

        if obj.params_.sigma_inv
            if obj.debug; disp('Full - Inv'); end
            if obj.num_h_params_ == length(obj.params_.sigma_inv)
                obj.params_.sigma_inv = c_reshape(obj.params_.sigma_inv, obj.d_, obj.d_);
            end
            obj.sigma_inv_ = obj.params_.sigma_inv;
            obj.is_sigma_inv_ = true;
        else
            if obj.debug; disp('Full'); end
            if obj.num_h_params_ == length(obj.h_params_.sigma)
                obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.d_, obj.d_);
            end
            obj.sigma_ = obj.h_params_.sigma;
            obj.is_sigma_ = true;

            if obj.params_.cholesky; obj.invert('chol'); end
        end

    % Full m-points dependent    
    case obj.m_*obj.d_^2
        obj.type_cov_ = 3;
        obj.is_data_dep_ = true;

        if obj.params_.sigma_inv
            if obj.debug; disp('Full - Inv - m'); end
            if obj.num_h_params_ == length(obj.params_.sigma_inv)
                obj.params_.sigma_inv = c_reshape(obj.params_.sigma_inv, obj.m_*obj.d_, obj.d_);
            end
            obj.sigma_inv_ = repmat(obj.params_.sigma_inv, obj.n_, 1);
            obj.is_sigma_inv_ = true;
        else
            if obj.debug; disp('Full - m'); end
            if obj.num_h_params_ == length(obj.h_params_.sigma)
                obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.m_*obj.d_, obj.d_);
            end
            obj.sigma_ = blk_matrix(repmat(obj.h_params_.sigma, obj.n_, 1));
            obj.is_sigma_ = true;

            if obj.params_.cholesky; obj.invert('chol'); end
        end

    % Full n-points dependent
    case obj.n_*obj.d_^2
        obj.type_cov_ = 3;
        obj.is_data_dep_ = true;

        if obj.params_.sigma_inv
            if obj.debug; disp('Full - Inv - n'); end
            if obj.num_h_params_ == length(obj.params_.sigma_inv)
                obj.params_.sigma_inv = c_reshape(obj.params_.sigma_inv, obj.n_*obj.d_, obj.d_);
            end
            obj.sigma_inv_ = repelem(obj.params_.sigma_inv, obj.m_, 1);
            obj.is_sigma_inv_ = true;
        else
            if obj.debug; disp('Full - n'); end
            if obj.num_h_params_ == length(obj.h_params_.sigma)
                obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.n_*obj.d_, obj.d_);
            end
            obj.sigma_ = blk_matrix(repelem(obj.h_params_.sigma, obj.m_, 1));
            obj.is_sigma_ = true;

            if obj.params_.cholesky; obj.invert('chol'); end
        end

    % Full mn-points dependent   
    case obj.m_*obj.n_*obj.d_^2
        obj.type_cov_ = 3;
        obj.is_data_dep_ = true;

        if obj.params_.sigma_inv
            if issparse(obj.params_.sigma_inv)
                if obj.debug; disp('Full - Inv - Sparse - mn'); end
                obj.sigma_inv_ = obj.params_.sigma_inv;
            elseif obj.num_h_params_ == length(obj.params_.sigma_inv)
                if obj.debug; disp('Full - Inv - mn'); end
                obj.params_.sigma_inv = c_reshape(obj.params_.sigma_inv, obj.m_*obj.n_*obj.d_, obj.d_);
                obj.sigma_inv_ = obj.params_.sigma_inv;
            end
            
            obj.is_sigma_inv_ = true;
        else
            if obj.debug; disp('Full - mn'); end
            if obj.num_h_params_ == length(obj.h_params_.sigma)
                obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.m_*obj.n_*obj.d_, obj.d_);
            end
            obj.sigma_ = blk_matrix(obj.h_params_.sigma);
            obj.is_sigma_ = true;

            if obj.params_.cholesky; obj.invert('chol'); end
        end

    % Unknown cases                
    otherwise
        error('Case not recognized');
end
end
