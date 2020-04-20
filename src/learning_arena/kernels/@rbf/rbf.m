classdef rbf < abstract_kernel
    %ANISOTROPIC_RBF Summary of this class goes here
    %   Detailed explanation goes here

    %=== PUBLIC ===%
    methods

        function obj = rbf(varargin)
            obj = obj@abstract_kernel(varargin{:});

            if ~isfield(obj.params_, 'sigma_inv'); obj.params_.sigma_inv = false; end
            if ~isfield(obj.params_, 'cholesky'); obj.params_.cholesky = false; end

            obj.opts_ut_.UT = true;
            obj.opts_lt_.LT = true;

            % Reset bool variables
            obj.is_covariance_ = false;
            obj.type_cov_ = 0; % By deafault the covariance type is 1 (spherical - diagonal)
            obj.is_data_dep_ = false; % By default the covariace matrix is dependent on the data
            obj.sigma_ = false; % Sigma is considered set
            obj.is_sigma_inv_ = false; % Inverse not set at beginning
            obj.is_chol_ = false; % Cholesky matrix not computed at beginning
            obj.reset;
        end

        set_params(obj, varargin)

        set_data(obj, varargin)

        log_k = log_kernel(obj, varargin)

        log_dk = log_gradient(obj, varargin)

        log_dp = log_pgradient(obj, varargin)

        S = covariance(obj, param)

        type = covariance_type(obj)
    end

    %=== PROTECTED ===%
    properties (Access = protected)
        type_cov_      % Type of covariance matrix
        num_h_params_  % Number of hyperparameters

        sigma_         % Covariance matrix
        sigma_inv_     % Inverse of covariance matrix
        chol_          % Cholesy decomposition of the covariace matrix

        log_k_       % Argument of the rbf kernel exponential
        log_dk_
        log_d2k_
        log_dp_

        is_covariance_ % Bool to check if the covariance matrix has to be calculated

        is_sigma_      % Bool presence of the covariance matrix
        is_sigma_inv_  % Bool presence of the inverse of covariance matrix
        is_chol_       % Bool presence cholesky L matrix

        is_log_k_    % Bool to check the presence of the log exponential
        is_log_dk_
        is_log_d2k_
        is_log_dp_

        is_data_dep_   % Check if the covariance matrix is data dependent

        opts_ut_
        opts_lt_
    end

    methods (Access = protected)
        signature(obj)

        check(obj)

        reset(obj)

        d = num_params(obj, name)

        counter = set_pvec(obj, name, vec, counter)

        [vec, counter] = pvec(obj, name, vec, counter)

        k = calc_kernel(obj)

        dk = calc_gradient(obj)

        d2k = calc_hessian(obj)

        dp = calc_pgradient(obj, name)

        log_k = calc_log_kernel(obj)

        log_dk = calc_log_gradient(obj)

        log_dp = calc_log_pgradient(obj)

        calc_covariance(obj)

        M = invert(obj, type)
    end

end
