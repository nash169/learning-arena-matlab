classdef pdf_normal < kernel_expansion
    %PDF Summary of this class goes here
    %   Detailed explanation goes here

    %=== PUBLIC ===%
    methods

        function obj = pdf_normal(varargin)
            %PDF Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@kernel_expansion(varargin{:});

            obj.h_params_.kernel = rbf('cholesky', true);

            obj.opts_ut_.UT = true;
            obj.opts_lt_.LT = true;

            obj.is_gauss_ = false;
            obj.reset;
        end

        set_params(obj, varargin)

        log_psi = log_expansion(obj, data)

        log_dp = log_pgradient(obj, param, data)
    end

    %=== PROTECTED ===%
    properties (Access = protected)
        log_psi_
        log_dp_

        type_cov_
        cov_
        inv_

        is_log_psi_
        is_log_dp_

        is_gauss_

        opts_ut_
        opts_lt_
    end

    methods (Access = protected)
        signature(obj)

        input(obj)

        reset(obj)

        set_gauss(obj)

        dp = calc_pgradient(obj, param)

        log_dp = calc_log_pgradient(obj, param)
    end

end
